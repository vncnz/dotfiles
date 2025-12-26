#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

PS1='[\u@\h \W]\$ '
alias gitdraw="git log --graph --abbrev-commit --decorate --format=format:'%C(yellow)%h%C(reset)%C(auto)%d%C(reset) %C(normal)%s%C(reset) %C(dim white)%an%C(reset) %C(dim blue)(%ar)%C     (reset)' --all"

# Make rm always interactive. If you want to remove a lot of files without confirm, you can pipeline yes and rm (yes | rm ...)
alias rm='rm -i'

command -v xo > /dev/null || xo () {
  # nohup xdg-open "$1" > /dev/null 2>&1 &
  setsid xdg-open "$1" > /dev/null 2>&1 &
  disown
  echo -e "\n\033[0;32m\033[1mDetached open request sent for $1\033[0m"
}

command -v deta > /dev/null || deta () {
  # nohup xdg-open "$1" > /dev/null 2>&1 &
  setsid $1 > /dev/null 2>&1 &
  disown
  echo -e "\n\033[0;32m\033[1mDetached $1 started\033[0m"
}

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


# Add user-specific bin directory to PATH
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
