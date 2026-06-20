# Testing Guide — MediMate

## 1. 테스트 실행

```bash
flutter test
```

## 2. 커버리지 측정

```bash
flutter test --coverage
```

커버리지 결과 위치:
```
coverage/lcov.info
```

HTML 리포트로 보기 (lcov 설치 필요: `choco install lcov` / `brew install lcov`):
```bash
genhtml coverage/lcov.info -o coverage/html
```
생성된 리포트: `coverage/html/index.html`

## 3. 테스트 구성

| 파일 | 종류 | 검증 대상 |
|------|------|-----------|
| `test/medicine_info_test.dart` | 단위 테스트 | Gemini 응답(`MedicineInfo.fromJson`) 파싱, `Medicine`/`Schedule`/`IntakeLog` `toMap`/`fromMap` 라운드트립 |
| `test/db_service_test.dart` | 단위/통합 테스트 | `sqflite_common_ffi` 기반 실제 SQLite로 `DbService` CRUD·복용 기록·통계 집계(`getWeeklyAdherence`, `getMedicineIntakeCounts`) |
| `test/widget_test.dart` | 위젯/통합 테스트 | 온보딩 → 메인 화면 하단 탭(홈/달력/통계/설정) 전환까지 앱 전체 흐름 |

현재 15개 테스트 전체 통과 (`flutter test` 기준).

## 4. 정적 분석

```bash
flutter analyze
```
`analysis_options.yaml`에서 `flutter_lints` 권장 규칙을 사용하며, 현재 `No issues found!` 상태.

## 5. 테스트 작성 시 주의 사항

- `sqflite_common_ffi`는 `testWidgets`의 FakeAsync 영역 안에서 10초짜리 내부 동기화 락 Timer를 생성한다. `tester.runAsync` 대신 `await tester.pump(const Duration(seconds: 15))`로 FakeAsync 시계를 직접 진행시켜야 타이머가 소진되고 위젯 트리 dispose 시 assertion 실패가 발생하지 않는다 (자세한 내용은 [AGENTS.md](../AGENTS.md) 5절 참고).
- DB 테스트는 매 테스트마다 임시 DB를 새로 열고 `tearDown`에서 닫아 테스트 간 상태가 섞이지 않게 한다.
