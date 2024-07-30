
cp "$(find ~/Pictures/wallpapers | shuf -n1)" ~/Pictures/wallpaper.jpg
sleep 0.1
OLD_PID=$(ps axf | grep swaybg | grep -v grep | awk '{print $1}')
nohup swaybg --image ~/Pictures/wallpaper.jpg --mode fill &
if [ "$OLD_PID" != "" ]; then
    sleep 0.1
    kill -9 $OLD_PID
fi