local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Shell
config.default_prog = { "pwsh" }


-- Font
config.font = wezterm.font("JetBrainsMonoNL Nerd Font Propo", { weight = "DemiBold" })
config.font_size = 16
config.freetype_load_target = "HorizontalLcd"
config.freetype_render_target = "HorizontalLcd"
config.harfbuzz_features = { "calt=0" }

-- Window
config.color_scheme = "rose-pine"
config.window_background_opacity = 0
config.win32_system_backdrop = "Mica"
config.window_padding = {
  left = 18,
  right = 15,
  top = 20,
  bottom = 5,
}
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.scrollback_lines = 20000

-- Performance
config.max_fps = 120
config.animation_fps = 120

-- Tabs
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 25

-- Misc
config.automatically_reload_config = true
config.audible_bell = "Disabled"

-- Cursor
config.default_cursor_style = "SteadyBlock"

return config
