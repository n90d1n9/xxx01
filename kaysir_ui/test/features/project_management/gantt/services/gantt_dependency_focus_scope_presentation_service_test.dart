import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_focus_scope_presentation_service.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  test(
    'dependency focus scope presentations stay aligned to package scopes',
    () {
      expect(
        ganttDependencyFocusScopePresentations.map((item) => item.scope),
        KyGanttDependencyLineFocusScope.values,
      );

      final upstream = ganttDependencyFocusScopePresentation(
        KyGanttDependencyLineFocusScope.upstream,
      );

      expect(upstream.label, 'Up');
      expect(upstream.summaryLabel, 'Upstream deps');
      expect(
        upstream.tooltip,
        'Highlights the upstream chain feeding the selected task',
      );
      expect(upstream.icon, Icons.subdirectory_arrow_left_outlined);
    },
  );
}
