package;

import haxe.Constraints.IMap;
import haxe.macro.Expr;
import neko.Lib;

class Interpreter {
	
	static function main() {
		var vars = ['foo' => true];
		var i = new Interpreter(vars);
		trace(i.interpret(macro {
			var x = 5;
			x += 3;
			x *= 2;
			foo = x;
			x = 0;
			for (i in 0...100)
				x += i;
			function () return x;
		})());
		trace(vars);
	}
	
	var stack:List<Map<String, Dynamic>>;
	
	public function new(?vars, ?stack) {
		this.stack = 
			if (stack == null) new List();
			else stack;
		enter(vars);
	}
	
	function enter(?scope)
		if (scope != null)
			stack.push(scope);
		else
			enter(new Map());
		
	function leave() 
		stack.pop();
		
	function scoped<T>(v:Void->T):T {
		var depth = stack.length;
		
		function restore()
			while (stack.length > depth) 
				stack.pop();
				
		var ret = 
			try v()			
			catch (e:Dynamic) {
				restore();
				neko.Lib.rethrow(e);
			}
		restore();
		return ret;
	}
		
	function leftHandValue<A>(e:ExprOf<A>):LeftHandValue<A>
		return switch e.expr {
			case EField(owner, field):
				var object = interpret(owner);
				{
					get: function () return Reflect.getProperty(object, field),
					set: function (value) { 
						Reflect.setProperty(object, field, value);
						return value;
					}
				}
			case EConst(CIdent(s)):
				var frame = seek(s);
				{
					get: function () return frame[s],
					set: function (value) return frame[s] = value,
				}
			case EArray(array, key):
				var a:Dynamic = interpret(array);
				var k:Dynamic = interpret(key);
				if (Std.is(a, IMap)) {
					var map:IMap<Dynamic, A> = a;
					{
						get: function () return map.get(k),
						set: function (value) {
							map.set(k, value);
							return value;
						}
					}
				}
				else {
					get: function () return a[k],
					set: function (value) return a[k] = value,
				}
			case v:
				throw 'Cannot assign value to ${v.getName()}';
		}
	
	function resolve(name:String) 
		return seek(name)[name];
	
	function seek(name:String) {
		for (frame in stack)
			if (frame.exists(name))
				return frame;
		throw 'unknown identifier $name';
	}
		
	public function interpret<A>(e:ExprOf<A>):A {
		var ret:Dynamic = 
			if (e == null) null;
			else
				switch e.expr {
					case EConst(c):
						switch c {
							case CString(s): s; 
							case CInt(s): 
								Std.parseInt(s);
							case CFloat(s): 
								Std.parseFloat(s);
							case CIdent('true'): 
								true;
							case CIdent('false'): 
								false;
							case CIdent('null'):
								null;
							case CRegexp(r, opt): 
								new EReg(r, opt);
							case CIdent(s):
								resolve(s);
						}
					case EArrayDecl(values):
						[for (v in values) interpret(v)];
					case EObjectDecl(fields):
						var o = { };
						for (f in fields)
							Reflect.setField(o, f.field, interpret(f.expr));
						o;
					case EIf(econd, eif, eelse):
						if (interpret(econd))
							interpret(eif);
						else
							interpret(eelse);
							
					case EFor(it, body):
						switch it.expr {
							case EIn({ expr: EConst(CIdent(s)) }, e2):
								var target:Iterator<Dynamic> = interpret(e2);
								
								if (Reflect.hasField(target, 'iterator'))
									target = untyped target.iterator();
								
								var ret = null;
									
								for (value in target) 
									try 
										scoped(function () {
											enter([s => value]);
											ret = interpret(body);
										})
									catch (e:LoopControl) 
										switch e {
											case LCBreak: break;
											default:
										}
									
								ret;
							case v:
								throw 'for loop should be over `name in target` expression at ' + it.pos;
						}
					case EWhile(econd, body, normalWhile):
						var ret = null;
						while (!normalWhile || interpret(econd)) {
							normalWhile = true;
							try
								ret = interpret(body)
							catch (e:LoopControl) 
								switch e {
									case LCBreak: break;
									default:
								}
						}
						return ret;
					case EBinop(op, e1, e2):
						switch op {
							case OpAssign:
								leftHandValue(e1).set(interpret(e2));
							case OpAssignOp(op):
								var lh = leftHandValue(e1);
								lh.set(binop(op, lh.get(), interpret(e2))); 
							default:
								binop(op, interpret(e1), interpret(e2));
						}
					case EBlock(exprs):
						scoped(function () {
							
							enter();
							
							var ret = null;
							
							for (e in exprs)
								ret = interpret(e);
							
							return ret;
						});
					case EVars(vars):
						enter([for (v in vars) v.name => interpret(v.expr)]);
						null;
					case EFunction(name, f):
						//var snapshot = null;
						var separate:Interpreter = null;
						var func = Reflect.makeVarArgs(function (args:Array<Dynamic>):Dynamic {
							var m = new Map();
							for (i in 0...f.args.length)
								m.set(
									f.args[i].name, 
									if (i < args.length) 
										if (f.args[i].opt) null
										else throw 'missing argument ' + f.args[i].name
									else
										args[i]
								);
								
							return scoped(function () {
								separate.enter(m);
								return 
									try {
										separate.interpret(f.expr);
										null;
									}
									catch (r:Return) {
										r.value;
									}
							});
							
						});
						
						if (name != null)
							enter([name => func]);
						
						separate = new Interpreter(Lambda.list(this.stack));
						func;
					case EReturn(e):
						throw new Return(interpret(e));
					case v:
						throw 'Cannot handle ' + v.getName() +' in ' + e.pos;
				}
			
		return ret;
	}
	
	function binop(op:Binop, v1:Dynamic, v2:Dynamic):Dynamic {
		return 
			switch op {
				case OpEq: v1 == v2;
				case OpAdd: v1 + v2;
				case OpSub: v1 - v2;
				case OpMult: v1 * v2;
				case OpDiv: v1 / v2;
				case OpMod: v1 % v2;
				case OpOr: v1 + v2;
				case OpAnd: v1 + v2;
				case OpInterval: v1...v2;
				default:
					throw '$op not implemented';
			}
	}
}

typedef LeftHandValue<A> = {
	function get():A;
	function set(v:A):A;
}

enum LoopControl {
	LCBreak;
	LCContinue;
}

class Return {
	public var value(default, null):Dynamic;
	public function new(value) 
		this.value = value;
}