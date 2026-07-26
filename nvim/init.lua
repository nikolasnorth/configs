-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key to space (must be before plugins load)
vim.g.mapleader = " "

-- Install plugins (if not already installed)
require("lazy").setup({
  {
    "nvim-treesitter/nvim-treesitter",
    -- master is frozen but stable; main requires nvim 0.12+ APIs (vim.list)
    branch = "master",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "java", "python", "bash", "json", "yaml", "lua", "markdown", "markdown_inline" },
        highlight = { enable = true },
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
  { "nvim-lualine/lualine.nvim" },  -- status line
  { "catppuccin/nvim", name = "catppuccin" },
  {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function()
      require("Comment").setup()
    end,
  },
  {
    "windwp/nvim-autopairs",
    lazy = false,
    config = function()
      require("nvim-autopairs").setup()
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    config = function()
      require("gitsigns").setup()
    end,
    keys = {
      { "<leader>gb", "<cmd>Gitsigns blame_line<cr>", desc = "Git blame line" },
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview git changes" },
    },
  },
  {
    "ibhagwan/fzf-lua",
    lazy = false,
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find buffers" },
      { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
    },
  },
  { "neovim/nvim-lspconfig" },
  { "mfussenegger/nvim-jdtls", ft = "java" },  -- config lives in ftplugin/java.lua
  {
    "saghen/blink.cmp",
    version = "1.*",  -- pin to release so the prebuilt fuzzy-matcher binary is used
    event = "InsertEnter",
    opts = {
      keymap = { preset = "default" },
      completion = { documentation = { auto_show = true } },
    },
  },
  {
    "folke/which-key.nvim",
    lazy = false,
    config = function()
      require("which-key").setup({
        triggers = { "<leader>" },
        delay = 500,  -- ms before popup appears
      })
    end,
  },
}, {
    defaults = { lazy = true },
    install = { colorscheme = { "catppuccin-mocha" } },
    ui = { open_on_start = false },  -- <--- this disables the dashboard
})

-- Enable line numbers and sign column
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

-- Re-apply settings when entering buffers. Fixes issue where Lazy plugin
-- manager's install UI disables these settings and doesn't restore them.
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.opt_local.number = true
    vim.opt_local.relativenumber = true
    vim.opt_local.signcolumn = "yes"
  end
})

-- Multiplexers can inhibit OSC 52 clipboard detection over SSH.
if vim.env.SSH_TTY then
  vim.g.clipboard = "osc52"
end

-- Use system clipboard
vim.opt.clipboard = "unnamedplus"

-- Enable syntax highlighting
vim.cmd("syntax enable")

-- Tabs & spaces
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Better search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank() end
})

-- Keep cursor away from edges when scrolling
vim.opt.scrolloff = 8

-- Word-aware line wrapping; preserve indent on wrapped lines
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.sidescroll = 1
vim.opt.sidescrolloff = 8

-- Persistent undo (survives closing file)
vim.opt.undofile = true

-- Auto-reload files changed outside of nvim
vim.opt.autoread = true
vim.opt.updatetime = 250
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  command = "checktime",
})

-- Catppuccin Mocha theme
vim.opt.background = "dark"
vim.opt.termguicolors = true
vim.cmd("colorscheme catppuccin-mocha")

-- Status line
require("lualine").setup({
  options = { theme = "auto" }
})

-- ========================= LSP =========================

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Goto definition")
    map("gD", vim.lsp.buf.declaration, "Goto declaration")
    map("gri", vim.lsp.buf.implementation, "Goto implementation")
    map("grr", "<cmd>FzfLua lsp_references<cr>", "References")
    map("grn", vim.lsp.buf.rename, "Rename symbol")
    map("gra", vim.lsp.buf.code_action, "Code action")
    map("<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", "Document symbols")
    map("<leader>fS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", "Workspace symbols")
    map("<leader>e", vim.diagnostic.open_float, "Show diagnostic")
  end,
})

vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
})

-- Non-Java servers (jdtls is handled by nvim-jdtls in ftplugin/java.lua).
-- Each is enabled only if its binary is installed.
local servers = { "lua_ls", "pyright", "bashls" }
local server_bins = { lua_ls = "lua-language-server", pyright = "pyright-langserver", bashls = "bash-language-server" }
for _, server in ipairs(servers) do
  if vim.fn.executable(server_bins[server]) == 1 then
    vim.lsp.enable(server)
  end
end

local work_config = vim.fn.expand("~/.config/nvim/work.lua")
if vim.fn.filereadable(work_config) == 1 then
  dofile(work_config)
end
