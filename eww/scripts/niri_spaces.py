#!/usr/bin/env python3

import subprocess, json

def exec (cmd):
    if type(cmd) == type(''): cmd = cmd.split(' ')
    return subprocess.run(cmd, stdout=subprocess.PIPE).stdout.decode('utf-8')

wors = json.loads(exec('niri msg -j workspaces'))
wins = json.loads(exec('niri msg -j windows'))

mons = set([w['output'] for w in wors])

applications = []

for mo in mons:
    applications.append(f'Display {mo}')
    for wo in sorted(filter(lambda w: w['output'] == mo, wors), key = lambda w: w['id']):
        # print(wo)
        applications.append(f'{wo['is_focused'] and '󰁕' or ' '} Workspace {wo['name'] or wo['id']}')
        wi = filter(lambda w: wo['id'] == w['workspace_id'], wins)
        for w in wi:
            applications.append(f'   {w['is_focused'] and '󰁕' or ' '} {w['title']} (appid {w['id']})')
        #print(list(wi))

print('\n'.join(applications))
exec(f'echo "{applications}" | fuzzel --dmenu --prompt=""')