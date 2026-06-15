# Setup Guide — MediMate

> 이 문서만 보고 5분 안에 실행할 수 있도록 작성되었습니다.
> Windows / macOS / Linux 모두 동일한 순서로 따라하면 됩니다.

---

## 1. 필요한 도구 버전

| 도구 | 버전 | 확인 명령 |
|------|------|-----------|
| Flutter | 3.41.9 이상 | `flutter --version` |
| Dart | 3.11.5 이상 | `dart --version` |
| Git | 2.x 이상 | `git --version` |
| Android Studio 또는 VS Code | 최신 | — |

---

## 2. Flutter 설치 (미설치 시)

### Windows
```powershell
# C:\flutter_install 에 SDK 압축 해제 후 PATH 등록
[Environment]::SetEnvironmentVariable(
  "Path",
  [Environment]::GetEnvironmentVariable("Path","User") + ";C:\flutter_install\flutter\bin",
  "User"
)
```

### macOS
```bash
brew install --cask flutter
```

### Linux
```bash
sudo snap install flutter --classic
```

설치 후 확인:
```bash
flutter doctor
# No issues found! 가 나올 때까지 안내에 따라 설치
```

---

## 3. 프로젝트 클론

```bash
git clone https://github.com/2024136034-hakcheol/MediMate.git
cd MediMate
```

---

## 4. 의존성 설치

```bash
flutter pub get
```

---

## 5. 환경 변수 설정 (.env)

프로젝트 루트에 `.env` 파일을 생성하고 아래 내용을 입력합니다.

```bash
# .env
GEMINI_API_KEY=여기에_Gemini_API_키_입력
```

**Gemini API 키 발급 방법:**
1. `aistudio.google.com` 접속 (Google 계정 필요)
2. 왼쪽 메뉴 → **Get API key** → **Create API key**
3. 생성된 키(`AIza...`)를 위 `.env`에 붙여넣기

> `.env` 파일은 `.gitignore`에 등록되어 있어 GitHub에 올라가지 않습니다.

---

## 6. 첫 실행

### Android 기기 또는 에뮬레이터
```bash
flutter run
```

### Windows 데스크탑
```bash
flutter run -d windows
```

### 웹 브라우저
```bash
flutter run -d chrome
```

---

## 7. 테스트 & 코드 품질

### 단위/위젯/통합 테스트 실행
```bash
flutter test
```

| 파일 | 종류 | 내용 |
|------|------|------|
| `test/medicine_info_test.dart` | 단위 테스트 | Gemini 응답(`MedicineInfo.fromJson`) 파싱, `Medicine`/`Schedule`/`IntakeLog` `toMap`/`fromMap` 라운드트립 |
| `test/db_service_test.dart` | 단위/통합 테스트 | `sqflite_common_ffi` 기반 실제 SQLite로 `DbService`의 CRUD·복용 기록·통계 집계(`getWeeklyAdherence`, `getMedicineIntakeCounts`) 검증 |
| `test/widget_test.dart` | 통합(위젯) 테스트 | 온보딩 페이지 흐름, 메인 화면 하단 탭(홈/복용 기록/통계/설정) 전환까지 앱 전체 흐름 검증 |

### 정적 분석 (코드 품질)
```bash
flutter analyze
```
`analysis_options.yaml`에서 `flutter_lints` 권장 규칙을 사용하며, 현재 `No issues found!` 상태를 유지한다.

---

## 8. 빌드 & 배포

### Android APK (릴리스 빌드)
```bash
flutter build apk --release
```
- 결과물 경로: `build/app/outputs/flutter-apk/app-release.apk`
- 배포: 위 APK 파일을 GitHub Release에 첨부하거나, 기기에 직접 설치(`adb install`)해 시연한다.

### Windows 데스크탑 빌드 (데모용)
```bash
flutter build windows
```
- 결과물 경로: `build/windows/x64/runner/Release/`

### 배포 단계 요약
1. `flutter analyze` / `flutter test` 통과 확인
2. `flutter build apk --release` 로 릴리스 APK 생성
3. APK를 GitHub Release 또는 로컬 기기에 배포 → 실제 기기에서 카메라 스캔·알림 동작 확인
4. (데스크탑 시연용) `flutter build windows` 로 발표 시연 환경 준비

---

## 9. 문제 해결 (FAQ)

**Q1. `flutter` 명령어를 찾을 수 없다**
```bash
# Flutter bin 경로가 PATH에 없는 것. 터미널을 재시작하거나 아래 실행
export PATH="$PATH:/path/to/flutter/bin"  # macOS/Linux
# Windows: 시스템 환경 변수 → Path에 flutter\bin 추가 후 터미널 재시작
```

**Q2. `.env` 파일이 없다는 오류가 나온다**
```
# 프로젝트 루트에 .env 파일이 있는지 확인
# MediMate/.env 위치에 GEMINI_API_KEY=... 형식으로 저장
```

**Q3. `flutter pub get` 실패 — 의존성 충돌**
```bash
flutter pub upgrade
flutter pub get
```

**Q4. Android 디바이스가 인식되지 않는다**
```bash
# USB 디버깅 활성화 확인 후
flutter devices        # 연결된 기기 목록 확인
adb devices            # Android Debug Bridge 확인
```

**Q5. Windows 빌드 시 Visual Studio 오류**
```bash
flutter doctor -v      # Visual Studio 항목 확인
# Visual Studio 2022 + "C++를 사용한 데스크탑 개발" 워크로드 필요
```
