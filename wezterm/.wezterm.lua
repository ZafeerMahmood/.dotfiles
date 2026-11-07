local wezterm = require("wezterm")
local config = wezterm.config_builder()
local leader_prefix = utf8.char(0x1f30a) -- ocean wave emoji

-- Shell
config.default_prog = { "pwsh" }


-- Font
config.font = wezterm.font("JetBrainsMonoNL Nerd Font Propo", { weight = "Regular" })
config.font_size = 16
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"
config.harfbuzz_features = { "calt=0" }

-- Window
config.color_scheme = "Catppuccin Mocha"
config.window_padding = {
  left = 25,
  right = 25,
  top = 20,
  bottom = 5,
}
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.scrollback_lines = 20000

-- Performance
config.max_fps = 240
config.animation_fps = 240
config.front_end = "WebGpu"

--[[
============================
Catppuccin Mocha Colors
============================
]]--

local mocha = {
    rosewater = "#f5e0dc",
    flamingo = "#f2cdcd",
    pink = "#f5c2e7",
    mauve = "#cba6f7",
    red = "#f38ba8",
    maroon = "#eba0ac",
    peach = "#fab387",
    yellow = "#f9e2af",
    green = "#a6e3a1",
    teal = "#94e2d5",
    sky = "#89dceb",
    sapphire = "#74c7ec",
    blue = "#89b4fa",
    lavender = "#b4befe",
    text = "#cdd6f4",
    subtext1 = "#bac2de",
    subtext0 = "#a6adc8",
    overlay2 = "#9399b2",
    overlay1 = "#7f849c",
    overlay0 = "#6c7086",
    surface2 = "#585b70",
    surface1 = "#45475a",
    surface0 = "#313244",
    base = "#1e1e2e",
    mantle = "#181825",
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

--[[
============================
Keybindings
============================
]]--

-- Leader key
config.leader = { key = "q", mods = "ALT", timeout_milliseconds = 2000 }

config.keys = {
    -- Direct combos (Windows Terminal feel)
    {
        mods = "CTRL",
        key = "t",
        action = wezterm.action.SpawnTab("CurrentPaneDomain"),
    },
    {
        mods = "CTRL",
        key = "w",
        action = wezterm.action.CloseCurrentPane({ confirm = true }),
    },
    {
        mods = "CTRL|ALT",
        key = "LeftArrow",
        action = wezterm.action.ActivatePaneDirection("Left"),
    },
    {
        mods = "CTRL|ALT",
        key = "RightArrow",
        action = wezterm.action.ActivatePaneDirection("Right"),
    },
    {
        mods = "CTRL|ALT",
        key = "UpArrow",
        action = wezterm.action.ActivatePaneDirection("Up"),
    },
    {
        mods = "CTRL|ALT",
        key = "DownArrow",
        action = wezterm.action.ActivatePaneDirection("Down"),
    },
    {
        mods = "ALT|SHIFT",
        key = "d",
        action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },
    {
        mods = "CTRL|SHIFT",
        key = "-",
        action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
    },
    {
        mods = "CTRL|SHIFT",
        key = "f",
        action = wezterm.action.Search("CurrentSelectionOrEmptyString"),
    },

    -- Leader combos (tmux/vim feel)
    {
        mods = "LEADER",
        key = "c",
        action = wezterm.action.SpawnTab("CurrentPaneDomain"),
    },
    {
        mods = "LEADER",
        key = "x",
        action = wezterm.action.CloseCurrentPane({ confirm = true }),
    },
    {
        mods = "LEADER",
        key = "b",
        action = wezterm.action.ActivateTabRelative(-1),
    },
    {
        mods = "LEADER",
        key = "n",
        action = wezterm.action.ActivateTabRelative(1),
    },
    {
        mods = "LEADER",
        key = "|",
        action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },
    {
        mods = "LEADER",
        key = "-",
        action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
    },
    {
        mods = "LEADER",
        key = "h",
        action = wezterm.action.ActivatePaneDirection("Left"),
    },
    {
        mods = "LEADER",
        key = "j",
        action = wezterm.action.ActivatePaneDirection("Down"),
    },
    {
        mods = "LEADER",
        key = "k",
        action = wezterm.action.ActivatePaneDirection("Up"),
    },
    {
        mods = "LEADER",
        key = "l",
        action = wezterm.action.ActivatePaneDirection("Right"),
    },
    {
        mods = "LEADER",
        key = "LeftArrow",
        action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
    },
    {
        mods = "LEADER",
        key = "RightArrow",
        action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
    },
    {
        mods = "LEADER",
        key = "DownArrow",
        action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
    },
    {
        mods = "LEADER",
        key = "UpArrow",
        action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
    },
}

-- Leader + number to switch tabs
for i = 0, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "LEADER",
        action = wezterm.action.ActivateTab(i),
    })
end

--[[
============================
Tab Bar Formatting
============================
]]--

local function tab_title(tab_info)
    local title = tab_info.tab_title
    if title and #title > 0 then
        return title
    end
    return tab_info.active_pane.title
end

wezterm.on(
    "format-tab-title",
    function(tab, tabs, panes, config, hover, max_width)
        local title = " " .. tab.tab_index .. ": " .. tab_title(tab) .. " "

        if tab.is_active then
            return {
                { Background = { Color = colors.tab_bar_active_tab_fg } },
                { Foreground = { Color = colors.tab_bar_text } },
                { Text = title },
            }
        end
    end
)

--[[
============================
Leader Active Indicator
============================
]]--

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

-- Misc
config.automatically_reload_config = true
config.audible_bell = "Disabled"

-- Cursor
config.default_cursor_style = "SteadyBlock"

return config
