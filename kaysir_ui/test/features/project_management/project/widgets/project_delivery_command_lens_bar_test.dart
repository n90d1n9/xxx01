import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_delivery_command_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_delivery_command_lens_bar.dart';

void main() {
  testWidgets('project delivery command lens bar applies preset filters', (
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
              return ProjectDeliveryCommandLensBar(
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

    expect(find.text('All Commands'), findsOneWidget);
    expect(find.text('Dependencies'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Dependencies'));
    await tester.pump();

    expect(
      filter,
      const ProjectDeliveryCommandFilter(
        kind: ProjectDeliveryCommandKind.dependency,
      ),
    );
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Dependencies'))
          .selected,
      isTrue,
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'All Commands'));
    await tester.pump();

    expect(filter, ProjectDeliveryCommandFilter.empty);
  });
}
