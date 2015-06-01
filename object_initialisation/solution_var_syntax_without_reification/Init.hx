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
		var statements = [];

		// We need a temporary variable to save our object to, so we can access it and set the various fields.
		// When we declare the variable, we should initialise it to whatever the `object` expression was.
		// `var _tmp_objectinit = $object`
		var tmpVarName = "_tmp_objectinit";
		var tmpVarSetup = { expr:EVars([{ type:null, name:tmpVarName, expr:object }]), pos:object.pos };
		statements.push( tmpVarSetup );

		// `tmpVar` variable identifier. We'll need to use it a few times.
		var tmpVar = { expr:EConst(CIdent(tmpVarName)), pos:object.pos };

		// Go through each of our arguments, and look for object properties to set.
		for (arg in args) {
			switch arg.expr {
				// Find a `name=value` style expression, and extract the name (as a String) and the value (as an Expr).
				case EBinop(OpAssign, { expr:EConst(CIdent(name)), pos:_}, valueExpression):
					var propertyExpression = { expr:EField(tmpVar,name), pos:arg.pos };
					var setPropertyStatement = { expr:EBinop(OpAssign, propertyExpression, valueExpression), pos:valueExpression.pos };
					statements.push( setPropertyStatement );
				default:
					// Always give good error messages!
					var msg = 'Init should be used with `property=value` style expressions. Instead there was '+arg.toString();
					// You can specify the position the error message should appear at too.
					Context.warning(msg, arg.pos);
			}
		}

		// In Haxe, a block of statements will return the value of the final statement.
		// So we can return our object as the last statement in the block.
		statements.push( tmpVar );
		var blockExpression = { expr:EBlock(statements), pos:object.pos };

		// Enable this trace to see what the expression we are returning looks like.
		//trace( blockExpression.toString() );

		return blockExpression;
	}
}
