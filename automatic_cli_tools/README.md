# Automatic CLI Tools

## Key lesson: Build macros for super powered classes

**Focus:** Show how a build macro can take a big-picture look at the whole class, and generate new functions that give your class super powers.

**Problem:** You are a sysadmin, and have to create a tonne of small command line utilities.  But you always end up just using `Sys.args()` and never remember which arguments you are supposed to use where, and your utilities get lost and confused.

**Can we solve it without macros:** Maybe.  We could use Haxe RTTI to read information at runtime, but that’s even harder than maros.  We could just list the functions on the object, but then we have no documentation.  We could have a separate UI function that sets up the menus based on us sending it commands + help tips, but this would require being updated separately to the code, so may not always be up to date.

**Code Example:** Have a file with some public methods that do something actually useful.  Perhaps a haxelib helper, that updates your haxelib.json, bundles a zip, and submits it.  Each person has to write a build function that finds each of the functions, and creates a useable, documented command line interface for the functions.

**Inspired by:** MCLI
