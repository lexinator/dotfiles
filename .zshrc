# Enable Powerlevel10k instant. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# profiling dotfiles https://kev.inburke.com/kevin/profiling-zsh-startup-time/
PROFILE_STARTUP=false
if [[ $PROFILE_STARTUP == true ]]; then
    PS4=$'%D{%M%S%.} %N:%i> '
    exec 3>&2 2>$HOME/tmp/startlog.$$
    setopt xtrace prompt_subst
fi

# all the stuff below is for interactive sessions
uptime

OS=$(uname -s)

#prompts
PROMPT='%n@%m%#'
RPROMPT='%(?..[%?])%T %v%~'
REPORTTIME=7

# my general preferences
setopt autolist auto_menu nohup list_types always_last_prompt auto_cd correct
setopt append_history hist_ignore_dups hist_ignore_space auto_resume
setopt hist_no_store extended_history complete_in_word ALWAYS_TO_END
setopt hist_expire_dups_first hist_reduce_blanks transient_rprompt
setopt share_history hist_find_no_dups inc_append_history
unsetopt list_beep menu_complete

#aliases
alias ls='ls -F'
alias ssh='ssh -A'
alias laxssh='ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oLogLevel=ERROR'
alias sudo='sudo -E'
alias rm='rm -i'
alias mv='mv -i'
alias les='less'
alias ttyset='set noglob; eval `tset -sQ -m :?vt100` ; unset noglob'
alias rsync='rsync -av --progress --stats'
alias aptinstall='apt-get update 1> /dev/null && apt-get install --force-yes'
alias tcpcount='netstat -an | egrep -v "127.0.0|10.16|^udp|^unix|LISTEN|^Proto|Active" | awk "{print \$6}" | sort | uniq -c | sort -nr'
alias pss='ps -e -o pid,user,rss,vsz,stime,time,args'
alias http='http --style solarized'

if (( $+commands[vim] )); then
    alias vi=vim
fi
if (( $+commands[nvim] )); then
    alias vi=nvim
fi

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

#OS command specific
psvar=$OS
case $OS in
    Linux)
        if [[ $EUID -ne 0 ]]; then
           alias su='su -m -s =zsh'
        fi
        if ls -d --color=auto / &> /dev/null; then
            alias ls='ls -F --color=auto'
        fi
        export GREP_COLOR='1;32'
        alias grep='grep --color=auto'

        #debian/ubuntu
        if [[ -f /etc/lsb-release ]]; then
            psvar="${psvar}-$(grep CODENAME /etc/lsb-release | \
                              awk -F= '{print $2}')"
        fi
        #redhat/centos
        if [[ -f /etc/redhat-release ]]; then
            export SYSSCREENRC=/dev/null
            if grep -q CentOS /etc/redhat-release; then
                psvar="${psvar}-$(awk '{print "cent-"$3}' /etc/redhat-release)"
            else
                psvar="${psvar}-$(awk '{print "rh-"$7$8}' /etc/redhat-release)"
            fi
        else
            if (( $+commands[lessfile] )); then
                eval "$(lessfile)"
            fi
        fi
        ;;

    SunOS)
        if (( $+commands[gtar] )); then
            alias tar=gtar
        fi
        alias ping='ping -s'
        alias truss_off 'truss -w2 -t \\!setcontext,\\!brk,\\!ioctl,\\!poll,\\!sigprocmask'
        ;;

    Darwin)
        psvar="${psvar}-$(sw_vers -productVersion)"
        export COMMAND_MODE=unix2003
        #manpage for definition
        export LSCOLORS=ExGxDxdxCxegedabagacad
        export GREP_COLOR='1;32'
        alias grep='grep --color=auto'
        alias ls='ls -G'
        alias lockscreen='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
        export BROWSER='open'
        # darwin defaults to sorted by PID...
        alias top='top -ocpu'
        ;;
esac

