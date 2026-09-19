# 글꼴 빌드 방법

## Docker로 빌드하기 (권장)

빌드 환경은 공개 이미지 [`ghcr.io/yuru7/composite-font-builder`](https://github.com/yuru7/composite-font-builder/pkgs/container/composite-font-builder)를 사용합니다. 이 이미지는 FontForge, ttfautohint, Python 3 + fontTools를 포함하고 있으며, 실행 시 저장소를 `/work`에 마운트해서 `./make.sh`를 실행합니다.

이미지는 PlemolJP 전용이 아니라 합성 글꼴 프로젝트 전반을 위한 것이라, 실행 가능한 `make.sh`가 있는 저장소라면 그대로 쓸 수 있습니다.

### 필요한 것

- [Docker](https://docs.docker.com/get-docker/)

소스 글꼴(IBM Plex Mono / IBM Plex Sans KR / Blex Mono Nerd Font)은 이 저장소의 `source/`에 포함되어 있습니다.

### 전체 빌드

저장소 루트에서 실행합니다. 처음에는 이미지를 받느라 시간이 걸립니다.

```bash
docker run --rm -v "$(pwd):/work" ghcr.io/yuru7/composite-font-builder
```

생성된 TTF는 호스트의 `./build/` 아래에 가족별 디렉터리로 나옵니다.

```
build/MonoplexKR/     MonoplexKR-{style}.ttf
build/MonoplexKRNerd/ MonoplexKRNerd-{style}.ttf
```

16개 스타일 × 2개 가족 = 32개 파일이 생성되며, 완료까지 수십 분이 걸립니다.

### 디버그 빌드 (빠른 확인용)

`DEBUG=1`을 주면 Nerd Fonts 없이 Regular 한 가지 두께만 생성합니다.

```bash
docker run --rm -e DEBUG=1 -v "$(pwd):/work" ghcr.io/yuru7/composite-font-builder
```

## Docker 없이 빌드하기

### Linux

Ubuntu 24.04 기준으로 대략 다음 패키지가 필요합니다.

```bash
sudo apt-get update
sudo apt-get install -y fontforge python3 python3-fontforge python3-pip ttfautohint
python3 -m pip install --break-system-packages fonttools
./make.sh
```

Arch Linux라면 다음과 같습니다.

```bash
sudo pacman -S fontforge python python-fonttools
# ttfautohint 는 AUR
./make.sh
```

디버그 빌드는 `./make.sh -d` 또는 `DEBUG=1 ./make.sh` 입니다.

의존 패키지의 정확한 정의는 [composite-font-builder](https://github.com/yuru7/composite-font-builder)를 참고하세요.

### 요구 도구

| 도구 | 용도 |
|---|---|
| `fontforge` | 글리프 합성·변형 (`-script` 모드) |
| `ttfautohint` | 힌팅 |
| `pyftmerge` (fontTools) | 힌팅된 글꼴과 한글/Nerd 글리프 병합 |
| `ttx` (fontTools) | OS/2·post 테이블 패치 (`os2_patch.sh`) |

과거에는 Python 2 + fontTools 3.44 조합을 썼지만, 현재는 Python 3 + 최신 fontTools에서 동작합니다.

## 빌드 후 검증

`make.sh`는 빌드가 끝나면 다음을 자동으로 확인합니다.

1. 기대한 32개 파일이 모두 생성되었는지
2. 생성된 TTF를 fontTools로 읽을 수 있는지 (`check_generated_fonts.py`)

둘 중 하나라도 실패하면 0이 아닌 종료 코드로 끝납니다.
