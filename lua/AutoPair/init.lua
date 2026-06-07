local M = {}

-- Default Config
M.config = {}


function M.setup(opts)
    if type(opts) ~= "table" then return end
    M.config = vim.tbl_deep_extend("force", M.config, opts)
end
