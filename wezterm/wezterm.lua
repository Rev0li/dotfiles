local wezterm = require 'wezterm'
local config  = wezterm.config_builder()
local act     = wezterm.action

-- ── Thème dynamique ─────────────────────────────────────────

local function read_theme()
  local f = io.open(wezterm.home_dir .. '/.config/theme', 'r')
  if f then
    local v = f:read('*l'); f:close()
    return v and v:match('^%s*(.-)%s*$') or 'dark'
  end
  return 'dark'
end

local THEMES = {
  dark  = { color_scheme = 'Tokyo Night',     cursor_bg = '#e0b3e5', cursor_fg = '#1a1b26', selection_bg = '#b297b9', selection_fg = '#ffffff', split = '#b297b9' },
  light = { color_scheme = 'Tokyo Night Day', cursor_bg = '#7c6f9f', cursor_fg = '#ffffff', selection_bg = '#7c6f9f', selection_fg = '#ffffff', split = '#7c6f9f' },
}

local theme = THEMES[read_theme()] or THEMES.dark
config.color_scheme = theme.color_scheme
config.colors = {
  cursor_bg     = theme.cursor_bg,
  cursor_border = theme.cursor_bg,
  cursor_fg     = theme.cursor_fg,
  selection_bg  = theme.selection_bg,
  selection_fg  = theme.selection_fg,
  split         = theme.split,
}

-- ── Police & fenêtre ────────────────────────────────────────

config.font           = wezterm.font('Monaspace Neon', { weight = 'Medium' })
config.font_size      = 13.0
config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }

config.enable_tab_bar             = true
config.use_fancy_tab_bar          = false
config.hide_tab_bar_if_only_one_tab = true
config.inactive_pane_hsb          = { saturation = 0.7, brightness = 0.6 }

-- ── Perf ────────────────────────────────────────────────────

config.max_fps           = 120
config.animation_fps     = 60
config.cursor_blink_rate = 500
config.audible_bell      = 'Disabled'
config.scrollback_lines  = 10000
config.default_prog      = { os.getenv('SHELL') or '/usr/bin/zsh' }

-- ── Status bar : COPY MODE indicator ────────────────────────

config.status_update_interval = 100

wezterm.on('update-right-status', function(window, _)
  if window:active_key_table() == 'copy_mode' then
    window:set_right_status(wezterm.format {
      { Background = { Color = '#cba6f7' } },
      { Foreground = { Color = '#1a1b26' } },
      { Attribute  = { Intensity = 'Bold' } },
      { Text = ' COPY ' },
      'ResetAttributes',
    })
  else
    window:set_right_status ''
  end
end)

-- ── Raccourcis ───────────────────────────────────────────────

config.keys = {
  -- Splits
  { key = 'c', mods = 'ALT', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },
  { key = 'v', mods = 'ALT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },

  -- Navigation panes
  { key = 'LeftArrow',  mods = 'CTRL', action = act.ActivatePaneDirection 'Left'  },
  { key = 'RightArrow', mods = 'CTRL', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'CTRL', action = act.ActivatePaneDirection 'Up'    },
  { key = 'DownArrow',  mods = 'CTRL', action = act.ActivatePaneDirection 'Down'  },

  -- Resize panes
  { key = 'LeftArrow',  mods = 'SHIFT|ALT', action = act.AdjustPaneSize { 'Left',  5 } },
  { key = 'RightArrow', mods = 'SHIFT|ALT', action = act.AdjustPaneSize { 'Right', 5 } },
  { key = 'UpArrow',    mods = 'SHIFT|ALT', action = act.AdjustPaneSize { 'Up',    5 } },
  { key = 'DownArrow',  mods = 'SHIFT|ALT', action = act.AdjustPaneSize { 'Down',  5 } },

  -- Tabs
  { key = 'e', mods = 'SUPER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'SUPER', action = act.CloseCurrentPane { confirm = true } },
  { key = 'r', mods = 'SUPER', action = act.PromptInputLine {
      description = 'Rename tab',
      action = wezterm.action_callback(function(window, _, line)
        if line then window:active_tab():set_title(line) end
      end),
  }},
}

return config
