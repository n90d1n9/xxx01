import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_delivery_command_service.dart';
import 'package:kaysir/features/project_management/project/services/project_delivery_saved_lens_service.dart';

void main() {
  test('project delivery saved lenses count and resolve filters', () {
    const commands = [
      ProjectDeliveryCommand(
        id: 'blocked',
        projectId: 'mobile-field-app',
        projectName: 'Mobile Field App',
        title: 'Project is blocked',
        detail: 'Ownership is blocked.',
        level: ProjectDeliveryCommandLevel.critical,
        kind: ProjectDeliveryCommandKind.projectBlocked,
        icon: Icons.block_outlined,
      ),
      ProjectDeliveryCommand(
        id: 'risk',
        projectId: 'retail-modernization',
        projectName: 'Retail Modernization',
        title: 'Security review',
        detail: 'Review needs a control owner.',
        level: ProjectDeliveryCommandLevel.critical,
        kind: ProjectDeliveryCommandKind.risk,
        icon: Icons.health_and_safety_outlined,
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

    final firefight = defaultProjectDeliverySavedCommandLenses.first;
    final budget = defaultProjectDeliverySavedCommandLenses.firstWhere(
      (lens) => lens.id == 'budget-control',
    );
    final counts = countProjectDeliverySavedLenses(commands);

    expect(counts[firefight], 2);
    expect(counts[budget], 1);
    expect(projectDeliverySavedLensForFilter(firefight.filter), firefight);
    expect(
      filterProjectDeliverySavedLens(
        commands: commands,
        lens: budget,
      ).map((command) => command.id),
      ['budget'],
    );
  });

  test('project delivery saved lens profiles expose role lens sets', () {
    final deliveryLead = projectDeliverySavedLensesForProfile(
      ProjectDeliverySavedLensProfile.deliveryLead,
    );
    final financePartner = projectDeliverySavedLensesForProfile(
      ProjectDeliverySavedLensProfile.financePartner,
    );
    final releaseDesk = projectDeliverySavedLensesForProfile(
      ProjectDeliverySavedLensProfile.releaseDesk,
    );

    expect(deliveryLead.map((lens) => lens.id), contains('firefight'));
    expect(financePartner.map((lens) => lens.id), contains('critical-funding'));
    expect(releaseDesk.map((lens) => lens.id), contains('schedule-watch'));
    expect(defaultProjectDeliverySavedCommandLenses, deliveryLead);
  });
}
