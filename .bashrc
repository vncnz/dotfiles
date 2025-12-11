#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
alias gitdraw="git log --graph --abbrev-commit --decorate --format=format:'%C(yellow)%h%C(reset)%C(auto)%d%C(reset) %C(normal)%s%C(reset) %C(dim white)%an%C(reset) %C(dim blue)(%ar)%C     (reset)' --all"

shutdown() {
    # read -r -p "Shutdown the system? [y/N] " ans
    read -r -t 10 -p "Shutdown the system? [y/N] " ans || exit
    [[ $ans =~ ^[yY](es)?$ ]] && systemctl poweroff
}

reboot() {
    read -r -t 10 -p "Reboot the system? [y/N] " ans || exit
    [[ $ans =~ ^[yY](es)?$ ]] && systemctl reboot
}

# Add user-specific bin directory to PATH
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
