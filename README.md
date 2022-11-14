# 🎨 Styler

Simple Neovim plugin to set a different `colorscheme` per filetype.

![image](https://user-images.githubusercontent.com/292349/201647881-c32e10c9-d00d-42f9-9e16-175c1fe90c71.png)

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
