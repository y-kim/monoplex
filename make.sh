#!/usr/bin/env bash
# Docker 이미지가 ./make.sh 를 실행하므로 얇게 감싸 둔다.
# 실제 빌드는 build.py 가 한다. 직접 쓸 때는 ./build.py 를 부르면 된다.
set -euo pipefail
exec python3 "$(cd "$(dirname "$0")"; pwd)/build.py" "$@"
