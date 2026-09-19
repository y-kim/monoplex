# 글꼴 빌드 방법

빌드 도구는 [hapchija](https://github.com/y-kim/hapchija) 라는 별도 저장소에
있고, 이 저장소에는 `tools/` 서브모듈로 들어와 있습니다. 이 저장소가 가진 것은
레시피([recipes/](recipes/))와 소스 글꼴([source/](source/))입니다.

## 받기

서브모듈까지 같이 받아야 합니다.

```bash
git clone --recursive https://github.com/y-kim/monoplex
# 이미 받았다면
git submodule update --init
```

## Docker 로 빌드 (권장)

FontForge, ttfautohint, fontTools 가 들어 있는 공개 이미지를 씁니다.

```bash
docker run --rm -v "$(pwd):/work" ghcr.io/yuru7/composite-font-builder \
  bash -c "cd /work && PYTHONPATH=tools/src python3 -m hapchija build --recipe recipes/monoplex-kr.json"
```

빠르게 확인하려면 `--debug` 를 붙입니다. Regular 한 두께만 만듭니다.

생성된 TTF 는 `build/` 아래에 가족별로 나옵니다.

```
build/MonoplexKR/     MonoplexKR-{style}.ttf
build/MonoplexKRNerd/ MonoplexKRNerd-{style}.ttf
```

16개 스타일 × 2개 가족 = 32개 파일이 나오며, 완료까지 수십 분 걸립니다.

## Docker 없이 빌드

FontForge 와 ttfautohint 는 pip 으로 설치되지 않습니다.

```bash
# Ubuntu
sudo apt-get install -y fontforge python3-fontforge ttfautohint
# Arch
sudo pacman -S fontforge && yay -S ttfautohint-cli
```

그다음 도구를 설치하고 빌드합니다.

```bash
pip install -e ./tools
hapchija build --recipe recipes/monoplex-kr.json
```

설치하지 않고 쓰려면 `PYTHONPATH=tools/src python3 -m hapchija ...` 로도 됩니다.

## 레시피 고치기

메트릭, 두께 표, 글리프 목록, Nerd Fonts 코드포인트 범위 같은 값은 전부
[recipes/monoplex-kr.json](recipes/monoplex-kr.json) 에 있습니다. 값만 바꿀 때는
이 파일만 고치면 됩니다.

레시피 형식과 쓸 수 있는 `fit` 전략, 글리프 `ops` 목록은
[tools/README.md](tools/README.md) 를 보세요.

## 빌드 후 검증

빌드가 끝나면 기대한 파일이 모두 생겼는지, 생성된 TTF 를 fontTools 로 읽을 수
있는지 자동으로 확인합니다. 둘 중 하나라도 실패하면 0 이 아닌 종료 코드로
끝납니다.
