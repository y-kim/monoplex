#!/usr/bin/env python3
"""레시피대로 글꼴을 합성한다.

FontForge 의 Python 바인딩으로 실행한다.

    fontforge -script fontforge_script.py --recipe recipes/monoplex-kr.json [--nerd] [--debug]

레시피의 sources 는 우선순위 순서다. 앞선 소스가 같은 코드포인트를 이긴다.
보통 라틴 고정폭(role=base)이 맨 앞, 그다음 CJK, 마지막이 심볼이다.
role=base 인 소스만 최종 글꼴의 뼈대가 되고, 나머지는 parts/ 에 따로 내보낸다.
힌팅을 넣은 뒤 fonttools_script.py 가 합친다.

FontForge 의 .pe 스크립트에서 옮겨 온 코드라 변환 의미를 맞춰 두었다.

    .pe Scale(s) / Rotate(a)    -> 글리프별 bounding box 중심 기준
    .pe Scale(sx, sy, 0, 0)     -> 원점 기준
    .pe CenterInWidth()         -> bbox 를 advance width 한가운데로
    .pe Italic(a)               -> font.italicize(italic_angle=a)

Scale 은 중심 인자를 생략하면 원점이 아니라 bbox 중심이 기준이다.
그리고 transform 은 advance width 도 같이 옮긴다. 둘 다 조용히 틀리기 쉬운 곳이다.
"""

from __future__ import annotations

import argparse
import json
import math
import os

import fontforge
import psMat

BASE_DIR = os.path.dirname(os.path.abspath(__file__))


def cp(value):
    return int(value, 16)


def cp_range(pair):
    return range(cp(pair[0]), cp(pair[1]) + 1)


class Context:
    """한 두께를 만드는 동안 들고 다니는 값."""

    def __init__(self, recipe, style, base_dir, variants):
        self.recipe = recipe
        self.style = style
        self.variants = variants
        target = recipe["target"]
        self.em_ascent = target["em"]["ascent"]
        self.em_descent = target["em"]["descent"]
        self.half_width = target["halfWidth"]
        self.full_width = self.half_width * 2
        self.italic_angle = target["italicAngle"]
        self.src_dir = os.path.join(base_dir, recipe.get("sourceDir", "source"))

    def path(self, template, style=None):
        return os.path.join(self.src_dir, template.format(**(style or self.style)))

    def width_value(self, name, source_half=None):
        if name == "half":
            return self.half_width
        if name == "full":
            return self.full_width
        if name == "source-half":
            return source_half
        raise ValueError("알 수 없는 폭 이름: %r" % name)


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


def center_in_width(glyph):
    """.pe CenterInWidth(). transform 이 폭도 옮기므로 되돌려 놓는다."""
    width = glyph.width
    xmin, _, xmax, _ = glyph.boundingBox()
    glyph.transform(psMat.translate((width - (xmax - xmin)) / 2 - xmin, 0))
    glyph.width = width


def worth(glyph):
    return glyph.isWorthOutputting()


def set_em(font, ctx):
    """.pe ScaleToEm. upem 이 다른 소스도 여기서 목표 크기로 맞춰진다."""
    font.em = ctx.em_ascent + ctx.em_descent
    font.ascent = ctx.em_ascent
    font.descent = ctx.em_descent


def unlink_all(font):
    font.selection.all()
    font.unlinkReferences()
    font.selection.none()


def codepoints_of(font):
    return {
        g.unicode for g in font.glyphs()
        if g.unicode is not None and g.unicode >= 0 and worth(g)
    }


# --------------------------------------------------------------------------
# 글리프 조작 op
# --------------------------------------------------------------------------

OPS = {}


def op(name):
    def deco(fn):
        OPS[name] = fn
        return fn
    return deco


def selected_codepoints(spec):
    out = []
    if "cp" in spec:
        out.append(cp(spec["cp"]))
    out.extend(cp(v) for v in spec.get("cps", []))
    if "range" in spec:
        out.extend(cp_range(spec["range"]))
    for pair in spec.get("ranges", []):
        out.extend(cp_range(pair))
    return out


def selected_glyphs(font, spec):
    for code in selected_codepoints(spec):
        if code in font:
            yield font[code]


