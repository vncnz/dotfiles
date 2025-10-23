from ignis.widgets import Widget
from ignis.utils import Utils
import json
# import time

import os

from gi.repository import GLib

# from niri import print_test
# print_test()

from ignis.app import IgnisApp
app = IgnisApp.get_default()
battery_eta = (0, 1, .5)

from BackgroundNotif import BackgroundNotif
from BackgroundSentence import BackgroundSentence
from ForegroundInfos import ForegroundInfos

def read_settings ():
    try:
        with open(os.path.expanduser('~/.config/ignis/settings.json')) as settings:
            obj = json.loads(settings.read())
            if "sentences" not in obj: obj["sentences"] = None
            return obj
    except:
        return {
            "wallpaper": None,
            "sentences": []
        }

settings = read_settings()
print("\nSETTINGS:")
print(settings)

def reload_settings (_, path, event_type):
    print('\n\nRELOADING SETTINGS\n\n')
    global settings
    # old_settings = settings
    settings = read_settings()
    # changed_wallpaper = not (old_settings and ('wallpaper' in old_settings) and settings and ('wallpaper' in settings) and settings['wallpaper'] == old_settings['wallpaper'])
    # if changed_wallpaper:
    #     wallpaper = os.path.expanduser(settings['wallpaper'])
    #     options.wallpaper.set_wallpaper_path(wallpaper)
    app.reload()

Utils.FileMonitor(
    path=os.path.expanduser('~/.config/ignis/settings.json'),
    recursive=False,
    callback = reload_settings # lambda _, path, event_type: print(path, event_type),
)



from WallpaperManager import set_wallpaper

if settings and ('wallpaper' in settings):
    wallpaper = settings['wallpaper'] # wallpaper = "~/Pictures/wallpapers/68d977081ada6ea065d5f020_nebulae-01.jpg"
else:
    wallpaper = "~/Repositories/dotfiles/wallpaper.jpg"

#wallpaper = os.path.expanduser(wallpaper)
#WallpaperService.get_default()  # just to initialize it
#options.wallpaper.set_wallpaper_path(wallpaper)
wallpaper = set_wallpaper(wallpaper)
# wallpaper = os.path.expanduser(wallpaper)

from theme_colors import col, generate_theme, gra, toggle_mode
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
                    fore.update_style()
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

from ResBox import ResBox, WeatherBox, BatteryBox, MemoryBox, NetworkBox, RowBox

class BackgroundInfos (Widget.Window):
    def __init__(self, monitor = None):

        weather_box = WeatherBox()
        battery_box = BatteryBox(rat['battery'])
        memory_used_box = MemoryBox()
        network_box = NetworkBox()
        multiline = RowBox()

        self.weather_box = weather_box
        self.battery_box = battery_box
        self.memory_used_box = memory_used_box
        self.network_box = network_box
        self.multiline = multiline

        # fetch = FetchService.get_default()
        # ram = fetch.mem_info
        # ram_used_perc = round(fetch.mem_used / fetch.mem_total * 100)

        avg_load_label = ResBox('Load {value}', f'{rat['loadavg']['m1']} {rat['loadavg']['m5']} {rat['loadavg']['m15']}', color=gra(rat['loadavg']['warn']))

        # {'sensor': 'Tctl', 'value': 72.125, 'color': '#55FF00', 'icon': '\uf2cb', 'warn': 0.0}
        temp_label = ResBox('Temperature {value}°', rat['temperature']['value'], color=gra(rat['temperature']['warn']))

        # self.ram_used_label = ram_used_label
        # self.swap_used_label = swap_used_label
        # self.disk_used_label = disk_used_label
        self.avg_load_label = avg_load_label
        self.temp_label = temp_label

        #battery_label = Widget.Label(
        #     label="Hello world!"
        # )

        # p = UPowerService()
        # battery_label.set_label(', '.join([f'Battery {batt.percent}%' for batt in p.batteries]) or 'No batteries')

        # Utils.Poll(1000, self.update_ratatoskr)
        
        box = Widget.Box(
            spacing = 6,
            vertical = True,
            child = [
                weather_box,
                Widget.Separator(vertical=False),
                memory_used_box,
                # ram_used_label,
                # Widget.Separator(vertical=False),
                # swap_used_label,
                Widget.Separator(vertical=False),
                avg_load_label,
                # temp_label,
                # disk_used_label,
                Widget.Separator(vertical=False),
                network_box,
                Widget.Separator(vertical=False),
                # battery_label,
                battery_box,
                Widget.Separator(vertical=False),
                multiline
            ]
        )

        super().__init__(
            namespace = 'background-infos',
            monitor = monitor,
            child = box,
            layer = 'bottom',
            anchor = ['bottom', 'left'],
            margin_left = 70,
            margin_bottom = 40
        )
        self.update_theme()
    
    def update_ratatoskr (self, rat):
        if rat:
            if 'weather' in rat: self.weather_box.update_value(rat['weather'])
            if 'battery' in rat:
                b = rat["battery"]
                self.battery_box.update_value(b)
            if 'ram' in rat: self.memory_used_box.update_value(rat['ram'])
            if 'network'in rat: self.network_box.update_value(rat['network'])
            if 'loadavg' in rat: self.avg_load_label.update_value(f'{rat['loadavg']['m1']} {rat['loadavg']['m5']} {rat['loadavg']['m15']}', color=gra(rat['loadavg']['warn']))
            if 'temperature' in rat and 'disk' in rat and 'volume' in rat: self.multiline.update_value(rat['temperature'], rat['disk'], rat['volume'])

            if False: battery_eta = (1, 273, .95)

    def update_theme (self):
        self.set_style(f'background-color:transparent;color:{col('on_background')};')

