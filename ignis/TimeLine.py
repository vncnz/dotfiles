from datetime import datetime

from ignis.widgets import Widget
from ResBox import ResIcon
from Bus import Bus

from gi.repository import Gtk

from theme_colors import col, gra, get_theme

class TimeLine (Widget.Window):
    def __init__(self, monitor = None):

        self.h = 950

        self.line_now = Widget.Label(
            label = '',
            justify='left',
            style = 'font-size: 1.5em;color:red;',
            xalign= 1.0
        )

        self.box2 = Gtk.Fixed(width_request=6, height_request=self.h)

        self.hours = []
        for h in range(3,24,3):
            size = '1.0em' if h % 6 else '1.2em'
            # m = (self.h / 12) * (h - 12)
            dict = {
                'label': '',
                'justify': 'left',
                'style': f'font-size: {size};color:white;',
                'xalign': 1.0,
            }
            # if m > 0: dict['margin_bottom'] = m
            # elif m < 0: dict['margin_top'] = -m
            # self.hours.append(
            #     Widget.Label(**dict)
            # )
            label = Widget.Label(**dict)
            m = (self.h / 24) * h
            # m = self.vadjust(label, m)
            self.box2.put(label, 0, m)
            self.hours.append(label)
            # print(f'time {h} pos {m}')

        self.battery = Widget.Label(
            label="",
            # style=f"background-image:linear-gradient(to top, transparent 0, transparent {start}px, {gra(0)} {start}px, {gra(1)} {end}px, transparent {end}px);",
            width_request=2,
            height_request=self.h
        )

        #self.box = Widget.Overlay(
        #    child=Widget.Label(label="", width_request=20, height_request=self.h),
        #    overlays = [ self.battery ] + self.hours + [ self.line_now ]
        #)

        self.box2.put(self.battery, 12, 0)
        self.box2.put(self.line_now, 0, self.h / 2)

        super().__init__(
            namespace = 'timeline',
            monitor = monitor,
            child = self.box2,
            layer = 'overlay',
            style = 'background:transparent;',
            anchor = ['right'],
            margin_right = 0
        )
        self.fixed = False
        # self.update_time(43200, 435)

        # self.update_style()

        # Bus.subscribe(lambda x: self.update_bus(x))
    
    def fix_hours (self):
        for h in self.hours:
            # print(h.get_allocation().y, h.get_allocation().height)
            if h.get_allocation().height > 0:
                m = h.get_allocation().y
                m = self.vadjust(h, m)
                self.box2.move(h, 0, m)
                self.fixed = True

    def vadjust (self, elem, y):
        alloc = elem.get_allocation()
        return y - (alloc.height // 2)
    
    def update_time (self, time, battery):
        if time is None:
            now = datetime.now()
            time = now.hour * 3600 + now.minute * 60 + now.second

            if not self.fixed: self.fix_hours()
        top = self.h - (time / 86400.0 * self.h)
        print('time shift', top, battery)
        self.box2.move(self.line_now, 0, self.vadjust(self.line_now, top))

        if battery[0] == -1:
            start = self.h - top
            end = start + (battery[1] * 60 / 86400.0 * self.h)
            # print('battery gradient', start, end)
            self.battery.set_style(f"filter:blur(2px);background-image:linear-gradient(to top, transparent {start}px, {gra(battery[2])} {start}px, {gra(1)} {end}px, transparent {end}px);")
        elif battery[0] == 1:
            start = self.h - top
            end = start + (battery[1] * 60 / 86400.0 * self.h)
            self.battery.set_style(f"filter:blur(2px);background-image:linear-gradient(to top, transparent {start}px, {gra(battery[2])} {start}px, {gra(0)} {end}px, transparent {end}px);")
        # self.set_style(f"background-image:linear-gradient(to top, transparent {start}px, {gra(0)} {start}px, {gra(1)} {end}px, transparent {end}px);")