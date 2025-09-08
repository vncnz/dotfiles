from ignis.widgets import Widget
from utils import get_color_gradient
from datetime import datetime

class ResBox (Widget.Box):
    def __init__(self, template, value, color=None, **kwargs):

        self.warn_level = [60, 90]
        self.high_is_good = self.warn_level[0] > self.warn_level[1]

        value_label = Widget.Label(
            label = template.format(value=value),
            #use_markup=False,
            justify='left',
            #wrap=True,
            #wrap_mode='word',
            #ellipsize='end',
            #max_width_chars=52,
            style = self.compute_style(value, color),
            xalign=0.0
        )
        self.label = value_label
        self.template = template

        super().__init__(
            spacing = 1,
            vertical = True,
            child = [
                self.label
            ], **kwargs)

    def compute_style (self, v, color=None):
        return f'font-size: 1.7em;color:{color or get_color_gradient(self.warn_level[0], self.warn_level[1], v, self.high_is_good)};'
    
    def update_value(self, value):
        # self.value = value
        self.label.set_label(self.template.format(value=value))
        self.label.set_style(self.compute_style(value))

class WeatherBox (Widget.Box):
    def __init__(self, value, **kwargs):

        # 'weather': {'icon': '\U000f0590', 'icon_name': 'overcast.svg', 'temp': 29, 'temp_real': 27, 'temp_unit': '°C', 'text': 'Overcast', 'day': '1', 'sunrise': '06:48', 'sunset': '19:42', 'sunrise_mins': 408, 'sunset_mins': 1182, 'daylight': 46482.52, 'locality': 'Desenzano Del Garda', 'humidity': 54, 'updated': '2025-09-08T10:46:21.620269155+00:00'}

        updated = datetime.fromisoformat(value['updated'])

        line1 = Widget.Label(
            label = f'{value['text']} / {value['temp']}{value['temp_unit']} / {value['humidity']}%',
            #use_markup=False,
            justify='left',
            #wrap=True,
            #wrap_mode='word',
            #ellipsize='end',
            #max_width_chars=52,
            style = 'font-size: 1.7em;', # self.compute_style(value)
            xalign=0.0
        )
        line2 = Widget.Label(
            label = f' {value['sunrise']}  {value['sunset']}',
            justify='left',
            hexpand=False,
            style = 'font-size: 1.1em;',
            xalign=0.0
        )
        line3 = Widget.Label(
            label = f'{value['locality']}, updated at {updated.strftime("%H:%M")}',
            justify='left',
            style = 'font-size: 1.1em;',
            xalign=0.0
        )
        self.lines = [line1, line2, line3]

        super().__init__(
            spacing = 1,
            vertical = True,
            homogeneous=False,
            child = self.lines, **kwargs)

    def compute_style (self, v):
        # return f'color:{get_color_gradient(self.warn_level[0], self.warn_level[1], v, self.high_is_good)};'
        return ''
    
    def update_value(self, value):
        # self.value = value
        # self.label.set_label(self.template.format(value=value))
        # self.label.set_style(self.compute_style(value))
        pass