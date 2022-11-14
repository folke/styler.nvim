local M = {}

---@type table<string, Theme>
M.themes = {}

---@alias Theme {colorscheme: string, background?: "light"|"dark"}
---@alias ThemeOptions {sync?:boolean}

---@param win window window id or 0 for the current window
---@param theme Theme
---@param opts? ThemeOptions
function M.set_theme(win, theme, opts)
	opts = opts or {}
	win = win == 0 and vim.api.nvim_get_current_win() or win

	vim.w[win].theme = theme
	vim.api.nvim_win_set_hl_ns(win, M.load(theme, { sync = opts.sync }))
end

---@param theme Theme
---@param opts? {sync?: boolean}
function M.load(theme, opts)
	opts = opts or {}
	local ns_name = table.concat({ "win_theme", theme.colorscheme, theme.background or "" }, "_")
	local create = not vim.api.nvim_get_namespaces()[ns_name]
	local ns = vim.api.nvim_create_namespace(ns_name)

	local function _load()
		local orig = {
			background = vim.go.background,
			colorscheme = vim.g.colors_name,
		}

		-- set background
		if theme.background and vim.go.background ~= theme.background then
			vim.go.background = theme.background
		end

		-- load the colorscheme
		vim.go.eventignore = "all"
		vim.cmd.colorscheme(theme.colorscheme)
		vim.go.eventignore = nil

		---@type table<string, table>
		---@diagnostic disable-next-line: assign-type-mismatch
		local defs = vim.api.nvim__get_hl_defs(0)
		for name, hl in pairs(defs) do
			if not hl[vim.type_idx] then
				vim.api.nvim_set_hl(ns, name, hl)
			end
		end

		if orig.background ~= vim.go.background then
			vim.go.background = orig.background
		end
		vim.cmd.colorscheme(orig.colorscheme)
	end

	if create then
		(opts.sync and _load or vim.schedule_wrap(_load))()
	end

	return ns
end

function M.clear(win)
	if vim.w[win].theme then
		vim.api.nvim_win_set_hl_ns(win, 0)
		vim.w[win].theme = nil
	end
end

---@param opts? {buf?: number}|ThemeOptions
function M.update(opts)
	opts = opts or {}

	if opts.buf then
		opts.buf = opts.buf == 0 and vim.api.nvim_get_current_buf() or opts.buf
	end

	local wins = vim.api.nvim_list_wins()
	for _, win in ipairs(wins) do
		local buf = vim.api.nvim_win_get_buf(win)
		if not (opts.buf and opts.buf ~= buf) then
			local ft = vim.bo[buf].filetype
			local theme = M.themes[ft]
			if theme then
				---@cast opts ThemeOptions
				M.set_theme(win, theme, opts)
			else
				M.clear(win)
			end
		end
	end
end

---@param opts {themes: table<string, Theme>}
function M.setup(opts)
	M.themes = opts.themes
	local group = vim.api.nvim_create_augroup("styler", { clear = true })

	vim.api.nvim_create_autocmd("OptionSet", {
		group = group,
		pattern = "winhighlight",
		callback = function(event)
			---@type number
			local buf = event.buf == 0 and vim.api.nvim_get_current_buf() or event.buf
			-- needs to be loaded twice, to prevent flickering
			-- due to the internal setting of winhighlight
			M.update({ buf = buf, force = true, sync = true })
			vim.schedule(function()
				M.update({ buf = buf, force = true, sync = true })
			end)
		end,
		nested = true,
	})

	vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
		group = group,
		callback = function(event)
			M.update({ buf = event.buf, sync = true })
		end,
		nested = true,
	})
	M.update()
end

return M
