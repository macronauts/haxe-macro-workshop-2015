import haxe.macro.Expr; // <-- This has all of the different Enums we need for matching and creating expressions.
import haxe.macro.Context; // <-- We use Context.warning to warn you when you use an expression isn't correct.
using haxe.macro.Tools; // <-- We are using the "ExprTools.toString()" property to trace our return expression when debugging.

class Init {

	/**
	The init() function is designed to be used by static extension.

	The `object` parameter is the expression we are doing our object initialisation on.
	See http://haxe.org/manual/macro-limitations-static-extension.html

	The `args` param is a "rest" argument, meaning this macro can take many different expressions, not just 1 or 2.
	It's supposed to contain lots of "name='Jason'" style declarations.
	See http://haxe.org/manual/macro-rest-argument.html
	**/
	public static macro function init( object:Expr, args:Array<Expr> ):Expr {
		var setStatements = [];
		var tmpVarName = "_tmp_objectinit";

		for (arg in args) {
			switch arg {
				case macro $i{name} = $valueExpression:
					var setPropertyStatement = macro $i{tmpVarName}.$name = $valueExpression;
					setStatements.push( setPropertyStatement );
				default:
					var msg = 'Init should be used with `property=value` style expressions. Instead there was '+arg.toString();
					Context.warning(msg, arg.pos);
			}
		}

		var blockExpression = macro {
			var $tmpVarName = $object;
			$b{setStatements};
			$i{tmpVarName};
		}

		// Enable this trace to see what the expression we are returning looks like.
		//trace( blockExpression.toString() );

		return blockExpression;
	}
}
