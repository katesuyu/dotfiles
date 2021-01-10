#!/usr/bin/env zsh
# SPDX-License-Identifier: 0BSD

update-zig () (
    # Create directory to store Zig downloads in.
    mkdir -p -- "${HOME}/.local/store" || exit
    cd -- "${HOME}/.local/store" || exit

    # Retrieve architecture and operating system with uname.
    os=$(uname -s) || exit
    arch=$(uname -m) || exit

    # Normalize operating system identifier into format used by download index.
    case "${os}" in
        [Ll]inux) os=linux ;;
        [Dd]arwin) os=macos ;;
        [Ww]indows* | CYGWIN* | MINGW* | MSYS*) os=windows ;;
        [Dd]ragon[Ff]ly*) os=dragonflybsd ;;
        [Ff]ree[Bb][Ss][Dd]*) os=freebsd ;;
        [Oo]pen[Bb][Ss][Dd]*) os=openbsd ;;
        [Nn]et[Bb][Ss][Dd]*) os=netbsd ;;
        *) printf 'Unrecognized operating system.\n' >&2 && exit 1 ;;
    esac

    # Normalize architecture identifier into format used by download index.
    case "${arch}" in
        x86_64 | amd64) arch=x86_64 ;;
        x86 | i[36]86 | i86pc) arch=i386 ;;
        aarch64 | arm64) arch=aarch64 ;;
        armv7*) arch=armv7a ;;
        riscv64) arch=riscv64 ;;
        *) printf 'Unrecognized CPU architecture.\n' >&2 && exit 1 ;;
    esac

    # Obtain the version number and tarball download URL for latest master build.
    version=$(
        { curl 'https://ziglang.org/download/index.json' --no-progress-meter || exit
        } | jq -r '.master | {
            version: (.version //
                error("Download index does not contain version")),
            tarball: (."'"${arch}-${os}"'".tarball //
                error("Download index does not contain tarball for target '"'${arch}-${os}'"'")),
        } | @sh "version=\(.version)\nversion=${version%'"'+'"'*}\ntarball=\(.tarball)"'
    ) || exit
    eval "${version}"

    # Determine the directory to download this version of Zig in. Do not perform
    # the download if the directory exists (i.e. latest version already installed).
    target_dir="zig-${version}"
    zip_name=${tarball##'/'}
    [ -e "${target_dir}" ] && {
        [ "${1}" != '--force' ] && {
            printf 'The latest version of Zig is already installed.\n' "${version}" >&2; exit
        }
        rm -rf "${target_dir}" || exit
    }

    # Download and extract the archive containing the Zig install.
    mkdir -p "${target_dir}" || exit
    {
        { curl "${tarball}" || exit
        } | if [ "${os}" = 'windows' ]; then
            unzip -d "${target_dir}" - "${zip_name%'.zip'}/*"
        else
            tar --directory "${target_dir}" --strip-components 1 -Jx
        fi
    } || {
        rmdir "${target_dir}"
        exit 1
    }

    # Symlink version-specific folder to 'zig' for convenience.
    [ \( ! -e 'zig' \) -o \( -h 'zig' \) ] && \
        { ln -Tsf "${target_dir}" 'zig' || exit; }

    # Symlink Zig executable to ~/.local/bin/zig, which should be in PATH.
    mkdir -p "${HOME}/.local/bin" || exit
    cd -- "${HOME}/.local/bin" || exit
    [ \( ! -e 'zig' \) -o \( -h 'zig' \) ] && \
        { ln -Tsf "../store/${target_dir}/zig" 'zig' || exit; }

    # Symlink Zig lib folder to ~/.local/lib/zig so the Zig executable can find it.
    mkdir -p "${HOME}/.local/lib" || exit
    cd -- "${HOME}/.local/lib"
    [ \( ! -e 'zig' \) -o \( -h 'zig' \) ] && \
        { ln -Tsf "../store/${target_dir}/lib" 'zig' || exit; }
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

. "${SHRC}/shellrc"
PS1='%B%F{red}%n%f %F{blue}%~%f%b '
