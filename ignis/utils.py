DEFAULT_WHITE = True

def clamp (vmin, vmax, val):
    return min(max(vmin, val), vmax)

def get_color_gradient (vmin, vmax, value, reversed = False):
    clamped = clamp(vmin, vmax, value)
    ratio = 0.5 if vmax == vmin else ((clamped - vmin) / (vmax - vmin))

    if not reversed: ratio = 1.0 - ratio
    sat = 0
    hue = 0
    if DEFAULT_WHITE:
        sat = max(1.0 - (ratio * ratio * ratio), 0.0) * 100
        hue = 60.0 * ratio; # 60 -> 0
    else:
        sat = 100
        hue = 100.0 * ratio; # 100 -> 0

    return f'hsl({hue}, {sat}%, {100-sat/2}%)'

def bytes_to_human (num, suffix="B"):
    for unit in ("", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi"):
        if abs(num) < 1024.0:
            return f"{num:3.1f}{unit}{suffix}"
        num /= 1024.0
    return f"{num:.1f}Yi{suffix}"
