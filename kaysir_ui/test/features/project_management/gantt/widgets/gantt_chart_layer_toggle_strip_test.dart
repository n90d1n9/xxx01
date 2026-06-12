import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_layer_toggle_strip.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  testWidgets('gantt chart layer strip updates dependency focus controls', (
    tester,
  ) async {
    var preferences = GanttChartDisplayPreferences.initial;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return GanttChartLayerToggleStrip(
                displayPreferences: preferences,
                onChanged: (value) => setState(() => preferences = value),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Scope'), findsOneWidget);
    expect(find.text('3 active - Full deps'), findsOneWidget);
    expect(
      preferences.dependencyFocusScope,
      KyGanttDependencyLineFocusScope.chain,
    );

    await tester.tap(
      find.byKey(GanttChartLayerToggleStrip.dependencyFocusScopeUpstreamKey),
    );
    await tester.pumpAndSettle();

    expect(
      preferences.dependencyFocusScope,
      KyGanttDependencyLineFocusScope.upstream,
    );
    expect(find.text('3 active - Upstream deps'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttChartLayerToggleStrip.dependencyFocusChipKey),
    );
    await tester.pumpAndSettle();

    expect(preferences.highlightSelectedDependencies, isFalse);
    expect(find.text('3 active - Focus off'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttChartLayerToggleStrip.dependencyFocusScopeDownstreamKey),
    );
    await tester.pumpAndSettle();

    expect(
      preferences.dependencyFocusScope,
      KyGanttDependencyLineFocusScope.upstream,
    );

    await tester.tap(
      find.byKey(GanttChartLayerToggleStrip.dependencyFocusChipKey),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(GanttChartLayerToggleStrip.dependencyFocusScopeDownstreamKey),
    );
    await tester.pumpAndSettle();

    expect(
      preferences.dependencyFocusScope,
      KyGanttDependencyLineFocusScope.downstream,
    );

    await tester.tap(
      find.byKey(GanttChartLayerToggleStrip.dependencyLinesChipKey),
    );
    await tester.pumpAndSettle();

    expect(preferences.showDependencyLines, isFalse);
    expect(find.text('2 active - Deps hidden'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttChartLayerToggleStrip.dependencyFocusChipKey),
    );
    await tester.pumpAndSettle();

    expect(preferences.highlightSelectedDependencies, isTrue);
  });
}
