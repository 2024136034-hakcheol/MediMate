# ADR 템플릿

> Architecture Decision Record 작성 형식

## 파일 위치 및 네이밍

```
.planning/decisions/ADR-XXXX-{주제}.md
예) ADR-0001-mobile-framework.md
```

## 작성 형식

```markdown
# ADR-XXXX — [결정 제목]

- 날짜: YYYY-MM-DD
- 상태: 확정 / 검토 중 / 폐기

## 배경
왜 이 결정이 필요했는지 설명

## 결정
무엇을 선택했는지 한 줄로

## 대안

| 대안 | 검토 결과 |
|------|-----------|
| 옵션 A | 탈락 이유 |
| 옵션 B | 탈락 이유 |

## 결과
이 결정으로 인한 영향 및 트레이드오프
```

## MediMate ADR 목록

| ADR | 결정 내용 | 위치 |
|-----|-----------|------|
| ADR-0001 | Flutter 선택 | `.planning/decisions/ADR-0001-mobile-framework.md` |
