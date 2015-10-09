#!/bin/zsh -f

BASE=$HOME/Dropbox

symfiles() {
    fullPath=($*)

    for fullfile in $fullPath; do
        filename=${fullfile:t}
        
        [[ $filename == ".git" ]] && continue
        if [[ -f $HOME/$filename ]] && [[ ! -L $HOME/$filename ]]; then
            echo "mv $HOME/$filename $HOME/${filename}.stock"
            mv $HOME/$filename $HOME/$filename.stock
        fi
        if [[ ! -L $HOME/$filename ]]; then
            echo "ln -s $fullfile $HOME/$filename"
            ln -s $fullfile $HOME/$filename
        fi
    done
}

symdirs() {
    fullDir=($*)
    for dirname in $fullDir; do
        baseName=${dirname:t}
        if [[ -d $HOME/$baseName ]] && [[ ! -L $HOME/$baseName ]]; then
            echo "mv $HOME/$baseName $HOME/${baseName}.stock"
            mv $HOME/$baseName $HOME/${baseName}.stock
        fi
        if [[ ! -L $HOME/$baseName ]]; then
            echo "ln -s $dirname $HOME/$baseName"
            ln -s $dirname $HOME/$baseName
        fi
    done
}

#prepare all dotfiles
symfiles $BASE/dotfiles/.[a-zA-Z]*

#deal with all private stuff
symdirs $BASE/local/{shared,zload}

#few more files
symfiles $BASE/local/.zshrc.local

if [[ -f $HOME/.ssh/config ]] && [[ ! -L $HOME/.ssh/config ]]; then
    echo "mv $HOME/.ssh/config $HOME/.ssh/config.stock"
    mv $HOME/.ssh/config $HOME/.ssh/config.stock
fi

if [[ ! -d $BASE/local ]]; then
    mkdir -p $BASE/local/{.ssh,bin,zload}
fi

if [[ ! -d $HOME/.ssh ]]; then
    mkdir -p $HOME/.ssh
    chmod 700 $HOME/.ssh
fi

if [[ ! -L $HOME/.ssh/config ]]; then
    if  [[ ! -f $BASE/local/.ssh/config ]]; then
        touch $BASE/local/.ssh/config
    fi
    echo "ln -s $BASE/local/.ssh/config $HOME/.ssh/config"
    ln -s $BASE/local/.ssh/config $HOME/.ssh/config
fi
