import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_control_header_layout_service.dart';

void main() {
  group('GanttChartControlHeaderLayoutService', () {
    const service = GanttChartControlHeaderLayoutService();

    test('uses compact header actions below breakpoint', () {
      final compact = service.layoutFor(
        viewportSize: const Size(640, 900),
        hasActiveFocus: false,
      );
      final wide = service.layoutFor(
        viewportSize: const Size(900, 900),
        hasActiveFocus: false,
      );

      expect(compact.useCompactHeaderActions, isTrue);
      expect(wide.useCompactHeaderActions, isFalse);
    });

    test('calculates relaxed and focused expanded control heights', () {
      final relaxed = service.layoutFor(
        viewportSize: const Size(900, 700),
        hasActiveFocus: false,
      );
      final focused = service.layoutFor(
        viewportSize: const Size(900, 700),
        hasActiveFocus: true,
      );

      expect(relaxed.expandedControlsMaxHeight, closeTo(224, 0.001));
      expect(focused.expandedControlsMaxHeight, closeTo(196, 0.001));
    });

    test('clamps expanded control heights for short and tall viewports', () {
      final short = service.layoutFor(
        viewportSize: const Size(900, 360),
        hasActiveFocus: false,
      );
      final tall = service.layoutFor(
        viewportSize: const Size(900, 1200),
        hasActiveFocus: false,
      );

      expect(
        short.expandedControlsMaxHeight,
        GanttChartControlHeaderLayoutService.minExpandedControlsHeight,
      );
      expect(
        tall.expandedControlsMaxHeight,
        GanttChartControlHeaderLayoutService.maxExpandedControlsHeight,
      );
    });
  });
}
