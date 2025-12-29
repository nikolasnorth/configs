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
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "bash", "java", "json", "lua", "markdown", "python", "ruby", "rust", "typescript" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  { "nvim-lualine/lualine.nvim" },  -- status line
  { "sainnhe/gruvbox-material" },
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
}, {
    defaults = { lazy = true },
    install = { colorscheme = { "gruvbox-material" } },
    ui = { open_on_start = false },  -- <--- this disables the dashboard
})

-- Enable line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Always show sign column (prevents editor shift when git signs appear)
vim.opt.signcolumn = "yes"

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

-- Persistent undo (survives closing file)
vim.opt.undofile = true

-- Gruvbox Material Dark theme
vim.opt.background = "dark"
vim.g.gruvbox_material_background = "medium"
vim.g.gruvbox_material_foreground = "material"
vim.cmd("colorscheme gruvbox-material")

-- Status line
require("lualine").setup({
  options = { theme = "gruvbox-material" }
})

