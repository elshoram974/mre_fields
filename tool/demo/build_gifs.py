"""Builds the GIFs in doc/images from the frames that record.mjs wrote.

Needs Pillow (`pip install pillow`). Identical neighbouring frames are merged
and a palette of 96 colors keeps each GIF well under 1 MB.

    python3 tool/demo/build_gifs.py
"""
import json
import os
import sys

from PIL import Image

FRAMES_DIR = os.environ.get("FRAMES_DIR", "/tmp/mre_fields_frames")
WIDTH = 640
COLORS = 96


def build(scenario: str, out: str) -> None:
    frames = json.load(open(f"{FRAMES_DIR}/{scenario}/frames.json"))

    merged = []
    previous = None
    for frame in frames:
        data = open(frame["file"], "rb").read()
        if data == previous:
            merged[-1][1] += frame["ms"]
        else:
            merged.append([frame["file"], frame["ms"]])
            previous = data

    images, durations = [], []
    for path, ms in merged:
        image = Image.open(path).convert("RGB")
        height = round(image.height * WIDTH / image.width)
        image = image.resize((WIDTH, height), Image.LANCZOS)
        images.append(image.quantize(colors=COLORS, method=Image.MEDIANCUT, dither=Image.NONE))
        durations.append(ms)

    images[0].save(
        out,
        save_all=True,
        append_images=images[1:],
        duration=durations,
        loop=0,
        optimize=True,
        disposal=2,
    )
    print(out, len(images), "frames", round(os.path.getsize(out) / 1024), "KB")


if __name__ == "__main__":
    outputs = {"text": "text-direction", "paste": "image-paste", "phone": "phone-field"}
    for scenario in sys.argv[1:] or outputs:
        build(scenario, f"doc/images/{outputs[scenario]}.gif")
