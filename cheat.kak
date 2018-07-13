# kakoune-cheat 0.1
# Author: @dryvenn
# License: MIT

declare-option -hidden str cheat_script %sh{ echo $(dirname $kak_source)/cht.sh }

define-command -docstring 'cheat <args>...: lookup cheat.sh' \
    -params .. \
    cheat %{ evaluate-commands -try-client %opt{docsclient} %sh{
        cht=$kak_opt_cheat_script
        if [ ! -x $cht ] || ! echo 'version' | $cht --shell | grep -iq 'up to date'
        then
            curl https://cht.sh/:cht.sh > $cht
            chmod +x $cht
        fi
        fifo=$(mktemp -d -t kak-XXXXXXXX)/fifo
        mkfifo $fifo
        ($cht $@ ?style=bw > $fifo ) &> /dev/null < /dev/null &
        echo "edit! -fifo $fifo *cheat*
              hook buffer BufClose .* %{ nop %sh{ rm -rf $(dirname $fifo) } }"
    }}
