local M = {}

---@type table<string, Theme>
M.themes = {}
---@type ThemeHighlights?
M.current = nil

---@alias Theme {colorscheme: string, background?: "light"|"dark"}
---@alias ThemeOptions {sync?:boolean}
---@alias ThemeHighlights table<string, table>

---@param win window window id or 0 for the current window
---@param theme Theme
---@param opts? ThemeOptions
function M.set_theme(win, theme, opts)
	opts = opts or {}
	win = win == 0 and vim.api.nvim_get_current_win() or win

	vim.w[win].theme = theme
	opts.sync = true
	vim.api.nvim_win_set_hl_ns(win, M.load(theme))
end

function M.get_hl_defs()
	local hi = vim.api.nvim_exec("hi", true)
	hi = hi:gsub("\n%s*links to", " links to")
	local lines = vim.split(hi, "\n")
	---@type table<string,string>
	local links = {}
	---@type table<string,boolean>
	local groups = {}
	for _, line in ipairs(lines) do
		local group = line:match("(%S+)%s+xxx")
		if group then
			groups[group] = true
			local link = line:match("%S+.*links to (%S+)")
			if link then
				links[group] = link
			end
		end
	end
	---@type ThemeHighlights
	local ret = {}
	---@type ThemeHighlights
	---@diagnostic disable-next-line: assign-type-mismatch
	local defs = vim.api.nvim__get_hl_defs(0)
	for group, hl in pairs(defs) do
		if groups[group] then
			if links[group] then
				hl = { link = links[group] }
			end
			---@diagnostic disable-next-line: no-unknown
			hl[vim.type_idx] = nil
			ret[group] = hl
		end
	end
	return ret
end

---@param theme Theme
function M.load(theme)
	local ns_name = table.concat({ "win_theme", theme.colorscheme, theme.background or "" }, "_")
	local create = not vim.api.nvim_get_namespaces()[ns_name]
	local ns = vim.api.nvim_create_namespace(ns_name)

	if create then
		M.current = M.current or M.get_hl_defs()
		-- d("loading", theme)
		local orig = {
			background = vim.go.background,
			colorscheme = vim.g.colors_name,
			defs = M.current,
			---@type table<string, string>
			terminal = {},
		}

		for i = 0, 15 do
			local key = "terminal_color_" .. i
			orig.terminal[key] = vim.g[key]
		end

		-- load the colorscheme
		vim.go.eventignore = "all"

		-- set background
		if theme.background and vim.go.background ~= theme.background then
			vim.go.background = theme.background
		end

		vim.cmd.colorscheme(theme.colorscheme)
		local defs = M.get_hl_defs()

		if orig.background ~= vim.go.background then
			vim.go.background = orig.background
		end

		vim.cmd([[hi clear]])
		M.set_hl_defs(0, orig.defs)
		M.set_hl_defs(ns, defs, orig.defs)

		for k, v in pairs(orig.terminal) do
			vim.g[k] = v
		end

		vim.g.colors_name = orig.colorscheme
		vim.go.eventignore = nil
	end

	return ns
end

---@param defs ThemeHighlights
function M.set_hl_defs(ns, defs, main)
	for group, hl in pairs(defs) do
		if not (main and vim.tbl_isempty(hl) and main[group]) then
			vim.api.nvim_set_hl(ns, group, hl)
		end
	end
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

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = function()
			M.current = nil
		end,
	})
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
	})

	vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
		group = group,
		callback = function(event)
			M.update({ buf = event.buf, sync = true })
		end,
	})
	M.update()
end

return M
