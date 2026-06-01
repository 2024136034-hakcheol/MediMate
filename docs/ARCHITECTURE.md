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
[Flutter UI Layer]
   ├── ScanScreen       ← 카메라/갤러리로 약 촬영
   ├── ResultScreen     ← AI 인식 결과 확인·수정
   ├── HomeScreen       ← 오늘 복용할 약 목록
   ├── CalendarScreen   ← 복용 기록 달력
   └── MedDetailScreen  ← 약 정보·주의사항
         │
         ▼
[Service Layer]
   ├── GeminiService ──────────────► [External API] (네트워크)
   │                                  └── Gemini API (generativelanguage.googleapis.com)
   │                                        ├── Vision: 이미지 → 약 정보 추출
   │                                        └── Text: 주의사항·부작용 요약
   │
   ├── MedicineService ──┐
   ├── ScheduleService ──┼──────────► [Data Layer] (로컬)
   └── NotificationService ─────────► ├── sqflite (SQLite DB)
                                       │     ├── medicines    ← 약 정보
                                       │     ├── schedules    ← 복용 스케줄
                                       │     └── intake_logs  ← 복용 기록
                                       └── flutter_local_notifications
```

---

## 3. 데이터 흐름

### 약 스캔 → 스케줄 생성 흐름
```
1. 사용자가 카메라로 약 포장지 촬영
2. 이미지를 base64로 인코딩
3. GeminiService → Gemini API 전송
4. API 응답: { name, dosage, frequency, duration, cautions }
5. ResultScreen에서 사용자 확인·수정
6. MedicineService → sqflite에 약 정보 저장
7. ScheduleService → 복용 시간 계산 → 스케줄 저장
8. NotificationService → 각 복용 시간에 로컬 알림 등록
```

### 복용 완료 처리 흐름
```
1. 알림 도착 → 사용자가 "복용 완료" 탭
2. NotificationService → ScheduleService 호출
3. intake_logs 테이블에 복용 기록 저장
4. HomeScreen 갱신
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
- **이유:** 단순 텍스트 추출이 아니라 "1일 3회 식후" 같은 복용법을 의미 단위로 파싱 가능. 주의사항 요약도 동일 API로 처리. **무료 티어 제공 (Gemini 1.5 Flash 기준 하루 1,500회)**
- **트레이드오프:** 네트워크 필요, Google 계정 필요

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
│   │   ├── home_screen.dart
│   │   ├── scan_screen.dart       ← 12주차 구현
│   │   ├── result_screen.dart     ← 12주차 구현
│   │   └── calendar_screen.dart   ← 13주차 구현
│   ├── widgets/                   ← 공통 위젯
│   └── theme/
│       └── app_theme.dart
├── application/
│   └── view_models/               ← 상태 관리
├── domain/
│   ├── entities/
│   │   ├── medicine.dart
│   │   ├── schedule.dart
│   │   └── intake_log.dart
│   └── services/                  ← 비즈니스 로직
└── data/
    ├── api/
    │   └── gemini_service.dart
    ├── local/
    │   └── db_service.dart
    └── repositories/
```
