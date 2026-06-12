import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_delivery_command_lens_service.dart';
import 'package:kaysir/features/project_management/project/services/project_delivery_command_service.dart';

void main() {
  test('project delivery command lenses filter and count commands', () {
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
      ProjectDeliveryCommand(
        id: 'risk',
        projectId: 'retail-modernization',
        projectName: 'Retail Modernization',
        title: 'Security review',
        detail: 'Review needs a new control owner.',
        level: ProjectDeliveryCommandLevel.critical,
        kind: ProjectDeliveryCommandKind.risk,
        icon: Icons.health_and_safety_outlined,
      ),
    ];

    final counts = countProjectDeliveryCommandLenses(commands);

    expect(counts[ProjectDeliveryCommandLens.all], 4);
    expect(counts[ProjectDeliveryCommandLens.criticalNow], 2);
    expect(counts[ProjectDeliveryCommandLens.blockers], 1);
    expect(counts[ProjectDeliveryCommandLens.dependencies], 1);
    expect(counts[ProjectDeliveryCommandLens.budget], 1);
    expect(
      filterProjectDeliveryCommandLens(
        commands: commands,
        lens: ProjectDeliveryCommandLens.risks,
      ).map((command) => command.id),
      ['risk'],
    );
  });

  test('project delivery command lenses resolve matching filters', () {
    expect(
      projectDeliveryCommandLensForFilter(
        const ProjectDeliveryCommandFilter(
          level: ProjectDeliveryCommandLevel.critical,
        ),
      ),
      ProjectDeliveryCommandLens.criticalNow,
    );
    expect(
      projectDeliveryCommandLensForFilter(
        const ProjectDeliveryCommandFilter(
          level: ProjectDeliveryCommandLevel.watch,
          kind: ProjectDeliveryCommandKind.budget,
        ),
      ),
      isNull,
    );
  });
}
