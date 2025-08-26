import os
import hashlib

# dir = '/media/sf_NNNNNNNNNNNNNNNNNN/wallpapers'
dir = '/home/vncnz/Pictures/wallpapers'
# dir2 = 'M:/NNNNNNNNNNNNNNNNNN/wallpapers'

def getFiles (dir):
  print('Scanning...')
  res = []
  for path, subdirs, files in os.walk(dir):
    for name in files:
      res.append((name, path))
  print(f'Done, {len(res)} files')
  return res

files = getFiles(dir)
# files2 = getFiles(dir2)

# print(files[:10])

print('Mapping...')
d = {}
l = len(files)
p = -1
i = 0
for fil, fol in files:
  i += 1
  pp = int(i/l*100)
  if pp > p:
    print(f'{pp}%')
    p = pp
  digest = hashlib.sha1(open(os.path.join(fol, fil), 'rb').read()).digest()
  if digest not in d:
    d[digest] = []
  else:
    pass
  d[digest].append((fil, fol))

AUTODELETE = True
fulldeletes = []

for k,v in d.items():
  if len(v) > 1:
    # print(f'{k} duplicated in: {", ".join([vv[1][len(dir)+1:] for vv in v])}')
    print(f'\nNew duplication ({len(v)} images):')
    #for vv in v:
    #  print(f'    {vv[1]}/{vv[0]}')
    if AUTODELETE:
      deletes = []
      keep = None
      for filename, path in v:
        this = False
        reason = None
        if not keep:
          this = True
        elif keep[0] < path.count('/'):
          reason = 'longer path'
        elif keep[0] > path.count('/'):
          this = True
          reason = 'longer path'
        elif keep[0] == path.count('/'):
          if filename.split('.')[0] in keep[2].split('.')[0]:
            this = True
            reason = 'same path, filename is superstring'
          elif len(keep[2]) > len(filename):
            this = True
            reason = 'same path, longer filename'
          else:
            reason = 'same path, longer filename'

        if this:
          if keep: deletes.append((*keep, reason))
          keep = (path.count('/'), path, filename)
        else:
          deletes.append((path.count('/'), path, filename, reason))

      print(f'  keep: {keep[2]} in {keep[1]}')
      for depth, path, filename, reason in deletes:
        pa = os.path.join(path, filename)
        # os.remove(pa)
        print(f'   DEL: {filename} in {path} ({reason})')
      fulldeletes += deletes
          

if len(fulldeletes) > 0:
  sure = input(f'\nDeleting {len(fulldeletes)} duplicates, are you sure? (y/n): ')
  if sure == 'y':
    for depth, path, filename, reason in fulldeletes:
        pa = os.path.join(path, filename)
        os.remove(pa)
        print(f'Deleted {pa} ({reason})')
    print('Deletion completed')
  else:
    print('Deletion aborted')