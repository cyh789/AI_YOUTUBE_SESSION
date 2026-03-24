# TTS 분할 계획 01

## 목적

- `scene-plan-01.md`의 장면 구성표를 기준으로 TTS용 음성 파일을 장면 단위로 분리합니다.
- 장면별 이미지와 장면별 음성을 1:1 또는 1:N으로 쉽게 매칭할 수 있도록 합니다.
- 편집 단계에서 재녹음, 재생성, 길이 조정이 쉽도록 짧은 단위로 관리합니다.

## 분할 원칙

- 한 파일에는 한 장면의 내레이션만 넣습니다.
- 한 파일 길이는 보통 1문단 또는 1~2문장으로 유지합니다.
- 한 장면이 길면 `a`, `b`처럼 추가 분할합니다.
- TTS용 문장은 읽기 자연스러운 구어체로 다듬고, 너무 긴 문장은 줄입니다.

## 파일 구조

- `tts/scene-01-hook.txt`
- `tts/scene-02-priority.txt`
- `tts/scene-03-intro.txt`
- `tts/scene-04-disclaimer.txt`
- `tts/scene-05-omega3-a.txt`
- `tts/scene-05-omega3-b.txt`
- `tts/scene-10-vitamin-d-a.txt`
- `tts/scene-15-magnesium-a.txt`

## 운영 원칙

- 이미지 프롬프트와 달리 TTS 문장은 반드시 한글로 유지합니다.
- 장면 번호는 `scene-plan-01.md`와 동일하게 맞춥니다.
- 나중에 자막 파일을 만들 때도 같은 장면 번호를 재사용합니다.

## 다음 작업

1. 장면별 TTS 텍스트 파일 생성
2. TTS 엔진 선택
3. 음성 스타일 결정
4. 생성된 음성과 이미지 길이 맞추기
