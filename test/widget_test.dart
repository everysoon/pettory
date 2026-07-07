import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pettory/screens/main_shell.dart';
import 'package:pettory/theme.dart';

void main() {
  testWidgets('Bottom navigation shows all four tabs', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const MainShell()));

    final bottomNav = find.byType(BottomNavigationBar);
    expect(find.descendant(of: bottomNav, matching: find.text('홈')), findsOneWidget);
    expect(find.descendant(of: bottomNav, matching: find.text('다이어리')), findsOneWidget);
    expect(find.descendant(of: bottomNav, matching: find.text('펫 프로필')), findsOneWidget);
    expect(find.descendant(of: bottomNav, matching: find.text('마이페이지')), findsOneWidget);

    await tester.tap(find.descendant(of: bottomNav, matching: find.text('펫 프로필')));
    await tester.pumpAndSettle();

    expect(find.text('몽이'), findsOneWidget);
  });
}
