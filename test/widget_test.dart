import 'package:flutter_test/flutter_test.dart';

import 'package:pettory/main.dart';

void main() {
  testWidgets('Bottom navigation shows all three tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const PetLogApp());

    expect(find.text('홈'), findsOneWidget);
    expect(find.text('다이어리'), findsOneWidget);
    expect(find.text('펫 프로필'), findsOneWidget);

    await tester.tap(find.text('펫 프로필'));
    await tester.pumpAndSettle();

    expect(find.text('몽이'), findsOneWidget);
  });
}
