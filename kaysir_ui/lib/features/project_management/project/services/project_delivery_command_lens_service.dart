import 'package:flutter/material.dart';

import 'project_delivery_command_service.dart';

enum ProjectDeliveryCommandLens {
  all,
  criticalNow,
  blockers,
  risks,
  dependencies,
  budget,
  milestones,
}

extension ProjectDeliveryCommandLensPresentation on ProjectDeliveryCommandLens {
  String get label {
    switch (this) {
      case ProjectDeliveryCommandLens.all:
        return 'All Commands';
      case ProjectDeliveryCommandLens.criticalNow:
        return 'Critical Now';
      case ProjectDeliveryCommandLens.blockers:
        return 'Blockers';
      case ProjectDeliveryCommandLens.risks:
        return 'Risks';
      case ProjectDeliveryCommandLens.dependencies:
        return 'Dependencies';
      case ProjectDeliveryCommandLens.budget:
        return 'Budget';
      case ProjectDeliveryCommandLens.milestones:
        return 'Milestones';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectDeliveryCommandLens.all:
        return Icons.rule_folder_outlined;
      case ProjectDeliveryCommandLens.criticalNow:
        return Icons.priority_high_rounded;
      case ProjectDeliveryCommandLens.blockers:
        return Icons.block_outlined;
      case ProjectDeliveryCommandLens.risks:
        return Icons.health_and_safety_outlined;
      case ProjectDeliveryCommandLens.dependencies:
        return Icons.link_rounded;
      case ProjectDeliveryCommandLens.budget:
        return Icons.account_balance_wallet_outlined;
      case ProjectDeliveryCommandLens.milestones:
        return Icons.flag_outlined;
    }
  }

  ProjectDeliveryCommandFilter get filter {
    switch (this) {
      case ProjectDeliveryCommandLens.all:
        return ProjectDeliveryCommandFilter.empty;
      case ProjectDeliveryCommandLens.criticalNow:
        return const ProjectDeliveryCommandFilter(
          level: ProjectDeliveryCommandLevel.critical,
        );
      case ProjectDeliveryCommandLens.blockers:
        return const ProjectDeliveryCommandFilter(
          level: ProjectDeliveryCommandLevel.critical,
          kind: ProjectDeliveryCommandKind.projectBlocked,
        );
      case ProjectDeliveryCommandLens.risks:
        return const ProjectDeliveryCommandFilter(
          kind: ProjectDeliveryCommandKind.risk,
        );
      case ProjectDeliveryCommandLens.dependencies:
        return const ProjectDeliveryCommandFilter(
          kind: ProjectDeliveryCommandKind.dependency,
        );
      case ProjectDeliveryCommandLens.budget:
        return const ProjectDeliveryCommandFilter(
          kind: ProjectDeliveryCommandKind.budget,
        );
      case ProjectDeliveryCommandLens.milestones:
        return const ProjectDeliveryCommandFilter(
          kind: ProjectDeliveryCommandKind.milestone,
        );
    }
  }
}

ProjectDeliveryCommandLens? projectDeliveryCommandLensForFilter(
  ProjectDeliveryCommandFilter filter,
) {
  for (final lens in ProjectDeliveryCommandLens.values) {
    if (lens.filter == filter) return lens;
  }

  return null;
}

List<ProjectDeliveryCommand> filterProjectDeliveryCommandLens({
  required Iterable<ProjectDeliveryCommand> commands,
  required ProjectDeliveryCommandLens lens,
}) {
  return filterProjectDeliveryCommands(
    commands: commands.toList(),
    filter: lens.filter,
  );
}

Map<ProjectDeliveryCommandLens, int> countProjectDeliveryCommandLenses(
  Iterable<ProjectDeliveryCommand> commands,
) {
  final commandList = commands.toList();

  return {
    for (final lens in ProjectDeliveryCommandLens.values)
      lens:
          lens == ProjectDeliveryCommandLens.all
              ? commandList.length
              : filterProjectDeliveryCommandLens(
                commands: commandList,
                lens: lens,
              ).length,
  };
}
