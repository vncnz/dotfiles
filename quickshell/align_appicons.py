#!/usr/bin/env python3

import subprocess
import json
import os, sys

# Directory for .desktop files
DESKTOP_DIRS = ["/usr/share/applications", os.path.expanduser("~/.local/share/applications")]

# Directory for icon files
ICON_DIRS = ["/usr/share/icons", os.path.expanduser("~/.local/share/icons"), "/usr/share/pixmaps"]

def fix_icon(app_id):
    icon_name = ""
    cache_url = '/tmp/app_icons/ico_' + app_id

    if not os.path.exists(cache_url):
        #with open(cache_url, 'r') as f:
        #    return f.read()

    # Looking for .desktop file corresponding to the app_id
        for dir in DESKTOP_DIRS:
            try:
                # Using subprocess to run the `find` command
                desktop_file = subprocess.check_output(
                    f"find {dir} -type f \\( -iname '{app_id}.desktop' -o -iname '{app_id.replace(' ', '-').lower()}.desktop' \\) 2>/dev/null | head -n 1",
                    shell=True,
                    text=True
                ).strip()

                if desktop_file:
                    # Get the first icon in the file
                    with open(desktop_file, 'r') as f:
                        for line in f:
                            if line.lower().startswith("icon="):
                                icon_name = line.split('=', 1)[1].strip()
                                break
                    break

            except subprocess.CalledProcessError:
                continue

        # If no icon returns an empty string
        if not icon_name:
            return ""

        # Look for the icon in the ICON_DIRS
        for dir in ICON_DIRS:
            try:
                icon_path = subprocess.check_output(
                    f"find {dir} -type f -name '{icon_name}.*' 2>/dev/null | head -n 1",
                    shell=True,
                    text=True
                ).strip()

                if icon_path:
                    os.makedirs('/tmp/app_icons', exist_ok=True)
                    # with open(cache_url, 'w') as f:
                    #     f.write(icon_path)

                    res = subprocess.check_output(
                        f"cp {icon_path} {cache_url}",
                        shell=True,
                        text=True
                    ).strip()
            except subprocess.CalledProcessError:
                continue

def main(appIds):
    for appId in appIds:
        fix_icon(appId)

if __name__ == "__main__":
    main(sys.argv[1:])