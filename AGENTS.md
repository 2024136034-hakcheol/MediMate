# AGENTS.md — MediMate AI Agent 운영 가이드

> PillNova 팀의 AI Agent 활용 방식과 본인만의 기법을 정리한 문서

## 1. 사용 AI Agent 도구

| 도구 | 용도 |
|------|------|
| Claude Code (CLI) | 코드 생성, 리팩토링, 문서 작성, 디버깅 |
| Gemini API | 앱 내 약 이미지 인식 및 주의사항 요약 |

---

## 2. 작업 유형별 Agent 활용 패턴

### 코드 생성
```
역할: Flutter 개발자 보조
입력: 기능 요구사항 (PRD 기반)
출력: Dart 코드 + 필요한 pubspec 패키지

예시 프롬프트:
"PRD의 F-01 요구사항을 기반으로 카메라로 이미지를 선택하는
Flutter 화면을 image_picker 패키지를 사용해서 만들어줘.
결과는 base64 문자열로 반환해야 해."
```

### 디버깅
```
역할: 에러 분석 및 수정
입력: 에러 메시지 + 관련 코드
출력: 원인 설명 + 수정된 코드

패턴: 에러 메시지를 그대로 붙여넣기 → 원인과 수정 방법 요청
```

### 문서 작성
```
역할: 기술 문서 작성 보조
입력: 구현된 코드 또는 설계 내용
출력: PRD, WBS, ARCHITECTURE, README 등 마크다운 문서
```

### Gemini API 프롬프트 설계 (앱 내부)
```
역할: 약 정보 추출 프롬프트 엔지니어링
목표: 이미지에서 약 이름·용량·복용법·주의사항을 JSON 배열로 추출 (다중 약 인식 지원)

사용 모델: gemini-2.5-flash (Vision 지원, v1 엔드포인트)
※ 최초 gemini-1.5-flash로 개발했으나 v1에서 지원 종료(404)되어 2.5-flash로 교체 (5절 참고)
```

---

## 3. 본인만의 기법 (PillNova Custom Technique)

### 기법명: PRD-Driven Prompting

**개념:**
Claude Code에 코드를 요청할 때 항상 PRD의 기능 번호(F-01, F-02...)를
기준으로 요청한다. 이렇게 하면 AI가 요구사항 문서와 코드를 연결해서
맥락을 잃지 않고 일관된 코드를 생성한다.

**방법:**
1. 요청 시 항상 해당 PRD 기능 번호를 명시
2. 기존 코드가 있으면 함께 첨부
3. 결과물이 PRD 조건을 만족하는지 확인 요청 포함

**예시:**
```
"PRD F-03 요구사항(로컬 알림, 복용 완료 처리)을 구현해줘.
현재 schedule_service.dart 코드는 아래와 같아. [코드 첨부]
구현 후 F-03의 모든 조건을 만족하는지 체크리스트로 확인해줘."
```

**효과:**
- 기능 누락 방지
- 코드와 문서 간 일관성 유지
- Q&A에서 "왜 이렇게 구현했나요?" 질문에 PRD 번호로 바로 대답 가능

---

## 4. Gemini API 약 인식 프롬프트

앱 내에서 실제로 사용하는 Gemini API 프롬프트 (다중 약 인식 — JSON 배열 반환):

```
당신은 약학 전문가입니다.
첨부된 이미지에 보이는 약을 모두 분석하여 아래 JSON 배열 형식으로 정보를 추출하세요.
약이 여러 종류 보이면 각각을 배열의 항목으로 추가하고, 한 종류만 보이면 항목을 1개만 담은 배열로 반환하세요.
이미지에서 확인할 수 없는 항목은 null로 반환하세요.

[
  {
    "name": "약 이름",
    "dosage": "1회 복용량 (예: 500mg, 1정)",
    "frequency": 1일 복용 횟수 (숫자),
    "duration_days": 복용 기간 (숫자, 일 단위, 없으면 null),
    "timing": "복용 시점 (예: 식후 30분, 취침 전)",
    "cautions": "주요 주의사항 3줄 이내 요약"
  }
]

JSON 배열 형식 외 다른 텍스트는 출력하지 마세요.
```

