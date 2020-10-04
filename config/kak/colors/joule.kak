# SPDX-License-Identifier: 0BSD

# This colorscheme is WIP: it highlights most things correctly, but due
# to a few faces not being defined here, some faces fall back to default
# terminal colors. This will be corrected as needed over tine.
evaluate-commands %sh{
    background='rgb:000000'
    foreground='rgb:eaeaea'
    unfocused='rgb:070707'
    n_black='rgb:969896'
    n_red='rgb:ff2c6d'
    n_green='rgb:f7d7ff'
    n_yellow='rgb:ffb86c'
    n_blue='rgb:e888a0'
    n_magenta='rgb:9f8cd5'
    n_cyan='rgb:19f9d8'
    n_white='rgb:f3f3f3'
    b_black='rgb:c6c8c6'
    b_red='rgb:7f70f0'
    b_green='rgb:ffe77c'
    b_yellow='rgb:c1cada'
    b_blue='rgb:42d1ef'
    b_magenta='rgb:ff9ecb'
    b_cyan='rgb:41fadf'
    b_white='rgb:f8f8f8'

    printf '%s' "
        face global value ${n_red}
        face global type ${n_blue}
        face global variable ${b_yellow}
        face global function ${b_magenta}
        face global string ${b_blue}
        face global error ${foreground},${n_red}
        face global keyword ${n_magenta}
        face global operator ${foreground}
        face global attribute ${n_magenta}
        face global comment ${n_black}
        face global meta ${n_red}
        face global title keyword
        face global header keyword
        face global module ${n_green}
        face global bullet value
        face global list string
        face global field ${b_yellow}

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
