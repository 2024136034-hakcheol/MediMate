# 아키텍처 & ADR — MediMate

## 1. 시스템 개요

MediMate는 백엔드 서버 없이 기기 로컬에서 동작하는 오프라인 우선(Offline-First) 모바일 앱이다.
외부 네트워크는 Gemini API 호출 시에만 사용한다.

---

## 2. 아키텍처 다이어그램

```
[사용자]
   │
   ▼
[Flutter UI Layer]  (lib/presentation/screens)
   ├── OnboardingScreen      ← 최초 실행 안내
   ├── MainScreen            ← 하단 탭 네비게이션 (Home/Calendar/Statistics/Settings)
   ├── HomeScreen            ← 오늘 복용할 약 목록
   ├── ScanScreen            ← 카메라/갤러리로 약 포장 촬영
   ├── ResultScreen          ← AI 인식 결과 확인·수정·저장 (단일 약)
   ├── ScanResultListScreen  ← 한 사진에서 여러 약이 인식된 경우 목록·개별 등록
   ├── CalendarScreen        ← 날짜별 복용 기록 달력
   ├── StatisticsScreen      ← 주간 복용률·약별 누적 복용 통계
   ├── MedicineDetailScreen  ← 약 정보·주의사항 상세
   └── SettingsScreen        ← 환경설정
         │
         ▼
[Data / Service Layer]  (lib/data)
   ├── GeminiService (api/) ─────────► [External API] (네트워크)
   │                                     └── Gemini API (generativelanguage.googleapis.com)
   │                                           └── gemini-2.5-flash (Vision): 이미지 → 약 정보 배열 추출
   │
   ├── DbService (local/) ───────────► [Data Layer] (로컬)
   │                                     └── sqflite (SQLite DB)
   │                                           ├── medicines    ← 약 정보
   │                                           ├── schedules    ← 복용 스케줄
   │                                           └── intake_logs  ← 복용 기록
   │
   └── NotificationService (local/) ─► flutter_local_notifications
```

> 별도의 MedicineService/ScheduleService 계층 없이 `DbService`가 약·스케줄·복용 기록의
> CRUD와 통계 집계 쿼리(`getWeeklyAdherence`, `getMedicineIntakeCounts`)를 함께 담당한다.
> (구조를 단순하게 유지해 1인 개발 범위에서 유지보수 비용을 낮추기 위한 선택)

---

## 3. 데이터 흐름

### 약 스캔 → 스케줄 생성 흐름 (다중 약 인식 포함)
```
1. 사용자가 카메라/갤러리에서 약 포장지 사진을 선택
2. 이미지를 base64로 인코딩
3. GeminiService → Gemini API(gemini-2.5-flash) 전송
4. API 응답: JSON 배열 [{ name, dosage, frequency, duration_days, timing, cautions }, ...]
   - 약이 1종이면 항목 1개, 여러 종이면 항목 여러 개로 반환
5-A. 인식 결과가 1건 → ResultScreen으로 바로 이동, 확인·수정 후 저장
5-B. 인식 결과가 2건 이상 → ScanResultListScreen에서 항목별로 ResultScreen을 열어
     하나씩 확인·수정 후 개별 저장 (저장 완료 항목은 체크 표시)
6. ResultScreen 저장 시 → DbService가 medicines·schedules 테이블에 기록
7. 복용 횟수(frequency)만큼 시간 분배 → 각 시간에 NotificationService로 로컬 알림 등록
```

### 복용 완료 처리 흐름
```
1. 알림 도착 또는 HomeScreen에서 "복용 완료" 탭
2. DbService.insertIntakeLog → intake_logs 테이블에 복용 기록 저장 (status='taken')
3. HomeScreen·CalendarScreen·StatisticsScreen이 최신 기록을 반영해 갱신
```

### 통계 집계 흐름
```
1. StatisticsScreen 진입 시 DbService 호출
2. getWeeklyAdherence() → 최근 7일간 (예정 복용 횟수 vs 실제 복용 횟수) 집계
3. getMedicineIntakeCounts() → 약별 누적 복용 횟수를 내림차순 집계
4. fl_chart(BarChart)와 진행률 위젯으로 시각화
```

---

