from ignis.widgets import Widget
from utils import get_color_gradient, bytes_to_human
from datetime import datetime

import random
import functools

def skip_if_unchanged(func):
    last_call = {"args": None, "kwargs": None}

    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        if (args, kwargs) == (last_call["args"], last_call["kwargs"]):
            return
        last_call["args"] = args
        last_call["kwargs"] = kwargs
        return func(*args, **kwargs)

    return wrapper

class ResIcon (Widget.Label):
    def __init__(self, icon):

        super().__init__(
            label = icon,
            #use_markup=False,
            #justify='left',
            #wrap=True,
            #wrap_mode='word',
            #ellipsize='end',
            #max_width_chars=52,
            #style = self.compute_style(value, color),
            style = 'opacity: 0.1;',
            xalign=0.0
        )

    def compute_style (self, warn, color=None):
        return f'font-size: 2rem;color:{color or 'inherit'};opacity:{0.3 + warn * 0.55};'
    
    @skip_if_unchanged
    def update_value(self, warn, color=None):
        self.set_style(self.compute_style(warn, color))


class ResBox (Widget.Box):
    def __init__(self, template, value, color=None, **kwargs):

        self.warn_level = [60, 90] # unused for now
        self.high_is_good = self.warn_level[0] > self.warn_level[1] # unused for now

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
        return f'font-size: 1.4em;color:{color or get_color_gradient(self.warn_level[0], self.warn_level[1], v, self.high_is_good)};'
    
    @skip_if_unchanged
    def update_value(self, value, color=None, template=None):
        # self.value = value
        if template: self.template = template
        self.label.set_label(self.template.format(value=value))
        self.label.set_style(self.compute_style(value, color))

    #def update_template_and_value (self, template, value, color=None):
    #    self.template = template
    #    self.label.set_label(self.template.format(value=value))
    #    self.label.set_style(self.compute_style(value, color))


class MultilineBox (Widget.Box):
    def __init__(self, right=False, **kwargs):

        # 'weather': {'icon': '\U000f0590', 'icon_name': 'overcast.svg', 'temp': 29, 'temp_real': 27, 'temp_unit': '°C', 'text': 'Overcast', 'day': '1', 'sunrise': '06:48', 'sunset': '19:42', 'sunrise_mins': 408, 'sunset_mins': 1182, 'daylight': 46482.52, 'locality': 'Desenzano Del Garda', 'humidity': 54, 'updated': '2025-09-08T10:46:21.620269155+00:00'}

        line1 = Widget.Label(
            label = 'line1',
            #use_markup=False,
            justify='left',
            #wrap=True,
            #wrap_mode='word',
            #ellipsize='end',
            #max_width_chars=52,
            style = 'font-size: 1.4em;', # self.compute_style(value)
            xalign= 1.0 if right else 0.0
        )
        line2 = Widget.Label(
            label = 'line2',
            justify='left',
            hexpand=False,
            style = 'font-size: 1.1em;',
            xalign= 1.0 if right else 0.0
        )
        line3 = Widget.Label(
            label = 'line3',
            justify='left',
            style = 'font-size: 1.1em;',
            xalign= 1.0 if right else 0.0
        )
        self.lines = [line1, line2, line3]

        super().__init__(
            spacing = 1,
            vertical = True,
            homogeneous=False,
            child = self.lines, **kwargs)
    
    def set_lines (self, texts):
        for label, text in zip(self.lines, texts):
            label.set_label(text)

    def compute_style (self, v):
        # return f'color:{get_color_gradient(self.warn_level[0], self.warn_level[1], v, self.high_is_good)};'
        return ''
    
    def update_value(self, value):
        # self.value = value
        # self.label.set_label(self.template.format(value=value))
        # self.label.set_style(self.compute_style(value))
        pass


