from ignis.utils import Utils
import json
# import time

import os

from gi.repository import GLib

from ignis.app import IgnisApp

app = IgnisApp.get_default()
battery_eta = (0, 1, .5)

from Settings import config, reload_config

from BackgroundNotif import BackgroundNotif
from BackgroundSentence import BackgroundSentence
from BackgroundInfos import BackgroundInfos
from ForegroundInfos import ForegroundInfos
from Frame import Frame
from Bus import Bus
import ignis

#######################################
areas = []

monitors = ignis.utils.Utils.get_monitors()
monitors = list(range(ignis.utils.Utils.get_n_monitors()))

for out in monitors:
    areas.append(Frame(out))

def refresh_frames (new_color):
    for area in areas:
        area.update_color(new_color)
#######################################

def reload_settings (_, path, event_type):
    print('\n\nRELOADING SETTINGS\n\n')
    reload_config()
    app.reload()

Utils.FileMonitor(
    path=os.path.expanduser('~/.config/ignis/settings.json'),
    recursive=False,
    callback = reload_settings # lambda _, path, event_type: print(path, event_type),
)



from WallpaperManager import set_wallpaper

if config:
    wallpaper = config.wallpaper # wallpaper = "~/Pictures/wallpapers/68d977081ada6ea065d5f020_nebulae-01.jpg"
else:
    wallpaper = "~/Repositories/dotfiles/wallpaper.jpg"

#wallpaper = os.path.expanduser(wallpaper)
#WallpaperService.get_default()  # just to initialize it
#options.wallpaper.set_wallpaper_path(wallpaper)
wallpaper = set_wallpaper(wallpaper)
# wallpaper = os.path.expanduser(wallpaper)

from theme_colors import col, generate_theme, gra, gra_rgb, toggle_mode
theme = generate_theme(wallpaper)
#print('\nCREATED THEME:')
#print(theme)

from TimeLine import TimeLine
tm = TimeLine()
Utils.Poll(1000, lambda x: tm.update_time(None, battery_eta))

import stat
class CmdManager:
    def __init__(self):
        # echo "toggle_clock" > ~/.config/ignis/control
        fifo_path = os.path.expanduser("~/.config/ignis/control")
        # fifo_path = '/tmp/ignis_cmd'

        if os.path.exists(fifo_path):
            if not stat.S_ISFIFO(os.stat(fifo_path).st_mode):
                os.remove(fifo_path)
                os.mkfifo(fifo_path)
        else:
            os.mkfifo(fifo_path)

        fifo_fd = os.open(fifo_path, os.O_RDONLY | os.O_NONBLOCK)
        fifo = os.fdopen(fifo_fd, "r", buffering=1)
        GLib.io_add_watch(fifo, GLib.IO_IN, self.on_fifo_readable)

    def on_fifo_readable(self, source, condition):
        global wallpaper
        if condition & GLib.IO_IN:
            line = source.readline()
            if line:
                line = line.strip()
                print(f"[IGNIS] comando ricevuto: {line}")
                # if line == "toggle_clock": print("→ Azione: toggle clock")
                if line == "wallpaper_prev": wallpaper = set_wallpaper(wallpaper, False)
                elif line == "wallpaper_next": wallpaper = set_wallpaper(wallpaper, True)
                elif line == "theme_toggle":
                    toggle_mode()
                    generate_theme(wallpaper)
                    if back: back.update_theme()
                    if fore: fore.update_style()
            else:
                # EOF: riapri la fifo
                return False
        return True  # continua ad ascoltare
CmdManager()





bgnotif = None
def manage_notification (x, notification):
    # print(notification.app_name, notification.summary, notification.__dict__)
    # {'_Notification__dbus': <dbus.DBusService object at 0x7fbf7db2a700 (ignis+dbus+DBusService at 0x5600f057e150)>, '_id': 64, '_app_name': 'Firefox', '_icon': '/home/vncnz/.cache/ignis/notifications/images/64', '_summary': 'Simona', '_body': ' Voice Message', '_timeout': 5000, '_time': 1758122136.296893, '_urgency': 1, '_popup': True, '_actions': [<action.NotificationAction object at 0x7fbf7db74500 (ignis+services+notifications+action+NotificationAction at 0x5600f850f160)>]}
    bgnotif.add_notif(notification)

try:
    from ignis.services.notifications import NotificationService

    notifications = NotificationService.get_default()

    notifications.connect("notified", manage_notification)
except Exception as ex:
    print(ex)


bgnotif = BackgroundNotif()
# bgnotif.add_notif(0)

################################################################

# from ignis.services.bluetooth import BluetoothService
# blue = BluetoothService.get_default()
# print(blue.connected_devices)

################################################################

def read_ratatoskr_output ():
    with open('/tmp/ratatoskr.json') as rat:
        data = json.loads(rat.read())
        return data

rat = read_ratatoskr_output()
#print('\nRATATOSKR FIRST READ:')
#print(rat)

# from ignis.services.fetch import FetchService
# from ignis.services.upower import UPowerService

back = BackgroundInfos()

################################################################

sentence = BackgroundSentence(config.sentences)

################################################################

fore = ForegroundInfos()

def update_ratatoskr (_, path, event_type):
    global rat, battery_eta
    rat = read_ratatoskr_output()

    # if back: back.update_ratatoskr(rat)
    # fore.update_ratatoskr(rat)
    Bus.publish(rat, topic='ratatoskr')

    if 'battery' in rat:
        b = rat['battery']
        state = 0
        if b["state"] == 'Discharging': state = -1
        elif b["state"] == 'Charging': state = 1
        battery_eta = (state, b["eta"], (100 - b["percentage"])*0.01)
    
    m = max(*[rat[k]['warn'] for k in ['loadavg', 'disk', 'temperature']], rat['ram']['mem_warn'], 0)
    color = (0,0,0,.5) if m <= 0.3 else gra_rgb(m)
    Bus.publish(color, topic='frame-color')

Utils.FileMonitor(
    path="/tmp/ratatoskr.json",
    recursive=False,
    callback = update_ratatoskr # lambda _, path, event_type: print(path, event_type),
)








########################################################
################## Experimental stuff ##################
########################################################

#import Applications
#import niri
#niri.w()

# from Navigation import Navigation
# navi = Navigation()

# import mpris