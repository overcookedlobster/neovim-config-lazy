-- ~/.config/nvim/lua/personal/sv_diagram.lua
local M = {}

-- LSP SymbolKinds. We use this to filter out noise (like wires, parameters, or functions)
-- so the diagram only shows structural blocks.
local ALLOWED_KINDS = {
    [2]  = true, -- Module
    [5]  = true, -- Class
    [11] = true, -- Interface
    [13] = true, -- Variable (Slang often categorizes instances as Variables)
    [19] = true, -- Object
    [23] = true, -- Struct
}

local function parse_symbols_to_mermaid(symbols)
    local lines = {
        "# SystemVerilog Hierarchy (LSP Generated)",
        "",
        "```mermaid",
        "graph LR", -- Left-to-Right is better for deep hardware trees
    }
    local node_counter = 0

    local function walk(symbol, parent_id)
        local has_children = symbol.children and #symbol.children > 0
        local name = (symbol.name or "unnamed"):gsub('["%c]', '')
        local detail = (symbol.detail or ""):gsub('["%c]', '')

        -- THE FILTER: Ignore ports, nets, dimensions, and basic types
        local is_noise = detail:match("^input") or
                         detail:match("^output") or
                         detail:match("^inout") or
                         detail:match("^reg") or
                         detail:match("^wire") or
                         detail:match("^logic") or
                         detail:match("^%[") -- Catches packed dimensions like [31:0]

        -- Skip if it's noise and has no sub-hierarchy
        if is_noise and not has_children then return end

        -- Skip unsupported kinds unless they contain children
        if not ALLOWED_KINDS[symbol.kind] and not has_children then return end

        -- Filter out standard synchronizer primitives (Optional, remove if you want them!)
        if detail == "CB_SYNC" or detail == "CB_FLOP_SYNC" or detail == "CB_MUX" then return end

        node_counter = node_counter + 1
        local current_id = "node" .. node_counter

        -- Construct the label: InstanceName\n(ModuleName)
        local label = name
        if detail ~= "" then
            label = label .. "\\n(" .. detail .. ")"
        end

        -- Add to graph
        if parent_id then
            table.insert(lines, string.format('    %s --> %s["%s"]', parent_id, current_id, label))
        else
            table.insert(lines, string.format('    %s["%s"]', current_id, label))
        end

        -- Traverse children
        if has_children then
            for _, child in ipairs(symbol.children) do
                walk(child, current_id)
            end
        end
    end

    for _, sym in ipairs(symbols) do
        walk(sym, nil)
    end

    table.insert(lines, "```")
    return lines
end

function M.generate_diagram()
    vim.notify("Asking slang-server for hierarchy...", vim.log.levels.INFO)

    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, 'textDocument/documentSymbol', { textDocument = params.textDocument }, function(err, result, ctx, config)
        if err then
            vim.notify("LSP Error: " .. tostring(err.message), vim.log.levels.ERROR)
            return
        end

        if not result or vim.tbl_isempty(result) then
            vim.notify("slang-server returned no symbols. Make sure the LSP is fully attached.", vim.log.levels.WARN)
            return
        end

        local md_lines = parse_symbols_to_mermaid(result)

        -- Write to a hidden file in the CURRENT directory so the web server can see it
        local temp_file = vim.fn.getcwd() .. "/.sv_diagram.md"
        local f = io.open(temp_file, "w")
        if f then
            f:write(table.concat(md_lines, "\n"))
            f:close()
        else
            vim.notify("Failed to write temporary markdown file", vim.log.levels.ERROR)
            return
        end

        -- Open the physical file in a split
        vim.cmd("vsplit " .. temp_file)

        -- Get the new buffer ID to attach our cleanup hooks
        local buf = vim.api.nvim_get_current_buf()

        -- Trigger LivePreview
        vim.cmd("LivePreview start")
        vim.notify("Diagram generated instantly from LSP!", vim.log.levels.INFO)

        -- Auto-clean up: Stop the server and delete the file when you close the buffer
        vim.api.nvim_create_autocmd("BufWipeout", {
            buffer = buf,
            callback = function()
                pcall(vim.cmd, "LivePreview close")
                os.remove(temp_file)
            end,
            once = true
        })
    end)
end

function M.setup()
    vim.api.nvim_create_user_command("SVDoc", M.generate_diagram, { desc = "Generate SV Block Diagram via Slang LSP" })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "systemverilog", "verilog" },
        callback = function(ev)
            vim.keymap.set("n", "<leader>sd", ":SVDoc<CR>", {
                buffer = ev.buf,
                desc = "Slang LSP: View Block Diagram"
            })
        end
    })
end

return M
