import 'package:flutter/material.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../models/project_portfolio_item.dart';
import 'project_status_update_service.dart';

enum ProjectStakeholderAlignmentStatus { blocked, decision, sync, aligned }

enum ProjectStakeholderAlignmentRole { sponsor, client, owner, team, domain }

class ProjectStakeholderAlignmentItem {
  const ProjectStakeholderAlignmentItem({
    required this.title,
    required this.detail,
    required this.icon,
    required this.status,
    required this.role,
  });

  final String title;
  final String detail;
  final IconData icon;
  final ProjectStakeholderAlignmentStatus status;
  final ProjectStakeholderAlignmentRole role;
}

class ProjectStakeholderAlignmentSummary {
  const ProjectStakeholderAlignmentSummary({
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
  final List<ProjectStakeholderAlignmentItem> items;

  int get blockedCount {
    return items
        .where(
          (item) => item.status == ProjectStakeholderAlignmentStatus.blocked,
        )
        .length;
  }

  int get decisionCount {
    return items
        .where(
          (item) => item.status == ProjectStakeholderAlignmentStatus.decision,
        )
        .length;
  }

  int get syncCount {
    return items
        .where((item) => item.status == ProjectStakeholderAlignmentStatus.sync)
        .length;
  }

  int get alignedCount {
    return items
        .where(
          (item) => item.status == ProjectStakeholderAlignmentStatus.aligned,
        )
        .length;
  }

  ProjectStakeholderAlignmentStatus get status {
    if (blockedCount > 0) return ProjectStakeholderAlignmentStatus.blocked;
    if (decisionCount > 0) return ProjectStakeholderAlignmentStatus.decision;
    if (syncCount > 0) return ProjectStakeholderAlignmentStatus.sync;

    return ProjectStakeholderAlignmentStatus.aligned;
  }

  ProjectStakeholderAlignmentItem get primaryItem {
    return items.firstWhere(
      (item) => item.status == status,
      orElse: () => items.first,
    );
  }
}

ProjectStakeholderAlignmentSummary buildProjectStakeholderAlignment({
  required ProjectPortfolioItem project,
  required List<gantt.GanttTask> timelineTasks,
  ProjectStatusUpdateVocabulary vocabulary =
      ProjectStatusUpdateVocabulary.general,
  ProjectStatusUpdateAudience audience =
      ProjectStatusUpdateAudience.stakeholder,
  DateTime? today,
}) {
  final referenceDate = DateUtils.dateOnly(today ?? DateTime.now());
  final overdueTaskCount =
      timelineTasks.where((task) {
        return task.progress < 1 &&
            DateUtils.dateOnly(task.endDate).isBefore(referenceDate);
      }).length;
  final overdueMilestoneCount =
      project.milestones.where((milestone) {
        return !milestone.isComplete &&
            DateUtils.dateOnly(milestone.dueDate).isBefore(referenceDate);
      }).length;
  final blockedRiskCount =
      project.risks
          .where((risk) => risk.severity == ProjectHealth.blocked)
          .length;
  final activeRiskCount =
      project.risks
          .where((risk) => risk.severity != ProjectHealth.onTrack)
          .length;
  final overloadedTeamCount =
      project.team.where((member) => member.allocation >= 0.75).length;
  final budgetDrift = project.budgetUsed - project.progress;
  final overdueCount = overdueTaskCount + overdueMilestoneCount;
  final items = [
    _sponsorItem(
      project: project,
      vocabulary: vocabulary,
      blockedRiskCount: blockedRiskCount,
      budgetDrift: budgetDrift,
    ),
    _clientItem(
      project: project,
      vocabulary: vocabulary,
      audience: audience,
      overdueCount: overdueCount,
      blockedRiskCount: blockedRiskCount,
    ),
    _ownerItem(
      project: project,
      vocabulary: vocabulary,
      overdueCount: overdueCount,
      blockedRiskCount: blockedRiskCount,
      activeRiskCount: activeRiskCount,
    ),
    _teamItem(
      project: project,
      vocabulary: vocabulary,
      timelineTaskCount: timelineTasks.length,
      overloadedTeamCount: overloadedTeamCount,
    ),
    _domainNetworkItem(
      project: project,
      vocabulary: vocabulary,
      overdueCount: overdueCount,
      blockedRiskCount: blockedRiskCount,
      activeRiskCount: activeRiskCount,
    ),
  ];
  final blockedCount =
      items
          .where(
            (item) => item.status == ProjectStakeholderAlignmentStatus.blocked,
          )
          .length;
  final decisionCount =
      items
          .where(
            (item) => item.status == ProjectStakeholderAlignmentStatus.decision,
          )
          .length;
  final alignedCount =
      items
          .where(
            (item) => item.status == ProjectStakeholderAlignmentStatus.aligned,
          )
          .length;
  final title =
      vocabulary == ProjectStatusUpdateVocabulary.general
          ? 'Delivery stakeholder alignment'
          : '${vocabulary.label} stakeholder alignment';

  return ProjectStakeholderAlignmentSummary(
    vocabulary: vocabulary,
    audience: audience,
    title: title,
    subtitle:
        '$blockedCount blocked - $decisionCount decision - $alignedCount aligned',
    items: List.unmodifiable(items),
  );
}

ProjectStakeholderAlignmentItem _sponsorItem({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required int blockedRiskCount,
  required double budgetDrift,
}) {
  if (project.sponsor.isEmpty) {
    return ProjectStakeholderAlignmentItem(
      title: 'Assign sponsor route',
      detail:
          'Add a sponsor or decision group before major ${vocabulary.milestoneLabel} commitments move forward.',
      icon: Icons.verified_user_outlined,
      status: ProjectStakeholderAlignmentStatus.decision,
      role: ProjectStakeholderAlignmentRole.sponsor,
    );
  }

  if (project.health == ProjectHealth.blocked || blockedRiskCount > 0) {
    return ProjectStakeholderAlignmentItem(
      title: 'Escalate sponsor decision',
      detail:
          '${project.sponsor} should own the unblock path for blocked ${vocabulary.riskLabel} or delivery constraints.',
      icon: Icons.priority_high_rounded,
      status: ProjectStakeholderAlignmentStatus.blocked,
      role: ProjectStakeholderAlignmentRole.sponsor,
    );
  }

  if (budgetDrift >= 0.15) {
    return ProjectStakeholderAlignmentItem(
      title: 'Confirm sponsor guardrail',
      detail:
          '${project.sponsor} needs a spend, scope, or sequencing decision before the next review.',
      icon: Icons.account_balance_wallet_outlined,
      status: ProjectStakeholderAlignmentStatus.decision,
      role: ProjectStakeholderAlignmentRole.sponsor,
    );
  }

  return ProjectStakeholderAlignmentItem(
    title: 'Keep sponsor aligned',
    detail:
        '${project.sponsor} has enough context to keep ${vocabulary.workLabel} direction stable.',
    icon: Icons.verified_user_outlined,
    status:
        project.health == ProjectHealth.onTrack
            ? ProjectStakeholderAlignmentStatus.aligned
            : ProjectStakeholderAlignmentStatus.sync,
    role: ProjectStakeholderAlignmentRole.sponsor,
  );
}

ProjectStakeholderAlignmentItem _clientItem({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectStatusUpdateAudience audience,
  required int overdueCount,
  required int blockedRiskCount,
}) {
  if (overdueCount > 0 || blockedRiskCount > 0) {
    return ProjectStakeholderAlignmentItem(
      title: 'Reset client confidence path',
      detail:
          'Give ${project.client} a clear view of timing, decision asks, and ${vocabulary.riskLabel} handling.',
      icon: Icons.handshake_outlined,
      status: ProjectStakeholderAlignmentStatus.decision,
      role: ProjectStakeholderAlignmentRole.client,
    );
  }

  if (audience == ProjectStatusUpdateAudience.client &&
      project.health != ProjectHealth.onTrack) {
    return ProjectStakeholderAlignmentItem(
      title: 'Prepare client alignment note',
      detail:
          'Lead with ${vocabulary.milestoneLabel} movement and the next confidence-building action for ${project.client}.',
      icon: Icons.mark_email_read_outlined,
      status: ProjectStakeholderAlignmentStatus.sync,
      role: ProjectStakeholderAlignmentRole.client,
    );
  }

  if (project.progress >= 0.72) {
    return ProjectStakeholderAlignmentItem(
      title: 'Confirm client acceptance route',
      detail:
          'Use the next update to confirm acceptance, handoff, and final ${vocabulary.milestoneLabel} evidence.',
      icon: Icons.fact_check_outlined,
      status: ProjectStakeholderAlignmentStatus.aligned,
      role: ProjectStakeholderAlignmentRole.client,
    );
  }

  return ProjectStakeholderAlignmentItem(
    title: 'Keep client context current',
    detail:
        'Keep ${project.client} close to progress, timing, and any decision that changes their experience.',
    icon: Icons.handshake_outlined,
    status: ProjectStakeholderAlignmentStatus.sync,
    role: ProjectStakeholderAlignmentRole.client,
  );
}

ProjectStakeholderAlignmentItem _ownerItem({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required int overdueCount,
  required int blockedRiskCount,
  required int activeRiskCount,
}) {
  if (blockedRiskCount > 0 || overdueCount > 0) {
    return ProjectStakeholderAlignmentItem(
      title: 'Clarify ${vocabulary.ownerLabel} recovery ownership',
      detail:
          '${project.owner} should name the next owner, date, and decision for recovery work.',
      icon: Icons.assignment_ind_outlined,
      status:
          blockedRiskCount > 0
              ? ProjectStakeholderAlignmentStatus.blocked
              : ProjectStakeholderAlignmentStatus.decision,
      role: ProjectStakeholderAlignmentRole.owner,
    );
  }

  if (activeRiskCount > 0) {
    return ProjectStakeholderAlignmentItem(
      title: 'Track ${vocabulary.ownerLabel} risk actions',
      detail:
          '${project.owner} should keep mitigation owners visible until ${vocabulary.riskLabel}s are stable.',
      icon: Icons.manage_accounts_outlined,
      status: ProjectStakeholderAlignmentStatus.sync,
      role: ProjectStakeholderAlignmentRole.owner,
    );
  }

  return ProjectStakeholderAlignmentItem(
    title: 'Keep ${vocabulary.ownerLabel} rhythm steady',
    detail:
        '${project.owner} has a clear path for current ${vocabulary.workLabel} ownership.',
    icon: Icons.assignment_turned_in_outlined,
    status: ProjectStakeholderAlignmentStatus.aligned,
    role: ProjectStakeholderAlignmentRole.owner,
  );
}

ProjectStakeholderAlignmentItem _teamItem({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required int timelineTaskCount,
  required int overloadedTeamCount,
}) {
  if (project.team.isEmpty) {
    return ProjectStakeholderAlignmentItem(
      title: 'Assign delivery team',
      detail:
          'Add owners and contributors so ${vocabulary.scheduleItemLabel}s have visible accountability.',
      icon: Icons.group_add_outlined,
      status: ProjectStakeholderAlignmentStatus.decision,
      role: ProjectStakeholderAlignmentRole.team,
    );
  }

  if (overloadedTeamCount > 0) {
    return ProjectStakeholderAlignmentItem(
      title: 'Balance team capacity',
      detail:
          '$overloadedTeamCount contributor${overloadedTeamCount == 1 ? '' : 's'} are heavily allocated; confirm handoff and backup coverage.',
      icon: Icons.balance_outlined,
      status: ProjectStakeholderAlignmentStatus.decision,
      role: ProjectStakeholderAlignmentRole.team,
    );
  }

  if (timelineTaskCount == 0) {
    return ProjectStakeholderAlignmentItem(
      title: 'Link team work plan',
      detail:
          'Attach ${vocabulary.scheduleItemLabel}s so team syncs connect directly to timeline evidence.',
      icon: Icons.add_link_outlined,
      status: ProjectStakeholderAlignmentStatus.sync,
      role: ProjectStakeholderAlignmentRole.team,
    );
  }

  return ProjectStakeholderAlignmentItem(
    title: 'Sync team execution path',
    detail:
        '${project.team.length} contributor${project.team.length == 1 ? '' : 's'} have visible roles for this ${vocabulary.workLabel}.',
    icon: Icons.groups_outlined,
    status: ProjectStakeholderAlignmentStatus.aligned,
    role: ProjectStakeholderAlignmentRole.team,
  );
}

ProjectStakeholderAlignmentItem _domainNetworkItem({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required int overdueCount,
  required int blockedRiskCount,
  required int activeRiskCount,
}) {
  final spec =
      _domainAlignmentSpecs[vocabulary.id] ?? _domainAlignmentSpecs['general']!;
  final status =
      blockedRiskCount > 0
          ? ProjectStakeholderAlignmentStatus.decision
          : overdueCount > 0 || activeRiskCount > 0
          ? ProjectStakeholderAlignmentStatus.sync
          : project.health == ProjectHealth.onTrack
          ? ProjectStakeholderAlignmentStatus.aligned
          : ProjectStakeholderAlignmentStatus.sync;

  return ProjectStakeholderAlignmentItem(
    title: spec.title,
    detail: spec.detail,
    icon: spec.icon,
    status: status,
    role: ProjectStakeholderAlignmentRole.domain,
  );
}

extension ProjectStakeholderAlignmentStatusPresentation
    on ProjectStakeholderAlignmentStatus {
  String get label {
    switch (this) {
      case ProjectStakeholderAlignmentStatus.blocked:
        return 'Blocked';
      case ProjectStakeholderAlignmentStatus.decision:
        return 'Decision';
      case ProjectStakeholderAlignmentStatus.sync:
        return 'Sync';
      case ProjectStakeholderAlignmentStatus.aligned:
        return 'Aligned';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectStakeholderAlignmentStatus.blocked:
        return Icons.priority_high_rounded;
      case ProjectStakeholderAlignmentStatus.decision:
        return Icons.rule_folder_outlined;
      case ProjectStakeholderAlignmentStatus.sync:
        return Icons.sync_alt_outlined;
      case ProjectStakeholderAlignmentStatus.aligned:
        return Icons.check_circle_outline;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectStakeholderAlignmentStatus.blocked:
        return colorScheme.error;
      case ProjectStakeholderAlignmentStatus.decision:
        return Colors.orange.shade700;
      case ProjectStakeholderAlignmentStatus.sync:
        return colorScheme.primary;
      case ProjectStakeholderAlignmentStatus.aligned:
        return Colors.green.shade700;
    }
  }
}

class _DomainAlignmentSpec {
  const _DomainAlignmentSpec({
    required this.title,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String detail;
  final IconData icon;
}

const _domainAlignmentSpecs = {
  'general': _DomainAlignmentSpec(
    title: 'Align operating network',
    detail:
        'Keep decision owners, delivery partners, and impacted teams synced before the next review.',
    icon: Icons.hub_outlined,
  ),
  'construction': _DomainAlignmentSpec(
    title: 'Align site, supplier, and authority routes',
    detail:
        'Keep site leads, suppliers, inspectors, and permit owners synced around phase gates.',
    icon: Icons.construction_outlined,
  ),
  'software': _DomainAlignmentSpec(
    title: 'Align product, QA, and release partners',
    detail:
        'Keep product, engineering, QA, security, and rollout owners aligned on release evidence.',
    icon: Icons.code_outlined,
  ),
  'event-production': _DomainAlignmentSpec(
    title: 'Align venue, vendors, and talent flow',
    detail:
        'Keep venue, vendor, talent, production, and contingency owners synced around the run sheet.',
    icon: Icons.event_outlined,
  ),
  'government': _DomainAlignmentSpec(
    title: 'Align governance and public accountability',
    detail:
        'Keep approvals, compliance, finance, communications, and escalation owners visible.',
    icon: Icons.account_balance_outlined,
  ),
  'education': _DomainAlignmentSpec(
    title: 'Align academic and learner operations',
    detail:
        'Keep faculty, calendar, learner support, facilities, and program owners coordinated.',
    icon: Icons.school_outlined,
  ),
  'wedding': _DomainAlignmentSpec(
    title: 'Align vendors, family, and venue',
    detail:
        'Keep vendor confirmations, family decisions, venue access, and day-of owners coordinated.',
    icon: Icons.celebration_outlined,
  ),
};
