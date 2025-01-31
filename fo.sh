function fo() {
    # Tested on OSX only.
    [ `uname -s` != 'Darwin' ] && return

    # Install brew
    if [ ! -x "$(which brew)" ];then
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    # Install fzf 
    [ ! -x "$(which fzf)" ] && brew install fzf
    # Install fd
    [ ! -x "$(which fd)" ] && brew install fd
    # Install bat
    [ ! -x "$(which bat)" ] && brew install bat

    local out filepath input ext
    input="fd . $HOME -H "
    IFS=$'\n' 
    out=($(eval $input | fzf --preview-window down:10 --preview='[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || cat{}) 2> /dev/null | head -200' --exit-0))
    filepath="$(head -2 <<< "$out" | tail -1)"
    ext="${filepath##*.}"

    # Enter directory
    if [ -d "$filepath" ];then
      cd "$filepath"
      return
    fi

    # All else must be a file to continue.
    if [ ! -f "$filepath" ];then
      return
    fi

    if [[ $(file -b "$filepath") =~ (JPEG|PDF|PNG|JPEG|GIF) ]];then
        open "$filepath"
    else
      # Exclude all executables except .sh or .zsh files for now.
      if [ -x "$filepath" ] && ([ $ext != "sh" ] && [ $ext != "zsh" ]);then
        echo "$filepath is an executable."
        return
      fi
      # Use your favourite editor. (In my case, it's vim)
      ${EDITOR:-vim} "$filepath"
    fi
}
