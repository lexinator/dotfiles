# all the stuff below is for interactive sessions
uptime

#stupid machines without screen termcap
if [[ $TERM == "screen" ]] && 
    [[ ! -f /etc/terminfo/s/screen ]] && 
    [[ ! -f /usr/share/lib/terminfo/s/screen ]] &&
    [[ ! -f /usr/share/terminfo/s/screen ]] &&
    [[ ! -L /usr/share/terminfo/s/screen ]]; then
    echo "System does not appear to have screen termcap assuming vt100..."
    TERM=vt100 ; export TERM
fi

if [[ $TERM == "rxvt" ]] && 
    [[ ! -f /etc/terminfo/r/rxvt ]] &&
    [[ ! -f /usr/share/terminfo/r/rxvt ]]; then
    echo "System does not appear to have rxvt termcap assuming vt220..."
    TERM=vt220 ; export TERM
fi

#prompts
PROMPT='%n@%m%#' ; RPROMPT='%(?..[%?])%T %v%~'
OS=$(uname -s)

# my general preferences
setopt autolist auto_menu nohup list_types always_last_prompt auto_cd correct
setopt append_history all_export hist_ignore_dups hist_ignore_space
setopt hist_no_store extended_history
unsetopt list_beep menu_complete

#aliases
alias ls='ls -F'
alias d='ls -C'
alias dir='ls -lg'
alias ssh='ssh -A'
alias laxssh='ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oLogLevel=ERROR'
alias sudo='sudo -E'
alias rm='rm -i'
alias mv='mv -i'
alias ttyset='set noglob; eval `tset -sQ -m :?vt100` ; unset noglob'
alias rsync='rsync -av --progress --stats'
alias aptinstall='apt-get update 1> /dev/null && apt-get install --force-yes'
alias tcpcount='netstat -an | egrep -v "127.0.0|10.16|^udp|^unix|LISTEN|^Proto|Active" | awk "{print \$6}" | sort | uniq -c | sort -nr' 
alias pss='ps -e -o pid,user,rss,vsz,stime,time,args'

if whence vim &> /dev/null; then
    alias vi=vim
fi

aws() { curl "http://169.254.169.254/latest/meta-data/$1" }

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

