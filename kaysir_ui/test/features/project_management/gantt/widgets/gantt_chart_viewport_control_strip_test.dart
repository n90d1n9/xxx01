import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_viewport_control_strip.dart';

void main() {
  testWidgets('gantt chart viewport strip updates density and scale controls', (
    tester,
  ) async {
    var preferences = GanttChartDisplayPreferences.initial;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return GanttChartViewportControlStrip(
                displayPreferences: preferences,
                onChanged: (value) => setState(() => preferences = value),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Viewport'), findsOneWidget);
    expect(find.text('Loose rows - Normal scale'), findsOneWidget);
    expect(
      find.byTooltip(
        'Airy rows maximize breathing room for dense task details.',
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip('Balanced zoom keeps date spacing at the default scale.'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(GanttChartViewportControlStrip.denseRowsChipKey),
    );
    await tester.pumpAndSettle();

    expect(preferences.density, GanttChartDensity.dense);
    expect(find.text('Tight rows - Normal scale'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttChartViewportControlStrip.wideScaleChipKey),
    );
    await tester.pumpAndSettle();

    expect(preferences.timelineZoom, GanttChartTimelineZoom.wide);
    expect(find.text('Tight rows - Open scale'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttChartViewportControlStrip.cozyRowsChipKey),
    );
    await tester.pumpAndSettle();

    expect(preferences.density, GanttChartDensity.cozy);
    expect(find.text('Steady rows - Open scale'), findsOneWidget);
  });
}
