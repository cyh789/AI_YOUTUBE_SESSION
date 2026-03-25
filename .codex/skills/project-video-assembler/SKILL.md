---
name: project-video-assembler
description: 이 프로젝트의 'output' 이미지와 'tts_audio' 오디오를 연결해 최종 영상을 조립한다. 'video_script/assemble-video.ps1'를 사용해 mp4 조립 단계가 필요할 때 사용한다.
---

# Project Video Assembler

이 스킬은 장면 이미지와 TTS 오디오를 최종 영상으로 묶을 때 사용합니다.

## 역할

- 'output' 폴더의 장면 이미지를 확인합니다.
- 'tts_audio' 폴더의 오디오 파일을 확인합니다.
- 'video_script/assemble-video.ps1'를 사용해 영상 조립을 진행합니다.
- 필요하면 장면 매핑 계획을 먼저 출력해 검토합니다.

## 핵심 규칙

- 입력 이미지는 'output' 폴더 하위에서 찾습니다.
- 입력 오디오는 'tts_audio' 폴더 하위에서 찾습니다.
- 실제 조립은 'video_script/assemble-video.ps1'를 사용합니다.
- 최종 결과물은 'video_output' 폴더 하위 mp4 파일입니다.
- 현재 환경에 'ffmpeg'가 없으면 실행 전 설치 필요 여부를 먼저 확인합니다.

## 작업 순서

1. 'AGENTS.md'를 읽습니다.
2. 'tasks.md', 'findings.md', 'progress.md'를 읽고 현재 프로젝트 상태를 파악합니다.
3. 'output' 이미지와 'tts_audio' 오디오 파일 존재 여부를 확인합니다.
4. 필요하면 'video_script/assemble-video.ps1 -PrintPlan'으로 장면 매핑 계획을 확인합니다.
5. 준비가 되면 영상 조립 스크립트를 실행합니다.
6. 결과를 'video_output' 폴더에서 확인합니다.
7. 작업 결과를 'tasks.md', 'findings.md', 'progress.md', 'CHATS.md'에 반영합니다.

## 작성 기준

- 장면 누락이나 매핑 누락이 없는지 먼저 확인합니다.
- 조립 전에 입력 파일 수와 이름 규칙을 점검합니다.
- 'ffmpeg' 미설치 상태면 그 사실을 명확히 알립니다.

## 결과물

- 기본 결과물: 'video_output' 폴더 하위 mp4 영상 파일
- 필요 시 부가 결과물: 장면 매핑 점검 메모
