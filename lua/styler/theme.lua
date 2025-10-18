---@class ThemeLoader
---@field ns number
---@field theme Theme
---@field orig Theme
---@field set_hl fun(ns:number, group:string, hl:table)
---@field has_hl boolean
local M = {}

---@return Theme
function M.get_current()
  return {
    colorscheme = vim.g.colors_name,
    background = vim.go.background,
  }
end

---@param theme Theme
function M.load(theme)
  local ns_name = table.concat({ "styler_", theme.colorscheme, theme.background or "" }, "_")
  local create = not vim.api.nvim_get_namespaces()[ns_name]
  local ns = vim.api.nvim_create_namespace(ns_name)

  if create then
    local self = setmetatable({}, { __index = M })
    self.ns = ns
    self.orig = M.get_current()
    self.theme = theme
    self:before()
    vim.api.nvim_exec_autocmds("ColorSchemePre", { pattern = self.theme.colorscheme })
    vim.cmd("colorscheme " .. self.theme.colorscheme)
    vim.api.nvim_exec_autocmds("ColorScheme", { pattern = self.theme.colorscheme })
    self:after()
  end
  return ns
end

function M:before()
  pcall(function()
    require("lazy.core.loader").colorscheme(self.theme.colorscheme)
  end)
  self.last_eventignore = vim.go.eventignore
  -- don't trigger autocmds
  if vim.fn.has('nvim-0.12') == 1 then
    vim.go.eventignore = "all,-ColorSchemePre,-ColorScheme"
  else
    vim.go.eventignore = "all"
  end

  -- set to nil, so most themes won't run `hi clear` to prevent flickering
  vim.g.colors_name = nil

  -- override nvim_set_hl to use the namespace instead
  self.set_hl = vim.api.nvim_set_hl
  vim.api.nvim_set_hl = function(_, group, hl)
    self.has_hl = true
    self.set_hl(self.ns, group, hl)
  end

  -- set theme background
  if self.theme.background and vim.go.background ~= self.theme.background then
    vim.go.background = self.theme.background
  end
end

function M:after()
  -- check for unsupported themes
  if not self.has_hl then
    vim.notify(
      "Colorscheme "
        .. self.theme.colorscheme
        .. " is not supported. Styler only works with colorschemes that use vim.api.nvim_set_hl",
      vim.log.levels.ERROR,
      { title = "styler.nvim" }
    )
  else
    -- set to nil, so most themes won't run `hi clear` to prevent flickering
    vim.g.colors_name = nil
  end

  -- restore nvim_set_hl
  vim.api.nvim_set_hl = self.set_hl

  -- restore background
  if self.orig.background ~= vim.go.background then
    vim.go.background = self.orig.background
  end

  -- enable autocmds
  vim.go.eventignore = self.last_eventignore

  -- schedule theme reload
  vim.schedule(function()
    if self.orig.colorscheme then
      vim.cmd("colorscheme " .. self.orig.colorscheme)
    end
  end)
end

return M
