#!/usr/bin/env python3
"""합성 글꼴 빌드 도구.

    ./build.py                                  기본 레시피로 전체 빌드
    ./build.py --recipe recipes/foo.json        레시피 지정
    ./build.py --debug                          한 두께만 (빠른 확인)
    ./build.py --variant nerd                   특정 변종만
    ./build.py --list                           레시피 목록

Docker 로 돌릴 때는 환경변수도 받는다.

    docker run --rm -v "$(pwd):/work" ghcr.io/yuru7/composite-font-builder
    docker run --rm -e DEBUG=1 -e RECIPE=recipes/foo.json -v "$(pwd):/work" ...

실제 합성은 fontforge_script.py 가, 마무리는 fonttools_script.py 가 한다.
이 파일은 둘을 순서대로 부르고 결과를 검증한다.
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import shutil
import subprocess
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
RECIPE_DIR = os.path.join(BASE_DIR, "recipes")
DEFAULT_RECIPE = os.path.join(RECIPE_DIR, "monoplex-kr.json")


def load(path):
    with open(path, encoding="utf-8") as fp:
        return json.load(fp)


def list_recipes():
    rows = []
    for path in sorted(glob.glob(os.path.join(RECIPE_DIR, "*.json"))):
        try:
            recipe = load(path)
        except Exception as exc:  # noqa: BLE001
            rows.append((os.path.relpath(path, BASE_DIR), "읽기 실패: %s" % exc))
            continue
        ids = " + ".join(s["id"] for s in recipe.get("sources", []))
        rows.append((os.path.relpath(path, BASE_DIR),
                     "%s  (%s)" % (recipe.get("name", "?"), ids)))
    width = max((len(r[0]) for r in rows), default=0)
    for path, desc in rows:
        print("  %-*s  %s" % (width, path, desc))
    return 0


def variants_of(recipe):
    """만들 변종 목록. (옵션 리스트, 출력 디렉터리, 파일 접두어)"""
    suffixes = recipe["output"].get("variantSuffix", {})
    family = recipe["output"]["familyName"].replace(" ", "")
    out = []
    # 심볼 소스처럼 when 이 붙은 소스가 있으면 그 변종도 만든다
    optional = [s["when"] for s in recipe["sources"] if s.get("when")]
    for name in optional:
        suffix = suffixes.get(name, name.capitalize())
        out.append((name, ["--%s" % name], family + suffix))
    out.append(("standard", [], family))
    return out


def run(cmd):
    print("$ " + " ".join(cmd))
    subprocess.run(cmd, check=True)


def build_variant(recipe_path, opts, debug):
    common = ["--recipe", recipe_path, "--out", BASE_DIR] + opts
    if debug:
        common.append("--debug")
    run(["fontforge", "-script", os.path.join(BASE_DIR, "fontforge_script.py")] + common)
    run([sys.executable, os.path.join(BASE_DIR, "fonttools_script.py"),
         "--recipe", recipe_path, "--dir", BASE_DIR] + opts + (["--debug"] if debug else []))


def move_output(prefix, build_dir):
    dest = os.path.join(build_dir, prefix)
    os.makedirs(dest, exist_ok=True)
    moved = 0
    for path in glob.glob(os.path.join(BASE_DIR, prefix + "-*.ttf")):
        shutil.move(path, os.path.join(dest, os.path.basename(path)))
        moved += 1
    return dest, moved


def check(recipe, build_dir, prefixes, debug):
    styles = recipe["styles"]
    if debug:
        styles = [styles[recipe.get("debugStyleIndex", 0)]]

    expected, missing = [], []
    for prefix in prefixes:
        for style in styles:
            path = os.path.join(build_dir, prefix, "%s-%s.ttf" % (prefix, style["file"]))
            expected.append(path)
            if not os.path.isfile(path):
                missing.append(path)

    for path in missing:
        print("MISSING: " + path, file=sys.stderr)
    print("expected=%d  missing=%d" % (len(expected), len(missing)))
    if missing:
        return 1

    try:
        from fontTools.ttLib import TTFont
    except ImportError:
        print("SKIP: fontTools 가 없어 읽기 확인을 건너뜁니다", file=sys.stderr)
        return 0

    bad = 0
    for path in expected:
        try:
            font = TTFont(path, recalcBBoxes=False, recalcTimestamp=False)
            for tag in ("head", "name", "cmap"):
                _ = font[tag]
            _ = font["glyf"] if "glyf" in font else font["CFF "]
            font.close()
        except Exception as exc:  # noqa: BLE001
            print("INVALID: %s: %s" % (path, exc), file=sys.stderr)
            bad += 1
    print("readable=%d/%d" % (len(expected) - bad, len(expected)))
    return 1 if bad else 0


def main():
    parser = argparse.ArgumentParser(description="합성 글꼴 빌드")
    parser.add_argument("--recipe", default=os.environ.get("RECIPE", DEFAULT_RECIPE))
    parser.add_argument("--debug", action="store_true",
                        default=os.environ.get("DEBUG") == "1")
    parser.add_argument("--variant", action="append",
                        help="만들 변종 (여러 번 지정 가능). 기본은 전부")
    parser.add_argument("--list", action="store_true", help="레시피 목록만 보여준다")
    args = parser.parse_args()

    if args.list:
        return list_recipes()

    recipe_path = args.recipe
    if not os.path.isabs(recipe_path):
        recipe_path = os.path.join(BASE_DIR, recipe_path)
    if not os.path.isfile(recipe_path):
        print("ERROR: 레시피가 없습니다: %s" % recipe_path, file=sys.stderr)
        return 2

    recipe = load(recipe_path)
    build_dir = os.path.join(BASE_DIR, recipe.get("build", {}).get("outputDir", "build"))

    wanted = variants_of(recipe)
    if args.debug:
        # 디버그는 기본 변종 하나만. 빠르게 보려고 쓰는 것이므로.
        wanted = [v for v in wanted if v[0] == "standard"]
    if args.variant:
        wanted = [v for v in wanted if v[0] in args.variant]
        if not wanted:
            print("ERROR: 그런 변종이 없습니다: %s" % args.variant, file=sys.stderr)
            return 2

    print("recipe : %s (%s)" % (os.path.relpath(recipe_path, BASE_DIR), recipe.get("name")))
    print("variant: %s" % ", ".join(v[0] for v in wanted))

    prefixes = []
    for name, opts, prefix in wanted:
        print("### Build: %s ###" % name)
        build_variant(recipe_path, opts, args.debug)
        dest, moved = move_output(prefix, build_dir)
        print("-> %s (%d 개)" % (os.path.relpath(dest, BASE_DIR), moved))
        prefixes.append(prefix)

    print("### Checking generated fonts ###")
    rc = check(recipe, build_dir, prefixes, args.debug)
    print("### Build OK ###" if rc == 0 else "### Build FAILED ###")
    return rc


if __name__ == "__main__":
    raise SystemExit(main())