class WeatherBox (MultilineBox):
    def __init__(self, **kwargs):
        super().__init__()
        self.last_updated = None

    @skip_if_unchanged
    def update_value(self, value):
        # 'weather': {'icon': '\U000f0590', 'icon_name': 'overcast.svg', 'temp': 29, 'temp_real': 27, 'temp_unit': '°C', 'text': 'Overcast', 'day': '1', 'sunrise': '06:48', 'sunset': '19:42', 'sunrise_mins': 408, 'sunset_mins': 1182, 'daylight': 46482.52, 'locality': 'Desenzano Del Garda', 'humidity': 54, 'updated': '2025-09-08T10:46:21.620269155+00:00'}
        if value:
            if value['updated'] != self.last_updated:
                updated = datetime.fromisoformat(value['updated'])
                self.set_lines([
                    f'{value['text']} / {value['temp']}{value['temp_unit']} / {value['humidity']}%',
                    f' {value['sunrise']}  {value['sunset']}',
                    f'{value['locality']}, updated at {updated.astimezone().strftime("%H:%M")}'
                ])
                self.last_updated = value['updated']
        else:
            self.set_lines([
                f'No weather data',
                f'Network still napping?',
                random.choice([
                    'Armageddon loading...',
                    'The end is nigh?',
                    'Impending doom?',
                    'Skies on strike?',
                    'Apocalypse scheduled?',
                    'Judgment Day soon?'
                ])
            ])

class BatteryBox (MultilineBox):
    def __init__(self, value):

        # 'battery': {'percentage': 0, 'capacity': 0.0, 'eta': None, 'state': 'no_battery', 'icon': '\uf1e6', 'color': None, 'watt': 0.0}

        super().__init__()

        self.update_value(value)

    @skip_if_unchanged
    def update_value(self, value):
        # import json
        # value = json.loads('{"percentage":98,"capacity":181008.0,"eta":418.04108,"state":"Discharging","icon":"󰁹","color":"#55FF00","watt":7.106}')
        if value['capacity'] > 0:
            if value['state'] == 'Full':
                second = 'Full, enjoy!'
                third = random.choice([
                    'ETA: ∞ (give or take)',
                    'ETA: Infinity and beyond',
                    'Eternal uptime (ish)',
                    'Deadline cancelled',
                    'Next stop: entropy'
                ])# 'Eta to infinity, I suppose'
            else:
                second = f'{value['state']} ({round(value['watt'], 1)} watts)'
                e = value['eta']
                third = e and f'Eta {int(e / 60)}h{int(e % 60)}m' or 'Calculating'
            self.set_lines([
                f'Battery {value['percentage']}%',
                second,
                third
            ])
            self.lines[0].set_style(f'font-size: 1.4em;color:{value['color']};')
        else:
            self.set_lines([
                f'No batteries',
                f'Not a laptop, maybe?',
                f'A blackout is unlikely to happen now, isn\'t it?'
            ])
            self.lines[0].set_style(f'font-size: 1.4em;')

class MemoryBox (MultilineBox):

    @skip_if_unchanged
    def update_value(self, value):
        # 'ram': {'total_memory': 4099457024, 'used_memory': 2791231488, 'total_swap': 6866382848, 'used_swap': 442261504, 'mem_percent': 68, 'swap_percent': 6, 'mem_color': '#C6FF00', 'swap_color': '#55FF00', 'mem_warn': 0.26666666666666666, 'swap_warn': 0.0}

        self.set_lines([
            f'Memory {value['mem_percent']}% / {value['swap_percent']}%',
            f'RAM {bytes_to_human(value['used_memory'])} of {bytes_to_human(value['total_memory'])}',
            f'SWAP {bytes_to_human(value['used_swap'])} of {bytes_to_human(value['total_swap'])}'
        ])
        color = value['mem_color'] if value['mem_warn'] > value['swap_warn'] else value['swap_color']
        self.lines[0].set_style(f'font-size: 1.4em;color:{color};')

class NetworkBox (MultilineBox):

    @skip_if_unchanged
    def update_value(self, value):
        # 'network': {'iface': 'wlan0', 'conn_type': 'wifi', 'ssid': 'TIM-23842378', 'signal': 43, 'ip': '192.168.1.191', 'icon': '\U000f08bd', 'color': '#FFF400', 'warn': 0.42500000000000004}
        if value:
            if value['conn_type'] == 'wifi':
                self.set_lines([
                    f'Connection {value['iface']} / {value['signal']}%',
                    f'Network {value['ssid']}',
                    f'IP address {value['ip']}'
                ])
            else:
                self.set_lines([
                    f'Connection {value['iface']} / wired',
                    f'No network name',
                    f'IP address {value['ip']}'
                ])
            self.lines[0].set_style(f'font-size: 1.4em;color:{value['color'] or 'inherit'};')

