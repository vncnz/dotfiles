from Bus import Bus


from ignis.services.applications import ApplicationsService

applications = ApplicationsService.get_default()
# for i in applications.apps:
#     print(i.name, i.icon, i.id, i.executable)

cache = {}
def get_icon (appid: str):
    if appid.endswith('.desktop'):
        appid = appid.rsplit('.', 1)[0]
    
    if appid in cache:
        return cache[appid].icon
    
    app = next(filter(lambda app: f'{appid}.desktop' == app.id, applications.apps), None)
    if app:
        cache[appid] = app
        return app.icon
    else:
        print(f'[warning] No icon for {appid}')
        #for i in applications.apps:
        #    if 'ark' in i.id:
        #        print(i.name, i.icon, i.id, i.executable, i.id == f'{appid}.desktop')





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


def l (el, k):
    return el._DataGObject__latest_synced_data['layout'][k]
def w ():
    active_ws = next(filter(lambda w: w.is_focused, niri.workspaces))
    active_ws_id = 0 if active_ws is None else active_ws.id
    windows_on_current_ws = filter(lambda w: w.workspace_id == active_ws_id, niri.windows)
    focused = next(filter(lambda w: w.is_focused, niri.windows), None)

    for win in windows_on_current_ws:
        print(win.__dict__)
    return

    #print('active_ws_id', active_ws_id)

    if 'layout' not in focused._DataGObject__latest_synced_data:
        print(focused.__dict__)
        print('focused', focused)
        print('EXITING w()')
        return
    
    lay = focused._DataGObject__latest_synced_data['layout']
    active_pos = lay['pos_in_scrolling_layout']
    # active_ws = filter(lambda ws: ws.id == active_ws_id, niri.workspaces).next()
    

    left = []
    right = []
    center = []

    for win in windows_on_current_ws:
        icon = get_icon(win.app_id)
        # print('\n\n')
        # print(win.__dict__)
        print(win.app_id, icon)
        for k in ['pos_in_scrolling_layout']:
            try: print(k, l(win, k))
            except: print(k, '<<error>>')

        lay = win._DataGObject__latest_synced_data['layout']
        pos = lay['pos_in_scrolling_layout']
        if pos[0] < active_pos[0]:
            left.append(icon)
        elif pos[0] > active_pos[0]:
            right.append(icon)
        else:
            center.append(icon)
    print(left, right)

    string = '' * len(left) + '' + '' * len(right)
    print(string)

    Bus.publish({
        'left': left,
        'center': center,
        'right': right
    }, 'tasks')

last_active = None
def check_active (_):
    global last_active, niri
    niri = NiriService.get_default()

    if last_active != niri.active_window.title:
        last_active = niri.active_window.title

        w()
    else: print('same window', niri.active_window)

from ignis.utils import Utils
Utils.Poll(1000, check_active)