import 'package:flutter/material.dart';

import 'project_custom_attribute.dart';

enum ProjectHealth { onTrack, atRisk, blocked }

class ProjectDeliveryRisk {
  const ProjectDeliveryRisk({
    required this.title,
    required this.detail,
    required this.severity,
  });

  final String title;
  final String detail;
  final ProjectHealth severity;
}

class ProjectMilestone {
  const ProjectMilestone({
    required this.label,
    required this.dueDate,
    required this.isComplete,
  });

  final String label;
  final DateTime dueDate;
  final bool isComplete;
}

class ProjectTeamMember {
  const ProjectTeamMember({
    required this.name,
    required this.role,
    required this.allocation,
  });

  final String name;
  final String role;
  final double allocation;
}

class ProjectPortfolioItem {
  const ProjectPortfolioItem({
    required this.id,
    required this.name,
    required this.owner,
    required this.client,
    required this.startDate,
    required this.endDate,
    required this.progress,
    required this.budgetUsed,
    required this.health,
    required this.milestones,
    this.businessDomain = 'General Business',
    this.summary = '',
    this.sponsor = '',
    this.risks = const [],
    this.team = const [],
    this.timelineTaskIds = const [],
    this.customAttributes = const [],
  });

  final String id;
  final String name;
  final String owner;
  final String client;
  final String businessDomain;
  final String summary;
  final String sponsor;
  final DateTime startDate;
  final DateTime endDate;
  final double progress;
  final double budgetUsed;
  final ProjectHealth health;
  final List<ProjectMilestone> milestones;
  final List<ProjectDeliveryRisk> risks;
  final List<ProjectTeamMember> team;
  final List<String> timelineTaskIds;
  final List<ProjectCustomAttribute> customAttributes;

  int get durationDays => endDate.difference(startDate).inDays + 1;
  int get openMilestoneCount =>
      milestones.where((milestone) => !milestone.isComplete).length;
  int get riskCount =>
      risks.where((risk) => risk.severity != ProjectHealth.onTrack).length;
  int get customAttributeCount =>
      customAttributes.where((attribute) => attribute.hasValue).length;
  Iterable<ProjectCustomAttribute> get pinnedCustomAttributes =>
      customAttributes.where(
        (attribute) => attribute.isPinned && attribute.hasValue,
      );
}

extension ProjectHealthPresentation on ProjectHealth {
  String get label {
    switch (this) {
      case ProjectHealth.onTrack:
        return 'On Track';
      case ProjectHealth.atRisk:
        return 'At Risk';
      case ProjectHealth.blocked:
        return 'Blocked';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectHealth.onTrack:
        return Icons.check_circle_outline;
      case ProjectHealth.atRisk:
        return Icons.warning_amber_rounded;
      case ProjectHealth.blocked:
        return Icons.block_outlined;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectHealth.onTrack:
        return Colors.green.shade700;
      case ProjectHealth.atRisk:
        return Colors.orange.shade700;
      case ProjectHealth.blocked:
        return colorScheme.error;
    }
  }
}
