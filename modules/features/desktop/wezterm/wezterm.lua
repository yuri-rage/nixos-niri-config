local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Wayland & Rendering
config.enable_wayland = true
config.window_decorations = 'RESIZE'

-- Fonts
config.font = wezterm.font_with_fallback({
  { family = 'FiraCode Nerd Font' },
  { family = 'MesloLGS Nerd Font', italic = true },
})
config.font_size = 10.0
config.line_height = 1.0

-- Geometry & Padding (matches foot pad=3x5)
config.window_padding = {
  left = 3,
  right = 3,
  top = 5,
  bottom = 5,
}

-- Opacity (matches foot alpha=0.875)
config.window_background_opacity = 0.875

-- Tab interface (tiled windows display tabs)
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_max_width = 32

-- Scrollback & Mouse
config.scrollback_lines = 10000

-- Colors (Catppuccin Mocha palette with custom #060405 background)
config.colors = {
  foreground = '#cdd6f4',
  background = '#060405',
  cursor_bg = '#f5e0dc',
  cursor_fg = '#11111b',
  cursor_border = '#f5e0dc',
  selection_fg = '#cdd6f4',
  selection_bg = '#414356',

  ansi = {
    '#45475a',
    '#f38ba8',
    '#a6e3a1',
    '#f9e2af',
    '#89b4fa',
    '#f5c2e7',
    '#94e2d5',
    '#bac2de',
  },
  brights = {
    '#585b70',
    '#f38ba8',
    '#a6e3a1',
    '#f9e2af',
    '#89b4fa',
    '#f5c2e7',
    '#94e2d5',
    '#a6adc8',
  },
  indexed = {
    [16] = '#fab387',
    [17] = '#f5e0dc',
  },
  tab_bar = {
    background = '#060405',
    active_tab = {
      bg_color = '#313244',
      fg_color = '#cdd6f4',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#181825',
      fg_color = '#a6adc8',
    },
    inactive_tab_hover = {
      bg_color = '#45475a',
      fg_color = '#cdd6f4',
    },
    new_tab = {
      bg_color = '#11111b',
      fg_color = '#a6adc8',
    },
    new_tab_hover = {
      bg_color = '#45475a',
      fg_color = '#cdd6f4',
    },
  },
}

-- Ensure scratchpad / spotify instances hide tabs
wezterm.on('window-config-reloaded', function(window, _pane)
  local overrides = window:get_config_overrides() or {}
  local ws = window:active_workspace()
  if ws == 'floating' or ws == 'spotify' then
    overrides.enable_tab_bar = false
    window:set_config_overrides(overrides)
  end
end)

return config
