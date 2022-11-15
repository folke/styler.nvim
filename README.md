# 🎨 Styler

Simple Neovim plugin to set a different `colorscheme` per filetype.

![image](https://user-images.githubusercontent.com/292349/201787416-204ab55f-0fe9-4336-8f00-a47ad0ca7e4f.png)

## ⚡️ Requirements

- Neovim >= 0.8.0
- **Styler** only work with `colorschemes` that set highlights using `vim.api.nvim_set_hl`

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

## 🚀 API

To programmatically set the colorscheme for a certain window, you can use:

```lua
require("styler").set_theme(0, {
  colorscheme = "elflord",
  background = "dark"
})
```