def as_scale(value):
    """by: 145 또는 [109, 106] 을 (sx, sy) 배율로."""
    if isinstance(value, (int, float)):
        return value / 100, value / 100
    sx, sy = value
    return sx / 100, sy / 100


def apply_set_width(ctx, glyph, spec, source_half):
    name = spec.get("setWidth")
    if name:
        glyph.width = ctx.width_value(name, source_half)


@op("scale")
def op_scale(ctx, font, spec, source_half):
    sx, sy = as_scale(spec["by"])
    for glyph in selected_glyphs(font, spec):
        transform_about_center(glyph, psMat.scale(sx, sy))
        apply_set_width(ctx, glyph, spec, source_half)


@op("scaleOrigin")
def op_scale_origin(ctx, font, spec, source_half):
    sx, sy = as_scale(spec["by"])
    for glyph in selected_glyphs(font, spec):
        glyph.transform(psMat.scale(sx, sy))
        apply_set_width(ctx, glyph, spec, source_half)


@op("rotate")
def op_rotate(ctx, font, spec, source_half):
    for glyph in selected_glyphs(font, spec):
        transform_about_center(glyph, psMat.rotate(math.radians(spec["deg"])))
        apply_set_width(ctx, glyph, spec, source_half)


@op("translate")
def op_translate(ctx, font, spec, source_half):
    dx, dy = spec.get("dx", 0), spec.get("dy", 0)
    for glyph in selected_glyphs(font, spec):
        width = glyph.width
        glyph.transform(psMat.translate(dx, dy))
        glyph.width = width
        apply_set_width(ctx, glyph, spec, source_half)


@op("setWidth")
def op_set_width(ctx, font, spec, source_half):
    for glyph in selected_glyphs(font, spec):
        glyph.width = ctx.width_value(spec["to"], source_half)
        if spec.get("center"):
            center_in_width(glyph)


@op("clear")
def op_clear(ctx, font, spec, source_half):
    for glyph in selected_glyphs(font, spec):
        glyph.clear()


@op("mergeSfd")
def op_merge_sfd(ctx, font, spec, source_half):
    if spec.get("skipWhen") == "italic" and ctx.style.get("italic"):
        return
    path = ctx.path(spec["from"])
    if not os.path.exists(path):
        return
    for code in [cp(c) for c in spec.get("clearFirst", [])]:
        if code in font:
            font[code].clear()
    font.mergeFonts(path)


@op("round")
def op_round(ctx, font, spec, source_half):
    for glyph in font.glyphs():
        if worth(glyph):
            glyph.round()


@op("removeLookups")
def op_remove_lookups(ctx, font, spec, source_half):
    tags = tuple(spec["tags"])
    for lookup in font.gpos_lookups:
        if any(tag in lookup for tag in tags):
            font.removeLookup(lookup)


@op("fitLineBox")
def op_fit_line_box(ctx, font, spec, source_half):
    """글리프를 목표 행 박스(ascent + descent)에 맞춘다.

    Powerline 구분자용이다. 구분자는 행 박스 전체를 덮어야 세로로 이어 붙였을 때
    틈이 생기지 않는다. 소스가 다른 행 박스 기준으로 그려져 있고 fit 단계에서
    한 번 축소됐으므로 (undoScale) 그만큼 되돌려서 맞춘다.
    """
    vertical = ctx.recipe["target"]["vertical"]
    undo = spec.get("undoScale", 100) / 100
    src_em = spec["srcAscent"] + spec["srcDescent"]
    line_em = vertical["ascent"] + vertical["descent"]
    scale_y = line_em / (src_em * undo)
    move_y = spec["srcDescent"] * undo * scale_y - vertical["descent"]
    for glyph in selected_glyphs(font, spec):
        width = glyph.width
        glyph.transform(psMat.scale(1, scale_y))
        glyph.transform(psMat.translate(0, move_y))
        glyph.width = width


def run_ops(ctx, font, ops, source_half=None):
    for spec in ops or []:
        handler = OPS.get(spec["op"])
        if handler is None:
            raise ValueError("알 수 없는 op: %r" % spec["op"])
        handler(ctx, font, spec, source_half)


# --------------------------------------------------------------------------
# fit 전략
# --------------------------------------------------------------------------