back = BackgroundInfos()

################################################################

sentence = BackgroundSentence(settings['sentences'])

################################################################

fore = ForegroundInfos()

def update_ratatoskr (_, path, event_type):
    global rat, battery_eta
    rat = read_ratatoskr_output()

    if back: back.update_ratatoskr(rat)
    fore.update_ratatoskr(rat)

    if 'battery' in rat:
        b = rat['battery']
        state = 0
        if b["state"] == 'Discharging': state = -1
        elif b["state"] == 'Charging': state = 1
        battery_eta = (state, b["eta"], (100 - b["percentage"])*0.01)

Utils.FileMonitor(
    path="/tmp/ratatoskr.json",
    recursive=False,
    callback = update_ratatoskr # lambda _, path, event_type: print(path, event_type),
)

################################################################

from gi.repository import Gtk, cairo
from ignis.widgets import Window
import ignis
import math

frames = {}
monitors = ignis.utils.Utils.get_monitors()
monitors = list(range(ignis.utils.Utils.get_n_monitors()))

# battery_is_used = rat['battery']['state'] == 'Discharging' or rat['battery']['state'] == 'Charging'

def roundrect(context, x, y, width, height, r, right=0):

    context.move_to(x, y)

    context.arc(x+r, y+r, r,
                math.pi, 3*math.pi/2)

    context.arc(x+width-r-right, y+r, r,
                3*math.pi/2, 0)

    context.arc(x+width-r-right, y+height-r,
                r, 0, math.pi/2)

    context.arc(x+r, y+height-r, r,
                math.pi/2, math.pi)

    context.close_path()

def draw_frame(area, cr, width, height, right=0):

    #if battery_is_used:
    #    margin = 12 - int(rat['battery']['percentage'] / 10)
    #    cr.set_source_rgba(0.2, 0.6, 0.5, 1)
    #else:
    margin = 0
    cr.set_source_rgba(0.0, 0.0, 0.0, 1)
    cr.set_fill_rule(cairo.FillRule.EVEN_ODD)

    # rettangolo esterno
    cr.rectangle(0, 0, width, height)

    # cr.rectangle(margin, margin, width - 2*margin, height - 2*margin)
    roundrect(cr, margin, margin, width - 2*margin, height - 2*margin, 30, right=right)

    cr.fill()

def make_frame (output):
    output_name = output
    area = Gtk.DrawingArea()
    right = 0
    if output == 0: right = 4
    area.set_draw_func(lambda *args, **kwargs: draw_frame(*args, **kwargs, right=right))
    area.set_hexpand(True)
    area.set_vexpand(True)
    # area.set_content_width(1920)
    # area.set_content_height(1080)

    # Finestra Ignis a schermo intero, livello overlay
    win = Window(
        namespace = f'screen-frame-{output_name}',
        layer = 'top',
        exclusivity = 'normal',
        kb_mode = 'none',
        style = 'background-color:transparent;',
        input_width = 1,
        input_height = 1,
        monitor = output_name,
        anchor=['top', 'left', 'bottom', 'right']
    )
    win.set_child(area)
    # win.set_pass_through(True)        # click-through
    win.present()
    frames[output_name] = win
    print(f'Frame created for output {output_name}')

def remove_frame(output_name):
    if output_name in frames:
        frames[output_name].close()
        del frames[output_name]
        print(f"Frame removed from {output_name}")

print('')
for out in monitors:
    make_frame(out)

#@ignis.on("output-added")
#def on_output_added(output, *_):
#    make_frame(output)

#@ignis.on("output-removed")
#def on_output_removed(output, *_):
#    remove_frame(output)