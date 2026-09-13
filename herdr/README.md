# Herdr

This package restores the Herdr settings and plugin versions on Linux/WSL and macOS.
From the repository root on a new machine:

```sh
bash scripts/setup-herdr.sh
```

Install Herdr 0.9.0 or newer, Git, Go 1.24 or newer, Python 3, and Yazi first.
On macOS, Git and Go builds also need the Xcode Command Line Tools.
Use a Nerd Font in the terminal for the configured icons. Network access to
GitHub and the Go module proxy is required.

The script copies the configs, backs up differing destination files, installs
plugins at pinned commits, and adds the Neovim navigation integration. It does
not use Stow. It detects the platform with `uname` and selects the paths below.
Review existing Neovim navigation mappings before running it on a configured
machine. The wrapper only loads the integration inside Herdr, preserving the
editor's existing navigation outside Herdr.

## Config locations

- Herdr and Nerd Font Tab Name: `~/.config/herdr/` on both platforms.
- Neovim integration: `~/.config/nvim/after/plugin/` on both platforms.
- Auto Title on Linux/WSL: `~/.config/herdr-auto-title/config.env`.
- Auto Title on macOS: `~/Library/Application Support/herdr-auto-title/config.env`.

`XDG_CONFIG_HOME` replaces `~/.config` when set. Auto Title on macOS always
uses `~/Library/Application Support`, even when `XDG_CONFIG_HOME` is set,
because the plugin resolves its path with Go's `os.UserConfigDir`.

Auto Title builds live in `~/.local/share/herdr-dotfiles` on Linux/WSL and
`~/Library/Application Support/herdr-dotfiles` on macOS. `XDG_DATA_HOME`
overrides the parent directory on either platform. Paths containing spaces
are supported. Native Windows is not supported by the script.

## Plugins

- **Auto Title** (`kryptamine/herdr-auto-title`): enabled, built from upstream
  commit `7fcec810280696b8b38b5bd884be2b340c73e02b` plus
  [the local patch](patches/auto-title.patch). The patch adds Nerd Font icons
  while keeping live title updates. Each run builds and tests a fresh checkout
  in the platform's build directory above.
- **Yazi Explorer** (`speardragon/herdr-yazi`): enabled; `prefix+y` opens a split,
  and `prefix+shift+y` opens a tab.
- **Vim Herdr Navigation** (`paulbkim-dev/vim-herdr-navigation`): enabled;
  Ctrl+h/j/k/l moves between editor splits and Herdr panes.
- **Nerd Font Tab Name** (`rohankewal/herdr-nerd-font-tab-name`): installed but
  disabled, matching the source machine. Auto Title supplies the icons.

All pins are recorded in [the setup script](../scripts/setup-herdr.sh).
Auto Title settings are in [.config/herdr-auto-title/config.env](.config/herdr-auto-title/config.env).

## Activation and maintenance

Startup plugins take effect when the Herdr server next starts. The script does
not stop or restart a running server; finish active work before restarting it.
Use `herdr plugin list` to inspect registration and enabled states afterwards.

Reruns back up changed config files and keep previous Auto Title builds so they
do not overwrite a local checkout. The generated `plugins.json`, plugin caches,
logs, sockets, session state, and remembered tab names are not versioned.

On Linux/WSL the config files can also be deployed with `stow herdr`, but plugin
installation still needs the setup script. On macOS use the script so Auto Title
settings reach its Application Support directory.
