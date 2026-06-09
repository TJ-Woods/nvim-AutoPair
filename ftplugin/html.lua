local auto_pair = require("AutoPair")

local function s_has(str, char)
    for c in str:gmatch(".") do
        if c == char then
            return true
        end
    end
    return false
end

local function HtmlCompleteTag()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_next = string.sub(line, col + 1, col + 1)
    local is_writeover = (char_next == ">")
    local before_cursor = line:sub(1, col)
    local open_bracket = before_cursor:match(".*<")

    if not open_bracket then
        return is_writeover and "<Right>" or ">"
    end

    local tag_content = before_cursor:sub(#open_bracket + 1)
    local tag_name = tag_content:match("^([%w%-]+)")

    local invld_strs = {
        "area", "base", "br", "col", "embed", "hr", "img",
        "input", "link", "meta", "param", "source", "track", "wbr"
    }

    if tag_name and not has(invld_strs, tag_name) then
        vim.schedule(function()
            local closing_tag = "</" .. tag_name .. ">"
            vim.api.nvim_put({ closing_tag }, "c", false, true)

            local move_left = vim.api.nvim_replace_termcodes(string.rep("<Left>", #closing_tag), true, false, true)
            vim.api.nvim_feedkeys(move_left, "n", true)
        end)
    end

    if is_writeover then
        return "<Right>"
    end
    return ">"
end

local function HtmlExpandReturn()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_prev = string.sub(line, col, col)
    local chars_next = string.sub(line, col + 1, col + 2)

    if char_prev == ">" and chars_next == "</" then
        return "<CR><Esc>O"
    end
    return auto_pair.ExpandReturn()
end

local function AngleBracketDelete()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_prev = string.sub(line, col, col)
    local char_next = string.sub(line, col + 1, col + 1)

    if char_prev == "<" and char_next == ">" then
        return "<BS><Del>"
    end
    return "<BS>"
end

local function HtmlAutoDelete()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_prev = string.sub(line, col, col)
    local angle_bracket = "<"

    if s_has(angle_bracket, char_prev) then
        return AngleBracketDelete()
    end
    return auto_pair.AutoDelete()
end




vim.keymap.set("i", "<", "<lt>><left>", { desc = "AutoPair: Auto close angle brackets in HTML files.", expr = true, silent = true, buffer = true })

vim.keymap.set("i", "<CR>", HtmlExpandReturn, { desc = "AutoPair: Expand return in HTML tags.", expr = true, silent = true, buffer = true })

vim.keymap.set("i", ">", HtmlCompleteTag, { desc = "AutoPair: Complete HTML tag closing.", expr = true, silent = true, buffer = true })

vim.keymap.set("i", "<BS>", HtmlAutoDelete, { desc = "AutoPair: Auto delete pairs in HTML files.", expr = true, silent = true, buffer = true })
