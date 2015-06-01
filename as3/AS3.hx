package;

import as3hx.*;
import as3hx.As3;
import haxe.macro.Context;
import haxe.macro.Expr;

import sys.FileSystem;
import sys.io.File;
import tink.SyntaxHub;
import tink.syntaxhub.FrontendContext;
import tink.syntaxhub.FrontendPlugin;

using tink.MacroApi;

class AS3 implements FrontendPlugin {
	var pos:Position;
	function new() {}
	static function use() 
		SyntaxHub.frontends.whenever(new AS3());
	
	public function extensions():Iterator<String> 
		return ['as'].iterator();
	
	function getPath(t:T) {
		return switch t {
			case TPath(parts):
				parts.join('.').asTypePath();
			default: 
				throw 'Path expected but found $t instead';
		}
	}
	static function getAccess(kwd:String) {
		return
			switch kwd {
				case 'public': APublic;
				case 'private': APrivate;
				case 'static': AStatic;
				default: throw 'cannot process keyword $kwd';
			}
	}
	function translate(e:As3.Expr):Expr {
		return switch e {
			case EBlock(exprs):
				exprs.map(translate).toBlock();
			case EIdent(name):
				macro @:pos(pos) $i{name};
			case EConst(c):
				Context.makeExpr(
					switch c {
						case CString(s):
							s;
						case CFloat(s):
							Std.parseFloat(s);
						case CInt(s):
							Std.parseInt(s);
					},
					pos
				);
				//macro @:pos
			case EField(owner, field):
				EField(translate(owner), field).at(pos);
			case ECall(e, params):
				ECall(translate(e), params.map(translate)).at(pos);
			default:
				throw 'Not implemented ' + e.getName();
		}
	}
	public function parse(file:String, context:FrontendContext):Void {
		var input = File.read(file);
		var program = new Parser(new Config()).parse(input);
		input.close();
		
		pos = Context.makePosition( { file: file, min: 0, max: FileSystem.stat(file).size } );
		try 
			for (f in program.defs) {
				//trace(f);
				switch f {
					case CDef(cls):
						
						var hx = context.getType(cls.name);
						hx.kind = TDClass(
							switch cls.extend {
								case null: null;
								case TPath(parts):
									parts.join('.').asTypePath();
								case v:
									throw 'NI: $v';
							},
							[for (i in cls.implement) getPath(i)],
							cls.isInterface
						);
						
						for (f in cls.fields)
							hx.fields.push( {
								name: f.name,
								pos: pos,
								access: f.kwds.map(getAccess),
								kind: switch f.kind {
									case FFun(f):
										FFun({
											ret: null,
											args: [],
											expr: translate(f.expr),
										});
									default:
										throw 'Not implemented: ' + f.kind.getName();
								}
							});
					default: 
						throw 'Only public classes supported';
				}
			}
		catch (e:Dynamic)
			Context.fatalError(Std.string(e), pos);
	}
	
}