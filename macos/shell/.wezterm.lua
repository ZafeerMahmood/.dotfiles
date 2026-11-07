-- macOS port of ~/.dotfiles/wezterm/.wezterm.lua, tuned to match the Windows Terminal PowerShell profile
-- Linked to ~/.wezterm.lua by install.sh
local wezterm = require("wezterm")
local action = wezterm.action
local config = wezterm.config_builder()
local leader_prefix = utf8.char(0x1f30a) -- ocean wave emoji

-- Shell: pwsh like Windows Terminal, falls back to the login shell (zsh) if pwsh is missing
for _, pwsh_path in ipairs({ "/opt/homebrew/bin/pwsh", "/usr/local/bin/pwsh" }) do
    if wezterm.glob(pwsh_path)[1] then
        config.default_prog = { pwsh_path, "-Login" }
        break
    end
end

-- Font (Windows Terminal: JetBrainsMonoNL Nerd Font Propo, semi-bold, 16)
-- NOTE: macOS renders points larger than Windows at 100% scaling, drop to 14-15 if it feels big
config.font = wezterm.font("JetBrainsMonoNL Nerd Font Propo", { weight = "DemiBold" })
config.font_size = 16
config.harfbuzz_features = { "calt=0" }

-- Window (Windows Terminal: 195x47, padding 10, opacity 85 with acrylic)
config.color_scheme = "Catppuccin Mocha"
config.initial_cols = 195
config.initial_rows = 47
config.window_padding = {
    left = 10,
    right = 10,
    top = 10,
    bottom = 10,
}
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.scrollback_lines = 20000
config.native_macos_fullscreen_mode = false

-- Left Option acts as Alt so PSReadLine/zsh Alt bindings and the Alt+q leader work
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

-- Performance
config.max_fps = 120
config.animation_fps = 120
config.front_end = "WebGpu"

-- Cursor (Windows Terminal: filledBox, #F9E2AF)
config.default_cursor_style = "SteadyBlock"
config.colors = {
    cursor_bg = "#f9e2af",
    cursor_border = "#f9e2af",
    cursor_fg = "#1e1e2e",
}

local mocha = {
    mauve = "#cba6f7",
    lavender = "#b4befe",
    crust = "#11111b",
}

local colors = {
    tab_bar_active_tab_fg = mocha.mauve,
    tab_bar_active_tab_bg = mocha.crust,
    tab_bar_text = mocha.crust,
    arrow_foreground_leader = mocha.lavender,
    arrow_background_leader = mocha.crust,
}

-- Tabs
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.tab_and_split_indices_are_zero_based = true

-- Keys: Windows Terminal Ctrl combos mapped to Cmd. Ctrl stays free for the shell (Ctrl+c, Ctrl+w, Ctrl+t).
config.leader = { key = "q", mods = "ALT", timeout_milliseconds = 2000 }

config.keys = {
    { mods = "CMD", key = "t", action = action.SpawnTab("CurrentPaneDomain") },
    { mods = "CMD", key = "w", action = action.CloseCurrentPane({ confirm = true }) },
    { mods = "CMD", key = "c", action = action.CopyTo("Clipboard") },
    { mods = "CMD", key = "v", action = action.PasteFrom("Clipboard") },
    { mods = "CMD|SHIFT", key = "p", action = action.ActivateCommandPalette },
    { mods = "CMD|SHIFT", key = "f", action = action.Search("CurrentSelectionOrEmptyString") },
    { mods = "CMD|SHIFT", key = "d", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { mods = "CMD|SHIFT", key = "-", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { mods = "CMD|SHIFT", key = "_", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { mods = "CMD|ALT", key = "LeftArrow", action = action.ActivatePaneDirection("Left") },
    { mods = "CMD|ALT", key = "RightArrow", action = action.ActivatePaneDirection("Right") },
    { mods = "CMD|ALT", key = "UpArrow", action = action.ActivatePaneDirection("Up") },
    { mods = "CMD|ALT", key = "DownArrow", action = action.ActivatePaneDirection("Down") },
    { mods = "CMD|SHIFT", key = "Enter", action = action.TogglePaneZoomState },
    { mods = "CMD", key = ",", action = action.SpawnCommandInNewTab({ args = { "nvim", wezterm.config_file } }) },

    -- Shift+Enter sends a newline escape for Claude Code (same as the Windows Terminal sendInput action)
    { mods = "SHIFT", key = "Enter", action = action.SendString("\x1b[13;2u") },

    -- Leader combos (tmux/vim feel)
    { mods = "LEADER", key = "c", action = action.SpawnTab("CurrentPaneDomain") },
    { mods = "LEADER", key = "x", action = action.CloseCurrentPane({ confirm = true }) },
    { mods = "LEADER", key = "b", action = action.ActivateTabRelative(-1) },
    { mods = "LEADER", key = "n", action = action.ActivateTabRelative(1) },
    { mods = "LEADER|SHIFT", key = "|", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { mods = "LEADER", key = "-", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { mods = "LEADER", key = "h", action = action.ActivatePaneDirection("Left") },
    { mods = "LEADER", key = "j", action = action.ActivatePaneDirection("Down") },
    { mods = "LEADER", key = "k", action = action.ActivatePaneDirection("Up") },
    { mods = "LEADER", key = "l", action = action.ActivatePaneDirection("Right") },
    { mods = "LEADER", key = "LeftArrow", action = action.AdjustPaneSize({ "Left", 5 }) },
    { mods = "LEADER", key = "RightArrow", action = action.AdjustPaneSize({ "Right", 5 }) },
    { mods = "LEADER", key = "DownArrow", action = action.AdjustPaneSize({ "Down", 5 }) },
    { mods = "LEADER", key = "UpArrow", action = action.AdjustPaneSize({ "Up", 5 }) },
}

for tab_number = 0, 9 do
    table.insert(config.keys, {
        key = tostring(tab_number),
        mods = "LEADER",
        action = action.ActivateTab(tab_number),
    })
end

local function tab_title(tab_info)
    local title = tab_info.tab_title
    if title and #title > 0 then
        return title
    end
    return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, tab_config, hover, max_width)
    local title = " " .. tab.tab_index .. ": " .. tab_title(tab) .. " "

    if tab.is_active then
        return {
            { Background = { Color = colors.tab_bar_active_tab_fg } },
            { Foreground = { Color = colors.tab_bar_text } },
            { Text = title },
        }
    end
end)

-- Leader active indicator
wezterm.on("update-status", function(window, _)
    local solid_left_arrow = ""
    local arrow_foreground = { Foreground = { Color = colors.arrow_foreground_leader } }
    local arrow_background = { Background = { Color = colors.arrow_background_leader } }
    local prefix = ""

    if window:leader_is_active() then
        prefix = " " .. leader_prefix
        solid_left_arrow = wezterm.nerdfonts.pl_left_hard_divider

        local tabs = window:mux_window():tabs_with_info()
        for _, tab_info in ipairs(tabs) do
            if tab_info.is_active and tab_info.index == 0 then
                arrow_background = { Foreground = { Color = colors.tab_bar_active_tab_fg } }
                solid_left_arrow = wezterm.nerdfonts.pl_right_hard_divider
                break
            end
        end
    end

    window:set_left_status(wezterm.format({
        { Background = { Color = colors.arrow_foreground_leader } },
        { Text = prefix },
        arrow_foreground,
        arrow_background,
        { Text = solid_left_arrow },
    }))
end)

config.automatically_reload_config = true
config.audible_bell = "Disabled"

return config
