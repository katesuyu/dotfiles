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
    printf "'';delete-buffer ''*scratch*''' catch 'quit 39'"
}

# Open Kakoune to browse the Zig standard library.
zigstd () {
    case "${#}" in
        0) kak -e 'zig-std-prompt true' ;;
        1) local __zigstd=$(
            printf "try 'zig-std ''"
            printf '%s' "${1}" | sed "s/'/''''/g"
            printf "'';delete-buffer ''*scratch*''' catch 'quit 39'"
        ) && env -u '__zigstd' -- kak -e "${__zigstd}"
        local err="${?}"
        [ "${err}" -eq 39 ] && \
            printf 'zigstd: No such file or directory: %s\n' "${1}" >&2
        return "${err}" ;;
        *) printf 'zigstd: expected 0 or 1 arguments, found %s\n' "${#}" >&2 && return 1 ;;
    esac
}

update-zig () (
    # Define ZIGDIR and ZIGEXE variables if not already defined.
    [ -z "${ZIGDIR}" ] && ZIGDIR="${HOME}/.local/zig"
    [ -z "${ZIGEXE}" ] && ZIGEXE="${ZIGDIR}/zig"

    # Get the url of the latest available Zig download.
    url () {
        local arch=$(uname -m)
        local url=$(
            curl 'https://ziglang.org/download/index.json' --no-progress-meter \
            | jq -r '.master."'"${arch}"'-linux".tarball'
        )
        [ "${url}" == 'null' ] && {
            printf '%s\n' "unable to retrieve url for ${arch}" >&2
            exit 1
        }
        printf '%s\n' "${url}"
    }

    # Check whether we actually need to update. If not, exit with error code 1.
    query () {
        # Invoke 'zig version' to retrieve current version. Failure implies Zig is
        # not installed, which is ok, we handle first time installs too.
        local oldver=$("${ZIGEXE}" version 2>/dev/null || printf '[not installed]')
        local newver=$(latest "${1}")

        # We already have the latest version of Zig. Nothing more needs to be done.
        [ -z "${F}" ] && [ "${oldver}" == "${newver}" ] && exit

        # Print update path that will be taken if script is invoked normally.
        printf '%s -> %s\n' "${oldver}" "${newver}"
    }

    # Extract the latest version from the tarball's file name.
    latest () {
        sed 's/^.\+'"$(uname -m)"'-\(.\+\)\.tar\.xz$/\1/' <<<"${1}"
    }

    # Download and install the new version.
    install () {
        # Ensure Zig directory exists and clear out any existing installation.
        mkdir -p "${ZIGDIR}" || exit
        find "${ZIGDIR}" -mindepth 1 -delete || exit

        # Download the new version, stripping out the root folder as we don't need it.
        printf 'Downloading %s\n' "${1}" >&2
        curl "${1}" | tar --directory "${ZIGDIR}" --strip-components 1 -Jx
    }

    F= && [[ "${1}" == 'force' ]] && F='force' && shift
    case "${1}" in
        'url') url ;;
        'query') query "$(url)" ;;
        'latest') latest "$(url)" ;;
        '') url=$(url)
            query "${url}" >/dev/null
            install "${url}" ;;
        *) printf "unknown argument: %s\n" "${1}" >&2 && exit 1 ;;
    esac
)

update-zls () (
    [ -z "${ZLSDIR}" ] && ZLSDIR="${HOME}/.local/zls"
    printf 'Checking for ZLS install\n' >&2
    if [ -e "${ZLSDIR}" ]; then
        # Pull updates to ZLS or its dependencies.
        printf 'Using ZLS install at %s\n' "${ZLSDIR}" >&2
        cd "${ZLSDIR}" || exit
        git pull --recurse-submodules >&2
    else
        # Clone the repo so the script can be used on a fresh system.
        mkdir -p "$(basename "${ZLSDIR}")" || exit
        git clone --recurse-submodules 'https://github.com/zigtools/zls.git' "${ZLSDIR}" >&2 || exit
        cd "${ZLSDIR}" || exit
        git config pull.rebase false >&2
    fi

    # Always attempt to build, even if we didn't pull any updates. Zig caches builds,
    # so if nothing else changed to force us to rebuild, this command is instant.
    zig build -Drelease-safe -Ddata_version=master --prefix .
)
