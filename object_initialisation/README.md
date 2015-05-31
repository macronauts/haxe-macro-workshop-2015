# Object Initialisation

## Key Lesson: Expressions in, expressions out

**Focus:** Exploring simple expression transformation macros.  Expression reification.

**Problem:** You have a new co-worker join your project, and he’s new to Haxe.  He has used C# before, which is similar, and he said he misses this syntax:

	Character myCharacter = new Character(name){ Role = BadGuy, Weapon = Sword, Hat = Sombrero };

Instead in Haxe he has to do:

	var myCharacter = new Character(name);
	myCharacter.role = BadGuy;
	myCharacter.weapon = Sword;
	myCharacter.hat = Sombrero;

You are worried he will hate Haxe forever, so you need to save him some key strokes!

**Can we solve it without macros?** We could do some “Reflect” magic, but it would lose type safety, so we might accidentally assign “Sword” to our characters hat, and we wouldn’t realize how silly this looks until a user runs into it at runtime.  We could also create a function which initializes the object, but it might be hard to remember variable order, and we’d need to write a new function for Character, and Weapon, and Vehicle, and Hat, and all sorts of different objects.

**Code example:** A repo with the “MyCharacter” and “Role” classes, and defining about 10 different object initialisations.  Have a competition to see who can make the easiest, most readable, most concise, most re-usable syntax.

**Pro tip:** Show how reification works.  Perhaps demonstrate a solution using ExprDef enums, and show how many lines it is.  And then do another one with reification.  Show how much easier it is to grasp.  Perhaps we could compare it to String Interpolation, we “used” + “ “ + “ to “ + “ “ + [“have”,”to”,”write”].join(“ “) + “ this”, now it’s much shorter.

**Take home thought:** Anything that is valid Haxe syntax can be given to a macro.  So you can make many different syntaxes that are very nice to read.  And they can return real code that does the same thing as typing something the long way.

**Inspired by:** ObjectInit
