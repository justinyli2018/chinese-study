import 'package:flutter_test/flutter_test.dart';

import 'package:chinese_study/main.dart';

void main() {
  testWidgets('Home screen shows the app title', (WidgetTester tester) async {
    await tester.pumpWidget(const ChineseStudyApp());
    await tester.pump();

    expect(find.text('Chinese Study'), findsWidgets);
  });
}