function setprompt {
    setopt prompt_subst
    autoload -U is-at-least

    # See if we can use extended characters to look nicer.
    typeset -A altchar
    set -A altchar ${(s..)terminfo[acsc]}
    PR_SET_CHARSET="%{$terminfo[enacs]%}"
    PR_SHIFT_IN="%{$terminfo[smacs]%}"
    PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
    PR_HBAR=${altchar[q]:--}
    PR_ULCORNER=${altchar[l]:--}
    PR_LLCORNER=${altchar[m]:--}
    PR_LRCORNER=${altchar[j]:--}
    PR_URCORNER=${altchar[k]:--}

    #TODO: figure out when in utf
    #PR_RIGHTARROW="➤"
    PR_RIGHTARROW=">"
    PR_LEFTARROW=${altchar[<]:-<}

    if [[ $TERM == *256color* || \
          $TERM == *rxvt* || \
          $TERM == "eterm-color" ]]; then
        if is-at-least 4.3; then
            # use 256 colors
            PR_CYAN='%F{081}'
            PR_WHITE='%F{255}'
            PR_DEFAULT='%f'
            PR_BLUE='%F{024}'
            PR_DARKRED='%F{001}'
            PR_RED='%F{009}'
            PR_GREEN='%F{048}'
            PR_YELLOW='%F{011}'
        else
            # use 16 colors
            autoload -U colors
            colors

            if [[ -n $fg ]]; then
                PR_CYAN="$fg[cyan]"
                PR_WHITE="$fg[white]"
                PR_DEFAULT="$fg[default]"
                PR_BLUE="$fg[blue]"
                PR_DARKRED="$fg[red]"
                PR_GREEN="$fg[green]"
                PR_YELLOW="$fg[yellow]"
            else
                PR_CYAN=""
                PR_WHITE=""
                PR_DEFAULT=""
                PR_BLUE=""
                PR_DARKRED=""
                PR_GREEN=""
                PR_YELLOW=""
            fi
        fi
    elif [[ $TERM == *color* ]]; then
        # use 16 colors
        autoload -U colors
        colors
        if [[ -n $fg ]]; then
            PR_CYAN="$fg[cyan]"
            PR_WHITE="$fg[white]"
            PR_DEFAULT="$fg[default]"
            PR_BLUE="$fg[blue]"
            PR_DARKRED="$fg[red]"
            PR_GREEN="$fg[green]"
            PR_YELLOW="$fg[yellow]"
        else
            PR_CYAN=""
            PR_WHITE=""
            PR_DEFAULT=""
            PR_BLUE=""
            PR_DARKRED=""
            PR_GREEN=""
            PR_YELLOW=""
        fi
    else
        PR_CYAN=""
        PR_WHITE=""
        PR_DEFAULT=""
        PR_BLUE=""
        PR_DARKRED=""
        PR_GREEN=""
        PR_YELLOW=""
    fi

    TOPLINE_PROMPT='$PR_SET_CHARSET\
${PR_GREEN}%(!.${PR_DARKRED}root%f.%n)$PR_BLUE@${PR_GREEN}%m\
$PR_YELLOW %T$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_HBAR\
${(e)PR_FILLBAR}$PR_HBAR$PR_SHIFT_OUT\
$GITSTATUS\
$PR_CYAN$PR_SHIFT_IN$PR_URCORNER$PR_SHIFT_OUT'
    BOTTOMLINE_PROMPT='\
$PR_CYAN$PR_SHIFT_IN$PR_LLCORNER$PR_HBAR$PR_SHIFT_OUT$PR_RIGHTARROW\
%(!.$PR_DARKRED.$PR_WHITE)%#$PR_DEFAULT '

#$(typeset -f git_prompt_info 1>/dev/null && git_prompt_info)\
#$(typeset -f git_prompt_status 1>/dev/null && git_prompt_status)\
    PROMPT="$TOPLINE_PROMPT\

$BOTTOMLINE_PROMPT"
    RPROMPT='$PR_CYAN\
%(?..$PR_RED%? )\
$PR_YELLOW%v$PR_RIGHTARROW \
$PR_WHITE%$PR_PWDLEN<...<%~%<<\
$PR_CYAN $PR_SHIFT_IN$PR_HBAR$PR_LRCORNER$PR_SHIFT_OUT\
$PR_DEFAULT'

#    PS2='$PR_CYAN$PR_SHIFT_IN$PR_LLCORNER$PR_SHIFT_OUT\
#$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
#$PR_GREEN%_>\
#$PR_DEFAULT'

    setopt transient_rprompt
    PS2=''
    RPS2='$PR_GREEN<%^\
$PR_DEFAULT'

    ZSH_THEME_GIT_PROMPT_PREFIX="${PR_WHITE}"
    ZSH_THEME_GIT_PROMPT_SUFFIX=" ${PR_WHITE}"

    ZSH_THEME_GIT_PROMPT_DIRTY=" ${PR_DARKRED}✘dirty"
    ZSH_THEME_GIT_PROMPT_AHEAD="${PR_YELLOW}!ahead"
    ZSH_THEME_GIT_PROMPT_CLEAN="${PR_GREEN}✓"

    ZSH_THEME_GIT_PROMPT_ADDED="$PR_GREEN✚ "
    ZSH_THEME_GIT_PROMPT_MODIFIED="$PR_BLUE✹ "
    ZSH_THEME_GIT_PROMPT_DELETED="$PR_RED✖ "
    ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%}➜ rename "
    ZSH_THEME_GIT_PROMPT_UNMERGED="$PR_YELLOW═ unmerged "
    ZSH_THEME_GIT_PROMPT_UNTRACKED="$PR_CYAN…untracked "

    ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE="="
    ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE="↑"
    ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR="$PR_GREEN"
    ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="↓"
    ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR="$PR_RED"
    ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE="diverged "

    ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_DETAILED=true
    DISABLE_UNTRACKED_FILES_DIRTY=true
}

