-- Swift / Xcode workflow.
-- LSP (sourcekit) lives in nvim-lspconfig.lua. This file owns the build/run/test/debug stack.
return {
  -- Build, run, test, debug Xcode projects from Neovim.
  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      require("xcodebuild").setup({
        restore_on_start = true,
        auto_save = true,
        logs = {
          auto_open_on_success_tests = false,
          auto_open_on_failed_tests = true,
          auto_open_on_success_build = false,
          auto_open_on_failed_build = true,
          auto_close_on_app_launch = false,
          auto_close_on_success_build = false,
          notify = function(message, severity)
            vim.notify(message, severity)
          end,
        },
        code_coverage = { enabled = false },
      })

      -- DAP setup for Swift via codelldb. Install separately:
      --   :MasonInstall codelldb     (if mason.nvim installed)
      -- Or download from https://github.com/vadimcn/codelldb/releases and adjust path below.
      local ok_dap, dap = pcall(require, "dap")
      if ok_dap then
        local mason_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = {
            command = mason_path .. "adapter/codelldb",
            args = { "--port", "${port}" },
          },
        }
        dap.configurations.swift = {
          {
            name = "iOS App / macOS App Debugger",
            type = "codelldb",
            request = "attach",
            program = function()
              return require("xcodebuild.dap").get_program_path()
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            waitFor = true,
          },
        }
      end

      local map = vim.keymap.set
      map("n", "<leader>X",  "<cmd>XcodebuildPicker<cr>",          { desc = "Xcode: action picker" })
      map("n", "<leader>xb", "<cmd>XcodebuildBuild<cr>",           { desc = "Xcode: build" })
      map("n", "<leader>xB", "<cmd>XcodebuildCleanBuild<cr>",      { desc = "Xcode: clean build" })
      map("n", "<leader>xr", "<cmd>XcodebuildBuildRun<cr>",        { desc = "Xcode: build & run" })
      map("n", "<leader>xR", "<cmd>XcodebuildRun<cr>",             { desc = "Xcode: run (no build)" })
      map("n", "<leader>xt", "<cmd>XcodebuildTest<cr>",            { desc = "Xcode: run tests" })
      map("n", "<leader>xT", "<cmd>XcodebuildTestClass<cr>",       { desc = "Xcode: test class" })
      map("n", "<leader>x.", "<cmd>XcodebuildTestSelected<cr>",    { desc = "Xcode: test selected" })
      map("n", "<leader>xs", "<cmd>XcodebuildSelectScheme<cr>",    { desc = "Xcode: select scheme" })
      map("n", "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>",    { desc = "Xcode: select device" })
      map("n", "<leader>xp", "<cmd>XcodebuildSelectTestPlan<cr>",  { desc = "Xcode: select test plan" })
      map("n", "<leader>xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", { desc = "Xcode: toggle coverage" })
      map("n", "<leader>xC", "<cmd>XcodebuildShowCodeCoverageReport<cr>", { desc = "Xcode: coverage report" })
      map("n", "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>",      { desc = "Xcode: toggle logs" })
      map("n", "<leader>xq", "<cmd>XcodebuildQuickfixLine<cr>",    { desc = "Xcode: quickfix line" })
      map("n", "<leader>xa", "<cmd>XcodebuildCodeActions<cr>",     { desc = "Xcode: code actions" })
      map("n", "<leader>xx", "<cmd>XcodebuildCancel<cr>",          { desc = "Xcode: cancel" })

      -- Fast bindings (IDE muscle memory).
      map("n", "<F5>",        "<cmd>XcodebuildBuildRun<cr>",       { desc = "Xcode: build & run" })
      map("n", "<S-F5>",      "<cmd>XcodebuildCancel<cr>",         { desc = "Xcode: cancel" })
      map("n", "<F6>",        "<cmd>XcodebuildRun<cr>",            { desc = "Xcode: run (no build)" })
      map("n", "<leader>r",   "<cmd>XcodebuildBuildRun<cr>",       { desc = "Xcode: build & run" })
    end,
  },

  -- Treesitter parser for Swift highlighting.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "swift" })
    end,
  },

  -- Formatting via swiftformat.
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        swift = { "swiftformat" },
      },
    },
  },
}
