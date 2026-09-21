![Monoplex KR](images/monoplex-kr.png)[^1]

[^1]: 글꼴 이름을 표현하는 그림의 아이디어는 Microsoft [Cascadia Code](https://github.com/microsoft/cascadia-code)에서 가져왔습니다.

# Monoplex (모노플렉스)

IBM Plex Mono에 동아시아 글자를 합쳐서 만든 프로그래밍 글꼴입니다.

언어 별로 두 가지 계열이 있습니다.

| | 담은 글자 | 쓰임 |
|---|---|---|
| **Monoplex KR** | 라틴 + 한글 | 한글만 쓰는 경우 |
| **Monoplex CJK** | 라틴 + 한글 + 한자 + 가나 | 한자나 일본어가 섞이는 경우 |

각 계열에 Nerd Fonts를 합친 판이 따로 있어서, 모두 네 가족입니다.

- `Monoplex KR` / `Monoplex KR Nerd Font`
- `Monoplex CJK` / `Monoplex CJK Nerd Font`

Nerd Font 판에는 Powerline 기호, Material Design Icons, Codicons, Devicons 등이
들어 있습니다. Nerd Font를 지원하는 환경에서는 이 글꼴을 사용하세요.

# Monoplex CJK

![Monoplex CJK](images/monoplex-cjk.png)

한자와 가나는 IBM Plex Sans의 지역 변종에서 가져왔습니다. 같은 코드포인트를
여러 글꼴이 갖고 있을 때는 아래 순서로 먼저 있는 것을 씁니다.

```
IBM Plex Mono  →  Plex Sans KR  →  Plex Sans JP  →  Plex Sans TC  →  Plex Sans SC
라틴              한글             가나·한자        한자 보충        간체·확장A
```

IBM Plex Sans KR은 한글 메트릭을 로마자에 맞춰 잡았고, 다른 동아시아 글꼴은
전통적인 CJK 메트릭을 씁니다. 그대로 합치면 어긋나서 가나와 한자를 한글에
맞췄습니다. 자세한 것은 [RECIPE.md](RECIPE.md)에 있습니다.

# 갤러리

**Monoplex KR** — 한글과 라틴을 정렬하여 볼 수 있습니다.

![Monoplex KR 예제](images/example-kr.png)

**Monoplex CJK** — 한글·한자·히라가나·가타카나를 나란히 놓아도 오른쪽 끝이
한 열에 떨어집니다.

![Monoplex CJK 예제](images/example-cjk.png)

**한 줄에 섞어 쓸 때** — 한국어 문장의 명사만 로마자·한자·가나로 바꾼
것입니다. 반각과 전각이 한 줄에서 예닐곱 번 번갈아도 아래 줄과 열이 맞습니다.
주석 줄에서는 라틴과 한글만 기울고 한자·가나는 곧게 섭니다.

![섞어 쓰기](images/example-mix.png)

**Nerd Font 판** — vim + [vim-airline](https://github.com/vim-airline/vim-airline)
화면입니다. Powerline 구분자가 한 칸에 들어갑니다.

![vim-airline (Monoplex KR Nerd Font)](images/vim-kr.png)

![vim-airline (Monoplex CJK Nerd Font)](images/vim-cjk.png)


# 설치

릴리즈 페이지에서 글꼴을 받아주세요: https://github.com/y-kim/monoplex/releases

압축파일을 풀면 ttf 파일이 생성됩니다. 각 운영체제에서 제공하는 방법을 사용하여
글꼴을 설치할 수 있습니다.

# 직접 빌드하기

빌드 도구는 [hapchija](https://github.com/y-kim/hapchija) 저장소에 있고 `tools/`
서브모듈로 들어옵니다. 소스 글꼴은 용량이 커서 저장소에 넣지 않고 받아 옵니다.

```bash
git clone --recursive https://github.com/y-kim/monoplex
cd monoplex

# 소스 글꼴 받기 (KR 은 24MB, CJK 는 175MB)
PYTHONPATH=tools/src python3 -m hapchija fetch --recipe recipes/monoplex-kr.json

docker run --rm -v "$(pwd):/work" ghcr.io/yuru7/composite-font-builder \
  bash -c "cd /work && PYTHONPATH=tools/src python3 -m hapchija build --recipe recipes/monoplex-kr.json"
```

`recipes/monoplex-cjk.json` 으로 바꾸면 CJK 판이 나옵니다.

| 문서 | 내용 |
|---|---|
| [HOW_TO_BUILD.md](HOW_TO_BUILD.md) | 빌드하는 법 |
| [RECIPE.md](RECIPE.md) | 레시피가 무엇을 왜 그렇게 하는지 |
| [VERSIONING.md](VERSIONING.md) | 버전을 매기는 기준 |
| [CHANGELOG.md](CHANGELOG.md) | 변경 이력 |

# 사용한 소스 글꼴

내부 버전은 글꼴 파일 안에 적힌 값으로, 배포 패키지의 번호와 다를 수 있습니다.

| 글꼴 | 내부 버전 | 업스트림 릴리스 | 쓰는 곳 |
|---|---|---|---|
| IBM Plex Mono | 2.005 | [`@ibm/plex-mono@2.5.0`](https://github.com/IBM/plex/releases/tag/%40ibm%2Fplex-mono%402.5.0) | 라틴 |
| IBM Plex Sans KR | 1.002 | [`v6.4.2`](https://github.com/IBM/plex/releases/tag/v6.4.2) (마지막 통합 릴리스) | 한글 |
| IBM Plex Sans JP | 1.004 | [`@ibm/plex-sans-jp@3.0.0`](https://github.com/IBM/plex/releases/tag/%40ibm%2Fplex-sans-jp%403.0.0) | CJK: 가나·한자 |
| IBM Plex Sans TC | 1.001 | [`@ibm/plex-sans-tc@1.1.1`](https://github.com/IBM/plex/releases/tag/%40ibm%2Fplex-sans-tc%401.1.1) | CJK: 한자 보충 |
| IBM Plex Sans SC | 1.000 | [`@ibm/plex-sans-sc@1.1.0`](https://github.com/IBM/plex/releases/tag/%40ibm%2Fplex-sans-sc%401.1.0) | CJK: 간체·확장A |
| Blex Mono Nerd Font | Nerd Fonts 3.5.1 | [`v3.5.1`](https://github.com/ryanoasis/nerd-fonts/releases/tag/v3.5.1) | Nerd Font 판 |

IBM Plex Sans KR 최신 버전인 1.003에서 반각 한글 자모가 빠져 이번 버전인 1.002를 사용합니다.

Nerd Fonts 글리프 중 Pomicons(U+E000–U+E00A)는 라이선스상 상업적 이용이
제한되어 포함하지 않았습니다.

# 알려진 이슈

## VS Code에서 커서를 위아래로 움직이면 열이 어긋남

![VS Code 커서](images/cursor.gif)

VS Code는 글자 폭을 재지 않고 고정된 유니코드 블록 표로 2칸 글자를 정합니다.
그 표에 없는 글자를 이 글꼴이 전각으로 그리면 커서 열이 튀고, 열 선택과 자동
줄바꿈, 미니맵도 함께 어긋납니다. 확장 API로는 고칠 수 없습니다.

- 근본 해결은 VS Code 쪽 기능 개선 요청
  [Vertical cursor movement considering character width](https://github.com/microsoft/vscode/issues/136226)
  에 달려 있습니다.
- 우회 방법으로 [vscode-fullwidth-patch](https://github.com/y-kim/vscode-fullwidth-patch)
  를 쓸 수 있습니다. 설치된 VS Code를 고치는 것이라 업데이트되면 다시 적용해야
  합니다.
