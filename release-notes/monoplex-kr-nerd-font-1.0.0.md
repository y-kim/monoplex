# Monoplex KR Nerd Font 1.0.0

**Monoplex KR**에 Nerd Fonts 3.5.1의 글리프를 더한 판입니다. Powerline
구분자, Material Design Icons, Codicons, Devicons, Font Awesome 등이 한 칸
(반각 528)에 들어 있습니다. 터미널 프롬프트나 파일 아이콘을 쓰신다면
이쪽입니다.

8종 굵기와 각각의 이탤릭, 모두 16개 파일입니다.

## 0.0.2에서 올리실 때 — 먼저 확인하세요

**글꼴 이름이 `Monoplex KR Nerd`에서 `Monoplex KR Nerd Font`로
바뀌었습니다.** 터미널이나 편집기 설정에 적어 두신 이름을 고치셔야 합니다.
Nerd Fonts의 패처가 기본으로 붙이는 형태이고, 도구들이 이 이름으로 글꼴을
찾습니다.

**아이콘이 두부(□)로 나올 수 있습니다.** Nerd Fonts를 v2.0.0에서 v3.5.1로
올리면서 Material Design Icons가 자리를 옮겼습니다.

```
v2   U+F500–FD46     (2,119자)
v3   U+F0001–F1AF0   (6,896자)
```

starship, eza, lsd, nvim-web-devicons 같은 도구의 설정이 옛 코드포인트를
직접 가리키고 있다면 그 자리가 비어 두부가 됩니다. 도구를 Nerd Fonts v3를
지원하는 판으로 올리면 대개 해결됩니다. 설정 파일에 코드포인트를 손으로
적어 두셨다면 그것만 고치시면 됩니다.

**그 밖에 사라진 것은 `U+274C` CROSS MARK 하나입니다.** OS 이모지 글꼴로
폴백시키려고 지웠습니다.

**메트릭은 그대로입니다.** 반각 528 / 전각 1056, ascent 950 /
descent 225. 줄바꿈 위치와 세로 정렬은 달라지지 않습니다.

**`Monoplex KR Wide Nerd`는 없어졌습니다.** 5:3 비율 계열입니다.

## 달라진 것

**Powerline 구분자의 위치 보정을 없앴습니다.** v2의 구분자는 자면이 칸 폭에
모자라서 코드에서 밀어 맞췄는데(U+E0B0이 0..528/600), v3.5.1은 −36..599로
칸을 넘치게 설계돼 있어 그 보정이 오히려 칸 사이에 틈을 만들었습니다.
이제 세로로 이어 붙여도 끊기지 않습니다.

이 밖에 Monoplex KR 1.0.0의 변경(IBM Plex Mono 2.005, `head.macStyle` 및
SemiBold `fsSelection` 수정, 공백 폭 정리, PANOSE 수정)이 그대로
들어 있습니다. 자세한 것은 Monoplex KR 1.0.0 릴리즈 노트를 보세요.

## 담은 글자

| | |
|---|---|
| cmap | 23,869자 |
| 한글 음절 | 11,172자 (전부) |
| Powerline | 40자 |
| Material Design Icons | 6,896자 |
| Codicons | 540자 |
| Devicons | 601자 |
| 박스 드로잉 | 160자 (반각) |
| 파일 | 16개 (8굵기 × 정체/이탤릭), 77 MB |

Nerd Fonts 글리프는 모두 라틴과 같은 반각 528입니다. 고정폭 정렬이
깨지지 않습니다.

**Pomicons(`U+E000–E00A`)는 넣지 않았습니다.** 상업적 이용이 제한되는
라이선스입니다.

한자가 필요하시면 **Monoplex CJK Nerd Font**를 받으세요.

## 소스 글꼴

| 글꼴 | 버전 | 쓰는 곳 |
|---|---|---|
| IBM Plex Mono | 2.005 | 라틴 |
| IBM Plex Sans KR | 1.002 | 한글 |
| Blex Mono Nerd Font | Nerd Fonts 3.5.1 | 기호·아이콘 |

넣을 코드포인트는 상류의 목록을 옮겨오지 않고
`cmap(BlexMonoNerdFont 3.5.1) − cmap(IBMPlexMono)` 로 직접 산출했습니다.
