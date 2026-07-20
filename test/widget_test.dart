import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dongla_care1/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // اختبار دخان أساسي: يتأكد فقط أن التطبيق يُبنى بدون استثناءات،
    // ويظهر عنوان الشاشة الرئيسية "دنقلا كير" في الـ AppBar.
    expect(find.text('دنقلا كير'), findsOneWidget);
  });
}
