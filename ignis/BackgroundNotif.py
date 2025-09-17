from ignis.widgets import Widget
from ignis.utils import Utils
import time

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
        # TODO: use id for notif replacement/update
        # print(f'id {notification.id}')
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