# BONUS.md — 가산점 신청 트래킹

> 최대 +6점 (발표 평가에 가산)

## 노릴 가산점 항목

| 항목 | 배점 | 상태 | 비고 |
|------|------|------|------|
| AI Agent / 스킬 / 워크플로우 적극 활용 | +1 | 완료 | Claude Code로 기획·코드 생성·디버깅·문서 작성 전 과정 진행 (예: Gemini 404 진단, 통계·다중 인식 기능 구현) |
| 본인만의 기법 구성 + 설명 | +2 | 완료 | `AGENTS.md` 3절 — PRD-Driven Prompting / `AUTHORING.문학철...md` 2~3절 — PRD-Driven Prompting, UI-First Mocking |
| 최신 LLM Wiki 기반 암묵지 관리 운영 | +1 | 완료 | `AGENTS.md` 5절·`AUTHORING...md` 4절 — 모델 지원 종료, 다중 인식 확장 등 실제 사례 누적 |
| 최신 AI Agent 리포트 발표 (10분 이상) | +2 | 발표 준비 필요 | 슬라이드(`index.html`)에는 미포함 — 발표 시 `AGENTS.md`·`AUTHORING...md`를 참고 자료로 구두 설명 예정 |

**목표 가산점: +6점 (전항목)**

## 항목별 준비 계획

### +1 AI Agent 적극 활용
- Claude Code로 코드 생성·디버깅·문서 작성 전 과정 활용
- 발표 시 "어떤 작업에 어떤 프롬프트를 썼는지" 예시 제시 (예: Gemini 404 오류를 ListModels API로 직접 진단해 모델 교체)

### +2 본인만의 기법
- 기법 1: **PRD-Driven Prompting** — `AGENTS.md` 3절 / `AUTHORING.문학철...md` 2절
- 기법 2: **UI-First Mocking** — `AUTHORING.문학철...md` 3절
- 발표 시 설명 포인트: 구조, 이유, 동작 방식, 효과

### +1 LLM Wiki 암묵지 관리
- `AGENTS.md` 5절 "실패 사례 & 교훈", `AUTHORING.문학철...md` 4절에 실제 겪은 문제·해결책 기록
- 최근 추가 사례: Gemini 모델 지원 종료(404) 진단·교체, 다중 약 인식 확장, 발표 자료-구현 불일치 발견 후 실제 기능 구현으로 해소

### +2 AI Agent 리포트 발표
- 발표 시간 안에 "AI Agent 활용 보고서" 10분 이상 구두 설명으로 포함
- 내용: 사용한 도구(Claude Code, Gemini API), 프롬프트 전략(PRD-Driven Prompting, UI-First Mocking), 효과, 한계
- 참고 자료: `AGENTS.md`, `AUTHORING.문학철.v0.1.0.md`
