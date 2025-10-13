from pathlib import Path

def list_wallpapers(root: str, exts={'.jpg', '.jpeg', '.png', '.bmp', '.webp'}):
    root = Path(root).expanduser()
    wallpapers = []
    for dirpath, _, filenames in sorted(Path(root).walk()):
        for name in sorted(filenames):
            if Path(name).suffix.lower() in exts:
                wallpapers.append(str(Path(dirpath) / name))
    return wallpapers


def next_wallpaper(current: str, wallpapers: list[str], direction: int = 1) -> str:
    """direction: +1 = next, -1 = previous"""
    current = str(Path(current).expanduser())
    try:
        idx = wallpapers.index(current)
    except ValueError:
        # Se il corrente non è nella lista, parti dal primo/ultimo
        return wallpapers[0 if direction > 0 else -1]

    new_idx = (idx + direction) % len(wallpapers)
    return wallpapers[new_idx]


def change_wallpaper(current):
    root = "~/Pictures/wallpapers"
    wallpapers = list_wallpapers(root)

    # current = "~/Pictures/wallpapers/natura/montagna.jpg"
    next_wp = next_wallpaper(current, wallpapers, +1)
    prev_wp = next_wallpaper(current, wallpapers, -1)

    print("Next:", next_wp)
    print("Prev:", prev_wp)

from ignis.services.wallpaper import WallpaperService
from ignis.options import options
import os

WallpaperService.get_default()
def set_wallpaper(wp, next=None):

    if next != None:
        root = "~/Pictures/wallpapers"
        wallpapers = list_wallpapers(root)

        if next:
            wp = next_wallpaper(wp, wallpapers, +1)
        else:
            wp = next_wallpaper(wp, wallpapers, -1)

        # print("Next:", next_wp)
        # print("Prev:", prev_wp)
        print('Setting wallpaper', wp)
        

    options.wallpaper.set_wallpaper_path(os.path.expanduser(wp))
    return wp