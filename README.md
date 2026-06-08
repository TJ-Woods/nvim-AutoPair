# nvim-AutoPair
Autocompletion for pairs and structures for Neovim

# Setup
This plugin does not require setup as of its current state. It will create the keymaps and autocommands upon Neovim startup.



# What does this plugin do?
## Auto Pairing Brackets
This plugin was originally created with the purpose of autocompleting and providing nice features regarding typing brackets `()[]{}` and quotation marks ''""``
It types out the closing bracket once the opening bracket is typed, and allows type-over so that fast typing a function call for example, isn't annoying.
Since then, it has expanded to also expand spaces, returns, and backspaces to work nicely with brackets.
Typing a <CR> while between a set of brackets will produce the following: (| = cursor)
```
int main() {|}


*press return*


int main() {
    |
}
```

Typing a space while between a set of brackets will produce the following: (| = cursor)
```
vec2 coords = {|}


*press space*


vec2 coords = { | }
```

## Auto-Deleting Brackets
When brackets or quotes are adjacent, and you try to backspace one of them, both will be backspaced.
This looks like the following in practice: (| = cursor)
```
(|)


*press backspace*


|
```

```
( | )


*press backspace*


(| )


*press backspace*


|
```


## Lua-Specific Completion
Since this plugin was written in Lua, while creating it, I came across some things that I would have found useful to have for writing in Lua so I added them to this plugin.
When typing out a function definition, this plugin will add the `end` statement once the enter key is pressed.
When typing out an if statement, for loop, while loop, or repeat-until loop, the appropriate ending will be automatically typed out for you.

## HTML-Specific Completion
When writing HTML tags, this plugin will automatically add the closing tag `</*tag_name*>` to appliccable tags that require closing. It will also autocomplete the closing of the angled bracket when writing out the tag name and once it is typed over, it will complete the tag close.



# What more is to come?
- More language-specific functionality
- Better auto-deletion of adjacent brackets dealing with nested brackets of the same type.
