return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local is_ok, lualine = pcall(require, "lualine")
        if not is_ok then
            return
        end

        local function updateHarpoonIndicator()
            vim.b.harpoonMark = "" -- empty by default
            local harpoonJsonPath = fn.stdpath("data") .. "/harpoon.json"
            local fileExists = fn.filereadable(harpoonJsonPath) ~= 0
            if not fileExists then return end
            local harpoonJson = u.readFile(harpoonJsonPath)
            if not harpoonJson then return end

            local harpoonData = vim.json.decode(harpoonJson)
            local pwd = vim.loop.cwd()
            if not pwd or not harpoonData then return end
            local currentProject = harpoonData.projects[pwd]
            if not currentProject then return end
            local markedFiles = currentProject.mark.marks
            local currentFile = fn.expand("%:p")

            for _, file in pairs(markedFiles) do
                local absPath = pwd .. "/" .. file.filename
                if absPath == currentFile then vim.b.harpoonMark = "󰛢" end
            end
        end

        function harpoonStatusline() return vim.b.harpoonMark or "" end

        -- so the harpoon state is only checked once on buffer enter and not every second
        -- also, the command is called on marking a new file
        vim.api.nvim_create_autocmd({ "BufReadPost", "UiEnter" }, {
            pattern = "*",
            callback = updateHarpoonIndicator,
        })

        lualine.setup({
            options = {
                icons_enabled = true,
                theme = "everforest",
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = false,
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                },
            },
            -- Lualine has sections as shown below.
            -- +-------------------------------------------------+
            -- | A | B | C                             X | Y | Z |
            -- +-------------------------------------------------+
            -- Each section holds its components
            sections = {
                lualine_a = { "mode" },
                lualine_b = {
                    "branch",
                    "diff",
                    "diagnostics",
                },
                lualine_c = {},
                lualine_x = { "encoding", "filesize", "filetype", "lsp_status" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { "filename" },
                lualine_x = { "location" },
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {
                lualine_a = {
                    {
                        "filename",
                        file_status = true, -- Displays file status (read-only status, modified status)
                        -- Path configurations
                        -- 0: Just the filename
                        -- 1: Relative path
                        -- 2: Absolute path
                        -- 3: Absolute path, with tilde as the home directory
                        -- 4: Filename and parent dir, with tilde as the home directory
                        path = 1,
                        shorting_target = 40, -- Shortens path to leave 40 spaces in the window
                    },
                    harpoonStatusline,
                },
            },
            winbar = {},
            inactive_winbar = {},
            extensions = {},
        })
	end,
}
