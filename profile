#!/bin/sh
# SPDX-License-Identifier: 0BSD

# Make some useful shell utilities available.
export SHRC="${HOME}/.local/share/shrc"
export ENV="${SHRC}/shellrc"

# Because these programs are too helpless to pick these
# defaults themselves, apparently.
export GPG_TTY="$(tty)"
export STEAM_COMPAT_DATA_PATH="${HOME}/.proton"
export DXVK_STATE_CACHE_PATH="${HOME}/.cache/dxvk"

# Create PATH entries for local files.
append () {
    case "${PATH}" in
        "${1}" | *":${1}" \
        | *":${1}:"* | "${1}:"*) ;;
        '') export PATH="${PATH}" ;;
        *) export PATH="${PATH}:${1}";;
    esac
}
append "${HOME}/.local/bin"
append "${HOME}/.cargo/bin"
unset -f append

# Integrate Kakoune with the rest of the system.
export VISUAL='kak'

# Add Homebrew-Linux variables to PATH.
[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
[ -x "${HOME}/.linuxbrew/bin/brew" ] && eval "$("${HOME}/linuxbrew/.linuxbrew/bin/brew" shellenv)"