def fit_half_scale(ctx, font, spec, shared):
    """전체를 일정 비율로 줄이고 반각 폭에 맞춘다. 라틴 고정폭과 심볼용."""
    sx, sy = as_scale(spec["scale"])
    font.selection.all()
    for glyph in font.selection.byGlyphs:
        glyph.transform(psMat.scale(sx, sy))
    font.selection.none()

    run_ops(ctx, font, spec.get("opsBeforeWidth"))

    # 소스의 반각 폭. 안 적어 두면 스페이스에서 읽는다 (set_em 뒤 기준).
    source_width = spec.get("sourceWidth")
    if source_width is None and 0x20 in font:
        source_width = font[0x20].width / sx
    move_x = (ctx.half_width - source_width * sx) / 2 if source_width else 0
    for glyph in font.glyphs():
        # 폭 0 인 글리프(결합 문자 등)는 건드리지 않는다
        if not worth(glyph) or glyph.width == 0:
            continue
        if move_x:
            glyph.transform(psMat.translate(move_x, 0))
        glyph.width = ctx.half_width


def fit_cjk_uniform(ctx, font, spec, shared):
    """소스의 전각 폭이 한 가지로 통일된 경우.

    set_em 이 이미 목표 em 으로 맞춰 놨으므로, 지금 폭을 읽어서
    전각이면 목표 전각, 아니면 목표 반각으로 맞춘다.
    """
    threshold = spec.get("fullWidthThreshold", 1.5)
    for glyph in font.glyphs():
        if not worth(glyph) or glyph.width <= 0:
            continue
        target = ctx.full_width if glyph.width > ctx.half_width * threshold else ctx.half_width
        if spec.get("scaleToFit") and glyph.width != target:
            transform_about_center(glyph, psMat.scale(target / glyph.width, 1))
        glyph.width = target
        center_in_width(glyph)


