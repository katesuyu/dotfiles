# SPDX-License-Identifier: 0BSD

# This colorscheme is WIP: it highlights most things correctly, but due
# to a few faces not being defined here, some things are not rendered
# in the intended color.
evaluate-commands %sh{
    background='rgb:000000'
    foreground='rgb:eaeaea'
    unfocused='rgb:070707'
    n_black='rgb:969896'
    n_red='rgb:ff2c6d'
    n_green='rgb:19f9d8'
    n_yellow='rgb:ffb86c'
    n_blue='rgb:4589f9'
    n_magenta='rgb:ff75b5'
    n_cyan='rgb:19f9d8'
    n_white='rgb:f3f3f3'
    b_black='rgb:c6c8c6'
    b_red='rgb:7f70f0'
    b_green='rgb:41fadf'
    b_yellow='rgb:9f8cd5'
    b_blue='rgb:42d1ef'
    b_magenta='rgb:ff9ecb'
    b_cyan='rgb:41fadf'
    b_white='rgb:f8f8f8'

    echo "
        face global value ${n_red}
        face global type ${n_yellow}
        face global variable ${n_red}
        face global function ${b_magenta}
        face global string ${b_blue}
        face global error ${foreground},${n_red}
        face global keyword ${b_yellow}
        face global operator ${foreground}
        face global attribute ${b_yellow}
        face global comment ${n_black}
        face global meta ${n_red}

        face global Default ${foreground},${background}
        face global LineNumbers ${foreground},rgb:333333
        face global MenuForeground ${foreground},${n_red}
        face global MenuBackground ${foreground},rgb:333333
        face global MenuInfo ${n_red}
        face global Information ${n_red},rgb:333333
        face global Error ${n_red},${background}
        face global BufferPadding ${unfocused},${unfocused}
        face global StatusLine ${n_black},${unfocused}
        face global LineFlagErrors ${n_red},rgb:333333
    "
}
