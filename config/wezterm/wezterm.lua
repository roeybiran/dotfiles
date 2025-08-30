local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_cursor_style = 'SteadyBar'
config.show_close_tab_button_in_tabs = false
config.show_new_tab_button_in_tab_bar = false
config.show_tab_index_in_tab_bar = false
config.audible_bell = 'Disabled'
config.window_close_confirmation = 'NeverPrompt'


-- https://wezterm.org/config/lua/wezterm.gui/get_appearance.html
-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
local function get_appearance()
    if wezterm.gui then
        return wezterm.gui.get_appearance()
    end
    return 'Dark'
end

wezterm.on('bell', function(window, pane)
    window:toast_notification("WezTerm", "Bell rang!", nil, 4000)
end)

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.

local function basename(s)
    return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

local function replace_home_with_tilde(path)
    local home = os.getenv("HOME")
    if home and path:sub(1, #home) == home then
        return "~" .. path:sub(#home + 1)
    end
    return path
end

local function tab_title(tab)
    local title = tab.tab_title
    -- if the tab title is explicitly set, take that
    if title and #title > 0 then
        return title
    end
    -- Otherwise, use the title from the active pane
    -- in that tab
    local pane_info = tab.active_pane;
    local cwd = pane_info.current_working_dir.file_path
    local proc = pane_info.foreground_process_name or ''
    return cwd and replace_home_with_tilde(cwd) .. ' — ' .. basename(proc) or basename(proc)
end

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
    return tab_title(tab)
end)

wezterm.on(
    'format-tab-title',
    function(tab, tabs, panes, config, hover, max_width)
        local title = tab_title(tab)
        return title
    end
)

local function scheme_for_appearance(appearance)
    if appearance:find 'Dark' then
        return 'Builtin Solarized Dark'
    else
        return 'Builtin Solarized Light'
    end
end

config.color_scheme = scheme_for_appearance(get_appearance())

config.keys = {
    {
        key = 'g',
        mods = 'ALT',
        action = wezterm.action.PaneSelect,
    },
    {
        key = 'Enter',
        mods = 'ALT',
        action = 'DisableDefaultAssignment',
    },
    {
        key = 'f',
        mods = 'ALT',
        action = wezterm.action.QuickSelect,
    },
    {
        key = 'c',
        mods = 'ALT',
        action = wezterm.action.ActivateCopyMode,
    },
    {
        key = 'd',
        mods = 'SUPER',
        action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
        key = 'D',
        mods = 'SUPER|SHIFT',
        action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
        key = ']',
        mods = 'SUPER',
        action = wezterm.action.ActivatePaneDirection 'Next',
    },
    {
        key = '[',
        mods = 'SUPER',
        action = wezterm.action.ActivatePaneDirection 'Prev',
    },
    {
        key = 'w',
        mods = 'SUPER',
        action = wezterm.action.CloseCurrentPane { confirm = false },
    },
    {
        key = 'k',
        mods = 'SUPER',
        action = wezterm.action.ClearScrollback 'ScrollbackAndViewport',
    },
    -- {
    --     key = 'd',
    --     mods = 'SUPER|SHIFT|ALT|CTRL',
    --     action = wezterm.action.ActivateCommandPalette,
    -- },
}

return config
