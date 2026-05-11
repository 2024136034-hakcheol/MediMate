# ADR-0001 — 모바일 프레임워크 선택

- **날짜:** 2026-05-11
- **상태:** 확정

## 배경

MediMate는 카메라 촬영, 로컬 알림, SQLite 저장이 필요한 모바일 앱이다.
개발 인원이 2명이므로 Android/iOS를 따로 개발하기보다 단일 코드베이스가 유리하다.
주요 후보는 Flutter와 React Native였다.

## 결정

**Flutter (Dart)** 를 선택한다.

## 대안

| 대안 | 검토 결과 |
|------|-----------|
| React Native | JavaScript 생태계 익숙하나 카메라·알림 플러그인 안정성이 Flutter보다 낮음 |
| Android Native (Kotlin) | 성능 최고이나 iOS 미지원, 개발 공수 2배 |
| iOS Native (Swift) | Android 미지원, 팀 내 Swift 경험 없음 |

## 결과

- 단일 코드베이스로 Android·iOS 동시 지원
- `image_picker`, `flutter_local_notifications`, `sqflite` 등 필요한 플러그인이 모두 Flutter pub.dev에 존재하고 관리 활성화 상태
- Dart 학습 비용 발생하지만 Claude Code로 보일러플레이트 생성하여 보완
