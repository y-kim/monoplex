"""README 맨 위의 이름 그림을 만든다.

    python3 scripts/header.py kr  "build/Monoplex KR"  MonoplexKR  images/monoplex-kr.png
    python3 scripts/header.py cjk "build/Monoplex CJK" MonoplexCJK images/monoplex-cjk.png

굵기는 글자의 가로 위치만으로 정한다. 왼쪽 끝이 가장 가는 Thin 이고
오른쪽 끝이 Bold 이며, 그 사이를 여덟 굵기가 고르게 나눠 가진다. 같은
세로축에 놓인 글자는 줄이 달라도 같은 굵기라서, 글줄이 어긋나 있어도
굵기의 결은 세로로 곧게 선다.

베이스라인을 손으로 맞추지 않는다. 넉넉한 화폭에 그린 다음 잉크가 닿은
사각형으로 잘라내고 여백을 두르므로, 굵기나 글자를 바꿔도 구도가 유지된다.
아이디어는 Microsoft Cascadia Code 의 표지 그림에서 가져왔다.
"""

from __future__ import annotations

import os
import sys

from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from render import Mono, draw_runs

SIZE, PITCH, MARGIN, STAGGER = 120, 148, 28, 70
INK, PAPER = (0, 0, 0), (255, 255, 255)

# 가는 것부터. Text 는 Regular 와 Medium 사이에 있는 IBM Plex 고유의 굵기다.
WEIGHTS = ["Thin", "ExtraLight", "Light", "Regular",
           "Text", "Medium", "SemiBold", "Bold"]

# (정렬, 기울임, 글자). 왼쪽 한 줄과 오른쪽 두 줄이 어긋나면서 글줄이
# 흔들리는 것이 이 구도의 나머지 절반이다.
SCENES = {
    "kr": [
        ("left",  False, "모노플렉스 KR"),
        ("right", False, "Monoplex KR"),
        ("right", True,  "Italic & 이탤릭"),
    ],
    "cjk": [
        ("left",  False, "모노플렉스 CJK"),
        ("right", False, "Monoplex CJK"),
        ("right", False, "한글 漢字 かな カナ"),
    ],
}


def ramp(text, italic, x0, span, mono):
    """가로 위치로 굵기를 정한 (글자, 색, 스타일) 목록.

    글자 칸의 한가운데가 몇 번째 반각 칸에 떨어지는지만 본다. 위치를
    칸 단위로 끊으므로 같은 세로축에 놓인 글자는 어느 줄에 있든 같은
    굵기가 되고, 굵기의 경계가 세로로 곧게 선다.
    """
    runs, x, last = [], x0, len(WEIGHTS) - 1
    columns = max(1, int(span / mono.cell) - 1)
    for ch in text:
        w = mono.width(ch)
        column = int((x + w / 2) / mono.cell)
        weight = WEIGHTS[max(0, min(last, round(column / columns * last)))]
        if weight == "Regular":
            style = "Italic" if italic else "Regular"
        else:
            style = weight + "Italic" if italic else weight
        runs.append((ch, INK, style))
        x += w
    return runs


def main(argv):
    scene, directory, prefix, out = argv[1:5]
    lines = SCENES[scene]
    mono = Mono(directory, prefix, SIZE)

    gone = sorted({c for _, _, t in lines for c in mono.missing(t)})
    if gone:
        raise SystemExit("ERROR: 글꼴에 없는 글자: " + " ".join(gone))

    widths = [mono.width(t) for _, _, t in lines]
    span = max(widths) + STAGGER                    # 왼쪽 줄과 오른쪽 줄의 합집합

    pad = SIZE * 2                                  # 잘라낼 것이므로 넉넉히
    scratch = Image.new("RGB", (int(span) + 2 * pad, PITCH * len(lines) + 2 * pad),
                        PAPER)
    d = ImageDraw.Draw(scratch)
    for i, ((align, italic, text), w) in enumerate(zip(lines, widths)):
        x0 = 0 if align == "left" else span - w
        draw_runs(d, pad + x0, pad + PITCH * (i + 1),
                  ramp(text, italic, x0, span, mono), mono)

    left, top, right, bottom = scratch.convert("L").point(
        lambda v: 255 - v).getbbox()
    img = Image.new("RGB", (right - left + 2 * MARGIN, bottom - top + 2 * MARGIN),
                    PAPER)
    img.paste(scratch.crop((left, top, right, bottom)), (MARGIN, MARGIN))
    img.save(out)
    print(f"{out}  {img.size[0]}x{img.size[1]}")


if __name__ == "__main__":
    main(sys.argv)
