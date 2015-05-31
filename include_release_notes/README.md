# Include Your Release Notes

## Key lesson: It runs when you hit compile, not when the user opens it

**Focus:** Access to macro APIs, adding content to your code.

**Problem:** You want to include release notes on your website.  You have a markdown file with the changelog, but your app is entirely run in Javascript, you don’t want to make an extra HTTP request, or process the markdown, and including HTML code straight in your code would just be messy.

**Can we solve it without macros?** We could include the notes in our “Client.hx” source file, but that is messy.  Or we could put them on a server and make a HTTP request.  We would need to include a markdown converter, either on the client or on the server somewhere.  

**Can macros help?** Can we load the “CHANGES.md” file?  Yes.  Can we convert it to HTML on our computer, so the converter doesn’t need to be on the server or client?  Yes.  Can we include the result directly in our code, as if we had typed it in there, but without all the mess?  Yes.

**Code example:** A repo containing a “Client.js” that does something simple, and has a “CHANGES.md” file.  Now they have to write a macro to load this, and make it display on the page.

**Inspired by:**  CompileTime.readMarkdownFile()
