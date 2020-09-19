# SPDX-License-Identifier: 0BSD
define-command -params 0..1 \
zig-std -docstring %{
    zig-std [<file>]: open the given <file> in the Zig standard library
                      opens std.zig if no <file> is provided
} %{
    evaluate-commands %sh{
        case "${#}" in
            0) printf "zig-std 'std.zig'\n" ;;
            1) cd "${HOME}/.local/zig/lib/zig/std" || exit 1
               L=$(realpath "${1}" | head -c -1; printf '.') || exit 1
               printf "edit -existing '"
               printf "%s" "${L%?}" | sed "s/'/''/g"
               printf "'\n" ;;
        esac
    }
}

define-command -hidden -params 0..1 zig-std-prompt %{
    evaluate-commands %sh{
        [ "${#}" -eq 1 ] && case "${1}" in
            'true' | 'false') ;;
            *) printf '%s\n' 'fail "Expected true or false, found %arg{1}"' ;;
        esac
    }
    evaluate-commands -save-regs 'D' %{
        set-register D %sh{realpath -s .}
        change-directory %sh{printf '%s' "${HOME}/.local/zig/lib/zig/std"}
        prompt -file-completion -on-abort %sh{
            [[ "${1}" == 'true' ]] && \
                printf 'quit 0\n' && exit
            printf "change-directory '"
            printf '%s' "${kak_reg_d}" | sed "s/'/''/g"
            printf "'\n"
        } 'file:' %sh{
            [[ "${1}" == 'true' ]] && \
                printf '%s\n' "try 'zig-std %val{text}' catch 'zig-std-prompt true'" && exit
            printf "try 'change-directory ''"
            printf '%s' "${kak_reg_d}" | sed "s/'/''''/g"
            printf "'''\n%s\n" 'zig-std %val{text}'
        }
    }
}

map -docstring 'browse the Zig standard library' global user t ': zig-std-prompt<ret>'

try %{
    require-module kak
    try %{
        add-highlighter shared/kakrc/code/zig_std regex '\bzig-std\b' 0:keyword
    } catch %{
        echo -debug "zig-std: Can't declare highlighters for 'kak' filetype."
        echo -debug "         Detailed error: %val{error}"
    }
}
