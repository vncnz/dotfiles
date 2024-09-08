#!/bin/bash

### AUTHOR:         Johann Birnick (github: jbirnick)
### PROJECT REPO:   https://github.com/jbirnick/waybar-timer

## FUNCTIONS

now () { date --utc +%s; }

killTimer () { rm -rf /tmp/waybar-timer ; }
timerSet () { [ -e /tmp/waybar-timer/ ] ; }
timerPaused () { [ -f /tmp/waybar-timer/paused ] ; }

timerExpiry () { cat /tmp/waybar-timer/expiry ; }
timerAction () { cat /tmp/waybar-timer/action ; }

secondsLeftWhenPaused () { cat /tmp/waybar-timer/paused ; }
minutesLeftWhenPaused () { echo $(( ( $(secondsLeftWhenPaused)  + 0 ) / 60 )) ; }
secondsLeft () { echo $(( $(timerExpiry) - $(now) )) ; }
minutesLeft () { echo $(( ( $(secondsLeft)  + 0 ) / 60 )) ; }
secondsLeftWhenPausedMod60 () { echo $(( $(secondsLeftWhenPaused) % 60 )) ; }
secondsLeftMod60 () { echo $(( ($(timerExpiry) - $(now)) % 60 )) ; }

printExpiryTime () { notify-send -u low -r 12345 "Timer expires at $( date -d "$(secondsLeft) sec" +%H:%M)" ;}
printPaused () { notify-send -u low -r 12345 "Timer paused" ; }
removePrinting () { notify-send -C 12345 ; }

updateTail () {
  # check whether timer is expired
  if timerSet
  then
    if { timerPaused && [ $(minutesLeftWhenPaused) -lt 0 ] ; } || { ! timerPaused && [ $(minutesLeft) -lt 0 ] ; }
    then
      eval $(timerAction)
      killTimer
      removePrinting
    fi
  fi

  # update output
  if timerSet
  then
    if timerPaused
    then
        class=""
      echo "{\"text\": \"$(minutesLeftWhenPaused)m$(secondsLeftWhenPausedMod60)s\", \"alt\": \"paused\", \"tooltip\": \"Timer paused\", \"class\": \"${class}\", \"icon\":\"󱫫\", \"m\": \"$(minutesLeftWhenPaused)m\", \"s\": \"$(secondsLeftWhenPausedMod60)s\" }"
    else
        class="ok-color"
        if (( $(minutesLeft) < 1 )); then
            class="err-color"
        elif (( $(minutesLeft) < 2 )); then
            class="warn-color"
        fi
      echo "{\"text\": \"$(minutesLeft)m$(secondsLeftMod60)s\", \"alt\": \"running\", \"tooltip\": \"Timer expires at $( date -d "$(secondsLeft) sec" +%H:%M)\", \"class\": \"${class}\", \"icon\":\"󱤥\", \"m\": \"$(minutesLeft)m\", \"s\": \"$(secondsLeftMod60)s\" }"
    fi
  else
    echo "{\"text\": \"0\", \"alt\": \"standby\", \"tooltip\": \"No timer set\", \"class\": \"timer\", \"icon\":\"󰔞\" }"
  fi
}

## MAIN CODE

case $1 in
  insert)
    v=$(echo -e "1m0s\n2m0s\n5m0s\n25m0s\n60m0s" | fuzzel --dmenu --prompt="")
    #echo $v
    if [ -z $v ]; then
        exit 1
    fi
    if timerSet
    then
        killTimer
    fi
    mkdir /tmp/waybar-timer
    minutes=$(echo "$v" | sed -n 's/\([0-9]\+\)m.*/\1/p')
    seconds=$(echo "$v" | sed -n 's/.*m\([0-9]\+\)s/\1/p')
    if [ -z $seconds ]; then
        seconds=0
    fi
    # echo "$(( 60*${minutes} + ${seconds} ))"
    echo "$(( $(now) + 60*${minutes} + ${seconds} ))" > /tmp/waybar-timer/expiry
    echo "${3}" > /tmp/waybar-timer/action
    printExpiryTime
  ;;
  updateandprint)
    updateTail
    ;;
  new)
    killTimer
    mkdir /tmp/waybar-timer
    echo "$(( $(now) + 60*${2} ))" > /tmp/waybar-timer/expiry
    echo "${3}" > /tmp/waybar-timer/action
    printExpiryTime
    ;;
  increase)
    if timerSet
    then
      if timerPaused
      then
        echo "$(( $(secondsLeftWhenPaused) + ${2} ))" > /tmp/waybar-timer/paused
      else
        echo "$(( $(timerExpiry) + ${2} ))" > /tmp/waybar-timer/expiry
        printExpiryTime
      fi
    else
      exit 1
    fi
    ;;
  cancel)
    killTimer
    removePrinting
    ;;
  togglepause)
    if timerSet
    then
      if timerPaused
      then
        echo "$(( $(now) + $(secondsLeftWhenPaused) ))" > /tmp/waybar-timer/expiry
        rm -f /tmp/waybar-timer/paused
        printExpiryTime
      else
        secondsLeft > /tmp/waybar-timer/paused
        rm -f /tmp/waybar-timer/expiry
        printPaused
      fi
    else
      exit 1
    fi
    ;;
  *)
    echo "Please read the manual at https://github.com/jbirnick/waybar-timer ."
    ;;
esac
