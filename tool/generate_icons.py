from pathlib import Path
from PIL import Image, ImageDraw

SCALE = 4
SIZE = 512
OUT = Path(__file__).resolve().parents[1] / "web" / "icons" / "pwa"


def point(x: int, y: int) -> tuple[int, int]:
    return x * SCALE, y * SCALE


def bezier(start, control_a, control_b, end, steps=48):
    points = []
    for index in range(steps + 1):
        t = index / steps
        inverse = 1 - t
        x = (
            inverse**3 * start[0]
            + 3 * inverse**2 * t * control_a[0]
            + 3 * inverse * t**2 * control_b[0]
            + t**3 * end[0]
        )
        y = (
            inverse**3 * start[1]
            + 3 * inverse**2 * t * control_a[1]
            + 3 * inverse * t**2 * control_b[1]
            + t**3 * end[1]
        )
        points.append(point(round(x), round(y)))
    return points


image = Image.new("RGB", point(SIZE, SIZE), "#174B38")
draw = ImageDraw.Draw(image)

# Quiet rings suggest a destination without adding small decorative detail.
for radius, color, width in [(194, "#1D5B43", 8), (154, "#22674B", 5)]:
    center = point(256, 256)
    draw.ellipse(
        (
            center[0] - radius * SCALE,
            center[1] - radius * SCALE,
            center[0] + radius * SCALE,
            center[1] + radius * SCALE,
        ),
        outline=color,
        width=width * SCALE,
    )

cream = "#F6F1DB"
page_shadow = "#0D3528"
page_line = "#B6B79D"
gold = "#F2C66D"

# Original open-page silhouette, deliberately kept inside the maskable safe area.
left_page = [point(78, 278), point(238, 244), point(256, 268), point(256, 412), point(82, 432)]
right_page = [point(434, 278), point(274, 244), point(256, 268), point(256, 412), point(430, 432)]
draw.polygon([(x + 4 * SCALE, y + 10 * SCALE) for x, y in left_page], fill=page_shadow)
draw.polygon([(x - 4 * SCALE, y + 10 * SCALE) for x, y in right_page], fill=page_shadow)
draw.polygon(left_page, fill=cream)
draw.polygon(right_page, fill=cream)

for y in (302, 334, 366):
    draw.line([point(108, y), point(224, y - 18)], fill=page_line, width=5 * SCALE)
    draw.line([point(288, y - 18), point(404, y)], fill=page_line, width=5 * SCALE)

# The single memorable element: a path emerging from the page toward light.
path = bezier((256, 424), (190, 354), (326, 268), (256, 148))
draw.line(path, fill="#123C2D", width=36 * SCALE, joint="curve")
draw.line(path, fill=gold, width=22 * SCALE, joint="curve")
draw.ellipse((*point(232, 116), *point(280, 164)), fill=gold)

OUT.mkdir(parents=True, exist_ok=True)
for size in (512, 192, 180, 32):
    resized = image.resize((size, size), Image.Resampling.LANCZOS)
    resized.save(OUT / f"icon-{size}.png", optimize=True)

print(f"Generated original Bible Path icons in {OUT}")
