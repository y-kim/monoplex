"""README 그림을 그리는 공통 부분.

글자 너비는 글꼴의 hmtx 에서 그대로 읽는다. 유니코드 폭 분류표를 따로
쓰지 않는 이유는, 이 그림의 요점이 "이 글꼴이 실제로 무슨 너비를 갖는가"
이기 때문이다. 표와 글꼴이 어긋나면 표가 아니라 글꼴이 맞다.
"""

from __future__ import annotations

import os

from PIL import Image, ImageDraw, ImageFont, ImageFilter
from fontTools.ttLib import TTFont


class Mono:
    """고정폭 글꼴 한 가족. 굵기와 이탤릭을 이름으로 꺼내 쓴다."""

    def __init__(self, directory, prefix, size):
        self.dir, self.prefix, self.size = directory, prefix, size
        self._faces = {}
        tt = TTFont(self.path("Regular"))
        upem = tt["head"].unitsPerEm
        cmap, hmtx = tt.getBestCmap(), tt["hmtx"]
        self._adv = {cp: hmtx[g][0] * size / upem for cp, g in cmap.items()}
        self.cell = self._adv[0x41]          # 반각 한 칸
        self.notdef = hmtx[".notdef"][0] * size / upem

    def path(self, style):
        return os.path.join(self.dir, f"{self.prefix}-{style}.ttf")

    def face(self, style="Regular"):
        if style not in self._faces:
            self._faces[style] = ImageFont.truetype(self.path(style), self.size)
        return self._faces[style]

    def width(self, text):
        return sum(self._adv.get(ord(c), self.notdef) for c in text)

    def missing(self, text):
        return [c for c in text if ord(c) not in self._adv]


def draw_runs(draw, x, y, runs, mono):
    """(글자, 색, 스타일) 목록을 베이스라인 y 에 이어 그린다."""
    for text, color, style in runs:
        if text:
            draw.text((x, y), text, font=mono.face(style), fill=color, anchor="ls")
            x += mono.width(text)
    return x


def window(size, body, radius=14, margin=(64, 58, 64, 60), lights=True):
    """맥 스타일 창. 회색 바탕 위에 그림자를 깔고 둥근 사각형을 얹는다."""
    W, H = size
    ml, mt, mr, mb = margin
    img = Image.new("RGB", (W, H), (169, 182, 193))
    box = [ml, mt, W - mr, H - mb]

    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [box[0], box[1] + 10, box[2], box[3] + 10], radius=radius, fill=(0, 0, 0, 90))
    img = Image.alpha_composite(
        img.convert("RGBA"), shadow.filter(ImageFilter.GaussianBlur(18))).convert("RGB")

    d = ImageDraw.Draw(img)
    d.rounded_rectangle(box, radius=radius, fill=body)
    if lights:
        for i, c in enumerate([(255, 95, 86), (255, 189, 46), (39, 201, 63)]):
            cx = ml + 40 + i * 40
            d.ellipse([cx - 10, mt + 38, cx + 10, mt + 58], fill=c)
    return img, d
