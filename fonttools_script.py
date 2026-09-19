#!/usr/bin/env python3
"""Monoplex KR 마무리 처리.

fontforge_script.py 가 만든 부품을 받아서

1. 라틴 부분에 ttfautohint 로 힌팅을 넣고
2. 한글 부품과 (있으면) Nerd Fonts 부품을 합치고
3. OS/2 와 post 테이블의 값을 바로잡는다

예전의 os2_patch.sh 는 ttx 로 XML 을 덤프해 sed 로 고치고 다시 컴파일했다.
여기서는 fontTools 로 테이블을 직접 건드린다. ttx 왕복이 사라져서 빠르고,
정규식이 어긋나 조용히 실패할 일도 없다.

    python3 fonttools_script.py [--nerd] [--debug]
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys

from fontTools.merge import Merger
from fontTools.ttLib import TTFont

BASE_DIR = os.path.dirname(os.path.abspath(__file__))


def load_config(path=None):
    with open(path or os.path.join(BASE_DIR, "build.json"), encoding="utf-8") as fp:
        return json.load(fp)


def short_name(cfg, suffix):
    family = cfg["meta"]["familyName"]
    if suffix:
        family = "%s %s" % (family, suffix)
    return family.replace(" ", "")


def run_ttfautohint(cfg, src, dst):
    args = ["ttfautohint"] + list(cfg["hinting"]["args"]) + ["-I", src, dst]
    subprocess.run(args, check=True)


def merge_parts(base, parts, out):
    """base 를 우선으로 부품을 합친다.

    fontTools 의 merge 는 같은 코드포인트가 겹치면 앞선 폰트를 남긴다.
    라틴(base) > Nerd > 한글 순서라, 세 곳 모두에 있는 글리프는 라틴이 이긴다.
    """
    merger = Merger()
    merged = merger.merge([base] + parts)
    merged.save(out)
    merged.close()


def fs_selection(filename):
    """예전 os2_patch.sh 가 파일 이름을 보고 고르던 값을 그대로 옮긴 것.

    bit 8 (WWS) 은 항상 켜고, 이름에 따라 REGULAR / BOLD / ITALIC 을 더한다.
    조건을 보는 순서까지 같아야 한다. 예를 들어 SemiBold 는 이름에 'Bold' 가
    들어 있어서 BOLD 비트가 붙는다.
    """
    wws = 1 << 8
    if "Regular" in filename:
        return wws | (1 << 6)
    if "BoldItalic" in filename:
        return wws | (1 << 5) | (1 << 0)
    if "Bold" in filename:
        return wws | (1 << 5)
    if "Italic" in filename:
        return wws | (1 << 0)
    return wws


def drop_codepoints(font, codepoints):
    """cmap 에서 코드포인트를 뺀다.

    FontForge 에서 윤곽을 비워도 cmap 항목은 남는다. 남아 있으면 OS 가
    그 글리프를 쓸 수 있다고 보고 이모지 글꼴로 넘어가지 않는다.
    """
    for table in font["cmap"].tables:
        for code in codepoints:
            table.cmap.pop(code, None)


def fix_tables(cfg, path, style):
    patch = cfg["os2Patch"]
    font = TTFont(path, recalcBBoxes=False, recalcTimestamp=False)

    drop_codepoints(font, [int(c, 16) for c in cfg["finalAdjust"]["removeGlyphs"]])

    os2 = font["OS/2"]
    os2.xAvgCharWidth = patch["xAvgCharWidth"]
    os2.fsSelection = fs_selection(os.path.basename(path))

    if patch.get("verticalMetrics"):
        m = cfg["metrics"]
        os2.usWinAscent = m["os2Ascent"]
        os2.usWinDescent = m["os2Descent"]
        os2.sTypoAscender = m["emAscent"]
        os2.sTypoDescender = -m["emDescent"]
        os2.sTypoLineGap = m["typoLineGap"]
        hhea = font["hhea"]
        hhea.ascent = m["os2Ascent"]
        hhea.descent = -m["os2Descent"]
        hhea.lineGap = 0

    post = font["post"]
    post.isFixedPitch = patch["isFixedPitch"]
    post.underlinePosition = patch["underlinePosition"]

    # VSCode 터미널 하단에서 디센더가 잘리는 문제 대비. 없으면 아무 일도 없다.
    if "BASE" in font:
        del font["BASE"]

    font.save(path)
    font.close()


def main():
    parser = argparse.ArgumentParser(description="Monoplex KR 마무리 처리")
    parser.add_argument("--nerd", action="store_true")
    parser.add_argument("--hidden-space", action="store_true")
    parser.add_argument("--debug", action="store_true")
    parser.add_argument("--config", default=None)
    parser.add_argument("--dir", default=BASE_DIR, help="부품이 있는 디렉터리")
    args = parser.parse_args()

    cfg = load_config(args.config)
    work = args.dir
    parts_dir = os.path.join(work, "parts")

    suffix = ""
    if args.hidden_space:
        suffix = cfg["variantSuffix"]["hiddenSpace"]
    elif args.nerd:
        suffix = cfg["variantSuffix"]["nerd"]
    prefix = short_name(cfg, suffix)

    styles = cfg["styles"]
    if args.debug:
        styles = [styles[cfg["debugStyleIndex"]]]

    nerd_part = os.path.join(parts_dir, "nerd.ttf")
    if args.nerd and not os.path.exists(nerd_part):
        print("ERROR: %s 가 없습니다" % nerd_part, file=sys.stderr)
        return 1

    for style in styles:
        name = "%s-%s.ttf" % (prefix, style["file"])
        latin = os.path.join(work, name)
        kr_part = os.path.join(parts_dir, "kr-%s.ttf" % style["file"])
        if not os.path.exists(latin):
            print("ERROR: %s 가 없습니다" % latin, file=sys.stderr)
            return 1
        if not os.path.exists(kr_part):
            print("ERROR: %s 가 없습니다" % kr_part, file=sys.stderr)
            return 1

        print("ttfautohint: " + name)
        hinted = os.path.join(work, "hinted-" + name)
        run_ttfautohint(cfg, latin, hinted)

        print("merge: " + name)
        parts = ([nerd_part] if args.nerd else []) + [kr_part]
        merge_parts(hinted, parts, latin)
        os.remove(hinted)

        print("fix tables: " + name)
        fix_tables(cfg, latin, style)

    shutil.rmtree(parts_dir, ignore_errors=True)
    print("fonttools_script: done")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
