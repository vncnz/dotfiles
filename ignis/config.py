from ignis.widgets import Widget
from ignis.utils import Utils
import json
import time

import os

from gi.repository import GLib

# from niri import print_test
# print_test()

from ignis.services.wallpaper import WallpaperService
from ignis.options import options

WallpaperService.get_default()  # just to initialize it
options.wallpaper.set_wallpaper_path(os.path.expanduser("~/Pictures/wallpapers/paesaggi fantasy o disegni/203518.jpg"))

# def read_settings ():
#     with open(os.path.expanduser('~/.config/ignis/settings.json')) as settings:
#         return json.loads(settings.read())

# settings = read_settings()
# print(settings)

def read_ratatoskr_output ():
    with open('/tmp/ratatoskr.json') as rat:
        data = json.loads(rat.read())
        return data


import stat

class CmdManager:
    def __init__(self):
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
        if condition & GLib.IO_IN:
            line = source.readline()
            if line:
                line = line.strip()
                print(f"[IGNIS] comando ricevuto: {line}")
                if line == "toggle_clock":
                    # esempio: qui metti il tuo codice per mostrare/nascondere l’orologio
                    print("→ Azione: toggle clock")
            else:
                # EOF: riapri la fifo
                return False
        return True  # continua ad ascoltare
CmdManager()





bgnotif = None
def manage_notification (x, notification):
    print(notification.app_name, notification.summary)
    bgnotif.add_notif(notification)

try:
    from ignis.services.notifications import NotificationService

    notifications = NotificationService.get_default()

    notifications.connect("notified", manage_notification)
except Exception as ex:
    print(ex)



from ResBox import ClockBox, NotifBox
class BackgroundNotif (Widget.Window):
    def __init__(self, monitor = None):

        self.box = Widget.Box(
            spacing = 6,
            vertical = True,
            child = []
        )
        self.line = Widget.Box(
            width_request=0,
            height_request=5,
            style='background-color:transparent;'
        )

        full = Widget.Box(
            spacing = 6,
            vertical = True,
            child = [
                ClockBox(),
                self.box,
                self.line
            ]
        )

        super().__init__(
            namespace = 'background-notifs',
            monitor = monitor,
            child = full,
            layer = 'bottom',
            style = 'background-color:transparent;text-shadow:1px 1px 2px black;color:whitesmoke;',
            anchor = ['bottom', 'right'],
            margin_right = 30,
            margin_bottom = 0
        )
        self.last_max_urgency = None
        self.new_color = None
        Utils.Poll(1000, self.check_notif_times)
    
    def add_notif(self, notification):
        # self.box.child = [x for x in self.box.child.append(Widget.Label(label=f"{notification.app_name}, {notification.summary}"))
        notif = NotifBox(notification, lambda x: self.remove(x))
        # self.box.child = [notif] + [x for x in self.box.child]
        # self.box.set_child([notif] + [x for x in self.box.child])
        self.box.append(notif)
        self.update_color()
    
    def remove(self, x):
        self.box.remove(x)
        self.update_color()
    
    # def remove (self, n):
    #    self.box.child = [x for x in self.box.child if x != n]

    def check_notif_times (self, _):
        # print(time.time())
        now = time.time()
        removed = False
        for n in self.box.child:
            # print(now, n.time, n.urgency)
            if n.time + 5 > now or n.urgency == 2:
                pass
            else:
                removed = True
                self.box.remove(n)

        if removed:
            self.update_color()

    def update_color (self):
        max_urgency = -1
        for n in self.box.child:
            max_urgency = max(max_urgency, n.urgency)

        if self.last_max_urgency != max_urgency:
            color = None
            if max_urgency == 2:
                color = 'red'
            elif max_urgency > -1:
                color = 'white'
            else:
                color = 'rgba(0, 0, 0, 0.01)'
            self.line.set_style(f'background:{color};')
            self.last_max_urgency = max_urgency
            print("Updated max_urgency", max_urgency, color)

bgnotif = BackgroundNotif()
# bgnotif.add_notif(0)

################################################################

rat = read_ratatoskr_output()
print(rat)

# from ignis.services.fetch import FetchService
# from ignis.services.upower import UPowerService

from ResBox import ResBox, WeatherBox, BatteryBox, MemoryBox, NetworkBox, RowBox, ResIcon

