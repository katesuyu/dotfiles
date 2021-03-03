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
    case "${3}" in
        '-'*) i=${3} && unset -v prepend force
        while i=${i#?} && [ -n "${i}" ]; do
            case "${i}" in
                'p'*) prepend=1 ;;
                'f'*) force=1 ;;
                *) return 1 ;;
            esac
        done ;;
    esac
    [ -z "${force}" -a ! -e "${2}" ] || eval '
        case "${'"${1}"'}" in
            "${2}" | *":${2}" \
            | *":${2}:"* | "${2}:"*) ;;
            "") export '"${1}"'="${2}" ;;
            *) if [ -n "${prepend}" ]; then
                export '"${1}"'="${2}:${'"${1}"'}"
            else
                export '"${1}"'="${'"${1}"'}:${2}"
            fi ;;
        esac
    '
}
append PATH '/sbin'
type npm >/dev/null && \
    append PATH "${HOME}/.local/store/npm-packages/bin" -fp
append PATH "${HOME}/.cargo/bin" -fp
append PATH "${HOME}/.local/bin" -fp
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

# Set preferred text editor to Kakoune.
type kak >/dev/null && \
    export VISUAL='kak'

# Standard configuration for GnuPG.
{ type gpg || type gpg2; } >/dev/null && \
    export GPG_TTY="$(tty)"
