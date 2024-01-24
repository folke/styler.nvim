# Changelog

## [1.0.1](https://github.com/folke/styler.nvim/compare/v1.0.0...v1.0.1) (2024-01-19)


### Bug Fixes

* fixed buggy split behaviour ([#8](https://github.com/folke/styler.nvim/issues/8)) ([e9ef6f6](https://github.com/folke/styler.nvim/commit/e9ef6f6966eebe5b97b8dedceb53d7ca00df65f6))
* unset eventignore with empty string instead of nil ([#11](https://github.com/folke/styler.nvim/issues/11)) ([e8c7360](https://github.com/folke/styler.nvim/commit/e8c736019e1ad3073638a43f50092716427b270a))

## 1.0.0 (2023-01-04)


### Features

* added Styler command to set a colorscheme for the current buffer ([b097163](https://github.com/folke/styler.nvim/commit/b097163c97d27fa15268b142461b21c3e71591c1))
* initial commit ([ec524aa](https://github.com/folke/styler.nvim/commit/ec524aa75bbc726c81c5580ded6cd7b716f1eacf))
* much better way of loading colorschemes, but only support those that use vim.api.nvim_set_hl ([0531487](https://github.com/folke/styler.nvim/commit/05314878f99b6a647fd5677b1573614cce4a3981))
* support lazy-loaded colorschemes ([ec3c4b0](https://github.com/folke/styler.nvim/commit/ec3c4b007df7304cfa9e70585040884e179ca1b0))


### Bug Fixes

* save current theme highlights to fix weirdness with cleared hl groups ([fea5cef](https://github.com/folke/styler.nvim/commit/fea5cef7da4189db6ee1631738b54504e4a39238))
* update current defs where needed ([d4d0cdc](https://github.com/folke/styler.nvim/commit/d4d0cdc4fbd09b2980b840af4927ec32faebc861))
* use main style for cleared highlights ([312c3cb](https://github.com/folke/styler.nvim/commit/312c3cb050100a51ecfc85b8860bc1a760cd6d0c))
* work-around for nvim__get_hl_defs weirdness with links and empty treesitter groups ([ce5f859](https://github.com/folke/styler.nvim/commit/ce5f859a18f1b9af93e5d79f7ab762684aee700f))
