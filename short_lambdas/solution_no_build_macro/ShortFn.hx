import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.Tools;
using StringTools;

/**
This implementation gives you `[1,2,3].filter( f(_>1) )` syntax.

It only works with functions that take 1 argument and always return a value.
So you can't use it for functions requiring more than 1 argument.

The `_` wildcard is replaced by the argument in the function.
**/
class ShortFn {
	public static macro function f(body:Expr) {

		function replaceWildcard(e:Expr) {
			return switch e {
				case macro $i{name} if (name.startsWith("_")):
					return macro _tmp;
				default:
					return e.map(replaceWildcard);
			}
		}

		body = body.map( replaceWildcard );

		return macro function(_tmp) return $body;
	}

}
