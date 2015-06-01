#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import sys.io.File;
using haxe.macro.Tools;
#end

class LoadNotes {
	public static macro function loadNotes():Expr {
		var notes = File.getContent( "ReleaseNotes.md" );
		notes = Markdown.markdownToHtml( notes );
		var returnVal = macro $v{notes};
		// trace( returnVal );
		// trace( returnVal.toString() );
		return returnVal;
	}
}
