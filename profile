#!/bin/sh
# SPDX-License-Identifier: 0BSD

# Make some useful shell utilities available.
export SHRC="${HOME}/.local/share/shrc"
export ENV="${SHRC}/shellrc"

# Because these programs are too helpless to pick these
# defaults themselves, apparently.
{ type gpg || type gpg2; } >/dev/null && \
    export GPG_TTY="$(tty)"
[ -e "${HOME}/.proton" ] && \
    export STEAM_COMPAT_DATA_PATH="${HOME}/.proton"
[ -e "${HOME}/.cache/dxvk" ] && \
    export DXVK_STATE_CACHE_PATH="${HOME}/.cache/dxvk"

# Create PATH entries for local files.
append () {
    case "${PATH}" in
        "${1}" | *":${1}" \
        | *":${1}:"* | "${1}:"*) ;;
        '') export PATH="${PATH}" ;;
        *) if [ "${2}" = '-p' ]; then
            export PATH="${1}:${PATH}"
        else
            export PATH="${PATH}:${1}"
        fi ;;
    esac
}
append '/sbin'
[ -e "${HOME}/.local/bin/betterwine" ] && \
    append "${HOME}/.local/bin/betterwine" -p
append "${HOME}/.local/bin"
[ -e "${HOME}/.cargo/bin" ] && \
    append "${HOME}/.cargo/bin"
unset -f append

# Integrate Kakoune with the rest of the system.
export VISUAL='kak'

# Add Homebrew-Linux variables to PATH.
[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
[ -x "${HOME}/.linuxbrew/bin/brew" ] && eval "$("${HOME}/linuxbrew/.linuxbrew/bin/brew" shellenv)"
