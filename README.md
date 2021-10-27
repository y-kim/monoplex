# Monoplex KR (모노플렉스 KR)

Monoplex KR은 IBM Plex Mono에 IBM Plex Sans KR의 글자체를 더해서 만든 프로그래밍 글꼴입니다. 이 글꼴 만들어 주는 스크립트는 [PlemolJP](https://github.com/yuru7/PlemolJp) 프로젝트에서 가져왔습니다.

# 가족 구성

`Monoplex KR`은 넓은폭문자와 좁은폭문자의 너비 비율이 2:1인 고정폭 글꼴입니다. 유니코드 기본 라틴판의 글자는 IBM Plex Mono의 글꼴을 사용하며, 한글을 비롯한 그 외의 글자는 IBM Plex Sans KR을 사용합니다.

더불어 Monoplex KR은 아래의 일곱 가족과 친족을 이룹니다.

- `Monoplex KR Console`
- `Monoplex KR Wide`
- `Monoplex KR Wide Console`
- `Monoplex KR NF`
- `Monoplex KR Console NF`
- `Monoplex KR Wide NF`
- `Monoplex KR Wide Console NF`

가족들 사이의 차이점은, 글꼴 이름에 더해진 키워드를 통해 확인할 수 있습니다.

- `Wide`: 좁은폭문자의 너비가 조금 더 넓어 너비 비율이 5:3이 되는 글꼴입니다.
- `Console`: IBM Plex Mono에 속한 글자를 우선하며, 이 글꼴에 없는 글자만 IBM Plex Sans KR에서 가져온 글꼴입니다.
- `NF`: Powerline 기호, 매테리얼 디자인 등이 포함된 Nerd Font가 일체화된 글꼴입니다.

참고로 원형인 PlemolJP와는 달리 전각공백을 가시화하지 않습니다. 이는 한국어 환경에서 전각공백을 사용하는 일이 거의 없기 때문입니다.

# 갤러리

TBD

# 설치

릴리즈 페이지에서 글꼴을 받아주세요:  https://github.com/y-kim/monoplex/releases

압축파일을 풀면 ttf 파일이 생성됩니다. 각 운영체제에서 제공하는 방법을 사용하여 글꼴을 설치할 수 있습니다.

# 직접 빌드하기

이 스크립트는 아래의 프로그램이 설치된 환경에서 동작이 확인되었습니다.

- ttfautohint 1.8.3
- fonttools 3.44.0
- fontforge 20201107
