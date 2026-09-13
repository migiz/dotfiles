#!/usr/bin/env bash
# Restore the Linux/WSL Herdr setup without requiring Stow.
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}
data_dir=${XDG_DATA_HOME:-$HOME/.local/share}

[[ $(uname -s) == Linux ]] || { echo 'This setup supports Linux/WSL.' >&2; exit 1; }
[[ -z ${HERDR_CONFIG_PATH:-} ]] || { echo 'Unset HERDR_CONFIG_PATH before setup.' >&2; exit 1; }
for dependency in herdr git go yazi; do
    command -v "$dependency" >/dev/null || { echo "Missing dependency: $dependency" >&2; exit 1; }
done

# Copy settings before registering plugins. Preserve any different existing file.
copy_config() {
    local source=$1 destination=$2 backup
    mkdir -p -- "$(dirname -- "$destination")"
    if [[ -e $destination || -L $destination ]]; then
        cmp -s -- "$source" "$destination" && return
        backup=$(mktemp "${destination}.backup.XXXXXX")
        cp -L -- "$destination" "$backup"
        echo "Saved previous config: $backup"
    fi
    cp -- "$source" "$destination"
}

copy_config "$repo_dir/herdr/.config/herdr/config.toml" "$config_dir/herdr/config.toml"
copy_config "$repo_dir/herdr/.config/herdr/herdr-nerd-font-tab-name.yml" "$config_dir/herdr/herdr-nerd-font-tab-name.yml"
copy_config "$repo_dir/herdr/.config/herdr-auto-title/config.env" "$config_dir/herdr-auto-title/config.env"

herdr plugin install rohankewal/herdr-nerd-font-tab-name --ref b5cc7db85fedc085385716e27464ed32a9b2d168 --yes
herdr plugin disable herdr-nerd-font-tab-name
herdr plugin install speardragon/herdr-yazi --ref 54aa4e6dff480189630fa3593146cdcc2768ade9 --yes
herdr plugin enable ray.file-explorer
herdr plugin install paulbkim-dev/vim-herdr-navigation --ref 79679dacc791f70fc34de8b29a3cf9706c0f5b2f --yes
herdr plugin enable vim-herdr-navigation

# Each run builds in a fresh directory so an existing local checkout is untouched.
mkdir -p -- "$data_dir/herdr-dotfiles"
auto_title_dir=$(mktemp -d "$data_dir/herdr-dotfiles/auto-title.XXXXXX")
git -C "$auto_title_dir" init -q
git -C "$auto_title_dir" fetch --depth 1 https://github.com/kryptamine/herdr-auto-title.git 7fcec810280696b8b38b5bd884be2b340c73e02b
git -C "$auto_title_dir" checkout --detach FETCH_HEAD
# The patch omits context whitespace and is applied only to the exact base above.
git -C "$auto_title_dir" apply --unidiff-zero --check "$repo_dir/herdr/patches/auto-title.patch"
git -C "$auto_title_dir" apply --unidiff-zero "$repo_dir/herdr/patches/auto-title.patch"
(
    cd -- "$auto_title_dir"
    go test ./...
    go build -o herdr-auto-title ./cmd/herdr-auto-title
)
herdr plugin link "$auto_title_dir"
herdr plugin enable herdr.auto-title

copy_config "$repo_dir/herdr/.config/nvim/after/plugin/herdr-navigation.lua" "$config_dir/nvim/after/plugin/herdr-navigation.lua"

herdr plugin list
echo 'Setup complete. Plugins with startup hooks take effect on the next Herdr server start.'
echo 'No running server was stopped. Previous Auto Title build directories are retained.'
