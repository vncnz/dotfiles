from ignis.services.niri import NiriService

niri = NiriService.get_default()

def print_test ():

    # Get IDs of all workspaces
    print(f'Workspaces: {[i.id for i in niri.workspaces]}')

    # Get the ID of the active workspace on eDP-1
    print(f'Active workspace in eDP-1: {[i.id for i in niri.workspaces if i.is_active and i.output == "eDP-1"]}')

    # Get the currently active keyboard layout
    print(niri.keyboard_layouts.current_name)

    # Get the title of the active window
    print(niri.active_window.title)