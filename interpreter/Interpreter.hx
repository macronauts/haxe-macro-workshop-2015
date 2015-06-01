package;

import haxe.Constraints.IMap;
import haxe.macro.Expr;
import neko.Lib;

//run with haxe -dce no --run Interpreter

class Interpreter {
	
	static function main() {
		var vars:Scope = ['foo' => true, 'trace' => function (d) trace(d)];
		var i = new Interpreter(vars);
		var func:Bool->Int = 
			i.interpret(macro {
				var x = 5;
				x += 3;
				x *= 2;
				foo = x;
				x = 0;
				for (i in 0...100)
					x += i;
				function getX() return x;
				function change(y, z = 200) x = y + z;
				change(100);
				{
					var x = 200;
					trace(x);
				}
				trace(x);
				function (flag)
					return
						if (flag) ++x;
						else x;
			});
		trace(vars);
		//trace(func(
	}
	
	/**
	 * The interpreter's stack.
	 * Do not access this directly.
	 * Instead, rely on `enterScope`, `scoped`, `seekScope` and `resolve`.
	 */
	@:noCompletion var stack:List<Scope>;
	
	public function new(?vars, ?stack) {
		this.stack = 
			if (stack == null) new List();
			else stack;
		enterScope(vars);
	}
	
	/**
	 * Enters a new scope
	 * @param	scope if null, an empty scope is entered
	 */
	function enterScope(?scope)
		if (scope != null)
			stack.push(scope);
		else
			enterScope(new Map());
			
	/**
	 * Executes a function and then restores the previous scope.
	 */
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
	
	/**
	 * Evaluates an expression to construct a valid left hand value or fails otherwise.
	 * 
	 * Valid left hand values are:
	 * 
	 * - expr[key]
	 * - expr.field
	 * - identifier
	 */	
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
				var scope = seekScope(s);
				{
					get: function () return scope[s],
					set: function (value) return scope[s] = value,
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
	
	/**
	 * Resolves an identifier
	 * 
	 * @param	identifier
	 */
	function resolve(identifier:String) 
		return seekScope(identifier)[identifier];
	
	/**
	 * Seeks the scope within which the given `identifier` is defined
	 * @param	identifier
	 */
	function seekScope(identifier:String) {
		for (frame in stack)
			if (frame.exists(identifier))
				return frame;
		throw 'unknown identifier $identifier';
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
						
					case ECall(e, params):
						var thisArg = null;
						var func = 
							switch e.expr {
								case EField(e, field):
									thisArg = interpret(e);
									Reflect.getProperty(thisArg, field);
								default:
									interpret(e);
							}
						Reflect.callMethod(thisArg, func, params.map(interpret));
					case EField(e, field):
						Reflect.getProperty(interpret(e), field);
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
											enterScope([s => value]);
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
							
							enterScope();
							
							var ret = null;
							
							for (e in exprs)
								ret = interpret(e);
							
							return ret;
						});
					case EVars(vars):
						enterScope([for (v in vars) v.name => interpret(v.expr)]);
						null;
					case EFunction(name, f):
						var separate:Interpreter = null;
						var func = Reflect.makeVarArgs(function (args:Array<Dynamic>):Dynamic {
							var m = new Map();
							for (i in 0...f.args.length)
								m.set(
									f.args[i].name, 
									if (i >= args.length) 
										if (f.args[i].opt || f.args[i].value != null) 
											separate.interpret(f.args[i].value)
										else throw 'missing argument ' + f.args[i].name
									else
										args[i]
								);
								
							return scoped(function () {
								separate.enterScope(m);
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
							enterScope([name => func]);
						
						separate = new Interpreter(Lambda.list(this.stack));
						func;
					case EReturn(e):
						throw new Return(interpret(e));
					case v:
						throw 'Cannot handle ' + v.getName() +' in ' + e.pos;
				}
			
		return ret;
	}
	
	/**
	 * Evaluates binary operation
	 */
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

/**
 * A scope that maps variables to values.
 */
typedef Scope = Map<String, Dynamic>;

/**
 * Representation of values that may be on the left hand side of an assignment statement.
 */
typedef LeftHandValue<A> = {
	function get():A;
	function set(v:A):A;
}

/**
 * Thrown to implement loop jumps.
 * See EFor and EWhile implementation
 */
enum LoopControl {
	LCBreak;
	LCContinue;
}

/**
 * Instantiated and thrown to return values from functions.
 * See EFunction handling.
 */
class Return {
	public var value(default, null):Dynamic;
	public function new(value) 
		this.value = value;
}