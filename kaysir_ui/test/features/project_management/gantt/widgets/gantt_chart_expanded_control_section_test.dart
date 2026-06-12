import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_expanded_control_section_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_expanded_control_section.dart';

void main() {
  testWidgets('gantt expanded control section renders heading and children', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GanttChartExpandedControlSection(
            role: GanttChartExpandedControlSectionRole.timeline,
            children: [Text('Timeline child')],
          ),
        ),
      ),
    );

    expect(find.text('Timeline scope'), findsOneWidget);
    expect(
      find.text('Filters, saved views, and viewport jumps'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.travel_explore_outlined), findsOneWidget);
    expect(find.text('Timeline child'), findsOneWidget);
    expect(
      find.byKey(
        GanttChartExpandedControlSection.sectionKey(
          GanttChartExpandedControlSectionRole.timeline,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('gantt expanded control section list spaces visible sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GanttChartExpandedControlSectionList(
            sections: [
              GanttChartExpandedControlSection(
                role: GanttChartExpandedControlSectionRole.presets,
                children: [Text('Preset child')],
              ),
              GanttChartExpandedControlSection(
                role: GanttChartExpandedControlSectionRole.display,
                children: [Text('Display child')],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Focus presets'), findsOneWidget);
    expect(find.text('Canvas display'), findsOneWidget);
    expect(find.text('Preset child'), findsOneWidget);
    expect(find.text('Display child'), findsOneWidget);
  });
}
