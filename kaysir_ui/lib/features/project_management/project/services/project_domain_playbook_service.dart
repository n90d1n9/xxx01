import 'package:flutter/material.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../data/project_domain_registry.dart';
import '../models/project_portfolio_item.dart';
import 'project_status_update_service.dart';

enum ProjectDomainPlaybookLevel { critical, attention, routine, ready }

class ProjectDomainPlaybookItem {
  const ProjectDomainPlaybookItem({
    required this.title,
    required this.detail,
    required this.icon,
    required this.level,
  });

  final String title;
  final String detail;
  final IconData icon;
  final ProjectDomainPlaybookLevel level;
}

class ProjectDomainPlaybookSummary {
  const ProjectDomainPlaybookSummary({
    required this.vocabulary,
    required this.audience,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final ProjectStatusUpdateVocabulary vocabulary;
  final ProjectStatusUpdateAudience audience;
  final String title;
  final String subtitle;
  final List<ProjectDomainPlaybookItem> items;

  int get criticalCount {
    return items
        .where((item) => item.level == ProjectDomainPlaybookLevel.critical)
        .length;
  }

  int get attentionCount {
    return items
        .where((item) => item.level == ProjectDomainPlaybookLevel.attention)
        .length;
  }

  ProjectDomainPlaybookLevel get level {
    if (criticalCount > 0) return ProjectDomainPlaybookLevel.critical;
    if (attentionCount > 0) return ProjectDomainPlaybookLevel.attention;

    return ProjectDomainPlaybookLevel.ready;
  }
}

ProjectDomainPlaybookSummary buildProjectDomainPlaybook({
  required ProjectPortfolioItem project,
  required List<gantt.GanttTask> timelineTasks,
  ProjectStatusUpdateVocabulary vocabulary =
      ProjectStatusUpdateVocabulary.general,
  ProjectStatusUpdateAudience audience =
      ProjectStatusUpdateAudience.stakeholder,
  DateTime? today,
}) {
  final referenceDate = DateUtils.dateOnly(today ?? DateTime.now());
  final overdueMilestoneCount =
      project.milestones.where((milestone) {
        return !milestone.isComplete &&
            DateUtils.dateOnly(milestone.dueDate).isBefore(referenceDate);
      }).length;
  final overdueTaskCount =
      timelineTasks.where((task) {
        return task.progress < 1 &&
            DateUtils.dateOnly(task.endDate).isBefore(referenceDate);
      }).length;
  final blockedRisk = project.risks.where(
    (risk) => risk.severity == ProjectHealth.blocked,
  );
  final activeRisks = project.risks.where(
    (risk) => risk.severity != ProjectHealth.onTrack,
  );
  final budgetDrift = project.budgetUsed - project.progress;
  final items = [
    _domainControlItem(vocabulary),
    _scheduleItem(
      vocabulary: vocabulary,
      taskCount: timelineTasks.length,
      overdueTaskCount: overdueTaskCount,
      overdueMilestoneCount: overdueMilestoneCount,
    ),
    _riskItem(
      vocabulary: vocabulary,
      blockedRiskCount: blockedRisk.length,
      activeRiskCount: activeRisks.length,
    ),
    _budgetItem(vocabulary: vocabulary, budgetDrift: budgetDrift),
    _audienceItem(vocabulary: vocabulary, audience: audience, project: project),
  ];
  final criticalCount =
      items
          .where((item) => item.level == ProjectDomainPlaybookLevel.critical)
          .length;
  final attentionCount =
      items
          .where((item) => item.level == ProjectDomainPlaybookLevel.attention)
          .length;
  final title =
      vocabulary == ProjectStatusUpdateVocabulary.general
          ? 'Delivery operating playbook'
          : '${vocabulary.label} operating playbook';

  return ProjectDomainPlaybookSummary(
    vocabulary: vocabulary,
    audience: audience,
    title: title,
    subtitle:
        '$criticalCount urgent - $attentionCount watch - ${items.length} checks',
    items: List.unmodifiable(items),
  );
}

ProjectDomainPlaybookItem _domainControlItem(
  ProjectStatusUpdateVocabulary vocabulary,
) {
  final template =
      projectDomainPackForStatusVocabularyId(
        vocabulary.id,
      ).playbookControlTemplate;

  return ProjectDomainPlaybookItem(
    title: template.title,
    detail: template.detail,
    icon: _domainControlIcon(vocabulary.id),
    level: ProjectDomainPlaybookLevel.routine,
  );
}

ProjectDomainPlaybookItem _scheduleItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required int taskCount,
  required int overdueTaskCount,
  required int overdueMilestoneCount,
}) {
  final overdueCount = overdueTaskCount + overdueMilestoneCount;
  if (overdueCount > 0) {
    return ProjectDomainPlaybookItem(
      title: 'Recover ${vocabulary.scheduleLabel}',
      detail:
          '$overdueCount overdue ${vocabulary.scheduleItemLabel}/milestone signal${overdueCount == 1 ? '' : 's'} need owner and date confirmation.',
      icon: Icons.event_busy_outlined,
      level: ProjectDomainPlaybookLevel.critical,
    );
  }

  if (taskCount == 0) {
    return ProjectDomainPlaybookItem(
      title: 'Link ${vocabulary.scheduleLabel}',
      detail:
          'Attach ${vocabulary.scheduleItemLabel}s so risks, handoff, and status updates read from the same plan.',
      icon: Icons.add_link_outlined,
      level: ProjectDomainPlaybookLevel.attention,
    );
  }

  return ProjectDomainPlaybookItem(
    title: 'Maintain ${vocabulary.scheduleLabel} rhythm',
    detail:
        'Keep ${vocabulary.scheduleItemLabel} progress current before each operating review.',
    icon: Icons.timeline_outlined,
    level: ProjectDomainPlaybookLevel.ready,
  );
}

