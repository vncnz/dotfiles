import os
import hashlib

# dir = '/media/sf_NNNNNNNNNNNNNNNNNN/wallpapers'
dir = '/home/vncnz/Pictures/wallpapers'
# dir2 = 'M:/NNNNNNNNNNNNNNNNNN/wallpapers'

def getFiles (dir):
  res = []
  for path, subdirs, files in os.walk(dir):
    for name in files:
      res.append((name, path))
  return res

files = getFiles(dir)
# files2 = getFiles(dir2)

# print(files[:10])

d = {}
for fil, fol in files:
  digest = hashlib.sha1(open(os.path.join(fol, fil), 'rb').read()).digest()
  if digest not in d:
    d[digest] = []
  else:
    pass
  d[digest].append((fil, fol))

for k,v in d.items():
  if len(v) > 1:
    # print(f'{k} duplicated in: {", ".join([vv[1][len(dir)+1:] for vv in v])}')
    print('New duplication:')
    for vv in v:
      print(f'    {vv[0]} in {vv[1]}')