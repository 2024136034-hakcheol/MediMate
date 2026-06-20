# 보안 체크리스트

> 발표 직전 점검. 모든 항목 코드/저장소를 직접 확인해 통과시켰다.

| # | 항목 | 확인 방법 | 결과 |
|---|------|-----------|------|
| 1 | API 키가 코드에 하드코딩되지 않았는가 | `grep -rn "AIza" lib/` → 매치 없음, `dotenv.env['GEMINI_API_KEY']`로만 참조 | ✅ |
| 2 | `.env`가 저장소에 커밋되지 않았는가 | `.gitignore`에 `.env` 등록, `git ls-files \| grep env` → 결과 없음 | ✅ |
| 3 | SQL 인젝션 위험이 없는가 | `db_service.dart`의 모든 `rawQuery`/`query`/`delete`가 `?` + `whereArgs` 파라미터 바인딩 사용, 문자열 보간으로 사용자 입력을 SQL에 직접 삽입하지 않음 | ✅ |
| 4 | 외부 통신이 HTTPS인가 | `gemini_service.dart`의 엔드포인트가 `https://generativelanguage.googleapis.com` | ✅ |
| 5 | 사용자 건강 데이터가 외부로 전송되지 않는가 | 약 정보·복용 기록은 기기 로컬 SQLite에만 저장 (ADR-03), 외부 전송은 스캔 시점 Gemini API 호출(이미지 1장)뿐 | ✅ |
| 6 | 불필요한 권한을 요청하지 않는가 | `image_picker`만 사용(카메라/갤러리 접근), 위치·연락처 등 민감 권한 요청 없음 | ✅ |
| 7 | 빌드 산출물(APK)에 `.env`가 포함되지 않는가 | `flutter_dotenv`는 런타임에 `.env`를 asset으로 로드하므로, 배포 전 `.env`가 실제 값으로 채워진 채 `pubspec.yaml`의 `assets`에 등록되어 있다면 APK 안에 포함됨 → 배포용 키는 별도 관리하거나 데모 직전에만 채워서 빌드 | ⚠️ 주의 |
| 8 | 의존성에 알려진 취약점이 없는가 | `flutter pub outdated` 기준 메이저 패키지(`sqflite`, `flutter_local_notifications`, `image_picker`, `flutter_dotenv`) 모두 최신 안정 버전 사용 | ✅ |

## 7번 항목 비고

`pubspec.yaml`에 `.env`를 asset으로 등록해 두면(`flutter_dotenv` 표준 사용법) 릴리스 APK 빌드 시 `.env` 내용이 그대로 패키징된다. 즉 APK를 디컴파일하면 API 키가 노출될 수 있다. 데모용 빌드이므로 허용 가능한 리스크로 보되, 발표 후 다음 중 하나를 적용하는 것을 권장한다.
- 발표 후 해당 Gemini API 키를 재발급(rotate)한다
- 또는 `--dart-define`으로 빌드 시점에 키를 주입하고 `.env`는 asset에서 제외한다
