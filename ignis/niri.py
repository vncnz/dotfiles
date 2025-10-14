from ignis.services.niri import NiriService

niri = NiriService.get_default()

def print_test_old ():

    # Get IDs of all workspaces
    print(f'Workspaces: {[i.id for i in niri.workspaces]}')

    # Get the ID of the active workspace on eDP-1
    print(f'Active workspace in eDP-1: {[i.id for i in niri.workspaces if i.is_active and i.output == "eDP-1"]}')

    # Get the currently active keyboard layout
    print(niri.keyboard_layouts.current_name)

    # Get the title of the active window
    print(niri.active_window.title)

def print_test ():
    # print(niri.active_window.__dict__)
    active_ws_id = niri.active_window.workspace_id
    # active_ws = filter(lambda ws: ws.id == active_ws_id, niri.workspaces).next()
    windows_on_current_ws = filter(lambda w: w.workspace_id == active_ws_id, niri.windows)
    windows = []
    current = None
    for win in windows_on_current_ws:
        # print('\n\n')
        # print(win.__dict__)
        lay = win._DataGObject__latest_synced_data['layout']
        pos = lay['pos_in_scrolling_layout']
        # print(idx, win.title, win.is_focused, '\n', pos)
        windows.append((win.title, win.is_focused, pos))


    windows.sort(key=lambda x: x[2])    
    for idx, win in enumerate(windows):
        if win[1]:
            current = idx
            break

    print(windows)
    print(current)
    print(windows[0:current])
    print(windows[current+1:])

def print_test ():
    # print(niri.active_window.__dict__)
    active_ws_id = niri.active_window.workspace_id
    lay = niri.active_window._DataGObject__latest_synced_data['layout']
    active_pos = lay['pos_in_scrolling_layout']
    # active_ws = filter(lambda ws: ws.id == active_ws_id, niri.workspaces).next()
    windows_on_current_ws = filter(lambda w: w.workspace_id == active_ws_id, niri.windows)
    left = 0
    right = 0
    for win in windows_on_current_ws:
        # print('\n\n')
        # print(win.__dict__)
        lay = win._DataGObject__latest_synced_data['layout']
        pos = lay['pos_in_scrolling_layout']
        if pos[0] < active_pos[0]:
            left += 1
        elif pos[0] > active_pos[0]:
            right += 1
    print(left, right)

    string = '' * left + '' + '' * right
    print(string)