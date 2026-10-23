"""Assemble actual native A/B captures; no generated imagery is substituted."""
from pathlib import Path
import argparse
from PIL import Image, ImageDraw, ImageFont

parser = argparse.ArgumentParser()
parser.add_argument("captures", type=Path)
parser.add_argument("motion", type=Path)
parser.add_argument("output", type=Path)
args = parser.parse_args()
args.output.mkdir(parents=True, exist_ok=True)
font = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 18)
small = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 14)
# Capture is 1280 x 800, while the Godot layout is 1600 x 1000.
stage = (188, 168, 904, 624)
frames = []
for index in range(0, 73, 2):
    source = Image.open(args.motion / f"ab-{index:03d}.png").convert("RGB")
    canvas = Image.new("RGB", (716, 494), "#080d16")
    canvas.paste(source.crop(stage), (0, 38))
    draw = ImageDraw.Draw(canvas)
    draw.text((12, 8), f"Electric A/B  |  same seed 17  |  {index / 60:.2f} s  |  0.5x speed", font=font, fill="#dbe8f8")
    frames.append(canvas)
frames[0].save(args.output / "electric-ab-half-speed.gif", save_all=True,
               append_images=frames[1:], duration=67, loop=0, optimize=True)

sheet = Image.new("RGB", (1432, 1470), "#080d16")
draw = ImageDraw.Draw(sheet)
phases = [(0, "Eye / 0.13 s"), (2, "Release / 0.29 s"), (4, "Recovery / 0.55 s")]
for row, (index, label) in enumerate(phases):
    for mode, title in [(0, "Baseline"), (1, "Astra attempt")]:
        source = Image.open(args.captures / f"mode{mode}-phase{index}.png").convert("RGB")
        crop = source.crop(stage)
        x, y = mode * 716, row * 490
        sheet.paste(crop, (x, y + 32))
        draw.text((x + 12, y + 7), f"{title}  |  {label}", font=font, fill="#dbe8f8")
sheet.save(args.output / "electric-ab-phases.jpg", quality=95)
for index, name in [(0, "eye"), (2, "release"), (4, "recovery")]:
    Image.open(args.captures / f"mode2-phase{index}.png").save(args.output / f"electric-ab-{name}.png")
print(args.output / "electric-ab-half-speed.gif")
print(args.output / "electric-ab-phases.jpg")
