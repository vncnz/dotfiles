#
# ~/.bash_profile
#

# Add user-specific bin directory to PATH
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
export PATH


[[ -f ~/.bashrc ]] && . ~/.bashrc
