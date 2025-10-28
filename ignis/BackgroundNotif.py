from ignis.widgets import Widget
from ignis.utils import Utils
import time

from ResBox import ClockBox, NotifBox
from Bus import Bus

#{'_Notification__dbus': <dbus.DBusService object at 0x7f2d990ebf00 (ignis+dbus+DBusService at 0x55d66e941e50)>, '_id': 636, '_app_name': 'nemo', '_icon': 'media-removable', '_summary': 'Writing data to USB SanDisk 3.2Gen1', '_body': 'Device should not be unplugged.', '_timeout': 5000, '_time': 1758353594.31154, '_urgency': 2, '_popup': True, '_actions': []}
#Updated max_urgency 2 red
#{'_Notification__dbus': <dbus.DBusService object at 0x7f2d990ebf00 (ignis+dbus+DBusService at 0x55d66e941e50)>, '_id': 637, '_app_name': 'nemo', '_icon': 'media-removable', '_summary': 'USB SanDisk 3.2Gen1 can be safely unplugged', '_body': 'Device can be removed.', '_timeout': 5000, '_time': 1758353595.824744, '_urgency': 1, '_popup': True, '_actions': []}

class BackgroundNotif (Widget.Window):
    def __init__(self, monitor = None):

        self.box = Widget.Box(
            spacing = 6,
            vertical = True,
            child = []
        )
        self.line = Widget.Box(
            width_request=0,
            height_request=2,
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
        # TODO: Implement something like @Utils.debounce(50) but sender-specific
        found = next((x for x in self.box.child if x.nid == notification.id), None)
        if not found and notification.icon == 'media-removable': # * patch for Nemo "removing usb drive" notification
            found = next((x for x in self.box.child if x.icon == 'media-removable' and x.app_name == notification.app_name), None)
        if not found and notification.app_name == 'Firefox': # * patch for avoid multiple chat notifications from same user for chats in Firefox
            found = next((x for x in self.box.child if x.summary == notification.summary), None)
        if found:
            self.remove(found)
            # TODO: replace the notification in its previous position, instead of removing and appending?

        notif = NotifBox(notification, lambda x: self.remove(x))
        self.box.append(notif)
        self.update_color()
    
    def remove(self, x):
        self.box.remove(x)
        self.update_color()

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
                Bus.publish('red', topic='notif')
            elif max_urgency > -1:
                color = 'white'
                Bus.publish('white', topic='notif')
            else:
                color = 'rgba(0, 0, 0, 0.01)'
                Bus.publish(None, topic='notif')
            self.line.set_style(f'background:{color};')
            self.last_max_urgency = max_urgency
            # print("Updated max_urgency", max_urgency, color)