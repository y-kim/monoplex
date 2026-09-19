#!/usr/bin/env python3
"""합성한 부품에 힌팅을 넣고 합친 뒤 테이블을 바로잡는다.

    python3 fonttools_script.py --recipe recipes/monoplex-kr.json [--nerd] [--debug]

fontforge_script.py 가 만든 것을 받는다.

    <Family>-<Style>.ttf   기준 소스(role=base)로 만든 뼈대
    parts/<id>-<Style>.ttf 두께마다 만드는 부품 (CJK 등)
    parts/<id>.ttf         두께와 무관한 부품 (심볼)

힌팅은 뼈대에만 넣는다. CJK 글리프에 ttfautohint 를 돌리면 획이 뭉개진다.
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


def family_short(recipe, suffix):
    family = recipe["output"]["familyName"]
    if suffix:
        family = "%s %s" % (family, suffix)
    return family.replace(" ", "")


def run_ttfautohint(args_list, src, dst):
    subprocess.run(["ttfautohint"] + list(args_list) + ["-I", src, dst], check=True)


# 부품에 남아 있어도 합성 결과에는 의미가 없고, fontTools 병합을 깨뜨리기도 하는 테이블.
# 세로쓰기 메트릭 (vhea/vmtx/VORG) 과 소스 글꼴의 힌팅 (cvt/fpgm/prep) 이다.
# 힌팅은 우리가 변형을 가한 뒤라 어차피 맞지 않는다.
STRIP_FROM_PARTS = ("vhea", "vmtx", "VORG", "cvt ", "fpgm", "prep")


def strip_tables(path, tags=STRIP_FROM_PARTS):
    font = TTFont(path, recalcBBoxes=False, recalcTimestamp=False)
    removed = [t for t in tags if t in font]
    if removed:
        for tag in removed:
            del font[tag]
        font.save(path)
    font.close()
    return removed


def merge_parts(base, parts, out):
    """base 를 우선으로 부품을 합친다.

    fontTools 의 merge 는 같은 코드포인트가 겹치면 앞선 폰트를 남긴다.
    레시피의 sources 순서가 그대로 우선순위가 된다.
    """
    merged = Merger().merge([base] + parts)
    merged.save(out)
    merged.close()


def fs_selection(filename):
    """이름을 보고 fsSelection 을 고른다.

    bit 8 (WWS) 은 항상 켜고 REGULAR / BOLD / ITALIC 을 더한다. 보는 순서까지
    예전 os2_patch.sh 와 같게 두었다. SemiBold 는 이름에 'Bold' 가 들어 있어서
    BOLD 비트가 붙는다.
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

    윤곽만 비우면 cmap 항목이 남아서, OS 가 그 글리프를 쓸 수 있다고 보고
    대체 글꼴(이모지 등)로 넘어가지 않는다.
    """
    for table in font["cmap"].tables:
        for code in codepoints:
            table.cmap.pop(code, None)


def fix_tables(recipe, path):
    fin = recipe["finalize"]
    os2_cfg = fin.get("os2", {})
    target = recipe["target"]
    font = TTFont(path, recalcBBoxes=False, recalcTimestamp=False)

    drop_codepoints(font, [int(c, 16) for c in fin.get("removeCodepoints", [])])

    os2 = font["OS/2"]
    if "xAvgCharWidth" in os2_cfg:
        os2.xAvgCharWidth = os2_cfg["xAvgCharWidth"]
    os2.fsSelection = fs_selection(os.path.basename(path))

    # 세로 메트릭은 FontForge 에서 넣어도 mergeFonts 와 generate 가 윤곽을 보고
    # 다시 계산해 버린다. 그래서 여기서 확정한다.
    if os2_cfg.get("forceVerticalMetrics"):
        v, em = target["vertical"], target["em"]
        os2.usWinAscent = v["ascent"]
        os2.usWinDescent = v["descent"]
        os2.sTypoAscender = em["ascent"]
        os2.sTypoDescender = -em["descent"]
        os2.sTypoLineGap = v.get("typoLineGap", 0)
        hhea = font["hhea"]
        hhea.ascent = v["ascent"]
        hhea.descent = -v["descent"]
        hhea.lineGap = 0

    post = font["post"]
    if "isFixedPitch" in os2_cfg:
        post.isFixedPitch = os2_cfg["isFixedPitch"]
    if "underlinePosition" in os2_cfg:
        post.underlinePosition = os2_cfg["underlinePosition"]

    # VSCode 터미널 하단에서 디센더가 잘리는 문제 대비. 없으면 아무 일도 없다.
    if "BASE" in font:
        del font["BASE"]

    font.save(path)
    font.close()


def main():
    parser = argparse.ArgumentParser(description="부품을 합치고 테이블을 바로잡는다")
    parser.add_argument("--recipe", required=True)
    parser.add_argument("--nerd", action="store_true")
    parser.add_argument("--hidden-space", action="store_true")
    parser.add_argument("--debug", action="store_true")
    parser.add_argument("--dir", default=BASE_DIR)
    args = parser.parse_args()

    with open(args.recipe, encoding="utf-8") as fp:
        recipe = json.load(fp)

    variants = {"nerd": args.nerd, "hiddenSpace": args.hidden_space}
    suffixes = recipe["output"].get("variantSuffix", {})
    suffix = suffixes.get("hiddenSpace", "") if args.hidden_space else (
        suffixes.get("nerd", "") if args.nerd else ""
    )
    prefix = family_short(recipe, suffix)

    work = args.dir
    parts_dir = os.path.join(work, "parts")
    styles = recipe["styles"]
    if args.debug:
        styles = [styles[recipe.get("debugStyleIndex", 0)]]

    sources = [s for s in recipe["sources"] if not s.get("when") or variants.get(s["when"])]
    extra = [s for s in sources if s.get("role") != "base"]
    hinting = recipe["finalize"].get("hinting", [])

    for style in styles:
        name = "%s-%s.ttf" % (prefix, style["file"])
        base = os.path.join(work, name)
        if not os.path.exists(base):
            print("ERROR: %s 가 없습니다" % base, file=sys.stderr)
            return 1

        parts = []
        for source in extra:
            if source.get("role") == "symbols":
                part = os.path.join(parts_dir, "%s.ttf" % source["id"])
            else:
                part = os.path.join(parts_dir, "%s-%s.ttf" % (source["id"], style["file"]))
            if not os.path.exists(part):
                print("ERROR: %s 가 없습니다" % part, file=sys.stderr)
                return 1
            parts.append(part)

        if hinting:
            print("ttfautohint: " + name)
            hinted = os.path.join(work, "hinted-" + name)
            run_ttfautohint(hinting, base, hinted)
        else:
            hinted = base

        for part in parts:
            removed = strip_tables(part)
            if removed:
                print("strip %s: %s" % (os.path.basename(part), ", ".join(removed)))

        print("merge: " + name)
        merge_parts(hinted, parts, base)
        if hinted != base:
            os.remove(hinted)

        print("fix tables: " + name)
        fix_tables(recipe, base)

    shutil.rmtree(parts_dir, ignore_errors=True)
    print("fonttools_script: done")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
