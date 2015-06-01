import haxe.macro.Expr;
using haxe.macro.Tools;

// Run with `haxe --run ExpressionExplorer`

class ExpressionExplorer {

	static function main() {
		var myExpression = macro var x = 0;

		// Trace the expression, showing the enums and objects it is made up of.
		trace( myExpression.expr );

		// Trace the expression, using the ExprTools.toString() to show what the source looks like.
		trace( myExpression.toString() );

		// Do some switching using enums.
		switch myExpression.expr {
			case EVars([varSetup]):
				trace('The variable name is: '+varSetup.name);
			default:
		}

		// Do some switching using reification.
		switch myExpression {
			case macro var x = $value:
				trace('The value is '+value.toString());
			default:
		}
	}
}