ProjectDomainPlaybookItem _riskItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required int blockedRiskCount,
  required int activeRiskCount,
}) {
  if (blockedRiskCount > 0) {
    return ProjectDomainPlaybookItem(
      title: 'Unblock ${vocabulary.riskLabel}',
      detail:
          '$blockedRiskCount blocked ${vocabulary.riskLabel}${blockedRiskCount == 1 ? '' : 's'} need an explicit decision owner.',
      icon: Icons.block_outlined,
      level: ProjectDomainPlaybookLevel.critical,
    );
  }

  if (activeRiskCount > 0) {
    return ProjectDomainPlaybookItem(
      title: 'Control ${vocabulary.riskLabel}',
      detail:
          '$activeRiskCount active ${vocabulary.riskLabel}${activeRiskCount == 1 ? '' : 's'} should stay visible in the next update.',
      icon: Icons.health_and_safety_outlined,
      level: ProjectDomainPlaybookLevel.attention,
    );
  }

  return ProjectDomainPlaybookItem(
    title: 'Keep ${vocabulary.riskLabel} register fresh',
    detail:
        'Confirm new constraints before they affect ${vocabulary.milestoneLabel} timing.',
    icon: Icons.verified_outlined,
    level: ProjectDomainPlaybookLevel.ready,
  );
}

ProjectDomainPlaybookItem _budgetItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required double budgetDrift,
}) {
  if (budgetDrift >= 0.15) {
    return ProjectDomainPlaybookItem(
      title: 'Rebalance ${vocabulary.budgetLabel}',
      detail:
          '${(budgetDrift * 100).round()} point spend/progress drift needs scope, supplier, or sequencing review.',
      icon: Icons.account_balance_wallet_outlined,
      level: ProjectDomainPlaybookLevel.attention,
    );
  }

  return ProjectDomainPlaybookItem(
    title: 'Track ${vocabulary.budgetLabel}',
    detail:
        'Compare spend and progress before committing the next ${vocabulary.milestoneLabel}.',
    icon: Icons.savings_outlined,
    level: ProjectDomainPlaybookLevel.routine,
  );
}

ProjectDomainPlaybookItem _audienceItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectStatusUpdateAudience audience,
  required ProjectPortfolioItem project,
}) {
  switch (audience) {
    case ProjectStatusUpdateAudience.stakeholder:
      return ProjectDomainPlaybookItem(
        title: 'Package stakeholder update',
        detail:
            'Summarize ${vocabulary.workLabel}, ${vocabulary.riskLabel}, and ${vocabulary.milestoneLabel} movement in plain operating language.',
        icon: Icons.diversity_3_outlined,
        level: ProjectDomainPlaybookLevel.routine,
      );
    case ProjectStatusUpdateAudience.sponsor:
      return ProjectDomainPlaybookItem(
        title: 'Prepare sponsor decision path',
        detail:
            'Make the next ask clear for ${project.sponsor.isEmpty ? project.owner : project.sponsor}.',
        icon: Icons.verified_user_outlined,
        level: ProjectDomainPlaybookLevel.attention,
      );
    case ProjectStatusUpdateAudience.team:
      return ProjectDomainPlaybookItem(
        title: 'Run team execution sync',
        detail:
            'Assign owners for the next ${vocabulary.scheduleItemLabel}s and refresh blockers before handoff.',
        icon: Icons.groups_outlined,
        level: ProjectDomainPlaybookLevel.routine,
      );
    case ProjectStatusUpdateAudience.client:
      return ProjectDomainPlaybookItem(
        title: 'Prepare client-facing note',
        detail:
            'Lead with ${vocabulary.milestoneLabel} timing, decisions needed, and ${vocabulary.riskLabel} handling.',
        icon: Icons.handshake_outlined,
        level: ProjectDomainPlaybookLevel.routine,
      );
  }
}

extension ProjectDomainPlaybookLevelPresentation on ProjectDomainPlaybookLevel {
  String get label {
    switch (this) {
      case ProjectDomainPlaybookLevel.critical:
        return 'Urgent';
      case ProjectDomainPlaybookLevel.attention:
        return 'Watch';
      case ProjectDomainPlaybookLevel.routine:
        return 'Routine';
      case ProjectDomainPlaybookLevel.ready:
        return 'Ready';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectDomainPlaybookLevel.critical:
        return Icons.priority_high_rounded;
      case ProjectDomainPlaybookLevel.attention:
        return Icons.visibility_outlined;
      case ProjectDomainPlaybookLevel.routine:
        return Icons.fact_check_outlined;
      case ProjectDomainPlaybookLevel.ready:
        return Icons.check_circle_outline;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDomainPlaybookLevel.critical:
        return colorScheme.error;
      case ProjectDomainPlaybookLevel.attention:
        return Colors.orange.shade700;
      case ProjectDomainPlaybookLevel.routine:
        return colorScheme.primary;
      case ProjectDomainPlaybookLevel.ready:
        return Colors.green.shade700;
    }
  }
}

IconData _domainControlIcon(String vocabularyId) {
  switch (vocabularyId) {
    case 'construction':
      return Icons.construction_outlined;
    case 'software':
      return Icons.code_outlined;
    case 'event-production':
      return Icons.event_outlined;
    case 'government':
      return Icons.account_balance_outlined;
    case 'education':
      return Icons.school_outlined;
    case 'wedding':
      return Icons.celebration_outlined;
    case 'retail-operations':
      return Icons.storefront_outlined;
    default:
      return Icons.tune_outlined;
  }
}
