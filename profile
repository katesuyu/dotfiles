#!/bin/sh
# SPDX-License-Identifier: 0BSD

# Make some useful shell utilities available.
export SHRC="${HOME}/.local/share/shrc"
export ENV="${SHRC}/shellrc"

# append <var> <dir> [-p]
# Append the specified directory to the PATH-like variable named by var.
# If the flag -p is specified, the directory is prepended instead.
append () {
    case "${1}" in
        *[!A-Za-z0-9_]* | '' | '_') return 1 ;;
        *[!0-9]*) ;;
        *) return 1 ;;
    esac
    [ ! -e "${2}" ] || eval '
        case "${'"${1}"'}" in
            "${2}" | *":${2}" \
            | *":${2}:"* | "${2}:"*) ;;
            "") export '"${1}"'="${2}" ;;
            *) if [ "${3}" = "-p" ]; then
                export '"${1}"'="${2}:${'"${1}"'}"
            else
                export '"${1}"'="${'"${1}"'}:${2}"
            fi ;;
        esac
    '
}
append PATH '/sbin'
append PATH "${HOME}/.local/bin"
append PATH "${HOME}/.cargo/bin"
append PATH "${HOME}/.local/bin/betterwine" -p
case "${PATH}" in
    *'linuxbrew'*) ;;
    *) if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [ -x "${HOME}/.linuxbrew/bin/brew" ]; then
        eval "$("${HOME}/linuxbrew/.linuxbrew/bin/brew" shellenv)"
    fi ;;
esac

# Add local man and info pages to MANPATH and INFOPATH.
append MANPATH "${HOME}/.local/share/man" -p
append INFOPATH "${HOME}/.local/share/info" -p
unset -f append

# Set preferred Proton prefix location.
[ -e "${HOME}/.proton" ] && \
    export STEAM_COMPAT_DATA_PATH="${HOME}/.proton"

# Set preferred DXVK cache location.
[ -e "${HOME}/.cache/dxvk" ] && \
    export DXVK_STATE_CACHE_PATH="${HOME}/.cache/dxvk"

# Standard configuration for GnuPG.
{ type gpg || type gpg2; } >/dev/null && \
    export GPG_TTY="$(tty)"

# Set preferred text editor to Kakoune.
{ type kak; } >/dev/null && \
    export VISUAL='kak'
