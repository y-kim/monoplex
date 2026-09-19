#!/usr/bin/env bash
set -euo pipefail

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
BUILD_DIR="${BASE_DIR}/build"

# DEBUG=1 環境変数 (Docker 用) と -d オプションの両方を受け付ける
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

# os2_patch.sh が退避先として使うので必ず用意しておく
mkdir -p "${BASE_DIR}/bak"

# fontTools が使えるときだけ走る後処理 (BASE テーブル削除など)
postProcess() {
  if command -v python3 > /dev/null 2>&1 && python3 -c 'import fontTools' > /dev/null 2>&1; then
    shopt -s nullglob
    local files=("${BASE_DIR}"/MonoplexKR*.ttf)
    shopt -u nullglob
    if (( ${#files[@]} > 0 )); then
      python3 "${BASE_DIR}/post_process.py" "${files[@]}"
    fi
  else
    echo 'SKIP: fontTools が無いため post_process をスキップします' >&2
  fi
}

mvBuild() {
  mkdir -p "${BUILD_DIR}/MonoplexKR"
  mv -f "${BASE_DIR}/"MonoplexKR*.ttf "${BUILD_DIR}/MonoplexKR/"
}

mvBuildNerd() {
  mkdir -p "${BUILD_DIR}/MonoplexKRNerd"
  mv -f "${BASE_DIR}/"MonoplexKRNerd*.ttf "${BUILD_DIR}/MonoplexKRNerd/"
  rm -f "${BASE_DIR}/"MonoplexKR*.ttf
}

if [ "$DEBUG_FLG" = 'true' ]; then
  echo '### Debug Mode (Regular only, no Nerd Fonts) ###'
  "${BASE_DIR}/monoplex_kr_generator.sh" -d
  "${BASE_DIR}/os2_patch.sh"
  postProcess
  mvBuild
  echo '### Build OK (debug) ###'
  exit 0
fi

echo '### Build: Nerd Fonts edition ###'
"${BASE_DIR}/monoplex_kr_generator.sh" -n
"${BASE_DIR}/os2_patch.sh"
postProcess
mvBuildNerd

echo '### Build: standard edition ###'
"${BASE_DIR}/monoplex_kr_generator.sh"
"${BASE_DIR}/os2_patch.sh"
postProcess
mvBuild

########################################
# 生成結果の検証
########################################

echo '### Checking generated fonts ###'

styles=(
  Thin ExtraLight Light Regular Text Medium SemiBold Bold
  ThinItalic ExtraLightItalic LightItalic Italic
  TextItalic MediumItalic SemiBoldItalic BoldItalic
)

# family_dir|file_prefix
families=(
  "MonoplexKR|MonoplexKR"
  "MonoplexKRNerd|MonoplexKRNerd"
)

missing=0
expected_files=()
for item in "${families[@]}"; do
  family_dir="${item%%|*}"
  prefix="${item#*|}"
  for style in "${styles[@]}"; do
    path="${BUILD_DIR}/${family_dir}/${prefix}-${style}.ttf"
    expected_files+=("$path")
    if [ ! -f "$path" ]; then
      echo "MISSING: ${path}" >&2
      missing=1
    fi
  done
done

shopt -s nullglob
actual_files=("${BUILD_DIR}"/*/*.ttf)
shopt -u nullglob

echo "expected=${#expected_files[@]}  actual=${#actual_files[@]}"
if (( missing != 0 )); then
  echo 'ERROR: 生成されなかったフォントがあります' >&2
  exit 1
fi

if command -v python3 > /dev/null 2>&1 && python3 -c 'import fontTools' > /dev/null 2>&1; then
  echo '### Checking font readability ###'
  python3 "${BASE_DIR}/check_generated_fonts.py" "${expected_files[@]}"
else
  echo 'SKIP: fontTools が無いため読み込み確認をスキップします' >&2
fi

echo '### Build OK ###'
