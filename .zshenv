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
    scotch*|bourbon*)
        if [[ -f /pkg/modules/init/zsh ]] then
            . /pkg/modules/init/zsh
            module load default rsync nmh vim gsu screen rcs wget top \
                        cvs gcc perl gtar combo/sysadmin subversion
        else
            echo "Expected modules on $HOST, something fishy is going on"
        fi

        case $(uname -r) in
            5*) export PATH=$HOME/bin/sunos5/$(uname -p):$PATH ;;
        esac
        ;;

    #sun/linux/meh whatever path
    *)
        path=(/usr/local/bin /usr/local/sbin
              /opt/local/bin /opt/local/sbin
              /usr/bin /bin /usr/sbin /sbin
              /usr/sfw/bin /opt/sfw/gcc-3/bin
              /opt/bin /opt/sbin /pkg/bin
              /opt/X11/bin /usr/X11R6/bin $path)
        manpath=(/usr/man /usr/share/man /usr/sfw/man /opt/sfw/man
                 /usr/dt/man /opt/sfw/mysql/man /usr/local/man
                 /opt/local/man $manpath)
        export PATH
        export MANPATH
        ;;
esac

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
#
export RSYNC_RSH=ssh
export VAGRANT_DEFAULT_PROVIDER='vmware_fusion'
export VAGRANT_VMWARE_CLONE_DIRECTORY=~/tmp/vagrant
export SELFIE_UPDATE_NAG=1

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

authssh
