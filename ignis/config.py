from ignis.widgets import Widget

Widget.Window(
    namespace="some-window",  # the name of the window (not title!)
    child=Widget.Label(  # we set Widget.Label as the child widget of the window
        label="Hello world!"  # define text here
    ),
)
