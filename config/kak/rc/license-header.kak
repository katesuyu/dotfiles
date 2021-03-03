# SPDX-License-Identifier: 0BSD
define-command -params 1.. \
license-header -docstring %{
    license-header [<switches>] <license> [<project>]: generate a license header for this file
    Switches:
        -project-copyright: use '{project} Contributors' instead of an individual name for '{author}'
} \
-shell-script-candidates %{
    switches=0
    while [ "${#}" -gt 0 ]; do
        case "${1}" in
            '--') true "$((switches+=1))" && shift && break ;;
            '-'*) true "$((switches+=1))" && shift ;;
            *) break ;;
        esac
    done
    case "$((${kak_token_to_complete}-${switches}))" in
        0) cd "${HOME}/templates/license-headers" && \
            for file in *'.zig'; do
                [ ! -e "${file}" ] && continue
                printf '%s\n' "${file%????}"
            done ;;
        1) if [ -n "${kak_opt_project_name}" ]; then
            printf '%s\n' "${kak_opt_project_name}"
        else
            git_repo=$("${kak_config}/rc/get-repo" "${kak_buffile}") && \
            "${kak_config}/rc/project-name" "${git_repo}"
        fi ;;
    esac
} %{
    evaluate-commands %sh{
        execute () {
            printf "license-header-execute '"
            printf '%s' "${1}" | sed "s/'/''/g"
            printf "' '"
            printf '%s' "${2}" | sed "s/'/''/g"
            printf "' %s\n" "${project}"
        }

        # Handle switches
        project=0
        while [ "${#}" -gt 0 ]; do
            case "${1}" in
                '--') shift && break ;;
                '-project-copyright') [ "${project}" -gt 0 ] && \
                    printf 'fail "%s%s"\n' "'license-header' switch " \
                    "'-project-copyright' specified twice" && exit 1
                    project=1 && shift ;;
                '-'*) printf "fail '''license-header'' unknown switch ''"
                    printf '%s' "${1}" | sed "s/'/''''/g"
                    printf "'''\n" && exit 1 ;;
                *) break ;;
            esac
        done
        { [ "${#}" -lt 1 ] || [ "${#}" -gt 2 ]; } && \
            printf '%s\n' "fail %['license-header' wrong argument count]" && exit

        # Check if we have a template for the license header.
        case "${1}" in
            *[!a-zA-Z0-9_-]*) false ;;
            *) [ -f "${HOME}/templates/license-headers/${1}.zig" ] ;;
        esac || {
            printf 'fail "%s"\n' "No license header for license '%arg{1}'" && exit
        }

        # Use project name provided through %arg{2} or %opt{project_name}.
        [ "${#}" -eq 2 ] && {
            # Escape hatch for licenses that do not use {project}.
            [ "${2}" != '_' ] && \
                printf 'set-option window project_name %%arg{%s}\n' "$((${project}+2))"
            execute "${1}" "${2}" && exit
        }
        [ -n "${kak_opt_project_name}" ] && \
            execute "${1}" "${kak_opt_project_name}" && exit

        # Infer project name if we have a Git repository and/or README files.
        git_repo=$("${kak_config}/rc/get-repo" "${kak_buffile}") && \
        name=$("${kak_config}/rc/project-name" "${git_repo}") && {
            printf "set-option window project_name '"
            printf '%s' "${name}" | sed "s/'/''/g"
            printf "'\n" && execute "${1}" "${name}"
            exit
        }

        # Handle case where project name is neither specified nor inferred.
        printf "%s\n" "fail 'No project name specified: set %opt{project_name}'"
    }
}

