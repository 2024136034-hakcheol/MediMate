# MediMate — AI 약 복용 관리 앱

> 카메라로 약을 찍으면 AI가 복용 스케줄을 자동으로 만들어 주는 Flutter 앱

## 프로젝트 개요

약 포장지를 촬영하면 Gemini API가 약 이름·용량·복용법을 인식하고, 맞춤 복용 알림과 복용 기록을 관리해 줍니다.

## 핵심 기능

| 기능 | 설명 |
|------|------|
| 약 스캔 | 카메라로 약 포장 촬영 → AI 자동 인식 |
| 복용 알림 | 맞춤 시간에 로컬 알림 |
| 복용 기록 | 날짜별 복용 여부 체크 및 히스토리 |
| 약 정보 | 주의사항·부작용 AI 요약 제공 |

## 기술 스택

- **앱:** Flutter (Dart)
- **AI:** Gemini API (Vision + Text)
- **로컬 DB:** sqflite (SQLite)
- **알림:** flutter_local_notifications
- **AI 개발 도구:** Claude Code

## 문서

- [설치 & 실행 가이드](docs/setup.md)
- [기획서 & 요구사항](docs/PRD.md)
- [WBS & 일정표](docs/WBS.md)
- [아키텍처 & ADR](docs/ARCHITECTURE.md)
- [AI Agent 운영 가이드](AGENTS.md)

## 프로젝트 구조

```
MediMate/
├── lib/
│   ├── main.dart
│   ├── services/         # GeminiService, DbService
│   └── models/           # Medicine, Schedule, IntakeLog
├── docs/
│   ├── setup.md
│   ├── PRD.md
│   ├── WBS.md
│   └── ARCHITECTURE.md
├── .planning/
├── .env                  # API 키 (gitignore)
├── AGENTS.md
├── BONUS.md
└── README.md
```

## 팀

- **PillNova** — 앱 프로그래밍 응용 Vibe Coding Project
- 문학철, 김성진
