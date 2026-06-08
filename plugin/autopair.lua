-- Keymaps for bracket autopair
vim.keymap.set("i", "(", function() return AutoBracket("(") end, { desc = "Close Bracket", expr = true, silent = true })
vim.keymap.set("i", "[", function() return AutoBracket("[") end, { desc = "Close Square Bracket", expr = true, silent = true })
vim.keymap.set("i", "{", function() return AutoBracket("{") end, { desc = "Close Curly Bracket", expr = true, silent = true })


-- Keymaps for bracket type-over
vim.keymap.set("i", ")", function() return TypeOver(")") end, { desc = "Allow Bracket Type-over", expr = true, silent = true })
vim.keymap.set("i", "]", function() return TypeOver("]") end, { desc = "Allow Square Bracket Type-over", expr = true, silent = true })
vim.keymap.set("i", "}", function() return TypeOver("}") end, { desc = "Allow Curly Bracket Type-over", expr = true, silent = true })


-- Keymaps for Quotation marks
vim.keymap.set("i", "'", function() return AutoQuote("'") end, { desc = "Close Single Quotes", expr = true, silent = true })
vim.keymap.set("i", '"', function() return AutoQuote('"') end, { desc = "Close Double Quotes", expr = true, silent = true })
vim.keymap.set("i", "`", function() return AutoQuote("`") end, { desc = "Close Backtick Quotes", expr = true, silent = true })


-- Keymaps for expanding
vim.keymap.set("i", "<CR>", ExpandReturn, { desc = "Expand <CR> inside brackets", expr = true, silent = true })
vim.keymap.set("i", "<BS>", AutoDelete, { desc = "Smart delete respectful to paired brackets and quotes", expr = true, silent = true })
vim.keymap.set("i", " ", ExpandBracketSpace, { desc = "Expand the space to both sides of an internally spaced bracket", expr = true, silent = true })
