#!/usr/bin/env python3
"""빌드된 TTF에 대한 마무리 처리.

현재 하는 일:

- ``BASE`` 테이블 제거.
  VSCode 터미널의 맨 아래 줄에서 ``g``, ``j`` 같은 글자의 디센더가 잘리는 문제에
  대한 대응이다. (PlemolJP ``bbda041`` 의 ``font.horizontalBaseline = None`` 과 같은 처리)
  FontForge 가 BASE 를 만들지 않은 경우에는 아무 일도 하지 않는다.
"""

from __future__ import annotations

import sys
from pathlib import Path

from fontTools.ttLib import TTFont

REMOVE_TABLES = ("BASE",)


def process(path: Path) -> str:
    font = TTFont(path, recalcBBoxes=False, recalcTimestamp=False)
    removed = [tag for tag in REMOVE_TABLES if tag in font]
    if not removed:
        font.close()
        return "unchanged"
    for tag in removed:
        del font[tag]
    font.save(path)
    font.close()
    return "removed " + ", ".join(removed)


def main() -> int:
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <font.ttf>...", file=sys.stderr)
        return 2

    changed = 0
    errors: list[str] = []
    for arg in sys.argv[1:]:
        path = Path(arg)
        if not path.is_file():
            errors.append(f"{path}: file not found")
            continue
        try:
            result = process(path)
        except Exception as exc:  # noqa: BLE001 - 한꺼번에 보고하고 싶다
            errors.append(f"{path}: {exc}")
            continue
        if result != "unchanged":
            changed += 1

    for message in errors:
        print(f"ERROR: {message}", file=sys.stderr)
    print(f"post_process: {changed} / {len(sys.argv) - 1} 개 파일 수정됨")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
