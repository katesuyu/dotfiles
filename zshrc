#!/usr/bin/env zsh
# SPDX-License-Identifier: 0BSD

# Pretty prompt and ls colors.
alias ls='ls --color=auto'
PS1=$'%B%F{red}%n%f %F{blue}%~%f%b '

# Use Kakoune as manpager and offer useful error messages.
man () {
    [[ ${#} -gt 2 || ${#} -eq 0 ]] && \
        printf 'man: expected 1 or 2 arguments, found %s\n' "${#}" >&2 && return 1
    [ "${#}" -eq 2 ] && \
        case "${2}" in
            1 | 2 | 3 | 4 \
            | 5 | 6 | 7 | 8)
                kak -e "$(__man "${1}(${2})")"
                local err="${?}"
                [ "${err}" -eq 39 ] && \
                    printf 'man: No entry for %s in section %s of the manual.\n' \
                    "${1}" "${2}" >&2
                return "${err}" ;;
            *) printf 'man: Invalid section: %s\n' "${2}" >&2 && return 39 ;;
        esac
    kak -e "$(__man "${1}")"
    local err="${?}"
    [ "${err}" -eq 39 ] && \
        printf 'man: No entry for %s in the manual.\n' "${1}" >&2
    return "${err}"
}
__man () {
    printf "try 'man ''"
    printf '%s' "${1}" | sed "s/'/''''/g"
    printf "''' catch 'quit 39'"
}

# Open Kakoune to browse the Zig standard library.
zigstd () {
    case "${#}" in
        0) kak -e 'zig-std-prompt true' ;;
        1) local __zigstd=$(
            printf "try 'zig-std ''"
            printf '%s' "${1}" | sed "s/'/''''/g"
            printf "''' catch 'quit 39'"
        ) && env -u '__zigstd' -- kak -e "${__zigstd}"
        local err="${?}"
        [ "${err}" -eq 39 ] && \
            printf 'zigstd: No such file or directory: %s\n' "${1}" >&2
        return "${err}" ;;
        *) printf 'zigstd: expected 0 or 1 arguments, found %s\n' "${#}" >&2 && return 1 ;;
    esac
}
