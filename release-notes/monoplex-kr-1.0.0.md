# Monoplex KR

IBM Plex Mono에 IBM Plex Sans KR의 한글을 더한 프로그래밍 글꼴입니다.

8종 굵기(Thin · ExtraLight · Light · Regular · Text · Medium · SemiBold ·
Bold)와 각각의 이탤릭이 들어 있습니다.

## 0.0.2 버전과의 차이점

 - IBM Plex Mono 2.005로 업데이트. 키릴 문자 및 발음 부호 등 106개의 문자 추가 됨
 - `Monoplex KR Wide` 계열 제거. 한글과 로마자가 비율이 5:3인 계열이지만, 한글에서는 쓰임새가 적어 삭제함
 - ❌(U+274C) 제거. 시스템 폴백으로 컬러 이모지가 나오게 허용
 - 이탤릭 속성 수정. 글꼴 정보가 어긋나 일부 프로그램이 이탤릭에 이탤릭을 덧씌울 수 있는 문제 수정
 - SemiBold 문제 수정. 글꼴 정보가 어긋나 SemiBold와 Bold가 Bold체 굵기에서 경쟁할 수 있는 문제 수정
 - 유니코드 공백 문자 조정. 1/4 EM과 1/3 EM, NARROW 등의 특수 공백 너비를 고려하여 문자 너비 조정.


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
