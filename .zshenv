#
# a worthy start up file
#
umask 022
setopt no_global_rcs

authssh() {
    #grab ssh agent session if available
    if [[ -n $HOME ]] && [[ -n $HOST ]]; then
        if [[ -e $HOME/tmp/$HOST-ssh-agent-s ]]; then
            export SSH_AUTH_SOCK=$HOME/tmp/$HOST-ssh-agent-s
        else
            if [[ -n $SSH_AUTH_SOCK ]] &&
                    [[ $SSH_AUTH_SOCK != $HOME/tmp/$HOST-ssh-agent-s ]]; then
                mkdir -p $HOME/tmp
                ln -sf $SSH_AUTH_SOCK $HOME/tmp/$HOST-ssh-agent-s
                export SSH_AUTH_SOCK=$HOME/tmp/$HOST-ssh-agent-s
            fi
        fi
    fi
}

case $HOST in
    # add the usual suspects
    *)
        path=(/opt/homebrew/bin
              /usr/local/bin /usr/local/sbin
              /opt/local/bin /opt/local/sbin
              /usr/bin /bin /usr/sbin /sbin
              /opt/bin /opt/sbin /pkg/bin
              /opt/X11/bin /usr/X11R6/bin $path)
        manpath=(/usr/man /usr/share/man /usr/local/man
                 /opt/local/man /usr/local/share/man $manpath)
        export PATH
        export MANPATH
        ;;
esac

# set up local user paths
if [[ -e ~$USERNAME/bin/shared ]]; then
    export PATH=~$USERNAME/bin/shared:$PATH
fi
if [[ -d ~$USERNAME/bin ]]; then
    export PATH=~$USERNAME/bin:$PATH
fi
if [[ -d ~$USERNAME/public/man ]]; then
    export MANPATH=~$USERNAME/public/man:$MANPATH
fi

# remove duplicate entries from path,manpath
typeset -U path manpath

export EDITOR=vi
export LESS="-x3iX"
export PAGER=less

if [[ -n $commands[src-hilite-lesspipe.sh] ]] && \
    [[ -n $commands[source-highlight] ]]; then
    export LESSOPEN="| $commands[src-hilite-lesspipe.sh] %s"
    export LESS="${LESS}R"
fi
#
export RSYNC_RSH=ssh
export VAGRANT_VMWARE_CLONE_DIRECTORY=~/tmp/vagrant

export GEM_HOME=~/tmp/local-gems

export HOMEBREW_CASK_OPTS=--require-sha
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_NO_ANALYTICS=1

export KO_DOCKER_REPO='host.docker.local:5000/ludeman'
export COURSIER_CREDENTIALS=~/.config/coursier/credentials.properties

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

authssh
