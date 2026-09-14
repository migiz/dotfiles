local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- --------------------------------------------------------------------
-- CONFIGURATION
-- --------------------------------------------------------------------

config.enable_kitty_graphics = true
config.automatically_reload_config = true

config.default_domain = "<DEFAULT_DOMAIN>"

-- Fonts & Color scheme
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("JetBrains NF Heavy Icons")
config.font_rules = {
	{ intensity = "Half", italic = false, font = wezterm.font("JetBrains NF Heavy Icons", { weight = "Regular" }) },
	{
		intensity = "Half",
		italic = true,
		font = wezterm.font("JetBrains NF Heavy Icons", { weight = "Regular", italic = true }),
	},
}
config.font_size = 12.0

-- Window
config.window_decorations = "TITLE|RESIZE"
config.window_padding = { left = 2, right = 2, top = 2, bottom = 2 }
config.adjust_window_size_when_changing_font_size = false
config.window_close_confirmation = "NeverPrompt"

-- UI
config.enable_scroll_bar = false
config.animation_fps = 240
config.max_fps = 240
config.default_cursor_style = "BlinkingBar"
config.status_update_interval = 1000
config.pane_focus_follows_mouse = false
config.scrollback_lines = 10000
config.warn_about_missing_glyphs = false

-- Tab bar
config.tab_bar_at_bottom = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_max_width = 40
config.show_tab_index_in_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true

config.launch_menu = {
	{
		label = "Git Bash",
		domain = { DomainName = "local" },
		args = { "C:/Program Files/Git/bin/bash.exe", "--login", "-i" },
	},
}

config.leader = { key = "Space", mods = "CTRL|SHIFT", timeout_milliseconds = 2000 }

config.keys = {
	{ key = "v", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },
	{
		key = "t",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({ flags = "LAUNCH_MENU_ITEMS|DOMAINS" }),
	},
}

-- Ctrl-click opens links in ordinary tabs; Herdr handles its captured clicks.
config.mouse_bindings = {
	{ event = { Down = { streak = 1, button = "Left" } }, mods = "CTRL", action = wezterm.action.Nop },
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

config.background = {
	{
		source = { Color = "#1e1e2e" },
		height = "100%",
		width = "100%",
	},
	{
		source = { File = "<WALLPAPER_PATH>" },
		horizontal_align = "Center",
		vertical_align = "Middle",
		width = "Cover",
		height = "Cover",
		repeat_x = "NoRepeat",
		repeat_y = "NoRepeat",
		opacity = 0.1,
	},
}

local nf = wezterm.nerdfonts
local profiles = {}
local function basename(value)
	return (value or ""):gsub("\\", "/"):match("([^/]+)$") or ""
end

local function pane_profile(id, domain, process)
	if domain:match("^WSL:") then
		return { icon = domain:lower():find("ubuntu", 1, true) and nf.linux_ubuntu or nf.md_console, name = domain }
	elseif domain ~= "local" then
		return { icon = nf.md_console, name = domain }
	end
	local shell = basename(process):lower()
	if shell == "bash.exe" then
		profiles[id] = { icon = nf.dev_git, name = "Git Bash" }
	elseif shell == "pwsh.exe" or shell == "powershell.exe" then
		profiles[id] = { icon = nf.md_powershell, name = shell == "pwsh.exe" and "PowerShell 7" or "PowerShell" }
	elseif shell == "cmd.exe" then
		profiles[id] = { icon = nf.md_microsoft_windows, name = "CMD" }
	end
	return profiles[id] or { icon = nf.md_microsoft_windows, name = "Windows" }
end

local function tab_label(tab)
	local pane = tab.active_pane
	local profile = pane_profile(pane.pane_id, pane.domain_name, pane.foreground_process_name)
	local program = (pane.user_vars or {}).WEZTERM_PROG
	local process = basename(pane.foreground_process_name):gsub("%.exe$", "")
	local title
	if pane.domain_name:match("^WSL:") then
		title = program or pane.title
	else
		title = process ~= "" and process or profile.name
	end
	if title == "fish" or title == "bash" or title == "pwsh" or title == "powershell" then
		local cwd = pane.current_working_dir
		title = title .. (cwd and (" · " .. basename(cwd.file_path)) or "")
	end
	return " " .. profile.icon .. " " .. (tab.tab_index + 1) .. " · " .. wezterm.truncate_right(title, 30) .. " "
end

local function environment_label(window)
	local pane = window:active_pane()
	local domain = pane:get_domain_name()
	local profile = pane_profile(pane:pane_id(), domain, pane:get_foreground_process_name())
	local label = profile.icon .. " " .. profile.name
	if domain == "local" and profile.name ~= "Windows" then
		label = nf.md_microsoft_windows .. " " .. label
	end
	return " " .. label .. " "
end

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
	options = {
		theme = "Catppuccin Mocha",
		theme_overrides = {
			normal_mode = {
				a = { fg = "#1e1e2e", bg = "#89b4fa" },
				b = { fg = "#cdd6f4", bg = "#45475a" },
				c = { fg = "#cdd6f4", bg = "#1e1e2e" },
			},
			tab = {
				active = { fg = "#1e1e2e", bg = "#89b4fa" },
				inactive = { fg = "#bac2de", bg = "#313244" },
				inactive_hover = { fg = "#cdd6f4", bg = "#45475a" },
			},
		},
	},
	sections = {
		tabline_a = {},
		tabline_b = {},
		tabline_c = {},
		tab_active = { tab_label },
		tab_inactive = { tab_label },
		tabline_x = {
			{ "cpu", use_pwsh = true, throttle = 3, icon = nf.oct_cpu },
			{
				"ram",
				use_pwsh = true,
				throttle = 3,
				icon = nf.md_memory,
				fmt = function(value)
					return (value:gsub(" GB", " GiB free"))
				end,
			},
		},
		tabline_y = {
			function()
				return " " .. nf.md_clock_outline .. " " .. wezterm.strftime("%H:%M") .. " "
			end,
		},
		tabline_z = { environment_label },
	},
})
config.colors = { tab_bar = { background = "#1e1e2e" } }

return config
