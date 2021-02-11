# SPDX-License-Identifier: 0BSD
define-command -params 1 \
edit-new -docstring %{
    edit-new <file>: create a new file, failing if it already exists
                     will mkdir -p the directory of the file on write
} -file-completion %{
    evaluate-commands %sh{
        [ -f "${1}" ] && \
            printf 'fail "%s"\n' "'edit-new' file '%arg{1}' exists"
    }
    edit %arg{1}
    hook -once buffer BufWritePre .* %{
        evaluate-commands %sh{
            dirname=$({ dirname -- "${kak_hook_param}" || exit; } | head -c -1; printf '.') || {
                printf 'fail "%s"\n' "'edit-new' failed to find dirname for '%arg{1}'"
                exit
            }
            mkdir -p -- "${dirname%?}" || {
                printf 'fail "%s"\n' "'edit-new' failed to execute 'mkdir -p' for '%arg{1}'"
                exit
            }
        }
    }
}

define-command -params 1 \
mkscript -docstring %{
    mkscript <file>: create a new file, failing if it already exists
                     automatically initializes the file with a shebang
                     will mkdir -p the directory of the file on write
                     will make the file executable on write
} -file-completion %{
    edit-new %arg{1}
    set-option buffer filetype sh
    execute-keys 'i#!/bin/sh<ret><esc>'
    hook -once buffer BufWritePost .* %{
        nop %sh{
            chmod +rw -- "${kak_hook_param}"
        }
    }
}

map global user -docstring 'create new file and containing folders' e \
    %[: prompt -file-completion 'file:' %[edit-new %val{text}]<ret>]

try %{
    require-module kak
    try %{
        add-highlighter shared/kakrc/code/edit_new regex '\bedit-new\b' 0:keyword
        add-highlighter shared/kakrc/code/mkscript regex '\bmkscript\b' 0:keyword
    } catch %{
        echo -debug "edit-new: Can't declare highlighters for 'kak' filetype."
        echo -debug "          Detailed error: %val{error}"
    }
}