class BackgroundInfos (Widget.Window):
    def __init__(self, monitor = None):

        weather_box = WeatherBox(rat['weather'])
        battery_box = BatteryBox(rat['battery'])
        memory_used_box = MemoryBox(rat['ram'])
        network_box = NetworkBox(rat['network'])
        multiline = RowBox()

        self.weather_box = weather_box
        self.battery_box = battery_box
        self.memory_used_box = memory_used_box
        self.network_box = network_box
        self.multiline = multiline

        # fetch = FetchService.get_default()
        # ram = fetch.mem_info
        # ram_used_perc = round(fetch.mem_used / fetch.mem_total * 100)
        # swap_used_perc = round(100 - ram['SwapFree'] / ram['SwapTotal'] * 100)
        # disk_used_perc = rat['disk']['used_percent']
        # print(ram)

        

        # ram_used_label = ResBox('RAM {value}%', rat['ram']['mem_percent'], color=rat['ram']['mem_color'])
        # swap_used_label = ResBox('SWAP {value}%', rat['ram']['swap_percent'], color=rat['ram']['swap_color'])
        # disk_used_label = ResBox('Disk {value}%', rat['disk']['used_percent'], color=rat['disk']['color'])
        avg_load_label = ResBox('Load {value}', f'{rat['loadavg']['m1']} {rat['loadavg']['m5']} {rat['loadavg']['m15']}', color=rat['loadavg']['color'])

        # {'sensor': 'Tctl', 'value': 72.125, 'color': '#55FF00', 'icon': '\uf2cb', 'warn': 0.0}
        temp_label = ResBox('Temperature {value}°', rat['temperature']['value'], color=rat['temperature']['color'])

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
            style = 'background-color:transparent;text-shadow:1px 1px 2px black;color:whitesmoke;',
            anchor = ['bottom', 'left'],
            margin_left = 70,
            margin_bottom = 40
        )
    
    def update_ratatoskr (self, rat):
        if rat:
            if 'weather' in rat: self.weather_box.update_value(rat['weather'])
            if 'battery' in rat: self.battery_box.update_value(rat['battery'])
            if 'ram' in rat: self.memory_used_box.update_value(rat['ram'])
            # self.ram_used_label.update_value(rat['ram']['mem_percent'], color=rat['ram']['mem_color'])
            # self.swap_used_label.update_value(rat['ram']['swap_percent'], color=rat['ram']['swap_color'])
            # self.disk_used_label.update_value(rat['disk']['used_percent'], color=rat['disk']['color'])
            if 'loadavg' in rat: self.avg_load_label.update_value(f'{rat['loadavg']['m1']} {rat['loadavg']['m5']} {rat['loadavg']['m15']}', color=rat['loadavg']['color'])
            # self.temp_label.update_value(int(rat['temperature']['value']), color=rat['temperature']['color'])
            if 'temperature' in rat: self.multiline.update_value(rat['temperature'], rat['disk'], rat['volume'])


back = BackgroundInfos()

################################################################

class ForegroundInfos (Widget.Window):
    def __init__(self, monitor = None):

        self.memory_icon = ResIcon('󰘚')
        self.disk_icon = ResIcon('󰋊')

        self.box = Widget.Box(
            spacing = 6,
            vertical = False,
            child = [
                self.memory_icon,
                self.disk_icon
            ]
        )

        super().__init__(
            namespace = 'foreground-infos',
            monitor = monitor,
            child = self.box,
            layer = 'top',
            style = 'background-color:transparent;text-shadow:1px 1px 2px black;color:whitesmoke;font-size:2rem;',
            anchor = ['bottom', 'right'],
            margin_right = 10,
            margin_bottom = 10
        )
    
    def update_ratatoskr (self, rat):
        if rat:
            if 'ram' in rat: self.memory_icon.update_value(rat['ram']['mem_warn'], rat['ram']['mem_color'])
            if 'disk' in rat: self.disk_icon.update_value(rat['disk']['warn'], rat['disk']['color'])
        # self.box.remove(self.memory_icon)
        # self.weather_box.update_value(rat['weather'])


# fore = ForegroundInfos()

def update_ratatoskr (_, path, event_type):
    global rat
    rat = read_ratatoskr_output()

    back.update_ratatoskr(rat)
    # fore.update_ratatoskr(rat)

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

def roundrect(context, x, y, width, height, r):
    context.move_to(x, y)

    context.arc(x+r, y+r, r,
                math.pi, 3*math.pi/2)

    context.arc(x+width-r, y+r, r,
                3*math.pi/2, 0)

    context.arc(x+width-r, y+height-r,
                r, 0, math.pi/2)

    context.arc(x+r, y+height-r, r,
                math.pi/2, math.pi)

    context.close_path()

def draw_frame(area, cr, width, height):

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
    roundrect(cr, margin, margin, width - 2*margin, height - 2*margin, 25)

    cr.fill()

def make_frame (output):
    output_name = output
    area = Gtk.DrawingArea()
    area.set_draw_func(draw_frame)
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

for out in monitors:
    make_frame(out)

#@ignis.on("output-added")
#def on_output_added(output, *_):
#    make_frame(output)

#@ignis.on("output-removed")
#def on_output_removed(output, *_):
#    remove_frame(output)