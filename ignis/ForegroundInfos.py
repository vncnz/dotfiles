from ignis.widgets import Widget
from ResBox import ResIcon

class ForegroundInfos (Widget.Window):
    def __init__(self, monitor = None):

        self.memory_icon = ResIcon('󰘚')
        self.disk_icon = ResIcon('󰋊')
        self.battery_icon = ResIcon('B')
        self.network_icon = ResIcon('N')

        self.box = Widget.Box(
            spacing = 6,
            vertical = True,
            child = [
                # self.memory_icon,
                # self.disk_icon,
                # self.battery_icon
            ]
        )

        super().__init__(
            namespace = 'foreground-infos',
            monitor = monitor,
            child = self.box,
            layer = 'top',
            style = 'background-color:transparent;text-shadow:1px 1px 2px black;color:whitesmoke;font-size:2rem;',
            anchor = ['bottom', 'left'],
            margin_left = 10,
            margin_bottom = 40
        )
    
    def update_ratatoskr (self, rat):
        if rat:
            if 'ram' in rat: self.update_ratatoskr_single(self.memory_icon, rat['ram']['mem_warn'], rat['ram']['mem_color'], 'memory')
            if 'disk' in rat: self.update_ratatoskr_single(self.disk_icon, rat['disk']['warn'], rat['disk']['color'], 'disk')
            if 'network' in rat:
                self.network_icon.set_label(rat['network']['icon'])
                self.update_ratatoskr_single(self.network_icon, rat['network']['warn'], rat['network']['color'], 'network')
            if 'battery' in rat:
                warn = 0
                if rat['battery']['state'] in ['Charging', 'Discharging']: warn = rat['percentage'] / 100.0
                self.battery_icon.set_label(rat['battery']['icon'])
                self.update_ratatoskr_single(self.battery_icon, warn, rat['battery']['color'], 'battery')
            # TODO: loadavg
            # TODO: temperature
            # if 'temperature' in rat: self.update_ratatoskr_single(self.disk_icon, rat['temperature']['warn'], rat['temperature']['color'], 'temperature')
    
    def update_ratatoskr_single (self, icon, warn, color, dbLabel = None):
        if warn > 0:
            icon.update_value(warn, color)
            self.check_icon_presence(icon, True, dbLabel)
        else:
            self.check_icon_presence(icon, False, dbLabel)
    
    def check_icon_presence (self, icon, desired, dbLabel = None):
        if desired and (icon not in self.box.child):
            self.box.append(icon)
            # print('Appending icon', dbLabel)
        elif not desired and (icon in self.box.child):
            self.box.remove(icon)
            # print('Removing icon', dbLabel)