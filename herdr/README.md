# Herdr

This package preserves the current Linux/WSL settings and plugin versions.
From the repository root on a new machine:

```sh
bash scripts/setup-herdr.sh
```

Install Herdr 0.9.0 or newer, Git, Go 1.24 or newer, and Yazi first.
Use a Nerd Font in the terminal for the configured icons. Network access to
GitHub and the Go module proxy is required.

The script copies the configs, backs up differing destination files, installs
plugins at pinned commits, and adds the Neovim navigation integration. It does
not use Stow. It follows `XDG_CONFIG_HOME` and `XDG_DATA_HOME` when set.
Review existing Neovim navigation mappings before running it on a configured
machine. The wrapper only loads the integration inside Herdr, preserving the
editor's existing navigation outside Herdr.

## Plugins

- **Auto Title** (`kryptamine/herdr-auto-title`): enabled, built from upstream
  commit `7fcec810280696b8b38b5bd884be2b340c73e02b` plus
  [the local patch](patches/auto-title.patch). The patch adds Nerd Font icons
  while keeping live title updates. Each run builds and tests a fresh checkout under
  `$XDG_DATA_HOME/herdr-dotfiles` (default `~/.local/share/herdr-dotfiles`).
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

The config files can also be deployed with `stow herdr`, but plugin installation
still needs the setup script. macOS and native Windows need different config
paths and are not supported by this script.
