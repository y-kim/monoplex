"""README 맨 위의 이름 그림을 만든다.

    python3 scripts/header.py kr  "build/Monoplex KR"  MonoplexKR  images/monoplex-kr.png
    python3 scripts/header.py cjk "build/Monoplex CJK" MonoplexCJK images/monoplex-cjk.png

글자마다 굵기를 한 단계씩 올린다. 줄의 첫 글자가 가장 가는 Thin 이고
마지막 글자가 Bold 이며, 그 사이를 여덟 굵기가 고르게 나눠 가진다. 한 줄을
왼쪽에서 오른쪽으로 읽으면 가족 전체를 한 번 훑게 된다.

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


def ramp(text, italic):
    """글자마다 굵기를 한 단계씩 올린 (글자, 스타일) 목록.

    빈칸은 굵기를 쓰지 않으므로 세지 않는다. 글자 수가 여덟과 맞지 않아도
    양 끝이 Thin 과 Bold 가 되도록 고르게 나눈다.
    """
    marks = [i for i, c in enumerate(text) if not c.isspace()]
    runs, step = [], len(marks) - 1
    for i, ch in enumerate(text):
        k = marks.index(i) if i in marks else None
        w = WEIGHTS[-1] if k is None else \
            WEIGHTS[round(k * (len(WEIGHTS) - 1) / step) if step else 0]
        if w == "Regular":
            style = "Italic" if italic else "Regular"
        else:
            style = w + "Italic" if italic else w
        runs.append((ch, INK, style))
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
        x = pad if align == "left" else pad + span - w
        draw_runs(d, x, pad + PITCH * (i + 1), ramp(text, italic), mono)

    left, top, right, bottom = scratch.convert("L").point(
        lambda v: 255 - v).getbbox()
    img = Image.new("RGB", (right - left + 2 * MARGIN, bottom - top + 2 * MARGIN),
                    PAPER)
    img.paste(scratch.crop((left, top, right, bottom)), (MARGIN, MARGIN))
    img.save(out)
    print(f"{out}  {img.size[0]}x{img.size[1]}")


if __name__ == "__main__":
    main(sys.argv)
