import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_date_range_editor.dart';

void main() {
  testWidgets('project form date range editor renders duration copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectFormDateRangeEditor(
            startDate: DateTime(2026, 6),
            endDate: DateTime(2026, 6, 12),
            onStartChanged: (_) {},
            onEndChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Start date'), findsOneWidget);
    expect(find.text('Jun 1, 2026'), findsOneWidget);
    expect(find.text('End date'), findsOneWidget);
    expect(find.text('Jun 12, 2026 - 12 days'), findsOneWidget);
  });
}
