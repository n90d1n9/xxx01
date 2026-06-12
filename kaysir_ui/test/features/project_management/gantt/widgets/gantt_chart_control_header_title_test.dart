import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_control_header_title.dart';

void main() {
  testWidgets('gantt control header title renders presentation copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttChartControlHeaderTitle(
            dateRange: DateTimeRange(
              start: DateTime(2026, 5, 1),
              end: DateTime(2026, 5, 30),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Timeline Planning'), findsOneWidget);
    expect(find.text('Full Gantt Chart'), findsOneWidget);
    expect(
      find.text('Interactive schedule canvas for May 1-30.'),
      findsOneWidget,
    );
  });
}
