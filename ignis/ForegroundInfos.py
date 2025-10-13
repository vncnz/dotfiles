from ignis.widgets import Widget
from ResBox import ResIcon
from Bus import Bus

from theme_colors import gra, get_theme

class ForegroundInfos (Widget.Window):
    def __init__(self, monitor = None):

        self.memory_icon = ResIcon('󰘚')
        self.disk_icon = ResIcon('󰋊')
        self.loadavg_icon = ResIcon('󰬢')
        self.battery_icon = ResIcon('B')
        self.network_icon = ResIcon('N')
        self.temperature_icon = ResIcon('T')
        self.notification_icon = ResIcon("󰂚") # , width_request=1, height_request=1, style="background-color:rgba(0, 0, 0, 0.01);")
        # self.notification_icon.update_value(1, 'rgba(0, 0, 0, 0.01)')

        chi = [] # [Widget.Label(label="", width_request=1, height_request=1, style="background-color:rgba(0, 0, 0, 0.01);")]
        if False:
            theme = get_theme()
            chi = chi + [
                Widget.Label(label="󱗜", width_request=1, height_request=1, style=f"font-size:1.2rem;color:{theme['on_background']};")
            ] + [
                Widget.Label(label="", width_request=1, height_request=1, style=f"font-size:1.2rem;color:{c};") for c in theme['warning_gradient']
            ] + [
                Widget.Label(label="", width_request=1, height_request=1, style=f"font-size:1.2rem;color:{theme['error']};")
            ]

        self.box = Widget.Box(
            spacing = 6,
            vertical = True,
            child = chi
        )

        self.empty = len(chi) == 0

        super().__init__(
            namespace = 'foreground-infos',
            monitor = monitor,
            child = self.box,
            layer = 'overlay',
            # style = f'background-color:{theme['primary_container']};text-shadow:1px 1px 2px black;color:whitesmoke;font-size:2rem;padding:5px;border:1px solid {theme['primary']};border-radius:8px;',
            anchor = ['bottom', 'left'],
            margin_left = 8,
            margin_bottom = 18
        )

        self.update_style()

        Bus.subscribe(lambda x: self.update_bus(x))
    
    def update_style (self):
        theme = get_theme()
        opacity = 0.001 if self.empty else 1
        self.set_style(f'background-color:{theme['background']};text-shadow:1px 1px 2px black;color:whitesmoke;font-size:2rem;padding:5px;border:1px solid {theme['primary']};border-radius:10px;opacity:{opacity};')
    
    def update_bus (self, x):
        # print('event', x)
        if x: self.update_ratatoskr_single(self.notification_icon, 1, x, 'notif')
        else: self.update_ratatoskr_single(self.notification_icon, 0, x, 'notif')

# TODO (after standby)
# File "/home/vncnz/.config/ignis/ForegroundInfos.py", line 37, in update_ratatoskr
#    self.network_icon.set_label(rat['network']['icon'])
#    │    │            │         └ {'ram': {'total_memory': 15559585792, 'used_memory': 6665543680, 'total_swap': 10737414144, 'used_swap': 380665856, 'mem_perc...
#    │    │            └ gi.FunctionInfo(set_label)
#    │    └ <ResBox.ResIcon object at 0x7f800bfa4280 (ResBox+ResIcon at 0x55ddc1ab1fc0)>
#    └ <ForegroundInfos.ForegroundInfos object at 0x7f800bfad440 (ForegroundInfos+ForegroundInfos at 0x55ddc1ab4e40)>
# TypeError: 'NoneType' object is not subscriptable

    def update_ratatoskr (self, rat):
        if rat:
            if 'ram' in rat: self.update_ratatoskr_single(self.memory_icon, rat['ram']['mem_warn'], None, 'memory')
            if 'disk' in rat: self.update_ratatoskr_single(self.disk_icon, rat['disk']['warn'], None, 'disk')
            if 'loadavg' in rat: self.update_ratatoskr_single(self.loadavg_icon, rat['loadavg']['warn'], None, 'loadavg')
            if 'network' in rat:
                if rat['network']:
                    self.network_icon.set_label(rat['network']['icon'])
                    self.update_ratatoskr_single(self.network_icon, rat['network']['warn'], None, 'network')
                else:
                    self.network_icon.set_label('󰞃')
                    self.update_ratatoskr_single(self.network_icon, 1, 'red', 'network')
            if 'battery' in rat:
                warn = 0
                if rat['battery']['state'] in ['Charging', 'Discharging']: warn = max(0, min((80 - rat['battery']['percentage']) / 60.0, 1))
                self.battery_icon.set_label(rat['battery']['icon'])
                self.update_ratatoskr_single(self.battery_icon, warn, rat['battery']['color'], 'battery')
            if 'temperature' in rat:
                self.temperature_icon.set_label(rat['temperature']['icon'])
                self.update_ratatoskr_single(self.temperature_icon, rat['temperature']['warn'], None, 'temperature')
    
    def update_ratatoskr_single (self, icon, warn, color = None, dbLabel = None):
        if not color: color = gra(warn)
        if warn > 0.3:
            # icon.update_value(warn, color)
            self.check_icon_presence(icon, True, warn, color, dbLabel)
        else:
            self.check_icon_presence(icon, False, warn, color, dbLabel)
    
    def check_icon_presence (self, icon, desired, warn, color, dbLabel = None):
        if desired:
            if (icon not in self.box.child):
                self.box.append(icon)
                # print('Appending icon', dbLabel)
            icon.update_value(warn, color)
            self.empty = len(self.box.child) == 0
            self.update_style()
        elif not desired and (icon in self.box.child):
            self.box.remove(icon)
            # print('Removing icon', dbLabel)
            self.empty = len(self.box.child) == 0
            self.update_style()