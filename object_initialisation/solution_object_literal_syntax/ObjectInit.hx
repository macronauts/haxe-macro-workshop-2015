import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.Tools;

/**
This macro can be used like so:

```
ObjectInit.set(new Person(), { name:"Jason", age:28 });
new Person().set({ name:"Jason", age:28 })
```
**/
class ObjectInit {
	public static macro function set<T>( obj:ExprOf<T>, fields:Expr ):ExprOf<T> {

		var statements = [];

		switch fields.expr {
			case EObjectDecl(fields):
				for ( field in fields ) {
					var fieldName = field.field;
					var setExpr = macro @:pos(field.expr.pos) tmp.$fieldName = $e{field.expr};
					statements.push( setExpr );
				}
			default:
				Context.error('Wrong syntax!', fields.pos);
		}

		var returnExpr = macro {
			var tmp = $obj;
			$b{statements};
			tmp;
		};

		return returnExpr;
	}
}
