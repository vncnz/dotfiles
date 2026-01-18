#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:pwd:history:clear:shutdown:reboot:date:man:mp"

alias ls='ls --color=auto'
alias grep='grep --color=auto'

PS1='[\u@\h \W]\$ '

# PS1="\[\e[00;32m\][\u / \W]\[\e[0m\] "

# PS1=" \$(if [ \$? -eq 0 ]; then echo '\e[32m✔\e[0m'; else echo '\e[31m✘\e[0m'; fi) \u \w > "
# PS1="\${?#0} \$ "


# RESET="\[\017\]"
# NORMAL="\[\033[0m\]"
# RED="\[\033[31;1m\]"
# YELLOW="\[\033[33;1m\]"
# WHITE="\[\033[37;1m\]"
# SMILEY="${WHITE}:)${NORMAL}"
# FROWNY="${RED}:(${NORMAL}"
# SELECT="if [ \$? = 0 ]; then echo \"${SMILEY}\"; else echo \"${FROWNY}\"; fi"
# Throw it all together 
# PS1="${RESET}\[\033[177;1m\]\h${NORMAL} \`${SELECT}\` ${YELLOW}>${NORMAL} "

alias emo="unipicker --copy-command \"wl-copy\""

alias gitdraw="git log --graph --abbrev-commit --decorate --format=format:'%C(yellow)%h%C(reset)%C(auto)%d%C(reset) %C(normal)%s%C(reset) %C(dim white)%an%C(reset) %C(dim blue)(%ar)%C     (reset)' --all"

# Make rm always interactive. If you want to remove a lot of files without confirm, you can pipeline yes and rm (yes | rm ...)
alias rm='rm -i'

if ! command -v xo >/dev/null; then
  command -v xo > /dev/null || xo () {
    # nohup xdg-open "$1" > /dev/null 2>&1 &
    setsid xdg-open "$1" > /dev/null 2>&1 &
    disown
    echo -e "\n\033[0;32m\033[1mDetached open request sent for $1\033[0m"
  }

  _xo_complete() {
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -f -- "$cur") )
  }

  complete -F _xo_complete xo

fi


# command -v deta > /dev/null || deta () {
if ! command -v deta >/dev/null; then
  deta () {
    # nohup xdg-open "$1" > /dev/null 2>&1 &
    setsid $1 > /dev/null 2>&1 &
    disown
    echo -e "\n\033[0;32m\033[1mDetached $1 started\033[0m"
  }

  _customrun_complete() {
      local cur
      cur="${COMP_WORDS[COMP_CWORD]}"

      COMPREPLY=( $(compgen -c -- "$cur") )
  }

  complete -F _customrun_complete deta
fi





shutdown() {
    # read -r -p "Shutdown the system? [y/N] " ans
    read -r -t 10 -p "Shutdown the system? [y/N] " ans || exit
    [[ $ans =~ ^[yY](es)?$ ]] && systemctl poweroff
}

reboot() {
    read -r -t 10 -p "Reboot the system? [y/N] " ans || exit
    [[ $ans =~ ^[yY](es)?$ ]] && systemctl reboot
}

calc () {
    awk "BEGIN{print $*}";
}

ff720() {
  if [ -z "$1" ]; then
    echo "Use: ff720 <file_input> [crf]"
    return 1
  fi

  input="$1"
  crf="${2:-22}"
  output="${input%.*}_720p_hevc.mkv"

  ffmpeg -i "$input" \
    -map 0:v:0 -map 0:a? \
    -map 0:s? \
    -vf "scale=-2:720" \
    -c:v libx265 -preset medium -crf "$crf" \
    -c:a copy \
    "$output"
}

ff720hw () {
    if [ -z "$1" ]; then
    echo "Use: ff720 <file_input> [crf]"
    return 1
  fi

  input="$1"
  bitrate="${2:-2500}"
  output="${input%.*}_720p_hevc_hw.mkv"

  ffmpeg -hwaccel vaapi -vaapi_device /dev/dri/renderD128 \
    -i "$input" \
    -map 0:s? \
    -vf 'format=nv12,hwupload,scale_vaapi=w=-2:h=720' \
    -c:v hevc_vaapi -rc_mode VBR -b:v "${bitrate}k" -maxrate 3500k -bufsize 5000k \
    -c:a copy \
    "$output"
  # -c:v hevc_vaapi -qp "$qp" \
  # -c:v hevc_vaapi -rc_mode ICQ -global_quality 27 \
}

mp () {
  local base="/run/media/vncnz/Dati/Music"

(
  cd $base || exit
  local selection
  selection=$(find . -type f |
              fzf --multi --extended --exact --highlight-line \
                  --delimiter='/' --nth=1,2,3 --with-nth=2..\
                  --bind 'ctrl-t:toggle-all' \
                  --bind 'tab:toggle+up' \
                  --bind 'ctrl-a:select-all' \
                  --bind 'ctrl-d:clear-multi')
                  # --prompt="🎵 ")
  # Add --exact or keep fuzzy search?

  if [ -n "$selection" ]; then
    printf '%s\n' "$selection" | kmp3 -v 100
  #else
  #   find . -type f | kmp3 -v 100
  fi
)
}

music() {
  if [ -t 0 ]; then
    kmp3 -v 100 /run/media/vncnz/Dati/Music/$@
  else
    kmp3 -v 100
  fi
}

_music_complete() {
  local base="/run/media/vncnz/Dati/Music"
  local cur="${COMP_WORDS[COMP_CWORD]}"

  # If globbing is already in play, do nothing
  [[ "$cur" == *[\*\?\[]* ]] && return 0

  local IFS=$'\n'
  local matches=($(compgen -f -- "$base/$cur"))

  COMPREPLY=()
  for m in "${matches[@]}"; do
    local rel="${m#$base/}"
    if [ -d "$m" ]; then
      COMPREPLY+=( "$rel/" )
    else
      COMPREPLY+=( "$rel" )
    fi
  done
}


complete -o nospace -F _music_complete music


# Add user-specific bin directory to PATH
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
