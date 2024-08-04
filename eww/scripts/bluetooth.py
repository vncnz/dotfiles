#!/usr/bin/env python3

import subprocess, json
#>>> result = subprocess.run(['ls', '-l'], stdout=subprocess.PIPE)
#>>> result.stdout
#result.stdout.decode('utf-8')

def exec (cmd):
    if type(cmd) == type(''): cmd = cmd.split(' ')
    return subprocess.run(cmd, stdout=subprocess.PIPE).stdout.decode('utf-8')

def getDevices ():
    devices = exec('bluetoothctl devices')
    devices = [row for row in devices.splitlines() if row != '']
    d = []
    for dev in devices:
        dd = dev.split(' ')
        d.append((dd[1], ' '.join(dd[2:])))
    return d

def getDeviceInfo (id):
    output = exec('bluetoothctl info ' + id)
    info = {
        'connected': False,
        'name': '',
        'icon_name': '',
        'icon': None,
        'battery': 0
    }
    for line in output.splitlines():
        if 'Connected' in line: info['connected'] = 'yes' in line
        elif 'Name' in line: info['name'] = line.split(':')[1].strip()
        elif 'Icon' in line: info['icon_name'] = line.split(':')[1].strip()
        elif 'Battery Percentage' in line and info['connected']: info['battery'] = int(line.split('(')[1].split(')')[0]) # re.findall(r'\(.*?\)', line)[0]
    if info['icon_name'] == 'input-mouse': info['icon'] = '󰦋'
    return info


# devices = getDevices()
# for device in devices:
#     dinfo = getDeviceInfo(device[0])
#    print(dinfo)

output = [getDeviceInfo(dev[0]) for dev in getDevices()]
output = [out for out in output if out['connected']]
print(json.dumps(output))
# print(devices)