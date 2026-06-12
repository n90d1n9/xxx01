import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_header_title.dart';

void main() {
  testWidgets('admin header title renders page and subtitle', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdminHeaderTitle(title: 'Dashboard')),
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Overview and daily operations'), findsOneWidget);
  });
}
