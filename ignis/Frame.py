import math
from gi.repository import Gtk, cairo
from ignis.widgets import Widget
from Bus import Bus

class Frame (Widget.Window):

    def __init__(self, output):

        self.border_color = (0, 0, 0, .5)
        self.last_size = (0,0)

        area = Gtk.DrawingArea()
        right = 0
        if output == 0: right = 5
        area.set_draw_func(lambda *args, **kwargs: self.draw_frame(*args, **kwargs, right=right))
        area.set_hexpand(True)
        area.set_vexpand(True)

        super().__init__(
            namespace = f'screen-frame-{output}',
            layer = 'top',
            exclusivity = 'normal',
            kb_mode = 'none',
            style = 'background-color:transparent;',
            input_width = 1,
            input_height = 1,
            monitor = output,
            anchor=['top', 'left', 'bottom', 'right'],
            child = area
        )

        self.area = area

        self.present()
        print(f'Frame created for output {output}')

        Bus.subscribe(lambda x: self.update_color(x), topic='frame-color')
        Bus.subscribe(lambda x: self.update_angle(x), topic='fore-icons-size')

    def roundrect(self, context, x, y, width, height, r, right=0):
        context.move_to(x, y+r)
        context.arc(x+r, y+r, r, math.pi, 3*math.pi/2)
        context.arc(x+width-r-right, y+r, r, 3*math.pi/2, 0)
        context.arc(x+width-r-right, y+height-r, r, 0, math.pi/2)
        context.arc(x+r, y+height-r, r, math.pi/2, math.pi)
        context.close_path()
    
    def roundrect_with_angle(self, context, x, y, width, height, r, right=0, w=0, h=0):
        context.move_to(x, y+r)
        context.arc(x+r, y+r, r, math.pi, 3*math.pi/2)
        context.arc(x+width-r-right, y+r, r, 3*math.pi/2, 0)
        context.arc(x+width-r-right, y+height-r, r, 0, math.pi/2)
        
        if h == 0:
            context.arc(x+r, y+height-r, r, math.pi/2, math.pi)
        else:
            rr = 10
            context.arc(x+rr + w, y+height-rr, rr, math.pi/2, math.pi)
            context.arc_negative(x-rr + w, y+height-h, rr, 0, 3*math.pi/2)
            context.arc(x+rr, y+height-h-2*rr, rr, math.pi/2, math.pi)

        context.close_path()
    
    def draw_frame(self, area, cr, width, height, right=0):

        margin = 0
        cr.set_source_rgba(0.0, 0.0, 0.0, 1)
        cr.set_fill_rule(cairo.FillRule.EVEN_ODD)
        cr.rectangle(0, 0, width, height)
        # self.roundrect(cr, margin, margin, width - 2*margin, height - 2*margin, 30, right=right)
        self.roundrect_with_angle(cr, margin, margin, width - 2*margin, height - 2*margin, 30, right=right, w=self.last_size[0], h=self.last_size[1])
        cr.fill()
        
        self.roundrect_with_angle(cr, margin, margin, width - 2*margin, height - 2*margin, 30, right=right, w=self.last_size[0], h=self.last_size[1])
        cr.set_source_rgba(*self.border_color)
        cr.stroke()

    def update_color(self, new_color):
        if type(new_color) == str:
            hex = new_color[-6:]
            new_color = tuple(int(hex[i:i+2], 16) for i in (0, 2, 4))

        self.border_color = new_color
        self.area.queue_draw()
    
    def update_angle(self, size):
        self.last_size = size
        print('size', size)
        self.area.queue_draw()