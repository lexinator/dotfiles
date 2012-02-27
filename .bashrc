# enough so that i can survive in bash

# all the stuff below is for interactive sessions
#prompts
PROMPT='%n@%m%#'

#shell features
#set -o notify
#set -o emacs
#set -o ignoreeof
#set -o noclobber
#set -o posix

#aliases
alias ls='ls -F'
alias d='ls -C'
alias dir='ls -lg'

alias rm='rm -i'
alias mv='mv -i'
alias ttyset='set noglob; eval `tset -sQ -m :?vt100` ; unset noglob'

alias vi=vim

alias j=jobs
alias e=edit

#OS command specific
case "`uname -s`" in
	Linux)
		alias su='su -m'
		alias ls='ls --color=auto'
		;;

	SunOS)
		alias ping='ping -s'
		;;
esac

function title {
	if [ $TERM == "screen" ]; then
		# Use these two for GNU Screen:
		echo "\033]0;\u@\h:\w\a"
#		echo -e '\033k'$USER@$HOSTNAME:r:r+$1$'\033'
#		echo -e '\033]0;'$*$'\a'
	elif [ $TERM == xterm ] || [ $TERM == rxvt ] ||
	     [ $TERM == xterms ]; then
		# Use this one instead for XTerms:
		echo "\[\033]0;\u@\h:\w\007\]"
#		echo -e '\033]0;'$USER@$HOSTNAME:r:r+$*$'\a'
	fi
	}

case $TERM in
	xterm|rxvt|xterms|screen)
		#local TITLEBAR=`title $cmd[1]:t "$cmd[2,-1]"`
		TITLEBAR='\[\033]0;\u@\h:\w\007\]'

		PS1="${TITLEBAR}\u@\h:\w%"
		;;

		*) PS1='\u@\h:\w\$'
		;;
esac

