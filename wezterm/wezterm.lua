local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Mocha"
config.font_size = 11

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

return config
