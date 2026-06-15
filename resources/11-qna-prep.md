# Q&A 대비 질문 모음

## 단골 질문 & 답변

**Q1. 왜 Flutter를 선택했나요?**
→ ADR-0001 참조. 단일 코드베이스로 Android/iOS 동시 지원, 필요한 플러그인(카메라, 알림, SQLite)이 모두 안정적으로 존재합니다.

**Q2. 이 화면의 데이터는 어디서 오나요?**
→ 아키텍처 참조. 약 정보는 Gemini API(외부), 복용 기록은 기기 내 SQLite(로컬)에서 옵니다.

**Q3. 지금 가장 큰 문제는?**
→ WBS 위험 체크리스트 R-04 참조. Gemini API 호출 시 네트워크 필요 — 오프라인 시 목업 데이터로 대체하는 방식으로 대비 중입니다.

**Q4. 어디서부터 어디까지 AI가 만들었나요?**
→ 솔직하게: 코드 초안은 Claude Code(AI Agent)가 생성했고, 저는 구조 검토·오류 수정·PRD 조건 충족 여부를 확인했습니다.

**Q5. 본인이 직접 짠 부분은 어떤 거예요?**
→ 솔직하게: 아키텍처 설계(레이어 구분), Gemini API 프롬프트 설계, DB 스키마 결정, 각 코드의 검토·수정을 직접 했습니다.

---

## ADR 관련 질문

**Q6. Gemini API를 안 쓰면 어떻게 했을 것 같나요? (ADR-02)**
→ ARCHITECTURE.md ADR-02 참조. OCR 라이브러리로 텍스트만 추출할 수도 있지만, "1일 3회 식후"처럼 의미 단위로 복용법을 파싱하려면 LLM 기반 Vision API가 필요했습니다. 무료 티어로 개발·데모가 가능한 점도 고려했습니다.

**Q7. Gemini 모델을 중간에 바꾼 이유는?**
→ ARCHITECTURE.md ADR-02 추가 결정 / AGENTS.md 5절 참조. 처음 사용한 `gemini-1.5-flash`가 v1 엔드포인트에서 지원 종료되어 404 오류가 발생했습니다. Google `ListModels` API로 사용 가능한 모델을 직접 조회해 `gemini-2.5-flash`로 교체했고, 동시에 응답 형식을 단일 JSON 객체에서 JSON 배열로 바꿔 사진 한 장에 여러 약이 있을 때도 인식하도록 확장했습니다.

**Q8. 서버(백엔드)는 왜 없나요? 데이터 동기화는 안 되나요? (ADR-03)**
→ ARCHITECTURE.md ADR-03 참조. 개인 건강 데이터를 외부 서버로 보내지 않고 기기 내부 SQLite에만 저장하도록 설계했습니다. 트레이드오프로 기기 간 동기화는 안 되며, 이는 MVP 범위 밖으로 명시했습니다.

**Q9. 알림은 인터넷이 없어도 오나요? (ADR-04)**
→ ARCHITECTURE.md ADR-04 참조. `flutter_local_notifications`로 기기에서 직접 예약하는 로컬 알림이라 오프라인에서도 정상 동작합니다. 다만 앱을 삭제하면 예약된 알림도 함께 사라집니다.

---

## 테스트 / 빌드 / 배포 관련 질문

**Q10. 테스트는 어떻게 작성했나요?**
→ `flutter test`로 단위·통합·위젯 테스트 3개 파일(15개 테스트)을 작성해 전체 통과 상태입니다. `medicine_info_test.dart`는 Gemini 응답 파싱과 엔티티 직렬화를, `db_service_test.dart`는 `sqflite_common_ffi` 기반 실제 SQLite로 CRUD·복용 기록·통계 집계를, `widget_test.dart`는 온보딩부터 메인 화면 탭 전환까지 앱 전체 흐름을 검증합니다. (docs/setup.md 7절 참고)

**Q11. 테스트 작성하면서 어려웠던 점은?**
→ `sqflite_common_ffi`가 위젯 테스트의 FakeAsync 영역 안에서 10초짜리 내부 타이머를 생성해 "Timer is still pending" 오류가 났습니다. `tester.pump(Duration(seconds: 15))`로 FakeAsync 시계를 직접 진행시켜 해결했습니다. (AGENTS.md 5절 LLM Wiki 참고)

**Q12. 코드 품질은 어떻게 관리했나요?**
→ `analysis_options.yaml`에서 `flutter_lints` 권장 규칙을 적용했고, `flutter analyze` 결과 "No issues found!"를 유지하고 있습니다.

**Q13. APK는 실제로 빌드되나요? 배포는 어떻게 하나요?**
→ `flutter build apk --release`로 릴리스 APK를 빌드했습니다. (docs/setup.md 8절 참고) 결과물은 `build/app/outputs/flutter-apk/app-release.apk`이며, GitHub Release에 첨부하거나 `adb install`로 실기기에 설치해 시연합니다.

**Q14. 빌드하면서 문제는 없었나요?**
→ 두 가지 문제가 있었습니다. 첫째, NDK 캐시가 손상되어 `[CXX1101] NDK ... did not have a source.properties file` 오류가 났는데, 손상된 NDK 캐시 디렉터리를 삭제하고 다시 빌드하니 AGP가 정상적으로 재다운로드하며 해결됐습니다. 둘째, `flutter_local_notifications`가 core library desugaring을 요구해 `checkReleaseAarMetadata` 단계에서 실패했는데, `build.gradle.kts`에 `isCoreLibraryDesugaringEnabled = true`와 `desugar_jdk_libs` 의존성을 추가해 해결했습니다. 최종적으로 56.5MB 크기의 `app-release.apk` 빌드에 성공했습니다. (AGENTS.md 5절 LLM Wiki 참고)

**Q15. 성능 최적화한 부분이 있나요?**
→ 카메라/갤러리에서 선택한 원본 이미지(4000px급)를 그대로 Gemini API에 보내면 응답이 느리고 페이로드도 큽니다. `image_picker`의 `maxWidth`/`maxHeight`를 1600, `imageQuality`를 80으로 설정해 다운스케일 후 전송하도록 개선했습니다 (`scan_screen.dart`).
