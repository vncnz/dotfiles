import json
import subprocess
import re

_computed = None
_mode = 'dark'

def toggle_mode ():
    global _mode
    _mode = 'light' if _mode == 'dark' else 'dark'

def get_theme():
    return _computed

def gra (value):
    if _computed:
        return _computed['warning_gradient'][int(value * 9.999)]
    return 'white'

def col (name):
    if name in _computed:
        return _computed[name]
    return None

def run_matugen(image_path: str) -> dict:
    """Exec matugen and returns the output"""
    result = subprocess.run(
        ["matugen", "image", image_path, "-j", "rgb", "--contrast", "0"],
        capture_output=True,
        text=True,
        check=True,
    )
    return json.loads(result.stdout)


def interpolate_color(c1: tuple[int, int, int], c2: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    """Color linear interpolation"""
    return tuple(
        round(c1[i] + (c2[i] - c1[i]) * t)
        for i in range(3)
    )

def interpolate_color_hsl(c1: tuple[int, int, int], c2: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    """Color linear interpolation"""
    return tuple(round(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))

def hex_from_rgb(rgb: tuple[int, int, int]) -> str:
    """Converts (R,G,B) #RRGGBB."""
    return f"#{rgb[0]:02X}{rgb[1]:02X}{rgb[2]:02X}"

def hex_from_hsl(hsl: tuple[int, int, int]) -> str:
    """Converts (R,G,B) #RRGGBB."""
    return f"hsl({hsl[0]},{hsl[1]}%,{hsl[2]}%)"

def build_warning_gradient(c1: tuple[int, int, int], c2: tuple[int, int, int], steps: int = 10) -> list[str]:
    """ Creates the gradient between colors c1 and c2"""
    return [hex_from_rgb(interpolate_color(c1, c2, i / (steps - 1))) for i in range(steps)]

def build_warning_gradient_hsl(c1: tuple[int, int, int], c2: tuple[int, int, int], steps: int = 10) -> list[str]:
    """ Creates the gradient between colors c1 and c2"""
    return [hex_from_hsl(interpolate_color_hsl(c1, c2, i / (steps - 1))) for i in range(steps)]

def extract (string):
    return [round(float(s)) for s in re.findall(r'\b[\d\.]+\b', string)]

def rgb_to_hsl(color):
    r, g, b = color
    r, g, b = [x / 255.0 for x in (r, g, b)]
    max_c, min_c = max(r, g, b), min(r, g, b)
    l = (max_c + min_c) / 2

    if max_c == min_c:
        h = s = 0  # achromatic
    else:
        d = max_c - min_c
        s = d / (2 - max_c - min_c) if l > 0.5 else d / (max_c + min_c)
        if max_c == r:
            h = ((g - b) / d + (6 if g < b else 0)) / 6
        elif max_c == g:
            h = ((b - r) / d + 2) / 6
        else:
            h = ((r - g) / d + 4) / 6

    #return h * 360, s * 100, l * 100
    return h, s, l

def hsl_to_rgb(color):
    h, s, l = color
    def hue_to_rgb(p, q, t):
        if t < 0: t += 1
        if t > 1: t -= 1
        if t < 1/6: return p + (q - p) * 6 * t
        if t < 1/2: return q
        if t < 2/3: return p + (q - p) * (2/3 - t) * 6
        return p

    if s == 0:
        r = g = b = l  # achromatic (grigio)
    else:
        q = l * (1 + s) if l < 0.5 else l + s - l * s
        p = 2 * l - q
        r = hue_to_rgb(p, q, h + 1/3)
        g = hue_to_rgb(p, q, h)
        b = hue_to_rgb(p, q, h - 1/3)

    return round(r * 255), round(g * 255), round(b * 255)


import os
def generate_theme(image_path: str, mode: str | None = None, steps: int = 10) -> dict:
    """
    mode can be 'dark'(default), 'light' or None
    """
    global _computed

    if '~' in image_path:
        image_path = os.path.expanduser(image_path)

    data = run_matugen(image_path)
    theme = data["colors"][mode or _mode]

    on_back = extract(theme["on_background"])
    back = extract(theme["background"])
    # c2 = extract(theme["error"])
    pri = extract(theme["primary"])
    pri_container = extract(theme["primary_container"])
    # c1_hsl = rgb_to_hsl(on_back)
    pri_hsl = rgb_to_hsl(pri)
    # red_hsl = (0, pri_hsl[1], pri_hsl[2])
    red = (255, 0, 0) # hsl_to_rgb(red_hsl)
    # c2_hsl = rgb_to_hsl(c2)
    #c2 = rgb_to_hsl(c2)
    # gradient = build_warning_gradient(on_back, red, steps)
    gradient = build_warning_gradient_hsl((90, pri_hsl[1]*100, pri_hsl[2]*100), (0,100,50), steps)

    # print('on_background', theme["on_background"], on_back)
    # print('primary', theme["primary"], pri_hsl)
    # print('myred', red, red_hsl)
    # print(hsl_to_rgb(rgb_to_hsl((30, 50, 50))))

    _computed = {
        "mode": mode or _mode,
        "background": hex_from_rgb(back),
        "on_background": hex_from_rgb(on_back),
        "primary": hex_from_rgb(pri),
        "primary_container": hex_from_rgb(pri_container),
        "error": hex_from_rgb(red),
        "warning_gradient": gradient,
    }
    return _computed