from ignis.utils import Utils
class ClockBox (MultilineBox):
    def __init__(self, **kwargs):

        super().__init__(right=True)
        Utils.Poll(1000, self.update)

    def update(self, tm):
        now = datetime.now()
        self.set_lines([
            f'{now.strftime("%H:%M")}',
            f'{now.strftime("%Y-%m-%d")}',
            f'{now.strftime("%A, week %V")}'
        ])
        self.lines[0].set_style(f'font-size: 3.4em;')


class RowBox (Widget.Box):
    def __init__(self, **kwargs):

        col1 = Widget.Label(
            label = 'No temp',
            #use_markup=False,
            justify='left',
            #wrap=True,
            #wrap_mode='word',
            #ellipsize='end',
            #max_width_chars=52,
            style = 'opacity:.5;',
            xalign=0.0
        )
        col2 = Widget.Label(
            label = 'No disk',
            justify='left',
            hexpand=False,
            style = 'opacity:.5;',
            xalign=0.0
        )
        col3 = Widget.Label(
            label = 'No vol',
            justify='left',
            style = 'opacity:.5;',
            xalign=0.0
        )
        self.cols = [col1, col2, col3]

        super().__init__(
            spacing = 8,
            vertical = False,
            homogeneous=False,
            style = 'font-size: 1.4em;',
            child = self.cols, **kwargs)
    
    def set_lines (self, texts):
        for label, text in zip(self.cols, texts):
            label.set_label(text)
    
    def update_value(self, temp, disk, volume):
        if temp['value'] > 0:
            self.cols[0].set_label(f'Temp {int(temp['value'])}°')
            self.cols[0].set_style(f'color:{temp['color'] or 'inherit'};')


        self.cols[1].set_label(f'Disk {int(disk['used_percent'])}%')
        self.cols[1].set_style(f'color:{disk['color'] or 'inherit'};')

        self.cols[2].set_label(volume['value'] > 0 and f'Vol. {int(volume['value'])}%' or 'Vol. MUTED')
        self.cols[2].set_style(f'color:{volume['color'] or 'inherit'};')

class NotifBox (Widget.EventBox):
    def __init__(self, notif, on_click=None, **kwargs):

        print(notif.__dict__)
        self.time = notif.time
        self.urgency = notif.urgency
        self.nid = notif.id

        content = notif.body # 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce non bibendum neque, in posuere eros. Curabitur condimentum mi ut nisi iaculis porta. Donec sollicitudin dolor non egestas malesuada. In tempus imperdiet lacus in ornare. Maecenas in felis vestibulum, venenatis ligula sit amet, convallis mauris. Etiam sodales accumsan purus sit amet lacinia. Donec aliquet turpis vel tempus semper. Proin eget metus in neque sodales vehicula. Mauris ac tristique nibh, sed laoreet quam. Phasellus et orci sit amet eros aliquet maximus ut eu justo. Vestibulum non enim quis metus vestibulum egestas. Proin leo ante, vulputate at quam ac, auctor rhoncus orci. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nunc suscipit erat eget euismod bibendum. Mauris eget augue semper, vestibulum nisi eget, congue ligula. Aenean sit amet bibendum dolor'
        if content: content = content[:157] + '...' if len(content) > 160 else content
        else: content = '[No content]'

        col1 = Widget.Label(
            label = f'{notif.summary} ({notif.app_name})',
            #use_markup=False,
            justify='left',
            #wrap=True,
            #wrap_mode='word',
            #ellipsize='end',
            #max_width_chars=52,
            #style = 'opacity:.5;',
            xalign=1.0
        )
        col2 = Widget.Label(
            label = content,
            justify='left',
            wrap=True,
            wrap_mode='word',
            # ellipsize='end',
            # width_chars=52,
            style = 'opacity:.7;margin-top:-0.4rem;',
            xalign=1.0
        )
        self.cols = [col1, col2]

        urgency_label = None
        urgency_color = None
        if notif.urgency == 2:
            urgency_label = 'Important'
            urgency_color = 'red'
        
        if urgency_label:
            col3 = Widget.Label(
                label = urgency_label,
                justify='left',
                style = f'opacity:.8;color:{urgency_color};font-size:1.2rem;margin-top:-0.9rem;',
                xalign=1.0
            )
            self.cols.insert(1, col3)
        
        # notif.actions TODO

        super().__init__(
            spacing = 6,
            vertical = True,
            homogeneous=False,
            hexpand=True,
            width_request=500,
            style = 'font-size: 1.4em;',
            on_click=on_click,
            child = self.cols, **kwargs)