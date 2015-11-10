# haxe-macro-workshop-2015

[![Build Status](https://travis-ci.org/macronauts/haxe-macro-workshop-2015.svg?branch=master)](https://travis-ci.org/macronauts/haxe-macro-workshop-2015)

Gateway drugs for the world of Haxe macros.

![Mad scientist](https://avatars3.githubusercontent.com/u/12681912?v=3&s=410 "You too could look like this... with MACROS!")

## Welcome

This repository aims to be a collection of tutorials, playgrounds and worked examples for using Haxe macros.

They have a reputation for being dark magic.  They're not magic, but they can be a bit hard to learn.  We hope to help with this.

This repo was originally created for a workshop at the WWX Haxe Conference, held in Paris on June 1 2015.

## Pre-requisite knowledge

Macros build on top of several Haxe concepts.  Each of these is a cool enough and powerful enough feature that they're fun to learn (and will empower your coding) all on their own.  If you're not familiar with any of these concepts, I recommend learning each of them first and becoming very familiar before exloring macros further.

  * __Enums__

	(Called "Generalized Algebraic Data Types", or GADTs in some other languages.)  Especially enums that can contain values:

	```haxe
	enum Color {
		Red;
		Green;
		Blue;
		RGB( r:Int, g:Int, b:Int );
		HSV( h:Int, s:Int, v:Int );
	}
	```

	If the above syntax looks weird to you, go learn about enums. They are very cool.

	See http://haxe.org/manual/types-enum-instance.html

  * __Pattern Matching__

	In haxe the `switch` statement can do a lot more than in simple ecmascript languages like JS or AS3.  It's called "Pattern Matching".

	It allows you to switch on enums, objects or arrays:

	```haxe
	switch colour {
		case Red: trace('Red');
		case RGB(red,_,_) if (red>200): trace('Mostly red');
		default: trace('Not red');
	}
	switch [gender,nation] {
		case [Male,French]: trace('He is French!');
		case [Female,German]: trace('She is German!');
		case [Male,nation]: trace('He is from $nation!');
		case [Female,nation]: trace('She is from $nation!');
	}
	switch person {
		case { name:"Jason", age:a }: trace('Jason is $a years old');
		default:
	}
	```

	If this all looks unfamiliar to you, you should definitely check out pattern matching.  It's powerful, and you'll need to use it all the time in macros.

	See http://haxe.org/manual/lf-pattern-matching.html

  * __Conditional Compilation__

	Conditional compilation allows you to change fields or expressions to only appear on a certain target, or if a certain compilation parameter is set (like `-debug`), or in a certain context.

	```haxe
	var platform =
	    #if (js && nodejs) "NodeJS"
		#elseif js "Browser"
		#else "Other" #end;
	```

	If this is unfamiliar to you, go learn about conditional compilation.  You'll find you need to use `#if macro` and `#if !macro` a fair bit.

	See http://haxe.org/manual/lf-condition-compilation.html

  * __Metadata__

	Metadata is annotations you can add to your code, which aren't executed at runtime, but can be inspected using either macros or the `haxe.rtti.Meta` API.

	If you haven't seen code like this:

	```Haxe
	@:route("/articles/$page")
	@inject
	public function( page:String) {}
	```

	then you should read up about metadata.

	See http://haxe.org/manual/lf-metadata.html

## Play Areas

* [Expression Explorer](expression_explorer)
* [Interpreter](interpreter)

## Problems

* [Include release notes in your build](include_release_notes)
* [Quick object initialisation](object_initialisation)
* [Short lambdas](short_lambdas)
* [Macro powered CLI tools](automatic_cli_tools)
