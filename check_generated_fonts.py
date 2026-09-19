#!/usr/bin/env python3
"""생성된 TTF를 fontTools로 읽을 수 있는지 확인한다."""

from __future__ import annotations

import sys
from pathlib import Path

from fontTools.ttLib import TTFont


def check_font(path: Path) -> str | None:
    """읽지 못하면 오류 메시지를, 문제가 없으면 None을 돌려준다."""
    try:
        font = TTFont(path, recalcBBoxes=False, recalcTimestamp=False)
        # 주요 테이블을 건드려서 깨진 오프셋 등을 잡아낸다
        _ = font["head"]
        _ = font["name"]
        _ = font["cmap"]
        _ = font["glyf"] if "glyf" in font else font["CFF "]
        font.close()
    except Exception as exc:  # noqa: BLE001 - 깨진 파일을 한꺼번에 보고하고 싶다
        return f"{path}: {exc}"
    return None


def main() -> int:
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <font.ttf>...", file=sys.stderr)
        return 2

    errors: list[str] = []
    for arg in sys.argv[1:]:
        path = Path(arg)
        if not path.is_file():
            errors.append(f"{path}: file not found")
            continue
        message = check_font(path)
        if message is not None:
            errors.append(message)

    if errors:
        for message in errors:
            print(f"INVALID: {message}", file=sys.stderr)
        print(
            f"ERROR: {len(errors)} / {len(sys.argv) - 1} 개 파일을 읽지 못했습니다",
            file=sys.stderr,
        )
        return 1

    print(f"readable={len(sys.argv) - 1}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
