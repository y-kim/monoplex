# 글꼴 빌드 방법

## Docker로 빌드하기 (권장)

빌드 환경은 공개 이미지 [`ghcr.io/yuru7/composite-font-builder`](https://github.com/yuru7/composite-font-builder/pkgs/container/composite-font-builder)를 사용합니다. 이 이미지는 FontForge, ttfautohint, Python 3 + fontTools를 포함하고 있으며, 저장소를 `/work`에 마운트해서 쓰면 됩니다.

이미지는 PlemolJP 전용이 아니라 합성 글꼴 프로젝트 전반을 위한 것이라, FontForge·ttfautohint·fontTools 가 필요한 프로젝트면 그대로 쓸 수 있습니다.

### 필요한 것

- [Docker](https://docs.docker.com/get-docker/)

소스 글꼴(IBM Plex Mono / IBM Plex Sans KR / Blex Mono Nerd Font)은 이 저장소의 `source/`에 포함되어 있습니다.

### 전체 빌드

저장소 루트에서 실행합니다. 처음에는 이미지를 받느라 시간이 걸립니다.

```bash
docker run --rm -v "$(pwd):/work" ghcr.io/yuru7/composite-font-builder python3 build.py
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
docker run --rm -v "$(pwd):/work" ghcr.io/yuru7/composite-font-builder python3 build.py --debug
```

## Docker 없이 빌드하기

### Linux

Ubuntu 24.04 기준으로 대략 다음 패키지가 필요합니다.

```bash
sudo apt-get update
sudo apt-get install -y fontforge python3 python3-fontforge python3-pip ttfautohint
python3 -m pip install --break-system-packages fonttools
./build.py
```

Arch Linux라면 다음과 같습니다.

```bash
sudo pacman -S fontforge python python-fonttools
# ttfautohint 는 AUR
./build.py
```

디버그 빌드는 `./build.py --debug` 입니다.

의존 패키지의 정확한 정의는 [composite-font-builder](https://github.com/yuru7/composite-font-builder)를 참고하세요.

### 요구 도구

| 도구 | 용도 |
|---|---|
| `fontforge` | 글리프 합성·변형. Python 바인딩을 씁니다 |
| `ttfautohint` | 힌팅 |
| `fontTools` | 부품 병합과 OS/2·post 테이블 수정 |

## 구성

| 파일 | 역할 |
|---|---|
| [build.py](build.py) | 빌드 도구. 레시피를 읽어 아래 둘을 순서대로 부르고 결과를 검증 |
| [recipes/](recipes/) | 레시피. 무엇을 어떻게 합칠지 |
| [fontforge_script.py](fontforge_script.py) | 글리프 합성. `fontforge -script` 로 실행 |
| [fonttools_script.py](fonttools_script.py) | 힌팅, 부품 병합, 테이블 수정 |

```bash
./build.py --list                                  # 레시피 목록
./build.py                                         # 기본 레시피 전체 빌드
./build.py --debug                                 # 한 두께만
./build.py --recipe recipes/foo.json --variant nerd
```

## 레시피 쓰기

레시피 하나가 글꼴 하나를 정의합니다. 핵심은 `sources` 입니다.

```json
{
  "target":  { "em": {...}, "halfWidth": 528, "vertical": {...} },
  "styles":  [ { "name": "Regular", "file": "Regular", "weight": 400, ... } ],
  "sources": [
    { "id": "latin", "role": "base",    "path": "...", "fit": {...} },
    { "id": "kr",    "role": "cjk",     "path": "...", "fit": {...} },
    { "id": "nerd",  "role": "symbols", "path": "...", "when": "nerd" }
  ]
}
```

- `sources` 는 **우선순위 순서**입니다. 앞선 소스가 같은 코드포인트를 이깁니다.
  라틴 + 한글 + 일본어처럼 셋 이상도 됩니다.
- `role: base` 인 소스가 최종 글꼴의 뼈대가 됩니다. 힌팅도 여기에만 들어갑니다.
- `when` 이 붙은 소스는 그 변종을 만들 때만 포함됩니다.
- `path` 의 `{...}` 에는 `styles` 항목의 필드 이름을 씁니다.
- 소스의 `upem` 이 달라도 `target.em` 으로 자동 정규화됩니다.

### fit 전략

소스를 목표 폭에 맞추는 방법입니다.

| 모드 | 언제 |
|---|---|
| `halfScale` | 라틴 고정폭·심볼. 일정 비율로 줄이고 반각 폭에 맞춥니다 |
| `cjkUniform` | CJK 소스의 전각 폭이 한 가지로 통일된 경우 (맑은 고딕 등) |
| `cjkClassify` | 글리프마다 폭이 제각각인 경우 (IBM Plex Sans KR 등). 한 번 훑어 분류합니다 |

### 글리프 조작 (ops)

`preOps` (참조 해제 전) → `ops` → `fit` → `opsAfter` 순서로 돕니다.

| op | 하는 일 |
|---|---|
| `scale` / `rotate` | bbox 중심 기준 변환 |
| `scaleOrigin` | 원점 기준 변환 |
| `translate` / `setWidth` / `clear` | 이동 / 폭 지정 / 비우기 |
| `mergeSfd` | 손질한 글리프를 담은 `.sfd` 를 합칩니다 |
| `removeLookups` | 커닝 등 GPOS lookup 제거 |
| `fitLineBox` | Powerline 구분자를 행 박스 전체에 맞춥니다 |

## 빌드 후 검증

`build.py` 는 빌드가 끝나면 다음을 자동으로 확인합니다.

1. 기대한 32개 파일이 모두 생성되었는지
2. 생성된 TTF를 fontTools로 읽을 수 있는지 (`check_generated_fonts.py`)

둘 중 하나라도 실패하면 0이 아닌 종료 코드로 끝납니다.
