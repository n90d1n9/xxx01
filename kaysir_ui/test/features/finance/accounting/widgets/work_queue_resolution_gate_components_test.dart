import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/services/work_queue_resolution_gate_service.dart';
import 'package:kaysir/features/finance/accounting/widgets/work_queue_resolution_gate_components.dart';

void main() {
  testWidgets('renders disabled resolution gate with blockers', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueResolutionGatePanel(
            gate: AccountingWorkspaceWorkQueueResolutionGate(
              canClear: false,
              isCleared: false,
              statusLabel: 'Waiting on clearance',
              detailLabel: 'Resolve Release or close gate before clearing',
              nextActionLabel: 'Next: Release or close gate',
              blockers: const ['Release or close gate'],
            ),
            onClear: () {},
          ),
        ),
      ),
    );

    expect(find.text('Resolution gate'), findsOneWidget);
    expect(find.text('Waiting on clearance'), findsOneWidget);
    expect(find.text('Release or close gate'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey('accounting-work-queue-mark-cleared')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('enables mark cleared when resolution gate is ready', (
    tester,
  ) async {
    var cleared = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueResolutionGatePanel(
            gate: AccountingWorkspaceWorkQueueResolutionGate(
              canClear: true,
              isCleared: false,
              statusLabel: 'Ready to clear',
              detailLabel: 'All clearance steps are ready',
              nextActionLabel: 'Mark queue cleared',
              blockers: const [],
            ),
            onClear: () => cleared = true,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-mark-cleared')),
    );
    await tester.pump();

    expect(cleared, isTrue);
  });
}