#OS command specific
case $OS in
    Linux)
        if [[ $EUID -ne 0 ]]; then
           alias su='su -m -s =zsh'
        fi
        alias ls='ls --color=auto -F'
        if [[ ! -f /etc/redhat-release ]]; then
            if [ -f =lessfile ]; then eval "$(lessfile)"; fi
        fi
        ;;

    SunOS)
        if whence gtar &> /dev/null; then
            alias tar=gtar
        fi
        alias ping='ping -s'
        alias truss_off 'truss -w2 -t \\!setcontext,\\!brk,\\!ioctl,\\!poll,\\!sigprocmask'
        function su() {
            if [[ $#argv == 0 ]]; then
                =su root -c =zsh
            else
                =su $argv[1] -c =zsh
            fi    
        }
        ;;

    Darwin)
        export COMMAND_MODE=unix2003
        #manpage for arrangement
        export LSCOLORS=ExGxDxdxCxegedabagacad
        alias ls='ls -G'
        alias lockscreen='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
         ;; 
esac

psvar=$OS
#debian/ubuntu
if [[ -f /etc/lsb-release ]]; then
    psvar="${psvar}-$(grep CODENAME /etc/lsb-release | awk -F= '{print $2}')"
fi
#redhat
if [[ -f /etc/redhat-release ]]; then
    export SYSSCREENRC=/dev/null
    psvar="${psvar}-$(awk '{print "rh-"$8}' /etc/redhat-release)"
fi

[[ -e $SSH_AUTH_SOCK ]] && psvar="*$psvar"
psvar="$psvar "

# zsh version specific commands
case $ZSH_VERSION in
    3.1*|4*)
        setopt HIST_EXPIRE_DUPS_FIRST HIST_REDUCE_BLANKS
        setopt SHARE_HISTORY HIST_SAVE_NO_DUPS INC_APPEND_HISTORY

        setopt null_glob
        fpath=($fpath /pkg/zsh-$ZSH_VERSION/share/zsh/$ZSH_VERSION/functions /usr/share/zsh/*/functions /usr/local/share/zsh/*/functions ~/public/share/zsh/*/functions )
        unsetopt null_glob

        #remove any duplicates
        typeset -U fpath

        autoload -U compinit

        # don't perform security check
        compinit -C -d ~/.zcompdump_$ZSH_VERSION

        function preexec {
              emulate -L zsh
              local -a cmd; cmd=(${(z)1})        # Re-parse the command line
#              title $cmd[1]:t "$cmd[2,-1]"

               # Construct a command that will output the desired job number.
              case $cmd[1] in
                  fg) if (( $#cmd == 1 )); then
                            # No arguments, must find the current job
                            cmd=(builtin jobs -l %+)
                        else
                            # Replace the command name, ignore extra args.
                            cmd=(builtin jobs -l ${(Q)cmd[2]})
                        fi;;
                    # Same as "else" %above
                    %*) cmd=(builtin jobs -l ${(Q)cmd[1]});;

                    *) title $cmd[1]:t "$cmd[2,-1]"   # Not resuming a job,
                        return;;                        # so we're all done
                esac

              local -A jt; jt=(${(kv)jobtexts})     # Copy jobtexts for subshell

            # Run the command, read its output, and look up the jobtext.
            # Could parse $rest here, but $jobtexts (via $jt) is easier.
            $cmd >>(read num rest
              cmd=(${(z)${(e):-\$jt$num}})
              title $cmd[1]:t "$cmd[2,-1]") 2>/dev/null
            }
            ;;
    *)  #ancient version of zsh
        echo "zstyle completion not available in zsh-$ZSH_VERSION"
        function zstyle { }
        ;;
esac

#user specific stuff
case $USERNAME in
    aludeman|lex|ludeman)
        export BINDKEYMODE="vi"
        bindkey -v

        #oh i'm sure there is some emacs special thing i'm overrriding
        bindkey "^[[A" history-beginning-search-backward
        bindkey "^[[B" history-beginning-search-forward
        bindkey "^Xq" push-line-or-edit
        bindkey "^Xr" history-incremental-search-backward
        bindkey "^Xs" history-incremental-search-forward
        bindkey "^[OA" history-beginning-search-backward
        bindkey "^[OB" history-beginning-search-forward

        bindkey "^X_" insert-last-word
        bindkey "^Xa" accept-and-hold
        bindkey -M vicmd "^R" redo

        #bindkey "^E" expand-word
        #bindkey "^N" menu-complete
        #bindkey "^P" reverse-menu-complete
        #bindkey -M vicmd "u" undo
        #bindkey -M vicmd "ga" what-cursor-position

        fignore=(.o .c~ .old)
        #check if zload exists
        #if [[ -d ~/zload ]] && [[ -n ~/zload/* ]]; then
        #    fpath=(~/zload $fpath)
        #    autoload ${fpath[1]}/*(:t)
        #fi

        umask 022
        HISTFILE=~/.zsh_history
        HISTSIZE=5000
        SAVEHIST=5000
    ;;

    *)  #let's do this
        if [[ $BINDKEYMODE == "vi" ]]; then
            bindkey -v
            #oh i'm sure there is some emacs special thing i'm overrriding
            bindkey "^[[A" history-beginning-search-backward
            bindkey "^[[B" history-beginning-search-forward
            bindkey "^Xq" push-line
            bindkey "^Xr" history-incremental-search-backward
            bindkey "^Xs" history-incremental-search-forward

            bindkey "^X_" insert-last-word
            bindkey "^Xa" accept-and-hold
            bindkey -M vicmd "^R" redo
        else
            bindkey -e
        fi

        umask 022
        HISTSIZE=300
        SAVEHIST=0
    ;;
esac

# cd to a file (cd path/path/file)
# go to the directory containing the file, no questions asked 
#added support for cd foo bar to change from /foo/subdir to /bar/subdir 
function cd () {
    if [[ -z $2 ]]; then
        if [[ -f $1 ]]; then
            builtin cd $1:h
        else
            builtin cd $1
        fi
    else
        if [[ -z $3 ]]; then
            builtin cd $1 $2
        else
            echo cd: too many arguments
        fi
    fi
}

# under screen label the screen window, under xterm label title bar
function title {
    if [[ $TERM == screen* ]] ||
       [[ $TERM == "vt100" ]] && [[ $HOST =~ scotch* ]]; then
        # screen hard status
        print -nR $'\033k'$USERNAME@$HOST[(ws:.:)1]+$1$'\033'\\
        # xterm bar
        print -nR $'\033]0;'$USERNAME@$HOST[(ws:.:)1]+$*$'\a'
    elif [[ $TERM == ((rxvt|vt220|xterm*)) ]]; then
        # Use this one instead for XTerms:
        print -nR $'\033]0;'$USERNAME@$HOST[(ws:.:)1]+$*$'\a'
    fi
}

function precmd { title zsh "$PWD" }

function console {
    ipmitool -I lanplus -H ${1}-ipmi -U root sol activate
}

## General completion technique - complete as much u can ..
zstyle ':completion:*' completer _complete _list _oldlist _expand _ignored _match _correct _approximate _prefix

## allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'

## formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format $'%{\e[0;31m%}%d%{\e[0m%}'
zstyle ':completion:*:messages' format $'%{\e[0;31m%}%d%{\e[0m%}'
zstyle ':completion:*:warnings' format $'%{\e[0;31m%}No matches for: %d%{\e[0m%}'
zstyle ':completion:*:corrections' format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
zstyle ':completion:*' group-name ''

## case-insensitive (uppercase from lowercase) completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
## case-insensitive (all) completion
#zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
## case-insensitive,partial-word and then substring completion
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

## offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

## insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions

## ignore completion functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'

## completion caching
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zcompcache/$HOST

## add colors to completions
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

## on processes completion complete all user processes
zstyle ':completion:*:processes' command 'ps -au$USER'

## add colors to processes for kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
