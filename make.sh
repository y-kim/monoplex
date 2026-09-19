#!/usr/bin/env bash
# Monoplex KR 빌드.
#
#   ./make.sh           전체 (Nerd 판 + 통상판, 16 두께)
#   ./make.sh -d        디버그 (통상판 Regular 한 두께만)
#   DEBUG=1 ./make.sh   같음. Docker 에서 쓰라고 환경변수도 받는다.
#
# 설정은 build.json 에 있다. 글리프 합성은 fontforge_script.py,
# 힌팅과 마무리는 fonttools_script.py 가 한다.

set -euo pipefail

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
BUILD_DIR="${BASE_DIR}/build"

DEBUG_FLG='false'
if [ "${DEBUG:-0}" = '1' ]; then
  DEBUG_FLG='true'
fi
while getopts d OPT; do
  case $OPT in
    'd' ) DEBUG_FLG='true';;
    *   ) echo "Usage: $0 [-d]" >&2; exit 2;;
  esac
done

DEBUG_OPT=''
if [ "$DEBUG_FLG" = 'true' ]; then
  DEBUG_OPT='--debug'
fi

buildVariant() {
  local opts="$1" label="$2"
  echo "### Build: ${label} ###"
  # shellcheck disable=SC2086
  fontforge -script "${BASE_DIR}/fontforge_script.py" ${opts} ${DEBUG_OPT} --out "${BASE_DIR}"
  # shellcheck disable=SC2086
  python3 "${BASE_DIR}/fonttools_script.py" ${opts} ${DEBUG_OPT} --dir "${BASE_DIR}"
}

moveTo() {
  local dir="$1" prefix="$2"
  mkdir -p "${BUILD_DIR}/${dir}"
  mv -f "${BASE_DIR}/${prefix}"-*.ttf "${BUILD_DIR}/${dir}/"
}

if [ "$DEBUG_FLG" = 'true' ]; then
  buildVariant '' 'debug (standard, Regular only)'
  moveTo MonoplexKR MonoplexKR
  echo '### Build OK (debug) ###'
  exit 0
fi

# 무거운 Nerd 판을 먼저 돌린다
buildVariant '--nerd' 'Nerd Fonts edition'
moveTo MonoplexKRNerd MonoplexKRNerd

buildVariant '' 'standard edition'
moveTo MonoplexKR MonoplexKR

########################################
# 생성 결과 검증
########################################

echo '### Checking generated fonts ###'

mapfile -t styles < <(python3 -c "
import json
cfg = json.load(open('${BASE_DIR}/build.json'))
for s in cfg['styles']:
    print(s['file'])
")

missing=0
expected=()
for item in "MonoplexKR|MonoplexKR" "MonoplexKRNerd|MonoplexKRNerd"; do
  dir="${item%%|*}"; prefix="${item#*|}"
  for style in "${styles[@]}"; do
    path="${BUILD_DIR}/${dir}/${prefix}-${style}.ttf"
    expected+=("$path")
    if [ ! -f "$path" ]; then
      echo "MISSING: ${path}" >&2
      missing=1
    fi
  done
done

echo "expected=${#expected[@]}"
if (( missing != 0 )); then
  echo 'ERROR: 생성되지 않은 글꼴이 있습니다' >&2
  exit 1
fi

echo '### Checking font readability ###'
python3 "${BASE_DIR}/check_generated_fonts.py" "${expected[@]}"

echo '### Build OK ###'
