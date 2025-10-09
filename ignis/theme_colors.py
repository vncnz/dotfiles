import json
import subprocess
import re


def run_matugen(image_path: str) -> dict:
    """Exec matugen and returns the output"""
    result = subprocess.run(
        ["matugen", "image", image_path, "-j", "rgb"],
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

def hex_from_rgb(rgb: tuple[int, int, int]) -> str:
    """Converts (R,G,B) #RRGGBB."""
    return f"#{rgb[0]:02X}{rgb[1]:02X}{rgb[2]:02X}"


def build_warning_gradient(c1: tuple[int, int, int], c2: tuple[int, int, int], steps: int = 10) -> list[str]:
    """ Creates the gradient between colors c1 and c2"""
    return [hex_from_rgb(interpolate_color(c1, c2, i / (steps - 1))) for i in range(steps)]

def extract (string):
    return [round(float(s)) for s in re.findall(r'\b[\d\.]+\b', string)]

def generate_theme(image_path: str, mode: str | None = 'dark', steps: int = 10) -> dict:
    """
    mode can be 'dark'(default), 'light' or None
    """
    data = run_matugen(image_path)
    theme = data["colors"][mode]

    c1 = extract(theme["on_background"])
    c2 = extract(theme["error_container"])
    gradient = build_warning_gradient(c1, c2, steps)

    print(theme["on_background"], c1)

    return {
        "mode": mode or "dark",
        "on_background": hex_from_rgb(c1),
        "error": hex_from_rgb(c2),
        "warning_gradient": gradient,
    }