# put functions before site-functions
setopt null_glob
fpath=(/usr/local/share/zsh/functions
    /usr/local/share/zsh/site-functions
    $fpath)
unsetopt null_glob

#user specific stuff
case $USERNAME in
    aludeman|lex|ludeman)
        export BINDKEYMODE="vi"
        bindkey -v
        # use even more autocompletions
        if [[ -d ~/src/zsh-completions/src ]]; then
            fpath=(~/src/zsh-completions/src $fpath)
        fi

        #check if zload exists
        setopt nullglob
        if [[ -d ~/zload ]] && [[ -n $(echo ~/zload/*) ]]; then
            fpath=(~/zload $fpath)
            for config_file (~/zload/*.zsh) source $config_file
            setopt extendedglob
            for config_file (~/zload/^*.zsh) autoload -U $config_file:t
            setopt no_extendedglob
        fi
        setopt no_nullglob

        HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=blue,fg=white,bold"
        export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND

        # avoid slow pastes
        ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=10

        FIGNORE='.pyc:.o'

        umask 022
        HISTFILE=~/.zsh_history
        HISTSIZE=900000000
        SAVEHIST=$HISTSIZE

        if [[ -d ~/bin/$OS ]]; then
            PATH=~/bin/$OS:$PATH
        fi

        if (( $+commands[git] )); then
            GIT_VERSION=$(git --version | awk '{print $3}')

            function git_lex {
                # compdef git_lex=git
                local cmd extra
                cmd=$1
                shift

                case $cmd in
                    commit|amend)
                        extra='--verbose'
                        ;;
                    ogpull)
                        cmd='pull'
                        extra='--stat'
                        ;;
                    rebase)
                        # can't add --verbose when using some commands
                        case $@[1] in
                            --abort|--continue|--skip) ;;
                            *) extra='--verbose' ;;
                        esac
                        ;;
                    pull)
                        git fetch
                        cmd='rebase'
                        extra='--stat'

                        # autostash doesn't exist on 1.7.1
                        case $GIT_VERSION in
                            2*) extra="$extra --autostash" ;;
                        esac

                        #remove --rebase if it exists
                        argv[$argv[(i)--rebase]]=()
                        ;;
                    *)
                        extra=""
                        ;;
                esac

                git $cmd $=extra $@
            }
            alias git='git_lex'
            setopt complete_aliases
        fi

    ;;

    *)  #let's do this
        if [[ $BINDKEYMODE == "vi" ]]; then
            bindkey -v
        else
            bindkey -e
        fi

        umask 022
        HISTSIZE=999999
        SAVEHIST=0
    ;;
esac

if [[ $BINDKEYMODE == "vi" ]]; then
    # see if history-substring is loaded
    if declare -f history-substring-search-up 1>/dev/null; then
        # up arrow
        bindkey "$terminfo[kcuu1]" history-substring-search-up
        bindkey "$terminfo[cuu1]" history-substring-search-up
        # down arrow
        bindkey "$terminfo[kcud1]" history-substring-search-down
        bindkey '^[[B' history-substring-search-down

        bindkey -M vicmd 'k' history-substring-search-up
        bindkey -M vicmd 'j' history-substring-search-down
    else
        bindkey "^[[A" history-beginning-search-backward
        bindkey "^[OA" history-beginning-search-backward
        bindkey "^Xr" history-incremental-search-backward
        bindkey "^[[B" history-beginning-search-forward
        bindkey "^[OB" history-beginning-search-forward
        bindkey "^Xs" history-incremental-search-forward
    fi

    bindkey "^Xq" push-line-or-edit
    bindkey "^X_" insert-last-word
    bindkey "^Xa" accept-and-hold
    bindkey '^W' backward-kill-word
    bindkey ' ' magic-space

    function backward-kill-partial-word {
        local WORDCHARS="${WORDCHARS//[\/.]/}"
        zle backward-kill-word "$@"
    }
    zle -N backward-kill-partial-word
    bindkey "^Xw" backward-kill-partial-word
    bindkey "^X^w" backward-kill-partial-word

    # ctrl arrows
    bindkey "^[[1;5D" backward-word
    bindkey "^[[1;5C" forward-word
fi
setprompt

#remove any duplicates
typeset -U fpath

autoload -U compinit
compinit -C -d ~/.zcompdump_$ZSH_VERSION

function preexec {
    emulate -L zsh
    local -a cmd
    # Re-parse the command line
    cmd=(${(z)1})

    # Construct a command that will output the desired job number.
    case $cmd[1] in
        fg)
            if (( $#cmd == 1 )); then
                # No arguments, must find the current job
                cmd=(builtin jobs -l %+)
            else
                # Replace the command name, ignore extra args.
                cmd=(builtin jobs -l ${(Q)cmd[2]})
            fi
            ;;
        # Same as "else" %above
        %*) cmd=(builtin jobs -l ${(Q)cmd[1]}) ;;

        # Not resuming a job, so we're all done
        *)
          title $cmd[1]:t "$cmd[2,-1]"
          return
          ;;
    esac

    # Copy jobtexts for subshell
    local -A jt; jt=(${(kv)jobtexts})

    # Run the command, read its output, and look up the jobtext.
    # Could parse $rest here, but $jobtexts (via $jt) is easier.
    $cmd >>(read num rest
            cmd=(${(z)${(e):-\$jt$num}})
    title $cmd[1]:t "$cmd[2,-1]") 2>/dev/null
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

function precmd {
    title zsh "$PWD"
    GITSTATUS="${PR_RIGHTARROW}\
$(typeset -f git_prompt_info 1>/dev/null && git_prompt_info)\
$(typeset -f git_prompt_status 1>/dev/null && git_prompt_status)\
$(typeset -f git_remote_status 1>/dev/null && git_remote_status)\
${PR_LEFTARROW}"

    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))
    PR_FILLBAR=""
    PR_PWDLEN=""

    local removeColors='%([BSUbfksu]|([FB]|){*})|$GITSTATUS|$PR_SET_CHARSET|$PR_SHIFT_IN|$PR_SHIFT_OUT|${(PR_RED|PR_GREEN|PR_DARKRED|PR_BLUE|PR_WHITE|PR_CYAN)}|$(PR_GREEN|PR_RED|PR_DARKRED|PR_BLUE|PR_WHITE|PR_CYAN|PR_YELLOW)|${\(e\)PR_FILLBAR}|%$PR_PWDLEN<...<%~%<<'
    local promptsize=${#${(S%%)TOPLINE_PROMPT//$~removeColors/}}
    local gitstatussize=${#${(S%%)GITSTATUS//$~removeColors/}}
    promptsize=$(($promptsize + $gitstatussize))

    #local pwdsize=${#${(%):-%~}}
    local pwdsize=0

    #calculate terminal width
    if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
        ((PR_PWDLEN=$TERMWIDTH - $promptsize))
    else
        PR_FILLBAR="\${(l.(($TERMWIDTH -($promptsize+$pwdsize)))..${PR_HBAR}.)}"
    fi
}

# zman "f "  http://chneukirchen.org/blog/category/zsh.html
function zman {
    PAGER="less -g -s '+/^       "$1"'" man zshall
}

###chpwd_zz() {
###  print -P '0\t%D{%s}\t1\t%~' >>~/.zz
###}
###zz() {
###  awk -v ${(%):-now='%D{%s}'} <~/.zz '
###    function r(t,f) {
###      age = now - t
###      return (age<3600) ? f*4 : (age<86400) ? f*2 : (age<604800) ? f/2 : f/4
###    }
###    { f[$4]+=$3; if ($2>l[$4]) l[$4]=$2 }
###    END { for(i in f) printf("%d\t%d\t%d\t%s\n",r(l[i],f[i]),l[i],f[i],i) }' |
###      sort -k2 -n -r | sed 9000q | sort -n -r -o ~/.zz
###  if (( $# )); then
###    local p=$(awk 'NR != FNR { exit }  # exit after first file argument
###                   { for (i = 3; i < ARGC; i++) if ($4 !~ ARGV[i]) next
###                     print $4; exit }' ~/.zz ~/.zz "$@")
###    [[ $p ]] || return 1
###    local op=print
###    [[ -t 1 ]] && op=cd
###    if [[ -d ${~p} ]]; then
###      $op ${~p}
###    else
###      # clean nonexisting paths and retry
###      while read -r line; do
###        [[ -d ${~${line#*$'\t'*$'\t'*$'\t'}} ]] && print -r $line
###      done <~/.zz | sort -n -r -o ~/.zz
###      zz "$@"
###    fi
###  else
###    sed 10q ~/.zz
###  fi
###}
###alias z=' zz'
###chpwd_functions=( ${(kM)functions:#chpwd?*} )

# use 'cdr' for this
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
#zstyle ':chpwd:*' recent-dirs-max 20
#zstyle ':chpwd:*' recent-dirs-default true
#zstyle ':completion:*' recent-dirs-insert fallback

# cd to a file (cd path/path/file)
# go to the directory containing the file, no questions asked
# added support for cd foo bar to change from /foo/subdir to /bar/subdir
function cd {
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

if zle -l | grep -q autosuggest-accept 1>/dev/null; then
    bindkey '^ ' autosuggest-accept

    ZSH_AUTOSUGGEST_CLEAR_WIDGETS=("${(@)ZSH_AUTOSUGGEST_CLEAR_WIDGETS:#(up|down)-line-or-history}")
    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(history-substring-search-up history-substring-search-down)
fi

# ctrl-j, then the letter you are looking to go to...
if declare -f jump-target 1> /dev/null; then
      bindkey "^J" jump-target
      bindkey -M vicmd "^J" jump-target
      ZSH_JUMP_TARGET_CHOICES="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      ZSH_JUMP_TARGET_STYLE="fg=black,underline,bg=red"
fi

# allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'

# when cycling through items, highlight item
zstyle ':completion:*' menu select

# formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''

zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'

# case-insensitive (uppercase from lowercase) completion
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# case-insensitive (all) completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# case-insensitive, partial-word and then substring completion
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# statusline for many hits
zstyle ':completion:*:default' select-prompt $'\e[01;35m -- Match %M    %P -- \e[00;00m'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions

# Ignore internal zsh functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'

# completion caching
zstyle ':completion:*' use-cache yes
zstyle ':completion::complete:*' use-cache yes
zstyle ':completion::complete:*' cache-path ~/.zcompcache/$HOST

# Speedup path completion
zstyle ':completion:*' accept-exact '*(N)'

# add colors to completions
if [[ -z $LS_COLORS ]]; then
  if (( $+commands[dircolors] )); then
    eval $(dircolors -b)
  elif (( $+commands[gdircolors] )); then
    eval $(gdircolors -b)
  else
    echo 'no ls colors found'
  fi
fi
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' list-colors ''

zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack \
                              path-directories
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' \
                                 'path-directories' 'users' 'expand'
zstyle ':completion:*' squeeze-slashes true

# on processes completion complete all user processes
zstyle ':completion:*:processes' command 'ps -au$USER'

# add colors to processes for kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# zstyle ':completion:*:history-words' remove-all-dups yes

zstyle ":completion:*" show-completer true

zstyle ":history-search-multi-word" page-size "10"

if [[ -z $ENABLE_AUTOFU ]]; then
    if (( $+commands[auto-fu-init] )); then
        zle-line-init () {
            auto-fu-init
        }
        zle -N zle-keymap-select auto-fu-zle-keymap-select
        zle -N zle-line-init
        zstyle ':completion:*' completer _oldlist _complete _list _expand \
                               _ignored _match _prefix
    fi
else
    autoload -U is-at-least
    _glob_expand() {
        reply=( $~1* )
    }
    zstyle :completion::user-expand:: user-expand _glob_expand
    if is-at-least 5.3; then
        zstyle :completion::user-expand::: tag-order \
                                           'expansions all-expansions'
    else
        zstyle :completion::user-expand:: tag-order expansions all-expansions
    fi
    zstyle ':completion:*' completer _expand _complete _match _ignored \
                           _correct _approximate _prefix _user_expand
fi

zstyle ':completion:most-recent-file:*' match-original both
zstyle ':completion:most-recent-file:*' file-sort modification
zstyle ':completion:most-recent-file:*' file-patterns '*:all\ files'
zstyle ':completion:most-recent-file:*' hidden all
zstyle ':completion:most-recent-file:*' completer _files
zle -C most-recent-file menu-complete _generic
bindkey "^N" most-recent-file

autoload -U url-quote-magic
zle -N self-insert url-quote-magic

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
zstyle :bracketed-paste-magic paste-init backward-extend-paste

if [[ $PROFILE_STARTUP == true ]]; then
    unsetopt xtrace
    exec 2>&3 3>&-
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