## 4. DB 스키마

```sql
-- 약 정보
CREATE TABLE medicines (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  name      TEXT NOT NULL,
  dosage    TEXT,           -- 예: "500mg"
  cautions  TEXT,           -- AI 요약 주의사항
  created_at TEXT NOT NULL
);

-- 복용 스케줄 (1일 N회면 N개 행으로 저장, 행 하나 = 복용 시간 하나)
CREATE TABLE schedules (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  medicine_id  INTEGER NOT NULL,
  time         TEXT NOT NULL,  -- 예: "08:00"
  start_date   TEXT NOT NULL,
  end_date     TEXT,
  is_active    INTEGER DEFAULT 1,
  FOREIGN KEY (medicine_id) REFERENCES medicines(id)
);

-- 복용 기록
CREATE TABLE intake_logs (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  schedule_id INTEGER NOT NULL,
  taken_at    TEXT NOT NULL,
  status      TEXT NOT NULL, -- 'taken' | 'skipped'
  FOREIGN KEY (schedule_id) REFERENCES schedules(id)
);
```

---

## 5. ADR (Architecture Decision Records)

### ADR-01. Flutter 선택
- **결정:** React Native 대신 Flutter 사용
- **이유:** Dart 언어의 강타입 특성, 카메라 플러그인 생태계 성숙도, 단일 코드베이스로 Android/iOS 동시 지원
- **트레이드오프:** Dart 학습 비용 발생

### ADR-02. Gemini API (Vision) 선택
- **결정:** OCR 라이브러리 대신 Google Gemini API로 약 정보 추출
- **이유:** 단순 텍스트 추출이 아니라 "1일 3회 식후" 같은 복용법을 의미 단위로 파싱 가능. 주의사항 요약도 동일 API로 처리. 무료 티어로 개발·데모에 충분
- **트레이드오프:** 네트워크 필요, Google 계정 필요
- **추가 결정 (모델 변경):** 최초 `gemini-1.5-flash`로 개발했으나, 해당 모델이 v1 엔드포인트에서
  지원 종료(404 `models/gemini-1.5-flash is not found for API version v1`)되어
  **`gemini-2.5-flash`** 로 교체. 응답 형식도 단일 JSON 객체에서 **JSON 배열**로 변경해
  사진 한 장에 약이 여러 개 보일 때 각각을 인식하도록 확장 (자세한 내용은 [AGENTS.md](../AGENTS.md) 5절 참고)

### ADR-03. sqflite (SQLite) 선택
- **결정:** Firebase Firestore 대신 로컬 SQLite 사용
- **이유:** 서버 없이 완전 오프라인 동작, 개인 건강 데이터를 외부로 전송하지 않음, 설정 복잡도 최소화
- **트레이드오프:** 기기 간 동기화 불가 (MVP 범위 외)

### ADR-04. flutter_local_notifications 선택
- **결정:** FCM(Firebase Cloud Messaging) 대신 로컬 알림 사용
- **이유:** 서버 없이 알림 동작, 오프라인에서도 알림 보장
- **트레이드오프:** 앱 삭제 시 알림 데이터 소실

---

## 6. 폴더 구조

```
lib/
├── main.dart
├── app.dart
├── presentation/
│   ├── screens/
│   │   ├── onboarding_screen.dart
│   │   ├── main_screen.dart            ← 하단 탭 네비게이션
│   │   ├── home_screen.dart
│   │   ├── scan_screen.dart
│   │   ├── result_screen.dart
│   │   ├── scan_result_list_screen.dart ← 다중 약 인식 결과 목록
│   │   ├── calendar_screen.dart
│   │   ├── statistics_screen.dart       ← 복용률·통계 (fl_chart)
│   │   ├── medicine_detail_screen.dart
│   │   └── settings_screen.dart
│   └── theme/
│       └── app_theme.dart
├── domain/
│   └── entities/
│       ├── medicine.dart
│       ├── schedule.dart
│       └── intake_log.dart
└── data/
    ├── api/
    │   └── gemini_service.dart    ← Gemini API 연동, MedicineInfo 모델
    └── local/
        ├── db_service.dart        ← sqflite CRUD + 통계 집계 쿼리
        └── notification_service.dart
```
