지침 파일만 쓰니까 다음의 문제점이 생기는거 같다.
1.	지침 파일이 계속 커진다.
2.	다른 곳에서 쓰기 어렵다.
3.	정확하게 어떤 기능을 지칭하는 게 어려울 때도 있다.

그래서 나는 skill을 만들려고 한다.

----------------------------------------

1. 대본을 만들어서 script 폴더의 하위에 생성하는 작업을 이 프로젝트 전용 스킬(로컬 스킬)로 만들어줘
=> project-script-writer

ex) $project-script-writer로 refer 폴더의 샘플 대본을 참고해서 [주제]로 10~20분짜리 한국어 유튜브 대본을 script 폴더 하위에 작성해줘

ex) $project-script-writer로 refer 폴더의 샘플 대본을 참고해서 40대 남성을 위한 혈압 관리 습관 3가지 주제로 10분짜리 한국어 유튜브 대본을 script 폴더 하위에 작성해줘

----------------------------------------

2. script 폴더 하위에 생성된 대본을 보고, 대본에 맞는 이미지를 만들어서 output 폴더 하위에 생성하는 작업을 이 프로젝트 전용 스킬(로컬 스킬)로 만들어줘
=> project-script-image-generator

ex) project-script-image-generator로 script 폴더의 대본을 참고해서 10~20분 유튜브 영상용 장면 이미지를 output 폴더에 생성해줘

ex) project-script-image-generator로 script/draft-script-01.md를 기준으로 오메가3, 비타민D, 마그네슘 장면 이미지를 output 폴더에 만들어줘. 무료 모델이니까 이미지 안에는 한글을 넣지 마

----------------------------------------

3. output 폴더 하위에 생성된 이미지를 보고, 이미지에 맞춰서 장면 별로 텍스트 파일을 만들어서 tts 폴더 하위에 생성하는 작업을 이 프로젝트 전용 스킬(로컬 스킬)로 만들어줘
=> project-scene-tts-builder

ex) $project-scene-tts-builder로 output 폴더의 이미지와 script 폴더의 대본을 참고해서 10~20분 영상용 장면별 한국어 TTS 텍스트 파일을 tts 폴더 하위에 만들어줘

ex) $project-scene-tts-builder로 output의 장면 이미지들과 script/draft-script-01.md를 기준으로 장면별 한국어 TTS 텍스트를 tts 폴더 하위에 만들어줘

----------------------------------------




