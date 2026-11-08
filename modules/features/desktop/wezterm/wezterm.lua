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
config.hide_tab_bar_if_only_one_tab = true
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

-- Modern Pill / Capsule Tab Formatting
wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, hover, max_width)
  local bar_bg = '#060405'
  local bg = '#181825'
  local fg = '#a6adc8'

  if tab.is_active then
    bg = '#313244'
    fg = '#cdd6f4'
  elseif hover then
    bg = '#45475a'
    fg = '#cdd6f4'
  end

  local title = tab.tab_title
  if not title or #title == 0 then
    title = tab.active_pane.title
  end

  local index = tab.tab_index + 1
  local prefix = ' ' .. index .. ': '
  local available_len = max_width - #prefix - 2
  if available_len > 0 and #title > available_len then
    title = wezterm.truncate_right(title, available_len)
  end
  title = prefix .. title .. ' '

  return {
    { Background = { Color = bar_bg } },
    { Foreground = { Color = bg } },
    { Text = wezterm.nerdfonts.ple_left_half_circle_thick }, -- 
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } },
    { Text = title },
    { Background = { Color = bar_bg } },
    { Foreground = { Color = bg } },
    { Text = wezterm.nerdfonts.ple_right_half_circle_thick }, -- 
    { Background = { Color = bar_bg } },
    { Text = ' ' },
  }
end)

-- Hyperlink rules: preserve defaults and match file paths with optional line/col/range
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Match paths containing directory separators (e.g. ~/.config/mimeapps.list:29-71, ~/foo.rs, /etc/hosts, ./flake.nix)
table.insert(config.hyperlink_rules, {
  regex = [=[(?:^|(?<=[\s"`'\(\[{<:=]))((?:~|\.\.?)?[/\w.-]+/[/\w.-]+(?::\d+(?:[:\-]\d+)?)?)(?=[\s"`'\)\]}>:;,\.]|$)]=],
  format = 'file://$1',
})

-- Match bare filenames with line numbers or ranges (e.g. main.rs:14:2 or default.nix:29-71)
table.insert(config.hyperlink_rules, {
  regex = [=[(?:^|(?<=[\s"`'\(\[{<:=]))([\w.-]+\.[a-zA-Z0-9]+:\d+(?:[:\-]\d+)?)(?=[\s"`'\)\]}>:;,\.]|$)]=],
  format = 'file://$1',
})

-- Open file URIs directly in Zed (preserves :line:col navigation and pane CWD)
wezterm.on('open-uri', function(_window, pane, uri)
  local url = wezterm.url.parse(uri)
  if url and url.scheme == 'file' then
    local path = url.file_path
    local line = nil
    local col = nil

    -- Handle tilde path when parsed as host (e.g. file://~/.config/...)
    if url.host == '~' then
      path = '~' .. path
    end

    -- Extract line/column number or range from path if present (e.g. file.rs:10:5 or file.rs:29-71)
    local p_col, l_col, c_col = path:match('^(.-):(%d+):(%d+)$')
    if p_col then
      path = p_col
      line = l_col
      col = c_col
    else
      local p_range, l_range = path:match('^(.-):(%d+)(?:%-(%d+))?$')
      if p_range then
        path = p_range
        line = l_range
      end
    end

    -- If no line extracted from path, check fragment (e.g. #L29-L71, #L29, #29, #29:10)
    if not line and url.fragment and url.fragment ~= '' then
      local frag = url.fragment:gsub('^L', '')
      local fl, fc = frag:match('^(%d+):(%d+)$')
      if fl then
        line = fl
        col = fc
      else
        local fl_range = frag:match('^(%d+)')
        if fl_range then
          line = fl_range
        end
      end
    end

    -- Expand tilde ~ to user's home directory
    if path:match('^~') then
      local home = os.getenv('HOME') or wezterm.home_dir
      if home then
        path = path:gsub('^~', home)
      end
    end

    -- Resolve relative paths against active pane's working directory
    if not path:match('^/') and pane then
      local cwd = pane:get_current_working_dir()
      if cwd and cwd.file_path then
        path = cwd.file_path .. '/' .. path
      end
    end

    -- Construct target for Zed: Zed only accepts path:line or path:line:col
    local target = path
    if line then
      target = target .. ':' .. line
      if col then
        target = target .. ':' .. col
      end
    end

    wezterm.background_child_process({ 'zeditor', target })
    return false
  end
end)

return config
