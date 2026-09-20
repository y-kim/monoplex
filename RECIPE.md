# 레시피 해설

`recipes/monoplex-kr.json` 과 `recipes/monoplex-cjk.json` 이 무엇을 하고
왜 그렇게 정했는지 적어 둔 문서입니다. 레시피의 `$note` 에 흩어져 있는
근거를 한자리에 모은 것이라, 레시피를 고치기 전에 읽으시면 됩니다.

글꼴을 쓰는 쪽에서 겪는 것은 릴리즈 노트에 있습니다.

- 레시피를 돌리는 법은 [HOW_TO_BUILD.md](HOW_TO_BUILD.md)
- 버전을 매기는 기준은 [VERSIONING.md](VERSIONING.md)
- 릴리즈별 변경 이력은 [CHANGELOG.md](CHANGELOG.md)
- 릴리즈 노트는 [release-notes/](release-notes/)

## 메트릭

네 가족이 모두 같습니다. 섞어 써도 줄이 맞습니다.

| | 값 |
|---|---|
| unitsPerEm | 1000 |
| 좁은폭 (라틴·기호) | 528 |
| 넓은폭 (한글·한자·가나) | 1056 |
| hhea ascent / descent | 950 / −225 |
| typoLineGap | 80 |
| italicAngle | −9 |
| OS/2 xAvgCharWidth | 528 |
| post.isFixedPitch | 1 |
| PANOSE | 2 11 ? 9 5 2 3 0 2 3 |

PANOSE의 세 번째 자리(weight)만 굵기마다 다릅니다.

0.0.2에서 1.0.0으로 오면서 이 값들은 하나도 바뀌지 않았습니다. 줄바꿈
위치와 세로 정렬이 그대로인 이유입니다.

### PANOSE 수정

상류 PlemolJP(4143f3d)의 수정을 가져왔습니다.

| 자리 | 전 | 후 |
|---|---|---|
| bContrast | 2 | 5 |
| bLetterForm | 2 | 0 |
| bXHeight | 7 | 3 |

bProportion은 9(Monospaced)로 둡니다.

## 공백 폭

전각 1056의 정수 분할로 맞췄습니다. 0.0.2까지는 IBM Plex Mono가 고정폭
글꼴이라 원본부터 모두 600이었고, 축소를 거쳐 전부 528이 되어 있었습니다.
그래서 `U+2005 FOUR-PER-EM`이 이름과 달리 em의 1/2였습니다.

| 유닛 | 문자 |
|---|---|
| 1056 | U+2001 EM QUAD, U+2003 EM SPACE, U+3000 IDEOGRAPHIC SPACE |
| 528 | U+0020 SPACE, U+00A0 NBSP, U+2000 EN QUAD, U+2002 EN SPACE, U+2007 FIGURE, U+2008 PUNCTUATION |
| 352 | U+2004 THREE-PER-EM |
| 264 | U+2005 FOUR-PER-EM, U+205F MEDIUM MATHEMATICAL |
| 176 | U+2006 SIX-PER-EM, U+2009 THIN, U+202F NARROW NBSP |
| 132 | U+200A HAIR |

이름과 유니코드 정의가 어긋나는 곳이 셋 있습니다. `U+2005`는 정의상
em의 1/4이므로 264로, `U+2009 THIN`은 1/5이나 인접한 약수인 1/6(176)으로,
`U+200A HAIR`는 1/10이나 1/8(132)로 맞췄습니다. 전각의 약수여야 칸이
어긋나지 않습니다.

레시피에는 유닛이 아니라 분모로 적습니다. 전각 폭을 바꿔도 따라갑니다.

## 이름과 스타일 비트

### macStyle과 fsSelection

0.0.2까지 `head.macStyle`을 아무도 채우지 않아 16개 중 10개가
`fsSelection`과 어긋나 있었습니다. 값이 어긋나면 일부 앱이 진짜 이탤릭
위에 가짜 기울임을 덧씌웁니다. ttfautohint가 빌드마다 경고하던 것이
이것입니다.

