import 'package:flutter/material.dart';

import 'project_delivery_command_service.dart';

enum ProjectDeliverySavedLensProfile {
  deliveryLead,
  financePartner,
  releaseDesk,
}

class ProjectDeliverySavedCommandLens {
  const ProjectDeliverySavedCommandLens({
    required this.id,
    required this.label,
    required this.description,
    required this.filter,
    required this.icon,
  });

  final String id;
  final String label;
  final String description;
  final ProjectDeliveryCommandFilter filter;
  final IconData icon;

  @override
  bool operator ==(Object other) {
    return other is ProjectDeliverySavedCommandLens &&
        other.id == id &&
        other.label == label &&
        other.description == description &&
        other.filter == filter &&
        other.icon == icon;
  }

  @override
  int get hashCode => Object.hash(id, label, description, filter, icon);
}

extension ProjectDeliverySavedLensProfilePresentation
    on ProjectDeliverySavedLensProfile {
  String get label {
    switch (this) {
      case ProjectDeliverySavedLensProfile.deliveryLead:
        return 'Delivery Lead';
      case ProjectDeliverySavedLensProfile.financePartner:
        return 'Finance Partner';
      case ProjectDeliverySavedLensProfile.releaseDesk:
        return 'Release Desk';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectDeliverySavedLensProfile.deliveryLead:
        return Icons.account_tree_outlined;
      case ProjectDeliverySavedLensProfile.financePartner:
        return Icons.account_balance_wallet_outlined;
      case ProjectDeliverySavedLensProfile.releaseDesk:
        return Icons.rocket_launch_outlined;
    }
  }
}

const defaultProjectDeliverySavedCommandLenses =
    deliveryLeadProjectDeliverySavedCommandLenses;

const deliveryLeadProjectDeliverySavedCommandLenses = [
  ProjectDeliverySavedCommandLens(
    id: 'firefight',
    label: 'Firefight',
    description: 'Critical recovery queue',
    filter: ProjectDeliveryCommandFilter(
      level: ProjectDeliveryCommandLevel.critical,
    ),
    icon: Icons.local_fire_department_outlined,
  ),
  ProjectDeliverySavedCommandLens(
    id: 'dependency-desk',
    label: 'Dependency Desk',
    description: 'Blocked and waiting handoffs',
    filter: ProjectDeliveryCommandFilter(
      kind: ProjectDeliveryCommandKind.dependency,
    ),
    icon: Icons.hub_outlined,
  ),
  ProjectDeliverySavedCommandLens(
    id: 'budget-control',
    label: 'Budget Control',
    description: 'Spend pressure by project',
    filter: ProjectDeliveryCommandFilter(
      kind: ProjectDeliveryCommandKind.budget,
    ),
    icon: Icons.savings_outlined,
  ),
  ProjectDeliverySavedCommandLens(
    id: 'milestone-watch',
    label: 'Milestone Watch',
    description: 'Near-term delivery dates',
    filter: ProjectDeliveryCommandFilter(
      kind: ProjectDeliveryCommandKind.milestone,
    ),
    icon: Icons.outlined_flag_rounded,
  ),
  ProjectDeliverySavedCommandLens(
    id: 'risk-sweep',
    label: 'Risk Sweep',
    description: 'Escalated delivery risks',
    filter: ProjectDeliveryCommandFilter(kind: ProjectDeliveryCommandKind.risk),
    icon: Icons.health_and_safety_outlined,
  ),
];

const financePartnerProjectDeliverySavedCommandLenses = [
  ProjectDeliverySavedCommandLens(
    id: 'budget-control',
    label: 'Budget Control',
    description: 'Spend pressure by project',
    filter: ProjectDeliveryCommandFilter(
      kind: ProjectDeliveryCommandKind.budget,
    ),
    icon: Icons.savings_outlined,
  ),
  ProjectDeliverySavedCommandLens(
    id: 'critical-funding',
    label: 'Critical Funding',
    description: 'Critical items needing finance cover',
    filter: ProjectDeliveryCommandFilter(
      level: ProjectDeliveryCommandLevel.critical,
    ),
    icon: Icons.priority_high_rounded,
  ),
  ProjectDeliverySavedCommandLens(
    id: 'risk-reserve',
    label: 'Risk Reserve',
    description: 'Risk items that can affect forecast',
    filter: ProjectDeliveryCommandFilter(kind: ProjectDeliveryCommandKind.risk),
    icon: Icons.health_and_safety_outlined,
  ),
];

const releaseDeskProjectDeliverySavedCommandLenses = [
  ProjectDeliverySavedCommandLens(
    id: 'release-blockers',
    label: 'Release Blockers',
    description: 'Blocked delivery work',
    filter: ProjectDeliveryCommandFilter(
      level: ProjectDeliveryCommandLevel.critical,
      kind: ProjectDeliveryCommandKind.projectBlocked,
    ),
    icon: Icons.block_outlined,
  ),
  ProjectDeliverySavedCommandLens(
    id: 'dependency-desk',
    label: 'Dependency Desk',
    description: 'Blocked and waiting handoffs',
    filter: ProjectDeliveryCommandFilter(
      kind: ProjectDeliveryCommandKind.dependency,
    ),
    icon: Icons.hub_outlined,
  ),
  ProjectDeliverySavedCommandLens(
    id: 'schedule-watch',
    label: 'Schedule Watch',
    description: 'Tasks with schedule pressure',
    filter: ProjectDeliveryCommandFilter(
      kind: ProjectDeliveryCommandKind.schedule,
    ),
    icon: Icons.event_busy_outlined,
  ),
  ProjectDeliverySavedCommandLens(
    id: 'milestone-watch',
    label: 'Milestone Watch',
    description: 'Near-term delivery dates',
    filter: ProjectDeliveryCommandFilter(
      kind: ProjectDeliveryCommandKind.milestone,
    ),
    icon: Icons.outlined_flag_rounded,
  ),
];

List<ProjectDeliverySavedCommandLens> projectDeliverySavedLensesForProfile(
  ProjectDeliverySavedLensProfile profile,
) {
  switch (profile) {
    case ProjectDeliverySavedLensProfile.deliveryLead:
      return deliveryLeadProjectDeliverySavedCommandLenses;
    case ProjectDeliverySavedLensProfile.financePartner:
      return financePartnerProjectDeliverySavedCommandLenses;
    case ProjectDeliverySavedLensProfile.releaseDesk:
      return releaseDeskProjectDeliverySavedCommandLenses;
  }
}

ProjectDeliverySavedCommandLens? projectDeliverySavedLensForFilter(
  ProjectDeliveryCommandFilter filter, {
  List<ProjectDeliverySavedCommandLens> lenses =
      defaultProjectDeliverySavedCommandLenses,
}) {
  for (final lens in lenses) {
    if (lens.filter == filter) return lens;
  }

  return null;
}

List<ProjectDeliveryCommand> filterProjectDeliverySavedLens({
  required Iterable<ProjectDeliveryCommand> commands,
  required ProjectDeliverySavedCommandLens lens,
}) {
  return filterProjectDeliveryCommands(
    commands: commands.toList(),
    filter: lens.filter,
  );
}

Map<ProjectDeliverySavedCommandLens, int> countProjectDeliverySavedLenses(
  Iterable<ProjectDeliveryCommand> commands, {
  List<ProjectDeliverySavedCommandLens> lenses =
      defaultProjectDeliverySavedCommandLenses,
}) {
  final commandList = commands.toList();

  return {
    for (final lens in lenses)
      lens:
          filterProjectDeliverySavedLens(
            commands: commandList,
            lens: lens,
          ).length,
  };
}
