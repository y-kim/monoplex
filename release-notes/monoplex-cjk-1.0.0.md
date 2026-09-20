# Monoplex CJK

IBM Plex Mono에 IBM Plex Sans의 한글·한자·가나를 더한 프로그래밍 글꼴입니다.
첫 릴리즈입니다.

8종 굵기(Thin · ExtraLight · Light · Regular · Text · Medium · SemiBold ·
Bold)와 각각의 이탤릭이 들어 있습니다.

## Monoplex KR과의 차이점

`Monoplex KR`에는 한자가 없어서, 한국어 문서에 한자가 섞이면 그 글자만
시스템 글꼴로 넘어가며 칸이 어긋납니다. 이 계열이 그 자리를 채웁니다.

 - 한자 추가. KS X 1001의 한자 4,888자를 빠짐없이 담음. 이체자가 있을 때는 한국 자형에 가까운 일본 쪽 자형을 씀
 - 가나 추가. 히라가나·가타카나·반각 가타카나가 들어 있어 일본어도 그대로 나옴
 - 세로 위치 보정. 한자는 한글보다, 가나는 그보다 더 위에 놓여 있어 섞어 쓰면 한글만 내려앉아 보이던 것을 셋의 윗선이 맞도록 내림
 - 이탤릭 범위 제한. 한자와 가나는 전통적으로 이탤릭이 없어 이탤릭 굵기에서도 곧게 둠. 기울이는 것은 라틴과 한글뿐

줄 간격과 글자 폭은 `Monoplex KR`과 같습니다. 두 글꼴을 섞어 써도 줄이
맞습니다. 한자를 쓸 일이 없다면 `Monoplex KR`이 가볍고 충분합니다.

## 설치

압축을 풀면 ttf 파일이 나옵니다. 쓰시는 운영체제의 방법대로 설치하시면
됩니다.

---

레시피가 무엇을 어떻게 하는지는
[RECIPE.md](https://github.com/y-kim/monoplex/blob/main/RECIPE.md),
전체 변경 이력은
[CHANGELOG.md](https://github.com/y-kim/monoplex/blob/main/CHANGELOG.md)
에 있습니다.

IBM Plex Mono 2.005와 IBM Plex Sans KR 1.002 · JP 1.004 · TC 1.001 ·
SC 1.000으로 만들었습니다. SIL Open Font License 1.1.
