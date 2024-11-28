#!/usr/bin/env python3

import subprocess
import json
import os

# Directory for .desktop files
DESKTOP_DIRS = ["/usr/share/applications", os.path.expanduser("~/.local/share/applications")]

# Directory for icon files
ICON_DIRS = ["/usr/share/icons", os.path.expanduser("~/.local/share/icons"), "/usr/share/pixmaps"]

def find_icon(app_id):
    icon_name = ""
    cache_url = '/tmp/app_icons/' + app_id

    if os.path.exists(cache_url):
        with open(cache_url, 'r') as f:
            return f.read()

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
                with open(cache_url, 'w') as f:
                    f.write(icon_path)
                return icon_path
        except subprocess.CalledProcessError:
            continue

    # If no file was found, return icon name
    return icon_name


def get_windows_json():
    # Run the `niri msg -j windows` command to get the windows data as JSON
    result = subprocess.run(
        ["niri", "msg", "-j", "windows"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    if result.returncode != 0:
        print(f"Error: {result.stderr}")
        return []

    return json.loads(result.stdout)


def main():
    windows_data = get_windows_json()

    output_data = []

    for app in windows_data:
        app_id = app.get('app_id', '')
        workspace_id = app.get('workspace_id', '')

        # Get the icon path for the app
        icon_path = find_icon(app_id)

        # Add icon and workspace_id to the app data
        app['icon'] = icon_path
        app['workspace_id'] = workspace_id

        output_data.append(app)

    # Group by workspace_id
    grouped_data = {}
    for app in output_data:
        workspace_id = app['workspace_id']
        if workspace_id not in grouped_data:
            grouped_data[workspace_id] = []
        grouped_data[workspace_id].append(app)

    # Print final output as JSON
    print(json.dumps(grouped_data, indent=2))


if __name__ == "__main__":
    main()