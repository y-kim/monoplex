# Monoplex KR 1.0.0

IBM Plex Mono에 IBM Plex Sans KR의 한글을 더한 프로그래밍 글꼴입니다.
넓은폭문자와 좁은폭문자의 너비 비율이 **2:1**이라 한글이 섞여도 칸이
어긋나지 않습니다.

8종 굵기(Thin · ExtraLight · Light · Regular · Text · Medium · SemiBold ·
Bold)와 각각의 이탤릭, 모두 16개 파일입니다.

## 0.0.2에서 올리실 때

**메트릭은 그대로입니다.** 반각 528 / 전각 1056, ascent 950 / descent 225,
typoLineGap 80. 줄바꿈 위치도 세로 정렬도 달라지지 않습니다.

**`Monoplex KR Wide`는 없어졌습니다.** 넓은폭:좁은폭이 5:3이던 계열입니다.
쓰고 계셨다면 2:1인 이 글꼴로 옮기셔야 합니다.

**사라진 글자는 `U+274C` CROSS MARK 하나입니다.** IBM Plex Mono의 흑백
반각 글리프가 OS 이모지 글꼴로의 폴백을 막고 있어서 지웠습니다. 이제 ❌가
시스템 이모지로 나옵니다.

## 달라진 것

**IBM Plex Mono를 2.3(2018)에서 2.005로 올렸습니다.** 106자가 늘었습니다.
키릴 확장, 결합 발음 부호 등입니다. 사라진 코드포인트는 없습니다.

**글꼴 메타데이터 결함 두 가지를 고쳤습니다.** 둘 다 0.0.2부터 있던
것입니다.

- `head.macStyle`을 아무도 채우지 않아 16개 중 10개가 `fsSelection`과
  어긋나 있었습니다. 값이 어긋나면 일부 앱이 진짜 이탤릭 위에 가짜
  기울임을 덧씌웁니다
- 파일 이름에 `Bold`가 들어 있는지로 `fsSelection`을 정한 탓에 SemiBold가
  BOLD 비트를 달고 있었습니다. 글꼴 선택기에서 SemiBold가 그 가족의
  볼드로 잡혀 Bold와 경쟁했습니다

**공백 폭을 전각 1056의 정수 분할로 맞췄습니다.** 전에는 전부 528이라
`U+2005 FOUR-PER-EM`이 이름과 달리 em의 1/2였습니다.

| 유닛 | 문자 |
|---|---|
| 1056 | EM QUAD, EM SPACE, IDEOGRAPHIC SPACE |
| 528 | SPACE, NBSP, EN QUAD, EN SPACE, FIGURE, PUNCTUATION |
| 352 | THREE-PER-EM |
| 264 | FOUR-PER-EM, MEDIUM MATHEMATICAL |
| 176 | SIX-PER-EM, THIN, NARROW NBSP |
| 132 | HAIR |

**PANOSE**를 고쳤습니다 (contrast 2→5, letterForm 2→0, xHeight 7→3).

## 담은 글자

| | |
|---|---|
| cmap | 13,001자 |
| 한글 음절 | 11,172자 (전부) |
| 한글 자모 | 94자 + 반각 자모 51자 |
| 박스 드로잉 | 160자 (반각) |
| 파일 | 16개 (8굵기 × 정체/이탤릭), 42 MB |

Thin 한 굵기만 12,944자입니다. IBM Plex Sans KR 1.002가 Thin에만 57자
(반각 한글 자모 등)를 빼 두었기 때문입니다. 0.0.2도 같았습니다.

한자는 들어 있지 않습니다. 한국어 문서에 한자가 섞이면 시스템 대체 글꼴로
넘어가면서 고정폭 정렬이 깨집니다. 한자를 쓰신다면 **Monoplex CJK**를
받으세요.

터미널 프롬프트나 파일 아이콘에 Powerline·Nerd Fonts 글리프가 필요하시면
**Monoplex KR Nerd Font**를 받으세요.

## 소스 글꼴

| 글꼴 | 내부 버전 | 쓰는 곳 |
|---|---|---|
| IBM Plex Mono | 2.005 | 라틴 |
| IBM Plex Sans KR | 1.002 | 한글 |

둘 다 SIL Open Font License 1.1입니다.
