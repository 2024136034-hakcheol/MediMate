# 문서 스캐폴드 권장 트리

## MediMate 문서 구조 현황

```
MediMate/
├── README.md                          ✅ 프로젝트 개요
├── AGENTS.md                          ✅ AI Agent 운영 가이드
├── BONUS.md                           ✅ 가산점 트래킹
├── AUTHORING.문학철.v0.1.0.md         ✅ 개인 기법 문서
│
├── docs/
│   ├── setup.md                       ✅ 환경 구축 가이드
│   ├── PRD.md                         ✅ 기획서 & 요구사항
│   ├── WBS.md                         ✅ WBS & 일정표
│   ├── ARCHITECTURE.md                ✅ 아키텍처 & ADR
│   └── qna-log.md                     ✅ Q&A 기록 (발표 후 작성)
│
├── .planning/
│   ├── 00-vision.md                   ✅ 비전·목표
│   ├── 01-requirements.md             ✅ 요구사항
│   ├── 02-wbs.md                      ✅ WBS + 위험 식별
│   ├── 04-schedule.md                 ✅ 6주 일정
│   └── decisions/
│       └── ADR-0001-mobile-framework.md ✅ Flutter 선택 ADR
│
└── resources/
    ├── 01-team-policy.md              ✅ 팀 구성 가이드
    ├── 02-evaluation-rubric.md        ✅ 평가표
    ├── 03-bonus-points.md             ✅ 가산점 상세
    ├── 04-doc-scaffold.md             ✅ 문서 구조 (이 파일)
    ├── 05-bootstrap-prompt.md         ✅ AI 부트스트랩 프롬프트
    ├── 06-llm-wiki-guide.md           ✅ 암묵지 운영 가이드
    ├── 10-demo-checklist.md           ✅ 데모 시연 체크리스트
    └── 11-qna-prep.md                 ✅ Q&A 대비 질문 모음
```

## 채점 기준 대조

| 채점 단계 | 필요 문서 | 상태 |
|-----------|-----------|------|
| +1 기획서/요구사항 | PRD.md | ✅ |
| +2 WBS/일정 | WBS.md, 04-schedule.md | ✅ |
| +3 아키텍처/ADR | ARCHITECTURE.md, ADR-0001 | ✅ |
| +4 setup/deploy/testing | setup.md | ✅ |
| +5 AGENTS.md/README 완비 | AGENTS.md, README.md | ✅ |
