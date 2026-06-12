import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_breadcrumbs.dart';

void main() {
  testWidgets('renders breadcrumb labels and separators', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdminBreadcrumbs(items: ['Admin', 'Dashboard'])),
      ),
    );

    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('renders nothing for an empty trail', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AdminBreadcrumbs(items: []))),
    );

    expect(find.byType(SizedBox), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });
}
