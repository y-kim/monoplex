#!/bin/bash

BASE_DIR=$(cd $(dirname $0); pwd)

function mvBuild() {
  mkdir -p "${BASE_DIR}/build/MonoplexKR"
  mkdir -p "${BASE_DIR}/build/MonoplexKRWide"
  mv -f "${BASE_DIR}/"MonoplexKRWide*.ttf "${BASE_DIR}/build/MonoplexKRWide/"
  mv -f "${BASE_DIR}/"MonoplexKR*.ttf "${BASE_DIR}/build/MonoplexKR/"
}

function mvBuildNerd() {
  mkdir -p "${BASE_DIR}/build/MonoplexKR_Nerd"
  mkdir -p "${BASE_DIR}/build/MonoplexKRWide_Nerd"
  mv -f "${BASE_DIR}/"MonoplexKRWide*.ttf "${BASE_DIR}/build/MonoplexKRWide_Nerd/"
  mv -f "${BASE_DIR}/"MonoplexKR*.ttf "${BASE_DIR}/build/MonoplexKR_Nerd/"
  rm -f "${BASE_DIR}/"MonoplexKR*.ttf
}

DEBUG_FLG='false'
while getopts d OPT
do
  case $OPT in
    'd' ) DEBUG_FLG='true';;
  esac
done

if [ "$DEBUG_FLG" = 'true' ]; then
  ("${BASE_DIR}/monoplex_kr_generator.sh" -d \
  && "${BASE_DIR}/os2_patch.sh" \
  && mvBuild)
  exit
fi

("${BASE_DIR}/monoplex_kr_generator.sh" -n \
&& "${BASE_DIR}/os2_patch.sh" \
&& mvBuildNerd)

("${BASE_DIR}/monoplex_kr_generator.sh" \
&& "${BASE_DIR}/os2_patch.sh" \
&& mvBuild)
