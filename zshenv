#!/usr/bin/env zsh
# SPDX-License-Identifier: 0BSD

# Because these programs are too helpless to pick these
# defaults themselves, apparently.
export GPG_TTY="$(tty)"
export STEAM_COMPAT_DATA_PATH="${HOME}/.proton"
export DXVK_STATE_CACHE_PATH="${HOME}/.cache/dxvk"

prepend() {
    case "${PATH}" in
        "${1}"*) return ;;
        *":${1}" | *":${1}:"*)
            export PATH=$(printf '%s' "${PATH}" | sed "s|:${1//|/\\|}||g") ;;
    esac
    export PATH="${1}${PATH:+:${PATH}}"
}
append () {
    case "${PATH}" in
        "${1}" | *":${1}" \
        | *":${1}:"* | "${1}:"*) ;;
        *) export PATH="${PATH:+${PATH}:}${1}" ;;
    esac
}
append "${HOME}/.local/bin/proton"
append "${HOME}/.cargo/bin"
append "${HOME}/.local/zig"
unset -f append
unset -f prepend

# Integrate Kakoune with the rest of the system.
export VISUAL='kak'
export KAKOUNE_POSIX_SHELL=$(which bash)

# Add Homebrew-Linux variables to PATH if Homebrew is installed.
[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
[ -x "${HOME}/.linuxbrew/bin/brew" ] && eval "$("${HOME}/linuxbrew/.linuxbrew/bin/brew" shellenv)"
