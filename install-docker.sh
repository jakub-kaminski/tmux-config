#!/usr/bin/env bash

set -e
set -u
set -o pipefail

is_app_installed() {
  type "$1" &>/dev/null
}

REPODIR="$(cd "$(dirname "$0")"; pwd -P)"
cd "$REPODIR";

USER_HOME=$1


if ! is_app_installed tmux; then
  printf "WARNING: \"tmux\" command is not found. \
Install it first\n"
  exit 1
fi

if [ ! -e "${USER_HOME}/.tmux/plugins/tpm" ]; then
  printf "WARNING: Cannot found TPM (Tmux Plugin Manager) \
 at default location: \${USER_HOME}/.tmux/plugins/tpm.\n"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if [ -e "${USER_HOME}/.tmux.conf" ]; then
  printf "Found existing .tmux.conf in your \${USER_HOME} directory. Will create a backup at ${USER_HOME}/.tmux.conf.bak\n"
fi

cp -f "${USER_HOME}/.tmux.conf" "${USER_HOME}/.tmux.conf.bak" 2>/dev/null || true
cp -a ./tmux/. "${USER_HOME}"/.tmux/
ln -sf .tmux/tmux.conf "${USER_HOME}"/.tmux.conf;

# Install TPM plugins.
# TPM requires running tmux server, as soon as `tmux start-server` does not work
# create dump __noop session in detached mode, and kill it when plugins are installed
printf "Install TPM plugins\n"
tmux new -d -s __noop >/dev/null 2>&1 || true
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "~/.tmux/plugins"
"${USER_HOME}"/.tmux/plugins/tpm/bin/install_plugins || true
tmux kill-session -t __noop >/dev/null 2>&1 || true


sudo cp "${REPODIR}/socketfiles/xclip.socket" "/etc/systemd/system/xclip.socket"
sudo cp "${REPODIR}/socketfiles/xclip@.service" "/etc/systemd/system/xclip@.service"
sudo systemctl enable xclip.socket

printf "OK: Completed\n"
