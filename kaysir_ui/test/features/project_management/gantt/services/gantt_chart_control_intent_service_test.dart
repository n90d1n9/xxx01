import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_control_intent_service.dart';

void main() {
  group('GanttChartControlIntentService', () {
    const service = GanttChartControlIntentService();
    const dispatcher = GanttChartControlIntentDispatcher();

    test('toggles controls from the current expanded state', () {
      expect(service.nextControlsExpanded(controlsExpanded: true), isFalse);
      expect(service.nextControlsExpanded(controlsExpanded: false), isTrue);
    });

    test('expands controls before focusing hidden search', () {
      final result = service.focusSearch(controlsExpanded: false);

      expect(result.shouldExpandControls, isTrue);
      expect(result.shouldSelectSearchText, isTrue);
    });

    test('keeps expanded controls open when focusing visible search', () {
      final result = service.focusSearch(controlsExpanded: true);

      expect(result.shouldExpandControls, isFalse);
      expect(result.shouldSelectSearchText, isTrue);
    });

    test('dispatches hidden search focus after expanding controls', () {
      final operations = <String>[];

      dispatcher.dispatchSearchFocus(
        intent: service.focusSearch(controlsExpanded: false),
        onExpandControls: () => operations.add('expand'),
        onScheduleSearchFocus:
            ({required selectText}) =>
                operations.add('schedule-select-$selectText'),
      );

      expect(operations, ['expand', 'schedule-select-true']);
    });

    test('dispatches visible search focus without expanding controls', () {
      final operations = <String>[];

      dispatcher.dispatchSearchFocus(
        intent: service.focusSearch(controlsExpanded: true),
        onExpandControls: () => operations.add('expand'),
        onScheduleSearchFocus:
            ({required selectText}) =>
                operations.add('schedule-select-$selectText'),
      );

      expect(operations, ['schedule-select-true']);
    });
  });
}
