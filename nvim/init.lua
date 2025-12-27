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

-- Install plugins (if not already installed)
require("lazy").setup({
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "nvim-lualine/lualine.nvim" },  -- status line
  { "sainnhe/gruvbox-material" },
}, {
    defaults = { lazy = true },
    install = { colorscheme = { "gruvbox-material" } },
    ui = { open_on_start = false },  -- <--- this disables the dashboard
})

-- Enable line numbers
vim.opt.number = true
vim.opt.relativenumber = true

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

-- Gruvbox Material Dark theme
vim.opt.background = "dark"
vim.g.gruvbox_material_background = "medium"
vim.g.gruvbox_material_foreground = "material"
vim.cmd("colorscheme gruvbox-material")

-- Status line
require("lualine").setup({
  options = { theme = "gruvbox-material" }
})

