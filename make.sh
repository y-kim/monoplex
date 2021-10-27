#!/bin/bash

BASE_DIR=$(cd $(dirname $0); pwd)

function mvBuild() {
  mkdir -p "${BASE_DIR}/build/MonoplexKR"
  mkdir -p "${BASE_DIR}/build/MonoplexKRConsole"
  mkdir -p "${BASE_DIR}/build/MonoplexKRWide"
  mkdir -p "${BASE_DIR}/build/MonoplexKRWideConsole"
  mv -f "${BASE_DIR}/"MonoplexKRWideConsole*.ttf "${BASE_DIR}/build/MonoplexKRWideConsole/"
  mv -f "${BASE_DIR}/"MonoplexKRWide*.ttf "${BASE_DIR}/build/MonoplexKRWide/"
  mv -f "${BASE_DIR}/"MonoplexKRConsole*.ttf "${BASE_DIR}/build/MonoplexKRConsole/"
  mv -f "${BASE_DIR}/"MonoplexKR*.ttf "${BASE_DIR}/build/MonoplexKR/"
}

function mvBuildNF() {
  mkdir -p "${BASE_DIR}/build/MonoplexKRConsole_NF"
  mkdir -p "${BASE_DIR}/build/MonoplexKRWideConsole_NF"
  mv -f "${BASE_DIR}/"MonoplexKRWideConsole*.ttf "${BASE_DIR}/build/MonoplexKRWideConsole_NF/"
  mv -f "${BASE_DIR}/"MonoplexKRConsole*.ttf "${BASE_DIR}/build/MonoplexKRConsole_NF/"
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
&& mvBuildNF)

("${BASE_DIR}/monoplex_kr_generator.sh" \
&& "${BASE_DIR}/os2_patch.sh" \
&& mvBuild)
