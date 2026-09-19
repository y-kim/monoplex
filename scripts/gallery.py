"""README 갤러리의 코드 스크린샷을 만든다.

    python3 scripts/gallery.py kr   "build/Monoplex KR"     MonoplexKR  images/example-kr.png
    python3 scripts/gallery.py cjk  "build/Monoplex CJK"    MonoplexCJK images/example-cjk.png

원래 Carbon 으로 만들었던 그림을 대신한다. 색은 VS Code Dark+ 이고, 창
크기는 내용에 맞춰 늘어난다. 글꼴을 새로 빌드하면 다시 돌려서 그림을
갱신한다.
"""

from __future__ import annotations

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from render import Mono, draw_runs, window

# VS Code Dark+
FG, CMT, IDENT = (212, 212, 212), (106, 153, 85), (156, 220, 254)
STR, NUM, KEY, TYPE = (206, 145, 120), (181, 206, 168), (197, 134, 192), (86, 156, 214)
BODY = (30, 30, 30)

C = lambda t: (t, CMT, "Italic")        # 주석
I = lambda t: (t, IDENT, "Regular")     # 식별자
T = lambda t: (t, FG, "Regular")        # 그 밖
Q = lambda t: (t, STR, "Regular")       # 문자열
N = lambda t: (t, NUM, "Regular")       # 숫자
K = lambda t: (t, KEY, "Regular")       # 제어 키워드
Y = lambda t: (t, TYPE, "Regular")      # 자료형

PRELUDE = [
    [C("#include <iostream>")],
    [],
    [Y("int"), T(" "), I("main"), T("("), Y("int"), T(" "), I("argc"), T(", "),
     Y("char"), T(" *"), I("argv"), T("[])")],
    [T("{")],
]
CODA = [
    [],
    [T("    "), C("// 사실은 반갑지 않아 에러가...")],
    [T("    "), K("return"), T(" "), N("123"), T(" + "), N("45"), T(" * "),
     N("678"), T(" - "), N("90"), T(";")],
    [T("}")],
]


def cout(head, string, comment=None):
    """std::cout 또는 이어지는 << 줄 하나."""
    runs = [T("    "), I("std"), T("::"), I("cout"), T(" << ")] if head \
        else [T("              << ")]
    runs.append(Q('"%s"' % string))
    if comment:
        runs += [T(" "), C("// " + comment)]
    return runs


def endl():
    return [T("              << "), I("std"), T("::"), I("endl"), T(";")]


def hello(text):
    return [T("    "), I("std"), T("::"), I("cout"), T(" << "), Q('"%s"' % text),
            T(" << "), I("std"), T("::"), I("endl"), T(";")]


SCENES = {
    # 라틴과 한글만. 두 너비가 2:1 로 맞는지 보여 준다.
    "kr": PRELUDE + [
        [T("    "), C("// Korean can say hello in Korean!")],
        hello("Hello, World!"),
        hello("반갑다 세상아"),
        [],
        [T("    "), C("// 네가 글쓰는 방법을 알려주지 않을래?")],
        cout(True,  "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "ABCDEFGHIJKLMNOPQRSTUVWXYZ"),
        cout(False, "abcdefghijlkmnopqrstuvwxyz", "abcdefghijklmnopqrstuvwzyz"),
        endl(),
        cout(True,  "가나다라마바사아자차카타파하", "가나다라마바사아자차카타파하"),
        cout(False, "아야어여오요우유으이", "아야어여오요우유으이"),
        cout(False, "감밝그붉얌이훗캬큵뿔딱", "감밝그붉얌이훗캬큵뿔딱"),
        endl(),
    ] + CODA,

    # 한글·한자·가나를 나란히 놓는다. 문자열 네 줄의 오른쪽 끝이 한 열에
    # 떨어지는 것이 이 그림이 말하려는 전부다.
    "cjk": PRELUDE + [
        [T("    "), C("// 한글과 漢字와 かな가 한 칸 안에서 만난다")],
        hello("Hello, World!"),
        hello("반갑다 世上아"),
        [],
        [T("    "), C("// 네 문자를 같은 너비로 늘어놓아도 열이 맞는다")],
        cout(True,  "가나다라마바사아자차카타파하", "한글"),
        cout(False, "大韓民國萬歲東西南北春夏秋冬", "漢字"),
        cout(False, "あいうえおかきくけこさしすせ", "ひらがな"),
        cout(False, "アイウエオカキクケコサシスセ", "カタカナ"),
        endl(),
        cout(True,  "一二三四五六七八九十百千萬億", "획이 적은 글자"),
        cout(False, "鬱靈鑑聽讀變觀權歡藝議驗鐵豐", "획이 많은 글자"),
        endl(),
    ] + CODA,
}

SIZE, LINE_HEIGHT, PAD = 32, 43, 32


def main(argv):
    scene, directory, prefix, out = argv[1:5]
    lines = SCENES[scene]
    mono = Mono(directory, prefix, SIZE)

    gone = sorted({c for ln in lines for t, _, _ in ln for c in mono.missing(t)})
    if gone:
        raise SystemExit("ERROR: 글꼴에 없는 글자: " + " ".join(gone))

    content = max(mono.width("".join(t for t, _, _ in ln)) for ln in lines)
    W = math.ceil(content) + 2 * PAD + 128
    H = 58 + 139 + (len(lines) - 1) * LINE_HEIGHT + 50 + 60

    img, d = window((W, H), BODY)
    y = 58 + 139
    for runs in lines:
        draw_runs(d, 64 + PAD, y, runs, mono)
        y += LINE_HEIGHT
    img.save(out)
    print(f"{out}  {img.size[0]}x{img.size[1]}  {len(lines)}줄")


if __name__ == "__main__":
    main(sys.argv)
