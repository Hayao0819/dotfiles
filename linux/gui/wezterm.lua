-- WezTerm APIを取得
local wezterm = require 'wezterm'
local config = {}
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- This is where you actually apply your config choices
config.enable_scroll_bar = true
config.automatically_reload_config = false
config.color_scheme = 'iceberg-dark'
config.font = wezterm.font('SauceCodePro Nerd Font', {weight="Regular", stretch="Normal", italic=false})
config.font_size = 9.0

-- configをWeztermに返す
return config
