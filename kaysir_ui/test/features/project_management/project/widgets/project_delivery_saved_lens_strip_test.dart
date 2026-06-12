import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_delivery_command_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_delivery_saved_lens_strip.dart';

void main() {
  testWidgets('project delivery saved lens strip applies saved filters', (
    tester,
  ) async {
    const commands = [
      ProjectDeliveryCommand(
        id: 'dependency',
        projectId: 'mobile-field-app',
        projectName: 'Mobile Field App',
        title: 'API dependency',
        detail: 'Dependency is waiting.',
        level: ProjectDeliveryCommandLevel.warning,
        kind: ProjectDeliveryCommandKind.dependency,
        icon: Icons.link_rounded,
      ),
      ProjectDeliveryCommand(
        id: 'budget',
        projectId: 'warehouse-automation',
        projectName: 'Warehouse Automation',
        title: 'Budget pressure',
        detail: 'Budget is ahead of progress.',
        level: ProjectDeliveryCommandLevel.warning,
        kind: ProjectDeliveryCommandKind.budget,
        icon: Icons.account_balance_wallet_outlined,
      ),
    ];
    var filter = ProjectDeliveryCommandFilter.empty;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ProjectDeliverySavedLensStrip(
                commands: commands,
                filter: filter,
                onFilterChanged:
                    (value) => setState(() {
                      filter = value;
                    }),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Saved Lenses'), findsOneWidget);
    expect(find.text('Budget Control'), findsOneWidget);
    expect(find.text('Dependency Desk'), findsOneWidget);

    await tester.tap(find.text('Budget Control'));
    await tester.pumpAndSettle();

    expect(
      filter,
      const ProjectDeliveryCommandFilter(
        kind: ProjectDeliveryCommandKind.budget,
      ),
    );
  });
}
