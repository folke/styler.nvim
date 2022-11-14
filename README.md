# 🎨 Styler

Simple Neovim plugin to set a different `colorscheme` per filetype.

## ⚡️ Requirements

- Neovim >= 0.8.0

## 📦 Installation

Install the plugin with your preferred package manager:

```lua
-- Packer
use({
  "folke/styler.nvim",
  config = function()
    require("styler").setup({
      themes = {
        markdown = { colorscheme = "gruvbox" },
        help = { colorscheme = "catppuccin-mocha", background = "dark" },
      },
    })
  end,
})
```

## 🚀 Usage

To programmatically set the colorscheme for a certain window, you can use:

```lua
require("styler").set_theme(0, {
  colorscheme = "elflord",
  background = "dark"
})
```
