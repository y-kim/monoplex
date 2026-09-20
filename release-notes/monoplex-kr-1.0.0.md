# Monoplex KR 1.0.0

IBM Plex Mono에 IBM Plex Sans KR의 한글을 더한 프로그래밍 글꼴입니다.
한글과 라틴의 너비 비율이 2:1이라 섞어 써도 칸이 어긋나지 않습니다.

8종 굵기(Thin · ExtraLight · Light · Regular · Text · Medium · SemiBold ·
Bold)와 각각의 이탤릭이 들어 있습니다.

## 0.0.2에서 올리실 때

**`Monoplex KR Wide`가 없어졌습니다.** 한글과 라틴이 5:3이던 계열입니다.
쓰고 계셨다면 2:1인 이 글꼴로 옮기셔야 합니다.

**❌(U+274C)가 컬러 이모지로 나옵니다.** 전에는 흑백 반각 글리프가 들어
있어서 OS 이모지 글꼴로 넘어가지 않았습니다. 그 글자를 뺐습니다.

그 밖에는 그대로 올리시면 됩니다. 줄 간격도, 글자 폭도, 줄바꿈 위치도
달라지지 않습니다. 0.0.2에 있던 글자 중 사라진 것은 위의 ❌ 하나뿐입니다.

## 달라진 것

**이탤릭이 제대로 나옵니다.** 글꼴 정보가 어긋나 있어서 일부 프로그램이
진짜 이탤릭 위에 가짜 기울임을 한 번 더 덧씌우고 있었습니다.

**SemiBold가 Bold 자리를 뺏지 않습니다.** 글꼴 선택기에서 SemiBold가 그
가족의 볼드로 잡혀 Bold와 경쟁하던 문제를 고쳤습니다.

**라틴 글자가 106자 늘었습니다.** IBM Plex Mono를 2018년판에서 최신판으로
올렸습니다. 키릴 확장과 발음 부호 등입니다.

**공백 문자의 너비가 이름대로 나옵니다.** 전에는 종류에 상관없이 모두
같은 폭이었습니다.

## 어느 것을 받을까

이 글꼴에는 **한자가 없습니다.** 한국어 문서에 한자가 섞이면 그 글자만
시스템 글꼴로 넘어가면서 칸이 어긋납니다. 한자를 쓰신다면
**Monoplex CJK**를 받으세요.

터미널 프롬프트나 파일 아이콘에 Powerline·Nerd Fonts 글리프를 쓰신다면
**Monoplex KR Nerd Font**를 받으세요.

## 설치

압축을 풀면 ttf 파일이 나옵니다. 쓰시는 운영체제의 방법대로 설치하시면
됩니다.

---

레시피가 무엇을 어떻게 하는지는
[RECIPE.md](https://github.com/y-kim/monoplex/blob/main/RECIPE.md),
전체 변경 이력은
[CHANGELOG.md](https://github.com/y-kim/monoplex/blob/main/CHANGELOG.md)
에 있습니다.

IBM Plex Mono 2.005와 IBM Plex Sans KR 1.002로 만들었습니다.
SIL Open Font License 1.1.
