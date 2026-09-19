"""vim + vim-airline 화면을 그대로 그림으로 만든다.

    python3 scripts/terminal.py kr  "build/Monoplex KR Nerd Font"  MonoplexKRNerdFont  images/example-nerd.png

Powerline 구분자를 손으로 흉내 내지 않는다. 진짜 vim 을 터미널 버퍼 안에
띄우고 term_scrape() 로 화면을 칸 단위(글자·전경·배경·속성)로 받아 와서,
그 칸들을 이 글꼴로 다시 그린다. 그래서 airline 이 실제로 무엇을 어떤
색으로 찍었는지가 그림에 그대로 남는다.

바깥 vim 에 pty 가 필요해서 script(1) 을 거친다. ~/.vimrc 와 거기 설정된
airline 테마를 그대로 쓰므로, 이 그림은 사용자의 vim 설정을 보여 준다.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile

from PIL import ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from render import Mono, window

HERE = os.path.dirname(os.path.abspath(__file__))
SIZE, COLS, ROWS = 26, 92, 27
PADX, TOP, BOT = 26, 100, 20

DEMO = {
    "kr": ("monoplex.py", '''# -*- coding: utf-8 -*-
"""모노플렉스 KR — 라틴과 한글의 너비가 2:1 인 고정폭 글꼴."""

EM = 1056                      # 전각 한 칸
WIDTHS = {"라틴": EM // 2, "한글": EM}


def cells(text: str) -> int:
    """문자열이 차지하는 반각 칸 수를 센다."""
    return sum(2 if is_wide(ch) else 1 for ch in text)


def align(rows, gap=2):
    """이름을 오른쪽으로 밀어 값의 열을 맞춘다."""
    width = max(cells(name) for name, _ in rows)
    for name, value in rows:
        print(f"{name}{' ' * (width - cells(name) + gap)}{value}")


align([("글꼴 이름", "Monoplex KR"),
       ("만든 이", "y-kim"),
       ("라이선스", "SIL Open Font License 1.1")])
'''),
    "cjk": ("monoplex.py", '''# -*- coding: utf-8 -*-
"""모노플렉스 CJK — 한글·漢字·かな 를 한 칸에 담는 고정폭 글꼴."""

EM = 1056                      # 전각 한 칸
SCRIPTS = {"라틴": EM // 2, "한글": EM, "漢字": EM, "かな": EM}


def cells(text: str) -> int:
    """문자열이 차지하는 반각 칸 수를 센다."""
    return sum(2 if is_wide(ch) else 1 for ch in text)


def align(rows, gap=2):
    """이름을 오른쪽으로 밀어 값의 열을 맞춘다."""
    width = max(cells(name) for name, _ in rows)
    for name, value in rows:
        print(f"{name}{' ' * (width - cells(name) + gap)}{value}")


align([("한글", "가나다라마바사아자차카타파하"),
       ("漢字", "大韓民國萬歲東西南北春夏秋冬"),
       ("かな", "あいうえおかきくけこさしすせ")])
'''),
}


def capture(path, rows=ROWS, cols=COLS, keys=()):
    """vim 을 띄워 화면을 칸 단위로 긁어 온다.

    파일이 있는 디렉터리에서 돌린다. airline 이 경로를 현재 디렉터리
    기준으로 보이므로, 그래야 임시 디렉터리 이름이 화면에 안 남는다.
    """
    work, path = os.path.split(path)
    out = tempfile.NamedTemporaryFile(suffix=".json", delete=False).name
    inner = "\n".join(["vim", "-u", os.path.expanduser("~/.vimrc"),
                       "-c", "colorscheme habamax", path])
    env = dict(os.environ, TERM="xterm-256color", COLORTERM="truecolor",
               MPX_ROWS=str(rows), MPX_COLS=str(cols), MPX_CMD=inner,
               MPX_KEYS="\n".join(keys), MPX_WAIT="2500", MPX_OUT=out)
    cmd = "vim -N -u NONE --cmd 'set t_TI= t_TE=' -S %s" % os.path.join(HERE, "screen.vim")
    subprocess.run(["script", "-qefc", cmd, "/dev/null"], env=env, cwd=work,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    with open(out) as fp:
        screen = json.load(fp)
    os.unlink(out)
    return screen


def paint(screen, mono, out):
    face = mono.face()
    ascent, descent = face.getmetrics()
    lh = ascent + descent
    rows, cell = len(screen), mono.cell

    # 본문 한가운데 칸의 배경을 창 색으로 쓴다.
    body = screen[len(screen) // 3][cell_index(screen, 0)]["bg"]
    W = round(COLS * cell) + 2 * PADX + 128
    H = 58 + TOP + rows * lh + BOT + 60
    img, d = window((W, H), hex_rgb(body))

    for r, line in enumerate(screen):
        x, y = 64 + PADX, 58 + TOP + r * lh
        for c in line:
            fg, bg = hex_rgb(c["fg"]), hex_rgb(c["bg"])
            if c["r"]:
                fg, bg = bg, fg
            w = c["w"] * cell
            d.rectangle([x, y, x + w, y + lh], fill=bg)
            ch = c["c"]
            if ch.strip():
                style = ("Bold" if c["b"] else "") + ("Italic" if c["i"] else "")
                d.text((x, y + ascent), ch, font=mono.face(style or "Regular"),
                       fill=fg, anchor="ls")
            if c["u"]:
                d.line([x, y + ascent + 2, x + w, y + ascent + 2], fill=fg)
            x += w
    img.save(out)
    print(f"{out}  {img.size[0]}x{img.size[1]}  {rows}행 {COLS}열")


def cell_index(screen, i):
    return i


def hex_rgb(s):
    return tuple(int(s[i:i + 2], 16) for i in (1, 3, 5))


def main(argv):
    scene, directory, prefix, out = argv[1:5]
    name, text = DEMO[scene]
    tmp = os.path.join(tempfile.mkdtemp(), name)
    with open(tmp, "w") as fp:
        fp.write(text)

    screen = capture(tmp)
    mono = Mono(directory, prefix, SIZE)
    gone = sorted({c for line in screen for cell in line
                   for c in mono.missing(cell["c"])})
    if gone:
        # 화면은 사용자의 vim 이 만든 것이라 글꼴이 통제하지 못한다.
        # 죽이지 않고 .notdef 로 그리되, 무엇이 없었는지는 알린다.
        print("경고: 글꼴에 없는 글자 " +
              " ".join("U+%04X %s" % (ord(c), c) for c in gone), file=sys.stderr)
    paint(screen, mono, out)


if __name__ == "__main__":
    main(sys.argv)
