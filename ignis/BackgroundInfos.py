from ignis.widgets import Widget

from ResBox import ResBox, WeatherBox, BatteryBox, MemoryBox, NetworkBox, RowBox
from Bus import Bus
from theme_colors import col, gra

class BackgroundInfos (Widget.Window):
    def __init__(self, monitor = None):

        weather_box = WeatherBox()
        battery_box = BatteryBox(None)
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

        avg_load_label = ResBox('Load {value}', '')

        # {'sensor': 'Tctl', 'value': 72.125, 'color': '#55FF00', 'icon': '\uf2cb', 'warn': 0.0}
        temp_label = ResBox('Temperature {value}°', 0)

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
                Widget.Separator(vertical=False),
                avg_load_label,
                Widget.Separator(vertical=False),
                network_box,
                Widget.Separator(vertical=False),
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
        Bus.subscribe(lambda x: self.update_ratatoskr(x), topic='ratatoskr')
    
    def update_ratatoskr (self, rat):
        if rat:
            if 'weather' in rat: self.weather_box.update_value(rat['weather'])
            if 'battery' in rat:
                b = rat["battery"]
                self.battery_box.update_value(b)
            if 'ram' in rat: self.memory_used_box.update_value(rat['ram'])
            if 'network'in rat: self.network_box.update_value(rat['network'])
            if 'loadavg' in rat and rat['loadavg']: self.avg_load_label.update_value(f'{rat['loadavg']['m1']} {rat['loadavg']['m5']} {rat['loadavg']['m15']}', color=gra(rat['loadavg']['warn']))
            if 'temperature' in rat and 'disk' in rat and 'volume' in rat: self.multiline.update_value(rat['temperature'], rat['disk'], rat['volume'])

            if False: battery_eta = (1, 273, .95)

    def update_theme (self):
        self.set_style(f'background-color:rgba(0,0,0,0.00001);color:{col('on_background')};')