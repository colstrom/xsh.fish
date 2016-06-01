function xsh
    function __xsh_args_to_envs
        set index 1

        for arg in $argv
            set --export XSH_COMMAND_LINE_ARG_$index "$arg"
            set index (math $index + 1)
        end
    end

    function __xsh_args_serialize
        for arg in $argv
            printf "%s " (string escape --no-quoted $arg)
        end
    end

    function __xsh_args_to_file
        mkdir -p ~/xiki/misc/tmp
        __xsh_args_serialize $argv >~/xiki/misc/tmp/params.txt
    end

    set --export GEM_HOME ~/xiki/misc/gems
    mkdir -p ~/xiki/misc/gems/bin
    set --export PATH $GEM_HOME/bin $PATH
    set --export xiki_dir ~/xiki-master

    if test "$xiki_dir" = "$HOME"
        cat "$xiki_dir/misc/command/shell_please_move.txt"
        return
    end

    switch "$argv[1]"
        case -- --help
            cat $xiki_dir/misc/command/external_shell_help.txt
        case -- --examples
            cat $xiki_dir/misc/command/external_shell_examples.txt
        case -- -i
            set --erase argv[1]
            __xsh_args_to_envs $argv
            exec emacs --quick --no-window-system --load "$xiki_dir/misc/emacs/start_xiki_no_socket.el"
        case '*'
            set unique (random)
            emacs --daemon=$unique --quick --no-window-system --eval '(setq initial-scratch-message nil)' --load "$xiki_dir/misc/emacs/start_xiki_daemon.el" >/dev/null ^/dev/null
            __xsh_args_to_file $argv
            env -u ALTERNATE_EDITOR emacsclient --socket-name=$unique --tty
    end
end
