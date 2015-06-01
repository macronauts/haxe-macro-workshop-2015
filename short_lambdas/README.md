# Short Lambdas

## Key lesson: Using build macros for syntax transformations.

**Focus:** Show how a build macro applies to a whole class, and can create, delete or modify fields, and all the expressions in each field.

**Problem:** You use lots of functions in your code, for event handlers and filtering functions and more.  But this looks ugly:

    players.filter(function(p) return p.age>21);

and you miss the “short lambda” syntax from coffeescript, ES6, C#, hell, even Java.  But Nicolas says no.

**Can we solve it without macros:** You could maybe create a pre-compiler, like how coffeescript generates JS, you could create something that generates HX files, but that would be so much work.

**Code example:**  Have a simple file (Flash or JS?) that uses a tonne of functions, for filtering, callbacks, events, everything.  Have a competition to see who can make the easiest, most readable syntax.

**Pro tip:** After people have built a build macro manually, we show them tink.macro.ClassBuilder, and show how it could be implemented with that.