# %arg{1} = license
# %arg{2} = project name
# %arg{3} = 0 if individual attribution
#           1 if project contributor attribution
define-command -hidden -params 3 license-header-execute %{
    evaluate-commands -draft -save-regs '/"|^@FML' %{
        # Save the comment line type before we switch to temp buffer.
        set-register M %opt{comment_line}
        try %{
            # Override the default generated license text if license is 'CUSTOM'.
            evaluate-commands %sh{
                [ "${1}" = 'CUSTOM' ] && \
                printf '%s\n' 'set-register F %opt{license_text}; fail'
            }
            # Load the license header into a register.
            set-register F %sh{cat -- "${HOME}/templates/license-headers/${1}.zig"}
            # If configured to do so, use "{project} Contributors" to
            # fill in the {author} field. Otherwise, use Git user.name.
            set-register L %sh{
                [ "${3}" -ne 0 ] && printf '%s Contributors' "${2}" && exit
                cd "$(dirname -- "${kak_buffile}")"
                git config --get user.name
            }
        }
        evaluate-commands -draft %{
            # Create a temporary buffer to edit our license header in.
            edit -scratch
            execute-keys '%c<c-r>F<esc>'
            try %{
                # Use language-appropriate comments.
                execute-keys '%s^//<ret>'
                execute-keys -itersel 'c<c-r>M<esc>'
            }
            try %{
                # Insert the current year into the copyright header.
                try %sh{[ "${1}" = 'CUSTOM' ] && printf 'fail\n'}
                set-register F %sh{date +%Y | head -c -1}
                execute-keys '%s\{year\}<ret>'
                execute-keys -itersel 'c<c-r>F<esc>'
            }
            try %{
                # Insert the project name into the copyright header.
                try %sh{[ "${1}" = 'CUSTOM' ] && printf 'fail\n'}
                set-register F %arg{2}
                execute-keys '%s\{project\}<ret>'
                execute-keys -itersel 'c<c-r>F<esc>'
            }
            try %{
                # Insert the author name into the copyright header.
                try %sh{[ "${1}" = 'CUSTOM' ] && printf 'fail\n'}
                execute-keys '%s\{author\}<ret>'
                execute-keys -itersel 'c<c-r>L<esc>'
            }
            # Yank the contents of the temporary buffer.
            execute-keys -save-regs '' '%y'
            delete-buffer
        }
        # Paste our fully processed copyright header!
        execute-keys 'gg'
        try %{
            # Avoid displacing the shebang in scripts.
            execute-keys -draft '<a-x>s^#!<ret>'
            execute-keys 'xa<c-r>"<esc>'
        } catch %{
            execute-keys 'i<c-r>"<esc>'
        }
    }
}

declare-user-mode license-header
declare-option -docstring 'project name to use for auto-generated text' str project_name
declare-option -docstring 'license text to use instead of a template' str license_text
declare-option -hidden bool license_repo_explored
map -docstring 'generate license header (individual author)' global user 'l' ': license-header-mode 0<ret>'
map -docstring 'generate license header (project authors)' global user 'L' ': license-header-mode 1<ret>'

define-command -hidden -params 1 license-header-mode %{
    evaluate-commands %sh{
        if [ -n "${kak_opt_license_text}" ]; then
            printf 'license-header-execute CUSTOM _ _\n'
        else
            [ "${kak_opt_license_repo_explored}" = 'false' ] && {
                printf 'set-option window license_repo_explored true\n'
                git_repo=$("${kak_config}/rc/get-repo" "${kak_buffile}") && {
                    [ -n "${kak_opt_license_text}" -o ! -e "${git_repo}/.kak/license-header.zig" ] || {
                        printf "set-option window license_text '"
                        text1=$(sed "s/'/''/g" <"${git_repo}/.kak/license-header.zig"; printf '.')
                        text=${text1%"$(printf '\n.')"}
                        [ "${text}" = "${text1}" ] && text=${text%?}
                        printf "%s'\nlicense-header-execute CUSTOM _ _\n" "${text}"
                        exit
                    }
                    [ -n "${kak_opt_project_name}" ] || {
                        name=$("${kak_config}/rc/project-name" "${git_repo}") && {
                            printf "set-option window project_name '"
                            printf '%s' "${name}" | sed "s/'/''/g"
                            printf "'\n"
                        }
                    }
                }
            }
            case "${1}" in
                0) switches= ;;
                1) switches='-project-copyright ' ;;
                *) printf 'fail\n' && exit ;;
            esac
            printf '%s%s\n%s%s\n%s%s\n%s\n' \
            "map -docstring 'MIT License' window license-header " \
            "m ': license-header ${switches}mit<ret>'" \
            "map -docstring 'BSD License (3-clause)' window license-header " \
            "b ': license-header ${switches}3bsd<ret>'" \
            "map -docstring 'BSD License (0-clause)' window license-header " \
            "0 ': license-header 0bsd _<ret>'" \
            'enter-user-mode license-header'
        fi
    }
}

try %{
    require-module kak
    try %{
        add-highlighter shared/kakrc/code/license_header regex '\blicense-header\b' 0:keyword
    } catch %{
        echo -debug "license-header: Can't declare highlighters for 'kak' filetype."
        echo -debug "                Detailed error: %val{error}"
    }
}