`fsSelection`은 파일 이름에 `Bold`가 들어 있는지로 정하고 있었습니다.
그래서 SemiBold가 BOLD 비트를 달았고, 글꼴 선택기에서 SemiBold가 그
가족의 볼드로 잡혀 Bold와 경쟁했습니다.

이제 둘 다 스타일 표에서 유도합니다. Regular와 Bold만 한 패밀리의 네 칸
(RIBBI)을 쓰고 나머지 굵기는 별도 패밀리를 가지므로, SemiBold는
"Monoplex KR SemiBold" 패밀리의 Regular이지 Bold가 아닙니다.

### Nerd Font 판의 이름

`Monoplex KR Nerd`에서 `Monoplex KR Nerd Font`로 바꿨습니다. Nerd Fonts의
패처가 기본으로 붙이는 형태이고, 도구들이 이 이름으로 글꼴을 찾습니다.
라이선스가 강제하는 것은 아니지만 관례를 따르는 편이 낫습니다.

## Monoplex CJK의 소스 우선순위

같은 코드포인트를 여러 글꼴이 갖고 있을 때 앞에 있는 것을 씁니다.

```
IBM Plex Mono  →  Plex Sans KR  →  Plex Sans JP  →  Plex Sans TC  →  Plex Sans SC
   라틴              한글            가나·한자         한자 보충        간체·확장A
```

일본어 글자는 모두 JP에서 가져옵니다. 한자에 이체자가 있을 때 JP를 TC·SC
앞에 둔 것은, 일본 쪽에 저장된 자형이 한국에서 쓰는 자형과 더 잘 맞기
때문입니다.

호환한자(U+F900–FAFF)는 소스 글꼴에 없습니다. 같은 한자의 다른 독음을
유니코드가 따로 부호화한 것이라 자형이 통합한자 쪽과 같으므로, 정준
등가(canonical decomposition)로 cmap을 연결했습니다. 그래서 KS X 1001의
한자 4,888자(통합 4,620 + 호환 268)를 100% 덮습니다.

### TC의 사용자 정의 영역

IBM Plex Sans TC는 PUA에 벤더 내부용 글리프를 4,729자 갖고 있습니다.
우선순위상 이것이 Nerd Fonts보다 앞이라 Nerd Fonts 영역을 통째로
가로챘습니다. Powerline 구분자 자리에 TC의 내부 글리프가 들어앉아 폭이
전각 1056이 되고, 터미널에서 칸이 어긋났습니다.

JP·TC·SC에서 PUA를 제외하니 Nerd Fonts의 기여가 8,307자에서 10,868자로
늘었습니다. Monoplex KR 계열에서는 드러나지 않던 문제입니다 —
IBM Plex Sans KR은 PUA가 0자입니다.

## 세로 정렬

Plex Sans의 한자와 가나는 한글과 세로 위치가 다릅니다. 섞어 쓰면 한자만,
또 가나만 들려 보입니다. 둘 다 내려서 맞췄습니다.

**한자** — 자면 중심이 한글보다 75유닛 위에 있었습니다. 최대 자면 기준으로
한글 304.5 / 한자 380이었고, 보정 후 310.9 / 309.9입니다.

**가나** — 위끝이 한자보다 40유닛 높았습니다.

| | 위끝 (보정 전) | 위끝 (보정 후) |
|---|---|---|
| 한자 | 772 | 772 |
| 히라가나 | 815 | 775 |
| 가타카나 | 809 | 769 |
| 반각 가타카나 | 816 | 770 |
| 한글 | 769 | 769 |

재는 방법: 탁점·반탁점이 붙은 글자(`が` `パ`)는 그 점이 자면 위로 올라가는
것이 정상이라 뺐습니다. 그리고 `鬱` 같은 극단적인 글자가 최대값을 끌어
올리므로 최대 대신 상위 5%를 썼습니다.

