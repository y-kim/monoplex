#!/usr/bin/env python3
"""Monoplex KR 글리프 합성.

FontForge 의 Python 바인딩으로 실행한다.

    fontforge -script fontforge_script.py [--nerd] [--hidden-space] [--debug]

예전에는 셸 스크립트가 FontForge 의 .pe 스크립트를 문자열로 만들어 넘겼다.
그 .pe 의 변환 의미를 그대로 옮긴 것이므로, 아래 대응 관계를 지켜야 한다.

    .pe Scale(s) / Rotate(a)    -> 글리프별 bounding box 중심을 기준으로 변환
    .pe Scale(sx, sy, 0, 0)     -> 원점 기준 변환
    .pe CenterInWidth()         -> bbox 를 advance width 한가운데로
    .pe Italic(a)               -> font.italicize(italic_angle=a)
    .pe UnlinkReference()       -> font.unlinkReferences()
    .pe RoundToInt()            -> glyph.round()

특히 Scale 은 중심 인자를 생략하면 원점이 아니라 bbox 중심이 기준이다.
원점 기준으로 바꾸면 글리프가 조용히 어긋난다.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import sys

import fontforge
import psMat

BASE_DIR = os.path.dirname(os.path.abspath(__file__))


# --------------------------------------------------------------------------
# 설정
# --------------------------------------------------------------------------


def load_config(path=None):
    with open(path or os.path.join(BASE_DIR, "build.json"), encoding="utf-8") as fp:
        return json.load(fp)


def cp(value):
    """'2500' 같은 16진 문자열을 코드포인트로."""
    return int(value, 16)


def cp_range(pair):
    return range(cp(pair[0]), cp(pair[1]) + 1)


# --------------------------------------------------------------------------
# .pe 변환 의미를 옮긴 도우미
# --------------------------------------------------------------------------


def transform_about_center(glyph, matrix):
    """.pe 의 중심 인자 없는 Scale/Rotate. 글리프 bbox 중심이 기준이다."""
    xmin, ymin, xmax, ymax = glyph.boundingBox()
    cx, cy = (xmin + xmax) / 2, (ymin + ymax) / 2
    glyph.transform(
        psMat.compose(
            psMat.translate(-cx, -cy),
            psMat.compose(matrix, psMat.translate(cx, cy)),
        )
    )


def scale_about_center(glyph, sx, sy=None):
    transform_about_center(glyph, psMat.scale(sx, sy if sy is not None else sx))


def rotate_about_center(glyph, degrees):
    transform_about_center(glyph, psMat.rotate(math.radians(degrees)))


def center_in_width(glyph):
    """.pe CenterInWidth(). bbox 를 advance width 한가운데로 옮긴다.

    FontForge 의 transform 은 advance width 도 같이 옮기므로 (.pe 의 Move 도
    마찬가지다) 폭을 따로 되돌려 놔야 한다.
    """
    width = glyph.width
    xmin, _, xmax, _ = glyph.boundingBox()
    glyph.transform(psMat.translate((width - (xmax - xmin)) / 2 - xmin, 0))
    glyph.width = width


def existing(font, codepoints):
    """폰트에 실제로 있는 코드포인트만 남긴다."""
    return [c for c in codepoints if c in font]


def glyphs_at(font, codepoints):
    for c in codepoints:
        if c in font:
            yield font[c]


def worth_outputting(glyph):
    """.pe WorthOutputting(). 윤곽이나 참조가 있는 글리프인지."""
    return glyph.isWorthOutputting()


def round_all(font):
    for glyph in font.glyphs():
        if worth_outputting(glyph):
            glyph.round()


def set_em(font, cfg):
    m = cfg["metrics"]
    font.em = m["emAscent"] + m["emDescent"]
    font.ascent = m["emAscent"]
    font.descent = m["emDescent"]


def unlink_all(font):
    font.selection.all()
    font.unlinkReferences()
    font.selection.none()


def apply_panose(font, cfg, panose_weight):
    """.pe 의 SetPanose.

    세로 메트릭(win/typo/hhea)은 여기서 넣어도 mergeFonts 와 generate 가 윤곽을
    보고 다시 계산해 버린다. 그래서 fonttools_script.py 에서 확정한다.
    """
    m = cfg["metrics"]
    p = m["panose"]
    font.os2_panose = (
        p["familyType"],
        p["serifStyle"],
        panose_weight,
        p["proportion"],
        p["contrast"],
        p["strokeVariation"],
        p["armStyle"],
        p["letterForm"],
        p["midline"],
        p["xHeight"],
    )


# --------------------------------------------------------------------------
# 1 단계: IBM Plex Mono 손질 (.pe 의 Material + Console 단계)
# --------------------------------------------------------------------------


def build_plex_mono(cfg, style, src_dir):
    adj = cfg["plexMonoAdjust"]
    mono_cfg = cfg["sources"]["plexMono"]

    path = os.path.join(src_dir, mono_cfg["path"].format(src=style["monoSrc"]))
    print("Open " + path)
    font = fontforge.open(path)

    # r 글리프를 손질한 것으로 교체 (직립 스타일에만 있다)
    r_path = os.path.join(
        src_dir, cfg["sources"]["adjustedGlyphs"]["r"].format(style=style["name"])
    )
    if not style["italic"] and os.path.exists(r_path):
        for glyph in glyphs_at(font, [cp(c) for c in adj["replaceRFrom"]]):
            glyph.clear()
        font.mergeFonts(r_path)

    unlink_all(font)
    set_em(font, cfg)

    # 반각 폭은 스페이스에서 얻는다
    half_src_width = font[0x20].width

    # 백틱: Rotate -> Scale -> Rotate 를 각각 bbox 중심 기준으로
    backtick = font[0x0060]
    rotate_about_center(backtick, adj["backtickRotate1"])
    scale_about_center(backtick, adj["backtickScale"][0] / 100, adj["backtickScale"][1] / 100)
    rotate_about_center(backtick, adj["backtickRotate2"])

    # 따옴표 확대
    sx, sy = adj["quoteScale"]
    for glyph in glyphs_at(font, [cp(c) for c in adj["quoteGlyphs"]]):
        scale_about_center(glyph, sx / 100, sy / 100)
        glyph.width = half_src_width

    # ; : , . 확대
    s = adj["punctuationScale"] / 100
    for glyph in glyphs_at(font, [cp(c) for c in adj["punctuationGlyphs"]]):
        scale_about_center(glyph, s)
        glyph.width = half_src_width

    # 괘선 삭제 (ttfautohint 대책. 반각 괘선은 한글 폰트 쪽에서 넣는다)
    for glyph in glyphs_at(font, cp_range(adj["removeBoxDrawing"])):
        glyph.clear()

    round_all(font)

    # --- 여기부터 .pe 의 Console 단계 ---
    shrink_x = mono_cfg["shrinkX"] / 100
    shrink_y = mono_cfg["shrinkY"] / 100
    half_width = cfg["metrics"]["halfWidth"]

    font.selection.all()
    for glyph in font.selection.byGlyphs:
        glyph.transform(psMat.scale(shrink_x, shrink_y))

    # 소문자는 조금 더 높게
    lo, hi = cp_range(adj["lowercaseRange"]).start, cp_range(adj["lowercaseRange"]).stop
    for glyph in glyphs_at(font, range(lo, hi)):
        glyph.transform(psMat.scale(1, adj["lowercaseScaleY"] / 100))

    # 폭 맞추기. 폭이 0 인 글리프(결합 문자 등)는 건드리지 않는다.
    move_x = (half_width - mono_cfg["width"] * shrink_x) / 2
    for glyph in font.glyphs():
        if not worth_outputting(glyph) or glyph.width == 0:
            continue
        if move_x:
            glyph.transform(psMat.translate(move_x, 0))
        glyph.width = half_width

    round_all(font)
    font.selection.none()
    return font


# --------------------------------------------------------------------------
# 2 단계: IBM Plex Sans KR 손질
# --------------------------------------------------------------------------


def classify_kr_widths(cfg, src_dir, mono_codepoints, style):
    """한글 폰트의 글리프를 폭에 따라 세 갈래로 나눈다.

    IBM Plex Sans KR 은 한글이 892, 일부 기호가 1000 등으로 제각각이라
    한 번 훑어서 분류해 두고 모든 두께에 같은 분류를 쓴다 (.pe 도 그렇게 한다).
    """
    kr_cfg = cfg["sources"]["plexSansKR"]
    half_width = cfg["metrics"]["halfWidth"]
    kr_width = kr_cfg["width"]

    path = os.path.join(src_dir, kr_cfg["path"].format(src=style["krSrc"]))
    print("Half width check loop start (%s)" % style["krSrc"])
    font = fontforge.open(path)

    half, full, others = [], [], []
    for glyph in font.glyphs():
        code = glyph.unicode
        if code is None or code < 0:
            continue
        if not worth_outputting(glyph):
            continue
        if code in mono_codepoints:
            continue
        if glyph.width <= 0:
            continue
        if glyph.width < half_width:
            half.append(code)
        elif glyph.width == kr_width:
            full.append(code)
        else:
            others.append(code)
    font.close()
    print(
        "Half width check loop end (half=%d full=%d others=%d)"
        % (len(half), len(full), len(others))
    )
    return set(half), set(full), set(others)


def build_plex_kr(cfg, style, src_dir, mono_codepoints, widths, hidden_space):
    adj = cfg["plexSansKRAdjust"]
    kr_cfg = cfg["sources"]["plexSansKR"]
    m = cfg["metrics"]
    half_width = m["halfWidth"]
    full_width = half_width * 2
    kr_width = kr_cfg["width"]
    half_set, full_set, others_set = widths

    path = os.path.join(src_dir, kr_cfg["path"].format(src=style["krSrc"]))
    print("Open " + path)
    font = fontforge.open(path)

    # 전각 공백을 보이는 글리프로 교체하는 변종
    if not hidden_space:
        if 0x3000 in font:
            font[0x3000].clear()
        font.mergeFonts(
            os.path.join(src_dir, cfg["sources"]["adjustedGlyphs"]["ideographicSpace"])
        )

    unlink_all(font)
    set_em(font, cfg)

    if style["italic"]:
        print("Generate %s Italic of IBMPlexSansKR" % style["name"])
        font.selection.all()
        font.italicize(italic_angle=m["italicAngle"])
        font.selection.none()

    # IBM Plex Mono 에 있는 글리프는 그쪽을 쓰므로 여기서 지운다
    print("Remove IBMPlexMono Glyphs start")
    for glyph in font.glyphs():
        if glyph.unicode is not None and glyph.unicode in mono_codepoints:
            glyph.clear()
    print("Remove IBMPlexMono Glyphs end")

    # --- 전각 폭 맞추기 ---
    print("Full SetWidth start")
    move_x = (full_width - kr_width) / 2
    for glyph in glyphs_at(font, sorted(full_set)):
        glyph.transform(psMat.translate(move_x, 0))
        glyph.width = full_width

    # 너무 넓은 글리프는 가로로 눌러 준다
    for glyph in glyphs_at(font, sorted(others_set)):
        if glyph.width > kr_width:
            # .pe 의 Scale(kr_width*100/width, 100) 은 정수 나눗셈이었다
            scale_about_center(glyph, (kr_width * 100 // glyph.width) / 100, 1)

    # 위에서 다루지 않은 나머지를 전각으로 센터링
    force_full = {cp(c) for c in adj["forceFullWidth"]}
    full_exclude = {cp(c) for c in adj["fullWidthCenteringExclude"]}
    for glyph in font.glyphs():
        code = glyph.unicode
        if code is None or code < 0 or not worth_outputting(glyph):
            continue
        selected = code not in half_set and code not in full_set
        if code in force_full:
            selected = True
        if code in full_exclude:
            selected = False
        if selected:
            glyph.width = full_width
            center_in_width(glyph)
    print("Full SetWidth end")

    # --- 반각 폭 맞추기 ---
    print("Half SetWidth start")
    half_exclude = set()
    for pair in adj["halfWidthCenteringExclude"]["ranges"]:
        half_exclude.update(cp_range(pair))
    half_exclude.update(cp(c) for c in adj["halfWidthCenteringExclude"]["single"])
    half_exclude.update(cp(c) for c in adj["halfToFullRightExclude"])
    half_exclude.update(force_full)

    for glyph in glyphs_at(font, sorted(half_set - half_exclude)):
        glyph.width = half_width
        center_in_width(glyph)
    print("Half SetWidth end")

    # 전각 구두점·따옴표 확대
    for item in adj["enlarge"]:
        code = cp(item["cp"])
        if code not in font:
            continue
        glyph = font[code]
        scale_about_center(glyph, item["scale"] / 100)
        glyph.width = full_width if item["width"] == "full" else half_width

    # 괘선을 반각으로 (별도 소스에서 가져온다)
    mono_cfg = cfg["sources"]["plexMono"]
    for glyph in glyphs_at(font, cp_range(adj["boxDrawingRange"])):
        glyph.clear()
    font.mergeFonts(
        os.path.join(src_dir, cfg["sources"]["adjustedGlyphs"]["boxDrawingHalf"])
    )
    for glyph in glyphs_at(font, cp_range(adj["boxDrawingRange"])):
        glyph.transform(psMat.translate(0, adj["boxDrawingMoveY"]))
        glyph.transform(psMat.scale(mono_cfg["shrinkX"] / 100, mono_cfg["shrinkY"] / 100))
        if worth_outputting(glyph):
            glyph.width = half_width

    # 결합 분음 기호는 IBM Plex Mono 쪽을 쓴다
    for glyph in glyphs_at(font, cp_range(adj["removeCombiningRange"])):
        glyph.clear()

    # 커닝·폭 조정 lookup 제거
    tags = tuple(adj["removeLookupTags"])
    for lookup in font.gpos_lookups:
        if any(tag in lookup for tag in tags):
            font.removeLookup(lookup)

    font.selection.none()
    return font


# --------------------------------------------------------------------------
# 3 단계: Nerd Fonts 기호
# --------------------------------------------------------------------------


def build_nerd_font(cfg, src_dir):
    nf = cfg["nerdFont"]
    mono_cfg = cfg["sources"]["plexMono"]
    m = cfg["metrics"]
    half_width = m["halfWidth"]

    path = os.path.join(src_dir, cfg["sources"]["nerdFont"])
    print("Open " + path)
    font = fontforge.open(path)
    unlink_all(font)
    set_em(font, cfg)

    keep = set()
    for item in nf["ranges"]:
        keep.update(cp_range(item["range"]))

    for glyph in font.glyphs():
        if glyph.unicode is None or glyph.unicode not in keep:
            glyph.clear()

    # 전체 축소 (IBM Plex Mono 쪽과 같은 비율)
    shrink_x = mono_cfg["shrinkX"] / 100
    shrink_y = mono_cfg["shrinkY"] / 100
    for glyph in font.glyphs():
        if not worth_outputting(glyph):
            continue
        glyph.transform(psMat.scale(shrink_x, shrink_y))
        glyph.width = half_width

    # Powerline 구분자를 Monoplex KR 의 행 박스에 맞춘다.
    #
    # 구분자는 행 박스 전체를 덮어야 세로로 이어 붙었을 때 틈이 없다.
    # Nerd Fonts 쪽 글리프는 ascent 1025 / descent 275 를 기준으로 그려져 있고,
    # 위에서 shrink_y 로 한 번 줄었으므로 그만큼 되돌려 맞춘다.
    pl = nf["powerline"]
    src_em = pl["srcAscent"] + pl["srcDescent"]
    line_em = m["os2Ascent"] + m["os2Descent"]
    scale_y = line_em / (src_em * shrink_y)
    move_y = pl["srcDescent"] * shrink_y * scale_y - m["os2Descent"]
    for glyph in glyphs_at(font, cp_range(pl["range"])):
        glyph.transform(psMat.scale(1, scale_y))
        glyph.transform(psMat.translate(0, move_y))

    font.selection.none()
    return font


# --------------------------------------------------------------------------
# 4 단계: 이름 짓고 합쳐서 내보내기
# --------------------------------------------------------------------------


def font_names(cfg, style, suffix):
    """.pe 의 SetFontNames / SetTTFName 조합을 그대로 옮긴 것.

    Regular / Bold / Italic / Bold Italic 은 RIBBI 네 칸에 들어가고,
    나머지 두께는 패밀리 이름에 두께를 붙여 별도 패밀리로 만든다.
    """
    family = cfg["meta"]["familyName"]
    if suffix:
        family = "%s %s" % (family, suffix)
    short = family.replace(" ", "")

    name = style["name"]
    is_ribbi = name in ("Regular", "Bold")
    file_style = style["file"]

    if style["italic"]:
        sub_ribbi = "Bold Italic" if name == "Bold" else "Italic"
        display = "Italic" if name == "Regular" else "%s Italic" % name
    else:
        sub_ribbi = "Bold" if name == "Bold" else "Regular"
        display = name

    if is_ribbi:
        # 패밀리는 그대로 두고 서브패밀리로 구분한다
        fontname = "%s-%s" % (short, file_style)
        familyname = family
        fullname = "%s %s" % (family, display)
        subfamily = display if style["italic"] else display
    else:
        # 두께를 패밀리 이름에 넣고 서브패밀리는 Regular/Italic 만 쓴다
        fontname = "%s-%s" % (short, file_style)
        familyname = "%s %s" % (family, name)
        fullname = "%s %s" % (family, display)
        subfamily = "Italic" if style["italic"] else "Regular"

    return {
        "fontname": fontname,
        "familyname": familyname,
        "fullname": fullname,
        "subfamily": subfamily,
        "typo_family": family,
        "typo_subfamily": display,
    }


def compose(cfg, style, suffix, mono_font, out_dir):
    m = cfg["metrics"]
    names = font_names(cfg, style, suffix)

    font = fontforge.font()
    font.encoding = "UnicodeFull"
    set_em(font, cfg)

    if style["italic"]:
        font.italicangle = m["italicAngle"]

    font.fontname = names["fontname"]
    font.familyname = names["familyname"]
    font.fullname = names["fullname"]
    font.copyright = cfg["meta"]["copyright"]
    font.version = cfg["meta"]["version"]
    font.weight = style["name"]

    font.appendSFNTName("English (US)", "SubFamily", names["subfamily"])
    font.appendSFNTName("English (US)", "Preferred Family", names["typo_family"])
    font.appendSFNTName("English (US)", "Preferred Styles", names["typo_subfamily"])

    font.os2_weight = style["weight"]
    font.os2_width = m["os2WidthClass"]
    font.os2_fstype = 0
    font.os2_vendor = cfg["meta"]["vendorId"]
    font.os2_family_class = cfg["meta"]["ibmFamily"]

    tmp_mono = os.path.join(out_dir, ".merge-mono-%s.sfd" % style["file"])
    mono_font.save(tmp_mono)
    print("Merge " + os.path.basename(tmp_mono))
    font.mergeFonts(tmp_mono)
    os.remove(tmp_mono)

    apply_panose(font, cfg, style["panoseWeight"])

    # OS 의 이모지 글꼴로 넘기기 위해 지우는 글리프.
    # 여기서는 윤곽만 비운다. cmap 에서 빼는 것은 fonttools_script.py 가 한다.
    for glyph in glyphs_at(font, [cp(c) for c in cfg["finalAdjust"]["removeGlyphs"]]):
        glyph.clear()

    out = os.path.join(out_dir, "%s-%s.ttf" % (short_name(cfg, suffix), style["file"]))
    print("Save " + os.path.basename(out))
    font.generate(out)
    font.close()
    return out


def short_name(cfg, suffix):
    family = cfg["meta"]["familyName"]
    if suffix:
        family = "%s %s" % (family, suffix)
    return family.replace(" ", "")


# --------------------------------------------------------------------------


def main():
    parser = argparse.ArgumentParser(description="Monoplex KR 글리프 합성")
    parser.add_argument("--nerd", action="store_true", help="Nerd Fonts 기호를 넣는다")
    parser.add_argument(
        "--hidden-space",
        action="store_true",
        help="전각 공백을 보이는 글리프로 바꾼다",
    )
    parser.add_argument("--debug", action="store_true", help="Regular 한 두께만 만든다")
    parser.add_argument("--config", default=None)
    parser.add_argument("--out", default=None, help="출력 디렉터리 (기본: 저장소 루트)")
    args = parser.parse_args()

    cfg = load_config(args.config)
    src_dir = os.path.join(BASE_DIR, cfg["sources"]["dir"])
    out_dir = args.out or BASE_DIR

    suffix = ""
    if args.hidden_space:
        suffix = cfg["variantSuffix"]["hiddenSpace"]
    elif args.nerd:
        suffix = cfg["variantSuffix"]["nerd"]

    styles = cfg["styles"]
    if args.debug:
        styles = [styles[cfg["debugStyleIndex"]]]

    # 모든 두께가 같은 분류를 쓰므로 한 번만 구한다
    print("Get trim target glyph from IBMPlexMono")
    probe = build_plex_mono(cfg, cfg["styles"][cfg["debugStyleIndex"]], src_dir)
    mono_codepoints = {
        g.unicode for g in probe.glyphs() if g.unicode is not None and g.unicode >= 0 and worth_outputting(g)
    }
    probe.close()

    # .pe 는 디버그일 때 두께 목록을 먼저 좁힌 다음 그 첫 번째로 폭을 분류했다.
    # 전체 빌드면 Thin, 디버그면 Regular 가 기준이 된다. 그대로 따른다.
    widths = classify_kr_widths(cfg, src_dir, mono_codepoints, styles[0])

    nerd_font = build_nerd_font(cfg, src_dir) if args.nerd else None

    # 한글과 Nerd 글리프는 힌팅이 끝난 뒤 fonttools 로 합친다.
    # 그래서 여기서는 합치지 않고 부품을 따로 내보낸다.
    parts_dir = os.path.join(out_dir, "parts")
    os.makedirs(parts_dir, exist_ok=True)

    if nerd_font is not None:
        nerd_path = os.path.join(parts_dir, "nerd.ttf")
        print("Save " + os.path.basename(nerd_path))
        nerd_font.generate(nerd_path)
        nerd_font.close()

    for style in styles:
        print("=== %s ===" % style["file"])
        mono = build_plex_mono(cfg, style, src_dir)
        out = compose(cfg, style, suffix, mono, out_dir)
        mono.close()

        kr = build_plex_kr(
            cfg, style, src_dir, mono_codepoints, widths, not args.hidden_space
        )
        kr_path = os.path.join(parts_dir, "kr-%s.ttf" % style["file"])
        print("Save " + os.path.basename(kr_path))
        kr.generate(kr_path)
        kr.close()

        print("Generated " + os.path.basename(out))

    print("fontforge_script: done")


if __name__ == "__main__":
    main()
