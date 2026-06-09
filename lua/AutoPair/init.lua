local M = {}

-- Default Config
M.config = {}

function M.setup(opts)
    if type(opts) ~= "table" then return end
    -- TODO: Is config appliccable to this plugin?
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

function M.InBracketPair()
    local openers = { ['('] = true, ['['] = true, ['{'] = true }
    local closers = { [')'] = '(', [']'] = '[', ['}'] = '{' }

    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local left_side = line:sub(1, col)
    local right_side = line:sub(col + 1)
    local balances = { ['('] = 0, ['['] = 0, ['{'] = 0 }

    for i = 1, #left_side do
        local char = left_side:sub(i, i)
        if openers[char] then
            balances[char] = balances[char] + 1
        elseif closers[char] then
            local matching_opener = closers[char]
            if balances[matching_opener] > 0 then
                balances[matching_opener] = balances[matching_opener] - 1
            end
        end
    end

    for i = 1, #right_side do
        local char = right_side:sub(i, i)
        if openers[char] then
            balances[char] = balances[char] - 1
        elseif closers[char] then
            local matching_opener = closers[char]
            balances[matching_opener] = balances[matching_opener] - 1
            if balances[matching_opener] == 0 then
                return true
            end
        end
    end
    return false
end


function M.QuoteDelete()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_prev = string.sub(line, col, col)
    local char_next = string.sub(line, col + 1, col + 1)
    local quotes = "\"'`"

    if s_has(quotes, char_prev) and char_prev == char_next then
        return "<BS><Del>"
    else
        return "<BS>"
    end
end

function M.AutoBracket(bracket)
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_next = string.sub(line, col + 1, col + 1)
    local start_brackets = "([{"
    local end_brackets = ")]}"
    local index = string.find(start_brackets, bracket, 1, true)

    if index and (char_next == "" or char_next == " " or s_has(end_brackets, char_next)) then
        return bracket .. string.sub(end_brackets, index, index) .. "<left>"
    end
    return bracket
end


function M.TypeOver(closing_char)
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_under_cursor = string.sub(line, col + 1, col + 1)

    if char_under_cursor == closing_char then
        return '<Right>'
    else
        return closing_char
    end
end


function M.AutoQuote(quote_char)
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local char_under_cursor = string.sub(line, col + 1, col + 1)

  if char_under_cursor == quote_char then
    return '<Right>'
  else
    return quote_char .. quote_char .. '<Left>'
  end
end




function M.BracketDelete()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_next_next = string.sub(line, col + 2, col + 2)
    local char_next = string.sub(line, col + 1, col + 1)
    local char_prev = string.sub(line, col, col)
    local start_brackets = "([{"
    local end_brackets = ")]}"
    local index = string.find(start_brackets, char_prev, 1, true)

    if M.InBracketPair() then
        if index and (char_next == string.sub(end_brackets, index, index)) then
            return "<BS><DEL>"
        elseif index and (char_next == " " and char_next_next == string.sub(end_brackets, index, index)) then
            return "<BS><DEL><DEL>"
        end
    else
        return "<BS>"
    end
end


function M.AutoDelete()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_prev = string.sub(line, col, col)

    local quotes = "\"'`"
    local start_brackets = "([{"

    if s_has(quotes, char_prev) then
        return M.QuoteDelete()
    elseif s_has(start_brackets, char_prev) then
        return M.BracketDelete()
    else
        return "<BS>"
    end
end


function M.ExpandReturn()
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


function M.ExpandBracketSpace()
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

return M
