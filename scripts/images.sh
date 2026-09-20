#!/bin/sh
# README 의 그림을 전부 다시 만든다. build/ 에 네 가족이 다 있어야 한다.
#
#   sh scripts/images.sh
#
# vim 화면은 ~/.vimrc 와 거기 설정된 airline 테마를 그대로 쓴다.
set -e
cd "$(dirname "$0")/.."

python3 scripts/header.py   kr  "build/Monoplex KR"            MonoplexKR          images/monoplex-kr.png
python3 scripts/header.py   cjk "build/Monoplex CJK"           MonoplexCJK         images/monoplex-cjk.png
python3 scripts/gallery.py  kr  "build/Monoplex KR"            MonoplexKR          images/example-kr.png
python3 scripts/gallery.py  cjk "build/Monoplex CJK"           MonoplexCJK         images/example-cjk.png
python3 scripts/gallery.py  mix "build/Monoplex CJK"           MonoplexCJK         images/example-mix.png
python3 scripts/terminal.py kr  "build/Monoplex KR Nerd Font"  MonoplexKRNerdFont  images/vim-kr.png
python3 scripts/terminal.py cjk "build/Monoplex CJK Nerd Font" MonoplexCJKNerdFont images/vim-cjk.png
