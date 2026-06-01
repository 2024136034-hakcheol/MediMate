# AI Agent 부트스트랩 프롬프트

> 새 작업 세션 시작 시 Claude Code에 컨텍스트를 빠르게 전달하는 프롬프트 모음

## 기본 부트스트랩

```
나는 Flutter로 MediMate(AI 약 복용 관리 앱)를 개발 중이야.
기술 스택: Flutter, Gemini API, sqflite, flutter_local_notifications
구조: lib/presentation/, lib/domain/, lib/data/ 레이어 분리
PRD는 docs/PRD.md에 있어.

지금 [작업 내용]을 하려고 해.
```

## 기능 구현 요청

```
PRD [기능번호] 요구사항을 구현해줘.
현재 코드: [코드 첨부]
구현 후 해당 기능의 조건을 체크리스트로 확인해줘.
```

## 디버깅 요청

```
아래 에러가 발생했어. 원인과 수정 방법을 알려줘.
에러: [에러 메시지]
관련 코드: [코드]
Flutter 버전: 3.41.9, Dart 3.11.5
```

## UI 화면 생성

```
Flutter로 [화면 이름] 화면을 만들어줘.
- 표시할 데이터: [데이터 구조]
- 목업 데이터로 먼저 구현 (나중에 실제 서비스로 교체)
- lib/presentation/screens/ 경로에 생성
- 파일명: [screen_name]_screen.dart
```

## 문서 작성 요청

```
[구현한 내용]을 바탕으로 [문서 종류]를 작성해줘.
기존 문서 스타일은 docs/ 폴더를 참고해줘.
```
