import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_gap_repair_action_chip.dart';

void main() {
  testWidgets('repair action chip renders compact action chrome', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairActionChip(
            chipKey: const ValueKey('repair-action-chip'),
            label: '2 fixes: Software Development',
            icon: Icons.business_center_outlined,
            color: Colors.blue,
            tooltip: 'Open the next software repair.',
            maxWidth: 180,
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('2 fixes: Software Development'), findsOneWidget);
    expect(find.byIcon(Icons.business_center_outlined), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('repair-action-chip')));

    expect(tapped, isTrue);
  });
}
