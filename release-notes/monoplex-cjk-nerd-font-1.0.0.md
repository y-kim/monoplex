# Monoplex CJK Nerd Font 1.0.0

첫 공개입니다.

**Monoplex CJK**에 Nerd Fonts 3.5.1의 글리프를 더한 판입니다. 한글·한자·
가나에 Powerline 구분자, Material Design Icons, Codicons, Devicons,
Font Awesome이 함께 들어 있습니다. 네 가족 중 가장 많이 담았습니다.

8종 굵기와 각각의 이탤릭, 모두 16개 파일, 210 MB입니다.

## 받기 전에

**용량이 큽니다.** 16개 파일 210 MB, 한 파일이 13 MB쯤입니다. 한자가 필요
없으시면 **Monoplex KR Nerd Font**(77 MB)가 가볍습니다.

**Nerd Fonts v2를 쓰시던 설정이라면 아이콘이 두부(□)로 나올 수 있습니다.**
v3에서 Material Design Icons가 `U+F500–FD46`에서 `U+F0001–F1AF0`으로
옮겨갔습니다. starship, eza, lsd, nvim-web-devicons 같은 도구를 v3 지원판
으로 올리면 대개 해결됩니다.

## 만들면서 잡은 것

IBM Plex Sans TC는 사용자 정의 영역(PUA)에 벤더 내부용 글리프를 4,729자
갖고 있습니다. 소스 우선순위상 이것이 Nerd Fonts보다 앞이라 **Nerd Fonts
영역을 통째로 가로챘습니다.** Powerline 구분자 자리에 TC의 내부 글리프가
들어앉아 폭이 전각 1056이 되고, 터미널에서 칸이 어긋났습니다.

JP·TC·SC에서 PUA를 제외하니 Nerd Fonts의 기여가 8,307자에서 10,868자로
늘었습니다. Monoplex KR Nerd Font에서는 드러나지 않던 문제입니다 —
IBM Plex Sans KR은 PUA가 0자입니다.

## 담은 글자

| | |
|---|---|
| cmap | 55,592자 |
| 한글 음절 | 11,172자 (전부) |
| 통합한자 | 20,992자 |
| 확장 A | 6,592자 |
| 호환한자 | 467자 |
| 히라가나 / 가타카나 | 93 / 96자 |
| **KS X 1001 한자** | **4,888자 전부** |
| Powerline | 40자 |
| Material Design Icons | 6,896자 |
| Codicons | 540자 |
| Devicons | 601자 |
| 박스 드로잉 | 160자 (반각) |
| 파일 | 16개 (8굵기 × 정체/이탤릭), 210 MB |

Nerd Fonts 글리프는 모두 라틴과 같은 반각 528입니다. 한자·가나는 전각
1056입니다. 고정폭 정렬이 깨지지 않습니다.

**Pomicons(`U+E000–E00A`)는 넣지 않았습니다.** 상업적 이용이 제한되는
라이선스입니다.

메트릭은 나머지 세 가족과 같습니다. 반각 528 / 전각 1056, ascent 950 /
descent 225, typoLineGap 80.

한자와 가나의 세로 위치를 한글에 맞춘 것, 이탤릭을 라틴과 한글에만
적용한 것은 Monoplex CJK와 같습니다. 자세한 것은 Monoplex CJK 1.0.0
릴리즈 노트를 보세요.

## 소스 글꼴

| 글꼴 | 버전 | 쓰는 곳 |
|---|---|---|
| IBM Plex Mono | 2.005 | 라틴 |
| IBM Plex Sans KR | 1.002 | 한글 |
| IBM Plex Sans JP | 1.004 | 가나·한자 |
| IBM Plex Sans TC | 1.001 | 한자 보충 |
| IBM Plex Sans SC | 1.000 | 간체·확장 A |
| Blex Mono Nerd Font | Nerd Fonts 3.5.1 | 기호·아이콘 |

IBM Plex는 SIL Open Font License 1.1, Nerd Fonts는 각 아이콘 모음의
라이선스를 따릅니다.
