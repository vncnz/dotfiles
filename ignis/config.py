from ignis.widgets import Widget
from ignis.utils import Utils
import json

# from niri import print_test
# print_test()

from ignis.services.wallpaper import WallpaperService
from ignis.options import options

WallpaperService.get_default()  # just to initialize it

options.wallpaper.set_wallpaper_path("/home/vncnz/Pictures/wallpapers/paesaggi fantasy o disegni/203518.jpg")

def read_ratatoskr_output ():
    with open('/tmp/ratatoskr.json') as rat:
        data = json.loads(rat.read())
        return data

rat = read_ratatoskr_output()
print(rat)

if True:
    from ignis.services.fetch import FetchService
    from ignis.services.upower import UPowerService

    from ResBox import ResBox, WeatherBox, BatteryBox, MemoryBox, NetworkBox

    class BackgroundInfos (Widget.Window):
        def __init__(self, monitor = None):

            weather_box = WeatherBox(rat['weather'])
            battery_box = BatteryBox(rat['battery'])
            network_box = NetworkBox(rat['network'])

            self.weather_box = weather_box
            self.battery_box = battery_box
            self.network_box = network_box

            # fetch = FetchService.get_default()
            # ram = fetch.mem_info
            # ram_used_perc = round(fetch.mem_used / fetch.mem_total * 100)
            # swap_used_perc = round(100 - ram['SwapFree'] / ram['SwapTotal'] * 100)
            # disk_used_perc = rat['disk']['used_percent']
            # print(ram)

            memory_used_box = MemoryBox(rat['ram'])

            # ram_used_label = ResBox('RAM {value}%', rat['ram']['mem_percent'], color=rat['ram']['mem_color'])
            # swap_used_label = ResBox('SWAP {value}%', rat['ram']['swap_percent'], color=rat['ram']['swap_color'])
            disk_used_label = ResBox('Disk {value}%', rat['disk']['used_percent'], color=rat['disk']['color'])
            avg_load_label = ResBox('Load {value}%', f'{rat['loadavg']['m1']} {rat['loadavg']['m5']} {rat['loadavg']['m15']}', color=rat['loadavg']['color'])

            # self.ram_used_label = ram_used_label
            # self.swap_used_label = swap_used_label
            self.disk_used_label = disk_used_label
            self.avg_load_label = avg_load_label

            #battery_label = Widget.Label(
            #     label="Hello world!"
            # )

            # p = UPowerService()
            # battery_label.set_label(', '.join([f'Battery {batt.percent}%' for batt in p.batteries]) or 'No batteries')

            # Utils.Poll(1000, self.update_ratatoskr)
            Utils.FileMonitor(
                path="/tmp/ratatoskr.json",
                recursive=False,
                callback = self.update_ratatoskr # lambda _, path, event_type: print(path, event_type),
            )
            
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
                    disk_used_label,
                    Widget.Separator(vertical=False),
                    network_box,
                    Widget.Separator(vertical=False),
                    # battery_label,
                    battery_box
                ]
            )

            super().__init__(
                namespace = 'background-infos',
                monitor = monitor,
                child = box,
                layer = 'bottom',
                style = 'background-color:transparent;text-shadow:1px 1px 2px black;color:whitesmoke;',
                anchor = ['bottom', 'left'],
                margin_left = 100,
                margin_bottom = 50
            )
        
        def update_ratatoskr (self, _, path, event_type):
            global rat
            rat = read_ratatoskr_output()

            self.weather_box.update_value(rat['weather'])
            self.battery_box.update_value(rat['battery'])
            # self.ram_used_label.update_value(rat['ram']['mem_percent'], color=rat['ram']['mem_color'])
            # self.swap_used_label.update_value(rat['ram']['swap_percent'], color=rat['ram']['swap_color'])
            self.disk_used_label.update_value(rat['disk']['used_percent'], color=rat['disk']['color'])
            self.avg_load_label.update_value(f'{rat['loadavg']['m1']} {rat['loadavg']['m5']} {rat['loadavg']['m15']}', color=rat['loadavg']['color'])


    BackgroundInfos()

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