# MediMate — AI 약 복용 관리 앱

> 카메라로 약을 찍으면 AI가 복용 스케줄을 자동으로 만들어 주는 Flutter 앱

## 프로젝트 개요

약 포장지를 촬영하면 Gemini API가 약 이름·용량·복용법을 인식하고, 맞춤 복용 알림과 복용 기록을 관리해 줍니다.

## 핵심 기능

| 기능 | 설명 |
|------|------|
| 약 스캔 & 다중 인식 | 카메라/갤러리로 약 포장 촬영 → AI 자동 인식 (사진 한 장에 약이 여러 종류 보이면 각각 인식해 개별 등록) |
| 복용 스케줄 & 알림 | 인식 결과 기반으로 복용 스케줄 자동 생성, 맞춤 시간에 로컬 알림 |
| 복용 기록 | 날짜별 복용 여부를 달력 뷰로 확인 및 체크 |
| 통계 | 최근 7일 복용률, 약별 누적 복용 횟수 차트로 시각화 |
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
- [docs/deploy.md](docs/deploy.md) — 배포 가이드 (명령어 복붙 가능)
- [docs/testing.md](docs/testing.md) — 테스트 명령 & 커버리지 위치
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
- [resources/01-planning-workflow.md](resources/01-planning-workflow.md) — 기획 워크플로우 상세
- [resources/02-wbs-template.md](resources/02-wbs-template.md) — WBS 템플릿
- [resources/03-adr-template.md](resources/03-adr-template.md) — ADR 템플릿
- [resources/04-risk-checklist.md](resources/04-risk-checklist.md) — 위험 체크리스트
- [resources/10-demo-checklist.md](resources/10-demo-checklist.md) — 데모 시연 체크리스트
- [resources/11-qna-prep.md](resources/11-qna-prep.md) — Q&A 대비 질문 모음
- [resources/12-presentation-script.md](resources/12-presentation-script.md) — 최종 발표 대본 (4분 30초 + 데모 30초)
- [resources/13-security-checklist.md](resources/13-security-checklist.md) — 보안 체크리스트

## 프로젝트 구조

```
MediMate/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── presentation/
│   │   ├── screens/                          # UI 화면 (스캔/결과/목록/홈/달력/통계/상세/설정 등)
│   │   └── theme/                            # 앱 테마 (app_theme.dart)
│   ├── domain/
│   │   └── entities/                         # Medicine, Schedule, IntakeLog
│   └── data/
│       ├── api/                               # GeminiService (Gemini Vision 연동, MedicineInfo 모델)
│       └── local/                             # DbService (SQLite CRUD·통계 집계), NotificationService
├── test/                                      # 단위/통합/위젯 테스트
│   ├── medicine_info_test.dart
│   ├── db_service_test.dart
│   └── widget_test.dart
│
├── docs/
│   ├── setup.md                              # 환경 구축 & 실행 가이드
│   ├── deploy.md                             # 배포 가이드 (명령어 복붙 가능)
│   ├── testing.md                            # 테스트 명령 & 커버리지 위치
│   ├── PRD.md                                # 기획서 & 요구사항
│   ├── WBS.md                                # WBS & 일정표
│   ├── ARCHITECTURE.md                       # 아키텍처 & ADR
│   └── qna-log.md                            # Q&A 기록 (발표 후 작성)
│
├── .planning/
│   ├── 00-vision.md                          # 비전·목표
│   ├── 01-requirements.md                    # 요구사항
│   ├── 02-wbs.md                             # WBS & 위험 식별
│   ├── 04-schedule.md                        # 6주 일정
│   └── decisions/
│       └── ADR-0001-mobile-framework.md      # ADR: Flutter 선택
│
├── resources/
│   ├── 01-team-policy.md                     # 팀 구성 가이드
│   ├── 01-planning-workflow.md               # 기획 워크플로우 상세
│   ├── 02-evaluation-rubric.md               # 평가표 전문
│   ├── 02-wbs-template.md                    # WBS 템플릿
│   ├── 03-bonus-points.md                    # 가산점 상세
│   ├── 03-adr-template.md                    # ADR 템플릿
│   ├── 04-doc-scaffold.md                    # 문서 스캐폴드 트리
│   ├── 04-risk-checklist.md                  # 위험 체크리스트
│   ├── 05-bootstrap-prompt.md                # AI 부트스트랩 프롬프트
│   ├── 06-llm-wiki-guide.md                  # 암묵지 운영 가이드
│   ├── 10-demo-checklist.md                  # 데모 시연 체크리스트
│   ├── 11-qna-prep.md                        # Q&A 대비 질문 모음
│   ├── 12-presentation-script.md             # 최종 발표 대본 (4분 30초 + 데모 30초)
│   └── 13-security-checklist.md              # 보안 체크리스트
│
├── index.html                                # 최종 발표 슬라이드 (reveal.js)
├── .env                                       # API 키 (gitignore, 커밋되지 않음)
├── AGENTS.md                                 # AI Agent 운영 가이드
├── BONUS.md                                  # 가산점 트래킹
├── AUTHORING.문학철.v0.1.0.md                 # 개인 AI 활용 기법
└── README.md                                 # 이 파일
```

## 팀

- **PillNova** — 앱 프로그래밍 응용 Vibe Coding Project
- 문학철 (단독)