`、。「」・` 같은 CJK 구두점은 위끝이 760으로 원래 한자와 맞아 있어서
건드리지 않았습니다. 장음부 `U+30FC ー`는 가나의 일부로 읽히므로 가나와
함께 내렸습니다.

둘 다 평행이동입니다. 자형 크기와 획 굵기는 손대지 않았습니다.

### 가로는 왜 안 맞추는가

한자의 최대 자면 가로는 934, 한글은 857로 한자가 9% 넓습니다. 세로는
922 대 930으로 이미 1% 안쪽입니다.

가로만 맞추려고 한쪽을 한 축으로만 늘이거나 줄이면 세로획과 가로획의
굵기 비율이 깨집니다. 한글을 가로로 8% 늘여 봤더니 세로획만 8% 굵어졌고,
한자를 가로세로 함께 9% 줄여 봤더니 가로는 맞았지만 세로가 0.903으로
어긋나면서 애써 맞춘 세로 위치까지 위로 떴습니다.

원래 자형의 비율이 가장 정확하므로 그대로 두었습니다. 한자가 9% 넓은
것은 IBM Plex Sans 자체의 설계입니다.

## 이탤릭

라틴과 한글만 기울입니다. 한자와 가나는 이탤릭 굵기에서도 곧게 둡니다.

라틴은 IBM Plex Mono의 실제 이탤릭 파일을 쓰고, 한글은 합성입니다
(`italicize`, −9도). CJK는 전통적으로 이탤릭이 없어 기울이면 어색합니다.
덧붙여 FontForge의 `italicize`는 글리프마다 윤곽을 다시 계산해서, 한자
2만 자에 돌리면 이탤릭 굵기가 정체보다 몇 배 느려집니다.

## Nerd Fonts

v2.0.0에서 v3.5.1로 올렸습니다. v3에서 Material Design Icons가
U+F500–FD46에서 U+F0001–F1AF0으로 옮겨갔습니다.

소스는 Symbols-only 대신 Blex Mono Nerd Font를 씁니다. IBM Plex Mono
패치본이라 전 글리프 폭이 600으로 균일해서 기존 파이프라인의 전제와
그대로 맞습니다.

넣을 코드포인트 범위는 상류의 목록을 옮겨오지 않고
`cmap(BlexMonoNerdFont 3.5.1) − cmap(IBMPlexMono)`로 직접 산출했습니다.
검증 결과 누락 0, 초과 0입니다.

**Pomicons(U+E000–E00A)는 제외합니다.** 상업적 이용이 제한되는
라이선스입니다.

### Powerline 구분자

v2의 구분자는 자면이 칸 폭에 모자라서(U+E0B0이 0..528/600) 코드에서 밀어
맞췄습니다. v3.5.1은 −36..599로 칸을 넘치게 설계되어 있어 그 보정이
오히려 칸 사이에 틈을 만듭니다. 제거했습니다.

## U+274C를 지운 이유

IBM Plex Mono의 U+274C CROSS MARK는 흑백 반각 글리프입니다. 이것이 있으면
OS의 이모지 글꼴로 폴백하지 않아 ❌가 흑백으로 나옵니다. 지워서
폴백시킵니다. 상류 PlemolJP(be3ac3a)의 수정입니다.

## 박스 드로잉

U+2500–259F 160자는 반각으로 손질한 `source/AdjustedGlyphs/Box_Drawing_half.sfd`
에서 가져옵니다. IBM Plex Mono와 IBM Plex Sans KR 양쪽에 원본이 있지만
전각이거나 칸에 맞지 않습니다.

## 굵기마다 커버리지가 다른 곳

IBM Plex Sans KR 1.002는 **Thin 굵기에만 57자가 없습니다.**

