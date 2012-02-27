#
# a worthy start up file
#
umask 022

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
	*kuci*)
		if [[ -f /pkg/modules/init/zsh ]] then
			. /pkg/modules/init/zsh
			module load vim irc mh
		fi
		;;

	scotch*|bourbon*)
		if [[ -f /pkg/modules/init/zsh ]] then
			. /pkg/modules/init/zsh
			module load default rsync nmh vim gsu screen rcs wget top \
			            cvs gcc perl gtar combo/sysadmin subversion
		else
			echo "no modules on scotch, something fishy is going on"
		fi

		case "`uname -r`" in
			5*) export PATH=$HOME/bin/sunos5/`uname -p`:$PATH ;;
		esac
		;;

	#sun/linux/whatever path
	*) PATH=/opt/local/bin:/usr/bin:/bin:/opt/local/sbin:/usr/sbin:$PATH
       PATH=/usr/sfw/bin:$PATH
		PATH=$PATH:/opt/sfw/gcc-3/bin:/pkg/bin:/sbin::/opt/sfw/bin
		PATH=$PATH:/usr/X11R6/bin:/usr/local/bin 
		MANPATH=/usr/man:/usr/share/man:/usr/sfw/man:/opt/sfw/man:/usr/dt/man
		MANPATH=$MANPATH:/opt/sfw/mysql/man:/usr/local/man
		MANPATH=$MANPATH:/opt/local/man
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

#get ssh agent
authssh
