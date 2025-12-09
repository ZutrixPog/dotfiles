return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
      "nvim-neotest/nvim-nio",
    },

    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason-nvim-dap").setup({
        ensure_installed = {
          "delve",     -- Go
          "codelldb",  -- Rust/C/C++
          "python",    -- debugpy
        },
        automatic_installation = true,
      })

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      dap.adapters.go = function(callback, config)
        local port = 38697
        local handle
        handle = vim.loop.spawn("dlv", {
          args = { "dap", "-l", "127.0.0.1:" .. port },
          detached = true
        }, function(code)
          handle:close()
        end)

        vim.defer_fn(function()
          callback({ type = "server", host = "127.0.0.1", port = port })
        end, 100)
      end

      dap.configurations.go = {
        {
          type = "go",
          name = "Debug file",
          request = "launch",
          program = "${file}",
        },
        {
          type = "go",
          name = "Debug package",
          request = "launch",
          program = "./",
        },
        {
          type = "go",
          name = "Debug Go test (nearest)",
          request = "launch",
          mode = "test",
          program = "${fileDirname}",
        },
        {
          type = "go",
          name = "Debug Go test (all)",
          request = "launch",
          mode = "test",
          program = "./",
        },
      }

      dap.adapters.python = {
        type = "executable",
        command = "python",
        args = { "-m", "debugpy.adapter" },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
        },
      }

      local codelldb_path = vim.fn.stdpath("data")
        .. "/mason/packages/codelldb/extension/adapter/codelldb"

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = codelldb_path,
          args = { "--port", "${port}" },
        },
      }

      local function prompt_executable()
        return vim.fn.input(
          "Path to executable: ",
          vim.fn.getcwd() .. "/target/debug/",
          "file"
        )
      end

      local function get_rust_test_binary(test_name)
        local cmd = "cargo test " .. test_name .. " --no-run --message-format=json"
        local output = vim.fn.systemlist(cmd)
        for _, line in ipairs(output) do
          local ok, json = pcall(vim.json.decode, line)
          if ok and json.executable then return json.executable end
        end
        print("Could not find test executable.")
      end

      local function get_all_rust_test_binaries()
        local cmd = "cargo test --no-run --message-format=json"
        local output = vim.fn.systemlist(cmd)
        for _, line in ipairs(output) do
          local ok, json = pcall(vim.json.decode, line)
          if ok and json.executable then return json.executable end
        end
      end

      dap.configurations.rust = {
        {
          name = "Debug executable",
          type = "codelldb",
          request = "launch",
          program = prompt_executable,
          cwd = "${workspaceFolder}",
        },

        {
          name = "Debug Rust test (nearest)",
          type = "codelldb",
          request = "launch",
          program = function()
            local test = vim.fn.expand("<cword>")
            return get_rust_test_binary(test)
          end,
          args = { "--nocapture" },
          cwd = "${workspaceFolder}",
        },

        {
          name = "Debug Rust tests (all)",
          type = "codelldb",
          request = "launch",
          program = get_all_rust_test_binaries,
          args = { "--nocapture" },
          cwd = "${workspaceFolder}",
        },
      }

      dap.configurations.cpp = dap.configurations.rust
      dap.configurations.c = dap.configurations.rust

      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      -- Basic debugger control
      map("n", "<leader>dc", dap.continue, opts)
      map("n", "<leader>ds", dap.step_over, opts)
      map("n", "<leader>di", dap.step_into, opts)
      map("n", "<leader>do", dap.step_out, opts)

      -- Breakpoints
      map("n", "<leader>db", dap.toggle_breakpoint, opts)
      map("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Condition: "))
      end, opts)

      -- UI + REPL
      map("n", "<leader>du", dapui.toggle, opts)
      map("n", "<leader>dr", dap.repl.open, opts)
      map("n", "<leader>dl", dap.run_last, opts)

      -- Go test mappings
      map("n", "<leader>dt", function()
        require("dap").run(require("dap").configurations.go[3])
      end, { desc = "Debug Go test (nearest)" })
      map("n", "<leader>dta", function()
        require("dap").run(require("dap").configurations.go[4])
      end, { desc = "Debug Go tests (all)" })

      -- Rust test mappings
      map("n", "<leader>rt", function()
        require("dap").run(require("dap").configurations.rust[2])
      end, { desc = "Debug Rust test (nearest)" })
      map("n", "<leader>rta", function()
        require("dap").run(require("dap").configurations.rust[3])
      end, { desc = "Debug Rust tests (all)" })
    end,
  },
}