def fit_cjk_classify(ctx, font, spec, shared):
    """폭이 제각각인 CJK 소스를 전각/반각 고정폭으로 맞춘다."""
    half_set, full_set, others_set = shared["widths"]
    source_full = spec["sourceFullWidth"]

    move_x = (ctx.full_width - source_full) / 2
    for code in sorted(full_set):
        if code not in font:
            continue
        glyph = font[code]
        glyph.transform(psMat.translate(move_x, 0))
        glyph.width = ctx.full_width

    # 너무 넓은 글리프는 가로로 눌러 준다.
    # .pe 가 정수 나눗셈이었으므로 배율 계산을 그대로 맞춘다.
    for code in sorted(others_set):
        if code not in font:
            continue
        glyph = font[code]
        if glyph.width > source_full:
            transform_about_center(
                glyph, psMat.scale((source_full * 100 // glyph.width) / 100, 1)
            )

    force_full = {cp(c) for c in spec.get("forceFull", [])}
    full_exclude = {cp(c) for c in spec.get("fullExclude", [])}
    for glyph in font.glyphs():
        code = glyph.unicode
        if code is None or code < 0 or not worth(glyph):
            continue
        selected = code not in half_set and code not in full_set
        if code in force_full:
            selected = True
        if code in full_exclude:
            selected = False
        if selected:
            glyph.width = ctx.full_width
            center_in_width(glyph)

    half_exclude = set(force_full)
    he = spec.get("halfExclude", {})
    for pair in he.get("ranges", []):
        half_exclude.update(cp_range(pair))
    half_exclude.update(cp(c) for c in he.get("single", []))
    half_exclude.update(cp(c) for c in spec.get("halfExcludeMore", []))

    for code in sorted(half_set - half_exclude):
        if code not in font:
            continue
        glyph = font[code]
        glyph.width = ctx.half_width
        center_in_width(glyph)


FITS = {
    "halfScale": fit_half_scale,
    "cjkClassify": fit_cjk_classify,
    "cjkUniform": fit_cjk_uniform,
}


def classify_widths(ctx, source, style, base_cps):
    """CJK 소스의 글리프를 폭에 따라 세 갈래로 나눈다.

    한 두께로 한 번만 분류하고 모든 두께에 같은 결과를 쓴다.
    """
    fit = source["fit"]
    path = ctx.path(source["path"], style)
    print("Width classify (%s)" % os.path.basename(path))
    font = fontforge.open(path)
    source_full = fit["sourceFullWidth"]
    half, full, others = set(), set(), set()
    for glyph in font.glyphs():
        code = glyph.unicode
        if code is None or code < 0 or not worth(glyph) or glyph.width <= 0:
            continue
        if code in base_cps:
            continue
        if glyph.width < ctx.half_width:
            half.add(code)
        elif glyph.width == source_full:
            full.add(code)
        else:
            others.add(code)
    font.close()
    print("  half=%d full=%d others=%d" % (len(half), len(full), len(others)))
    return half, full, others


# --------------------------------------------------------------------------
# 소스 하나 만들기
# --------------------------------------------------------------------------


def build_source(ctx, source, shared, base_cps=None):
    path = ctx.path(source["path"])
    print("Open " + path)
    font = fontforge.open(path)

    if source.get("keepRanges"):
        keep = set()
        for pair in source["keepRanges"]:
            keep.update(cp_range(pair))
        for glyph in font.glyphs():
            if glyph.unicode is None or glyph.unicode not in keep:
                glyph.clear()

    hs = source.get("hiddenSpace")
    if hs and ctx.variants.get("hiddenSpace"):
        code = cp(hs["cp"])
        if code in font:
            font[code].clear()
        font.mergeFonts(ctx.path(hs["from"]))

    # 참조를 풀기 전에 돌려야 하는 op. 합성 글리프(ŕ 등)가 교체한 글리프를
    # 참조로 물고 있으므로, 교체는 여기서 해야 반영된다.
    run_ops(ctx, font, source.get("preOps"))

    unlink_all(font)
    set_em(font, ctx)

    if source.get("italicize") and ctx.style.get("italic"):
        font.selection.all()
        font.italicize(italic_angle=ctx.italic_angle)
        font.selection.none()

    # 우선순위가 높은 소스가 이미 가진 코드포인트는 지운다
    if base_cps:
        for glyph in font.glyphs():
            if glyph.unicode is not None and glyph.unicode in base_cps:
                glyph.clear()

    source_half = font[0x20].width if 0x20 in font else None
    run_ops(ctx, font, source.get("ops"), source_half)

    fit = source.get("fit")
    if fit:
        FITS[fit["mode"]](ctx, font, fit, shared)

    run_ops(ctx, font, source.get("opsAfter"), source_half)
    font.selection.none()
    return font


# --------------------------------------------------------------------------
# 이름 짓기
# --------------------------------------------------------------------------


def font_names(recipe, style, suffix):
    """RIBBI 네 칸에 들어가는 두께와 그렇지 않은 두께를 나눠 이름을 만든다."""
    family = recipe["output"]["familyName"]
    if suffix:
        family = "%s %s" % (family, suffix)
    short = family.replace(" ", "")
    name = style["name"]

    if style["italic"]:
        display = "Italic" if name == "Regular" else "%s Italic" % name
    else:
        display = name

    if name in ("Regular", "Bold"):
        familyname, subfamily = family, display
    else:
        familyname = "%s %s" % (family, name)
        subfamily = "Italic" if style["italic"] else "Regular"

    return {
        "short": short,
        "fontname": "%s-%s" % (short, style["file"]),
        "familyname": familyname,
        "fullname": "%s %s" % (family, display),
        "subfamily": subfamily,
        "typo_family": family,
        "typo_subfamily": display,
    }


def compose(ctx, base_font, suffix, out_dir):
    recipe, style = ctx.recipe, ctx.style
    target = recipe["target"]
    names = font_names(recipe, style, suffix)

    font = fontforge.font()
    font.encoding = "UnicodeFull"
    set_em(font, ctx)
    if style["italic"]:
        font.italicangle = ctx.italic_angle

    font.fontname = names["fontname"]
    font.familyname = names["familyname"]
    font.fullname = names["fullname"]
    font.copyright = recipe["output"]["copyright"]
    font.version = recipe["output"]["version"]
    font.weight = style["name"]
    font.appendSFNTName("English (US)", "SubFamily", names["subfamily"])
    font.appendSFNTName("English (US)", "Preferred Family", names["typo_family"])
    font.appendSFNTName("English (US)", "Preferred Styles", names["typo_subfamily"])

    font.os2_weight = style["weight"]
    font.os2_width = target["widthClass"]
    font.os2_fstype = 0
    font.os2_vendor = recipe["output"]["vendorId"]
    font.os2_family_class = recipe["output"].get("ibmFamily", 0)

    p = target["panose"]
    font.os2_panose = (
        p["familyType"], p["serifStyle"], style["panoseWeight"], p["proportion"],
        p["contrast"], p["strokeVariation"], p["armStyle"], p["letterForm"],
        p["midline"], p["xHeight"],
    )

    tmp = os.path.join(out_dir, ".merge-base-%s.sfd" % style["file"])
    base_font.save(tmp)
    font.mergeFonts(tmp)
    os.remove(tmp)

    # 윤곽만 비운다. cmap 에서 빼는 것은 fonttools_script.py 가 한다.
    for code in [cp(c) for c in recipe["finalize"].get("removeCodepoints", [])]:
        if code in font:
            font[code].clear()

    out = os.path.join(out_dir, "%s-%s.ttf" % (names["short"], style["file"]))
    print("Save " + os.path.basename(out))
    font.generate(out)
    font.close()
    return out


# --------------------------------------------------------------------------


def main():
    parser = argparse.ArgumentParser(description="레시피대로 글꼴을 합성한다")
    parser.add_argument("--recipe", required=True)
    parser.add_argument("--nerd", action="store_true")
    parser.add_argument("--hidden-space", action="store_true")
    parser.add_argument("--debug", action="store_true")
    parser.add_argument("--out", default=BASE_DIR)
    args = parser.parse_args()

    with open(args.recipe, encoding="utf-8") as fp:
        recipe = json.load(fp)

    variants = {"nerd": args.nerd, "hiddenSpace": args.hidden_space}
    suffixes = recipe["output"].get("variantSuffix", {})
    suffix = suffixes.get("hiddenSpace", "") if args.hidden_space else (
        suffixes.get("nerd", "") if args.nerd else ""
    )

    styles = recipe["styles"]
    if args.debug:
        styles = [styles[recipe.get("debugStyleIndex", 0)]]

    sources = [s for s in recipe["sources"] if not s.get("when") or variants.get(s["when"])]
    base_source = next(s for s in sources if s.get("role") == "base")

    out_dir = args.out
    parts_dir = os.path.join(out_dir, "parts")
    os.makedirs(parts_dir, exist_ok=True)

    # 기준 소스가 가진 코드포인트를 미리 구한다. 뒤 소스에서 겹치는 것을 지우는 데 쓴다.
    print("=== 기준 소스 훑기 ===")
    ref_ctx = Context(recipe, styles[0], BASE_DIR, variants)
    probe = build_source(ref_ctx, base_source, {})
    base_cps = codepoints_of(probe)
    probe.close()
    shared = {}

    # 폭 분류는 한 번만. .pe 는 디버그일 때 두께 목록을 먼저 좁힌 다음 그 첫 번째로
    # 분류했다. 전체 빌드면 첫 두께, 디버그면 디버그 두께가 기준이 된다.
    for source in sources:
        if source.get("fit", {}).get("mode") == "cjkClassify":
            shared["widths"] = classify_widths(ref_ctx, source, styles[0], base_cps)

    # 심볼 소스는 두께와 무관하므로 한 번만 만든다
    symbol_parts = {}
    for source in sources:
        if source.get("role") == "symbols":
            font = build_source(ref_ctx, source, shared, base_cps)
            part = os.path.join(parts_dir, "%s.ttf" % source["id"])
            print("Save " + os.path.basename(part))
            font.generate(part)
            font.close()
            symbol_parts[source["id"]] = part

    for style in styles:
        print("=== %s ===" % style["file"])
        ctx = Context(recipe, style, BASE_DIR, variants)

        base_font = build_source(ctx, base_source, shared)
        compose(ctx, base_font, suffix, out_dir)
        base_font.close()

        for source in sources:
            if source is base_source or source.get("role") == "symbols":
                continue
            font = build_source(ctx, source, shared, base_cps)
            part = os.path.join(parts_dir, "%s-%s.ttf" % (source["id"], style["file"]))
            print("Save " + os.path.basename(part))
            font.generate(part)
            font.close()

    print("fontforge_script: done")


if __name__ == "__main__":
    main()
