import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:medimate/app.dart';
import 'package:medimate/presentation/screens/onboarding_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('온보딩 화면에서 페이지를 넘기면 마지막 페이지에서 "시작하기" 버튼이 표시된다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    expect(find.text('약 포장을 찍으면\n끝입니다'), findsOneWidget);
    expect(find.text('다음'), findsOneWidget);

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.text('AI가 약 정보를\n자동으로 분석합니다'), findsOneWidget);

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.text('복용 시간에 딱\n맞춰 알려드립니다'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
  });

  testWidgets('온보딩 완료 후 메인 화면 하단 탭이 모두 표시되고 전환된다', (tester) async {
    await tester.pumpWidget(const MediMateApp(onboardingDone: true));

    // 각 탭(Home/Calendar/Statistics)의 DbService(sqflite_common_ffi) 비동기 로딩 및
    // 내부 동기화 락 타이머가 정리될 때까지 fake clock을 충분히 진행시킨다.
    await tester.pump(const Duration(seconds: 15));

    expect(find.text('MediMate'), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('복용 기록'), findsOneWidget);
    expect(find.text('통계'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);

    await tester.tap(find.text('통계'));
    await tester.pump(const Duration(seconds: 15));

    expect(find.text('복용 통계'), findsOneWidget);

    // 종료 전 남은 타이머를 모두 정리
    await tester.pump(const Duration(seconds: 15));
  });
}
