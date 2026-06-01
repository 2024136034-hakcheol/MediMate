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

### 핵심 문서
- [AGENTS.md](AGENTS.md) — AI Agent 운영 가이드
- [BONUS.md](BONUS.md) — 가산점 트래킹
- [AUTHORING.문학철.v0.1.0.md](AUTHORING.문학철.v0.1.0.md) — 개인 AI 활용 기법

### docs/
- [docs/setup.md](docs/setup.md) — 환경 구축 & 실행 가이드
- [docs/PRD.md](docs/PRD.md) — 기획서 & 요구사항
- [docs/WBS.md](docs/WBS.md) — WBS & 일정표
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — 아키텍처 & ADR
- [docs/qna-log.md](docs/qna-log.md) — Q&A 기록 (발표 후 작성)

### .planning/
- [.planning/00-vision.md](.planning/00-vision.md) — 비전·목표
- [.planning/01-requirements.md](.planning/01-requirements.md) — 요구사항
- [.planning/02-wbs.md](.planning/02-wbs.md) — WBS & 위험 식별
- [.planning/04-schedule.md](.planning/04-schedule.md) — 6주 일정
- [.planning/decisions/ADR-0001-mobile-framework.md](.planning/decisions/ADR-0001-mobile-framework.md) — ADR: Flutter 선택

### resources/
- [resources/01-team-policy.md](resources/01-team-policy.md) — 팀 구성 가이드
- [resources/02-evaluation-rubric.md](resources/02-evaluation-rubric.md) — 평가표 전문
- [resources/03-bonus-points.md](resources/03-bonus-points.md) — 가산점 상세
- [resources/04-doc-scaffold.md](resources/04-doc-scaffold.md) — 문서 스캐폴드 트리
- [resources/05-bootstrap-prompt.md](resources/05-bootstrap-prompt.md) — AI 부트스트랩 프롬프트
- [resources/06-llm-wiki-guide.md](resources/06-llm-wiki-guide.md) — 암묵지 운영 가이드
- [resources/10-demo-checklist.md](resources/10-demo-checklist.md) — 데모 시연 체크리스트
- [resources/11-qna-prep.md](resources/11-qna-prep.md) — Q&A 대비 질문 모음

## 프로젝트 구조

```
MediMate/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── presentation/
│   │   ├── screens/      # UI 화면
│   │   ├── widgets/      # 공통 위젯
│   │   └── theme/        # 앱 테마
│   ├── application/
│   │   └── view_models/  # 상태 관리
│   ├── domain/
│   │   ├── entities/     # Medicine, Schedule, IntakeLog
│   │   └── services/     # 비즈니스 로직
│   └── data/
│       ├── api/          # GeminiService
│       ├── local/        # DbService (SQLite)
│       └── repositories/
├── docs/
├── .planning/
├── .env                  # API 키 (gitignore)
├── AGENTS.md
├── BONUS.md
└── README.md
```

## 팀

- **PillNova** — 앱 프로그래밍 응용 Vibe Coding Project
- 문학철 (단독)
