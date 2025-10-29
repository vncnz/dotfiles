from ignis.widgets import Widget
from ResBox import ResIcon
from Bus import Bus

from ignis.utils import Utils

from theme_colors import col, gra, get_theme

class Navigation (Widget.Window):
    def __init__(self, monitor = None):

        self.left = Widget.Box(
            spacing = 6,
            vertical = False,
            child = []
        )
        self.right = Widget.Box(
            spacing = 6,
            vertical = False,
            child = []
        )
        self.center = Widget.Box(
            spacing = 6,
            vertical = False,
            child = [],
            # style=f'background-color:{col('on_background')};'
        )

        self.box = Widget.CenterBox(
            vertical=False,
            start_widget=self.left,
            center_widget=self.center,
            end_widget=self.right
        )
        self.box.set_hexpand(True)

        super().__init__(
            namespace = 'navigation',
            monitor = monitor,
            child = self.box,
            layer = 'overlay',
            anchor = ['left', 'bottom', 'right'],
            margin_left = 50,
            margin_bottom = 20,
            margin_right = 50,
            style='padding:5px;opacity:.8;'
        )

        Bus.subscribe(lambda x: self.update_bus(x), topic='tasks')
    
    def update_bus (self, tasks):
        self.left.child = [Widget.Icon(image=task, pixel_size=32) for task in tasks['left']]
        self.center.child = [Widget.Icon(image=task, pixel_size=32) for task in tasks['center']]
        self.right.child = [Widget.Icon(image=task, pixel_size=32) for task in tasks['right']]