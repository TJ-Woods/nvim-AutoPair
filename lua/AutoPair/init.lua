local M = {}

-- Default Config
M.config = {}


function M.setup(opts)
    if type(opts) ~= "table" then return end
    M.config = vim.tbl_deep_extend("force", M.config, opts)
end

local function s_has(str, char)
    for c in str:gmatch(".") do
        if c == char then
            return true
        end
    end
    return false
end

-- File-specific additions
function HTML_ExpandReturn()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_prev = string.sub(line, col, col)
    local char_next = string.sub(line, col + 1, col + 2)

    if char_prev == ">" and char_next == "</" then
        return "<CR><Esc>O"
    else
        return "<CR>" -- Return None?
    end
end

vim.keymap.set("i", "<CR>", function()
    local curs = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local start_to_curs = string.sub(line, 1, curs)
    local match_opener = start_to_curs:match("%s*function%s*[%w_.:]*%(.*%)%s*$")
        or (start_to_curs:match("if%s+.*%s+then%s*$") and not start_to_curs:match(".*elseif.*"))
        or start_to_curs:match("do%s*$")
    local match_repeat = start_to_curs:match("repeat%s*$")

    if match_opener then
        print("LUA_ENTER")
        return "<CR>end<Esc>O"
    elseif match_repeat then
        return "<CR>until "
    else
        return "<CR>"
    end
end, { desc = "Auto-insert end for Lua blocks", expr = true, buffer = true })

function AutoBracket(bracket)
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_next = string.sub(line, col + 1, col + 1)
    local start_brackets = "([{"
    local end_brackets = ")]}"
    local index = string.find(start_brackets, bracket, 1, true)

    if index and (char_next == "" or char_next == " " or has_s(end_brackets, char_next)) then
        return bracket .. string.sub(end_brackets, index, index) .. "<left>"
    end
    return bracket
end


function TypeOver(closing_char)
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_under_cursor = string.sub(line, col + 1, col + 1)

    if char_under_cursor == closing_char then
        return '<Right>'
    else
        return closing_char
    end
end


function AutoQuote(quote_char)
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local char_under_cursor = string.sub(line, col + 1, col + 1)

  if char_under_cursor == quote_char then
    return '<Right>'
  else
    return quote_char .. quote_char .. '<Left>'
  end
end


function QuoteDelete()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_prev = string.sub(line, col, col)
    local char_next = string.sub(line, col + 1, col + 1)
    local quotes = "\"'`"

    if has_s(quotes, char_prev) and char_prev == char_next then
        return "<BS><Del>"
    else
        return "<BS>"
    end
end


function BracketDelete()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_next_next = string.sub(line, col + 2, col + 2)
    local char_next = string.sub(line, col + 1, col + 1)
    local char_prev = string.sub(line, col, col)
    local start_brackets = "([{"
    local end_brackets = ")]}"
    local index = string.find(start_brackets, char_prev, 1, true)

    if index and (char_next == string.sub(end_brackets, index, index)) then
        return "<BS><DEL>"
    elseif index and (char_next == " " and char_next_next == string.sub(end_brackets, index, index)) then
        return "<BS><DEL><DEL>"
    else
        return "<BS>"
    end
end


function AutoDelete()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_prev = string.sub(line, col, col)

    local quotes = "\"'`"
    local start_brackets = "([{"

    if s_has(quotes, char_prev) then
        return QuoteDelete()
    elseif s_has(start_brackets, char_prev) then
        return BracketDelete()
    else
        return "<BS>"
    end
end


function ExpandEnter()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_next = string.sub(line, col + 1, col + 1)
    local char_prev = string.sub(line, col, col)
    local start_brackets = "([{"
    local end_brackets = ")]}"
    local index = string.find(start_brackets, char_prev, 1, true)

    if index and string.sub(end_brackets, index, index) == char_next then
        return "<CR><Esc>O"
    else
        return "<CR>"
    end
end


function ExpandBracketSpace()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_next = string.sub(line, col + 1, col + 1)
    local char_prev = string.sub(line, col, col)
    local start_brackets = "([{"
    local end_brackets = ")]}"
    local index = string.find(start_brackets, char_prev, 1, true)

    if index and char_next == string.sub(end_brackets, index, index) then
        return " <left> "
    else
        return " "
    end
end



vim.api.nvim_create_autocmd("FileType", {
    pattern = "lua",
    callback = function()
        print("Running the Lua Return Autocmd")
        -- Map <CR> in insert mode only for Lua files
    end,
})




vim.api.nvim_create_autocmd("FileType", {
    pattern = "html",
    callback = function()
        vim.keymap.set("i", "<", "<lt>><left>", { desc = "Close Angle Bracket", buffer = true })

        vim.keymap.set(
            "i",
            "<CR>",
            HTML_ExpandReturn,
            {
                desc = "Expand return on HTML tags",
                expr = true,
                silent = true,
                buffer = ev.buf
            }
        )
        vim.keymap.set("i", ">", function()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local line = vim.api.nvim_get_current_line()

            local char_under_cursor = string.sub(line, col + 1, col + 1)
            local is_writeover = (char_under_cursor == ">")

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
            else
                return ">"
            end

        end, { desc = "Smart HTML close tag", expr = true, silent = true, buffer = true })
    end
})



vim.api.nvim_create_autocmd("FileType", {
    pattern = { "html" },
    callback = function(ev)
    end
})