> 처음에는 단일 JSON 객체를 요구했으나, "사진 한 장에 약이 여러 개면 어떻게 하나"라는
> 질문에서 출발해 배열 형식으로 바꾸고 `analyzeMedicineImage`의 반환 타입을
> `Future<MedicineInfo?>` → `Future<List<MedicineInfo>>` 로 확장했다 (`gemini_service.dart`).

---

## 5. 실패 사례 & 교훈 (LLM Wiki)

| 상황 | 문제 | 해결책 |
|------|------|--------|
| 약 포장 이미지 인식 | 배경이 복잡하면 인식률 저하 | 프롬프트에 "배경을 무시하고 약 포장 텍스트만 집중" 추가 |
| Flutter 코드 생성 | 패키지 버전 불일치로 빌드 오류 | pubspec.yaml을 함께 첨부해서 버전 맞춰달라고 요청 |
| JSON 파싱 오류 | API가 JSON 외 텍스트 포함 | 프롬프트 끝에 "JSON 외 텍스트 출력 금지" 명시 |
| Gemini 모델 404 오류 | `models/gemini-1.5-flash is not found for API version v1` — 모델이 v1 엔드포인트에서 지원 종료됨 | Google `ListModels` API로 사용 가능한 모델을 직접 조회해 `gemini-2.5-flash`로 교체 후 curl로 200 응답 확인 |
| 다중 약 인식 확장 | 사진 한 장에 약이 여러 개 있으면 단일 객체 응답으로는 처리 불가 | 프롬프트를 JSON 배열 반환으로 변경, 인식 결과 개수에 따라 단일 결과는 ResultScreen, 복수 결과는 새 ScanResultListScreen으로 분기 |
| Windows 데스크탑 카메라 | `image_picker`가 Windows에 cameraDelegate를 제공하지 않아 카메라 촬영 불가 | 데스크탑 데모는 갤러리 선택(`ImageSource.gallery`)으로 진행, 실제 기기에서는 카메라 정상 동작 |
| 위젯/통합 테스트 작성 | `sqflite_common_ffi`가 `testWidgets`의 FakeAsync 영역 안에서 10초짜리 내부 동기화 락 Timer를 생성해 "A Timer is still pending even after the widget tree was disposed" assertion 실패 | `tester.runAsync` 대신 `await tester.pump(const Duration(seconds: 15))`로 FakeAsync 시계를 직접 진행시켜 타이머를 소진시킴 → 단위/통합/위젯 테스트 15개 전체 통과 |
| Android APK 릴리스 빌드 — NDK | `[CXX1101] NDK at .../ndk/28.2.13676358 did not have a source.properties file` — `ndkVersion = flutter.ndkVersion` 설정 때문에 AGP가 NDK를 요구했는데, 이전 다운로드가 1KB짜리 `.installer`만 남기고 중단되어 손상되어 있었음 | 손상된 NDK 캐시 디렉터리를 삭제한 뒤 `flutter build apk --release`를 재실행 → AGP가 NDK를 처음부터 다시 내려받아 해결 |
| Android APK 릴리스 빌드 — desugaring | `:app:checkReleaseAarMetadata` 실패 — `flutter_local_notifications`가 core library desugaring 활성화를 요구 | `android/app/build.gradle.kts`의 `compileOptions`에 `isCoreLibraryDesugaringEnabled = true` 추가, `dependencies`에 `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` 추가 → `app-release.apk`(56.5MB) 빌드 성공 |
| 이미지 업로드 성능 | 최신 스마트폰 카메라(4000px급) 원본 이미지를 그대로 Gemini API에 전송하면 응답 지연·페이로드 증가 | `image_picker`의 `maxWidth`/`maxHeight`를 1600, `imageQuality`를 80으로 설정해 다운스케일 후 전송 (`scan_screen.dart`) |

---

## 6. 브랜치 & 커밋 전략

```
main        ← 배포 가능한 안정 버전
dev         ← 개발 통합 브랜치
feature/*   ← 기능별 브랜치 (예: feature/scan-screen)
```

커밋 메시지 형식:
```
feat: 약 스캔 화면 구현 (F-01)
fix: Gemini API JSON 파싱 오류 수정
docs: WBS 일정 업데이트
```
