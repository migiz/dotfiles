# WezTerm

Copy [.config/wezterm/wezterm.lua](.config/wezterm/wezterm.lua) to your WezTerm
configuration directory, then replace these placeholders before launching:

- `<DEFAULT_DOMAIN>`: your domain, such as `WSL:Ubuntu` or `local`.
- `<WALLPAPER_PATH>`: an absolute image path. Use forward slashes on Windows,
  such as `C:/Users/YOUR_USER/Pictures/wallpaper.jpg`.

The config preserves the Windows/WSL setup, including the Git Bash launcher,
PowerShell CPU/RAM queries, and the `tabline.wez` plugin. Adjust those sections
if using a different platform or Git installation path.

The `JetBrains NF Heavy Icons` font is installed by the
[Herdr font installer](../scripts/install-herdr-font.py); see the
[Herdr setup instructions](../herdr/README.md#jetbrains-font-installation).
