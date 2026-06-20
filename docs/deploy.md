# Deploy Guide — MediMate

> 명령어를 그대로 복사해서 실행하면 빌드·배포가 끝납니다.

## 1. 배포 전 확인

```bash
flutter analyze
flutter test
```
둘 다 통과해야 빌드를 진행한다.

## 2. Android APK (릴리스)

```bash
flutter build apk --release
```

결과물:
```
build/app/outputs/flutter-apk/app-release.apk
```

기기에 직접 설치:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 3. Windows 데스크탑 (시연용)

```bash
flutter build windows
```

결과물:
```
build/windows/x64/runner/Release/
```

실행:
```bash
build/windows/x64/runner/Release/medimate.exe
```

## 4. 발표 슬라이드 배포 (GitHub Pages)

저장소 루트의 `index.html`이 발표 슬라이드다. GitHub Pages 설정(Settings → Pages → Branch: main, Folder: /)만 켜면 별도 빌드 없이 바로 배포된다.

```
https://<github-id>.github.io/MediMate/
```

## 5. 배포 단계 요약

1. `flutter analyze` / `flutter test` 통과 확인
2. `flutter build apk --release` 로 릴리스 APK 생성
3. APK를 GitHub Release에 첨부하거나 `adb install`로 실기기에 배포
4. (시연용) `flutter build windows` 로 데스크탑 빌드 준비
5. GitHub Pages로 `index.html` 슬라이드 배포

## 6. 배포 후 점검

- [ ] APK 실기기 설치 후 카메라 스캔 → 알림 동작 확인
- [ ] Windows exe 실행 후 갤러리 선택 플로우 확인 (Windows는 카메라 미지원, [AGENTS.md](../AGENTS.md) 5절 참고)
- [ ] `.env`가 빌드 산출물에 포함되지 않았는지 확인 (`.gitignore`로 커밋 자체가 차단됨)