```
U+3008 U+3009  U+FB00 U+FB03 U+FB04  U+FF5E
U+FFA1–FFDC (반각 한글 자모 51자)
```

나머지 일곱 굵기에는 다 있습니다. 그래서 Monoplex KR의 Thin은 12,944자,
나머지는 13,001자입니다. 0.0.2도 같았습니다.

IBM이 1.003에서 이 57자를 전 굵기에서 빼는 쪽으로 정리했는데, 그래서
1.003으로 올리지 않았습니다.

## IBM Plex Sans KR을 1.003으로 올리지 않은 이유

자면은 사실상 같습니다. bbox가 12,151/12,156자 완전 일치입니다. 그런데
반각 한글 자모를 비롯한 57자가 빠지고 16자만 늘어납니다. 늘어난 16자는
이미 IBM Plex Mono 쪽에 있어서 쓰이지 않으므로, 얻는 것 없이 잃기만
합니다.

## 소스 글꼴 버전

버전은 글꼴 파일 안의 값(name ID 5)입니다. 배포 채널의 패키지 번호와는
다를 수 있습니다. 예를 들어 `@ibm/plex-mono@2.5.0` 릴리스에 들어 있는
글꼴의 내부 버전은 `2.005`입니다.

| 글꼴 | 내부 버전 | 업스트림 릴리스 |
|---|---|---|
| IBM Plex Mono | 2.005 | [`@ibm/plex-mono@2.5.0`](https://github.com/IBM/plex/releases/tag/%40ibm%2Fplex-mono%402.5.0) |
| IBM Plex Sans KR | 1.002 | [`v6.4.2`](https://github.com/IBM/plex/releases/tag/v6.4.2) (마지막 통합 릴리스) |
| IBM Plex Sans JP | 1.004 | [`@ibm/plex-sans-jp@3.0.0`](https://github.com/IBM/plex/releases/tag/%40ibm%2Fplex-sans-jp%403.0.0) |
| IBM Plex Sans TC | 1.001 | [`@ibm/plex-sans-tc@1.1.1`](https://github.com/IBM/plex/releases/tag/%40ibm%2Fplex-sans-tc%401.1.1) |
| IBM Plex Sans SC | 1.000 | [`@ibm/plex-sans-sc@1.1.0`](https://github.com/IBM/plex/releases/tag/%40ibm%2Fplex-sans-sc%401.1.0) |
| Blex Mono Nerd Font | Nerd Fonts 3.5.1 | [`v3.5.1`](https://github.com/ryanoasis/nerd-fonts/releases/tag/v3.5.1) |

## 커버리지

| | Monoplex KR | KR Nerd Font | Monoplex CJK | CJK Nerd Font |
|---|---|---|---|---|
| cmap | 13,001 | 23,869 | 44,724 | 55,592 |
| 한글 음절 | 11,172 | 11,172 | 11,172 | 11,172 |
| 한글 자모 | 94 | 94 | 94 | 94 |
| 반각 한글 자모 | 51 | 51 | 51 | 51 |
| 통합한자 | — | — | 20,992 | 20,992 |
| 확장 A | — | — | 6,592 | 6,592 |
| 호환한자 | — | — | 467 | 467 |
| KS X 1001 한자 | — | — | 4,888 / 4,888 | 4,888 / 4,888 |
| 히라가나 / 가타카나 | — | — | 93 / 96 | 93 / 96 |
| 반각 가타카나 | — | — | 58 | 58 |
| 박스 드로잉 | 160 | 160 | 160 | 160 |
| Powerline | — | 40 | — | 40 |
| Material Design Icons | — | 6,896 | — | 6,896 |
| Codicons | — | 540 | — | 540 |
| Devicons | — | 601 | — | 601 |
| 16스타일 용량 | 42 MB | 77 MB | 176 MB | 210 MB |

한글 음절 11,172자는 U+AC00–D7A3 전부입니다.
