import '../models/project_portfolio_item.dart';
import 'project_domain_gap_repair_service.dart';

enum ProjectDomainGapRepairReasonKind {
  requiredField,
  riskSignal,
  recommendedField,
  coverageGap,
  blockedProject,
  atRiskProject,
  dueSoon,
  overdue,
}

class ProjectDomainGapRepairReason {
  const ProjectDomainGapRepairReason({
    required this.kind,
    required this.label,
    required this.detail,
  });

  final ProjectDomainGapRepairReasonKind kind;
  final String label;
  final String detail;
}

class ProjectDomainGapRepairReasonSet {
  const ProjectDomainGapRepairReasonSet({
    required this.target,
    required this.reasons,
  });

  final ProjectDomainGapRepairTarget target;
  final List<ProjectDomainGapRepairReason> reasons;

  bool get isEmpty => reasons.isEmpty;
  String get compactLabel => reasons.map((reason) => reason.label).join(' - ');
}

ProjectDomainGapRepairReasonSet buildProjectDomainGapRepairReasonSet({
  required ProjectDomainGapRepairTarget target,
  DateTime? today,
  int dueSoonDays = 30,
}) {
  final reasons = <ProjectDomainGapRepairReason>[
    _priorityReason(target),
    ..._healthReasons(target),
  ];

  final dueReason = _dueReason(
    target: target,
    today: today ?? DateTime.now(),
    dueSoonDays: dueSoonDays,
  );
  if (dueReason != null) reasons.add(dueReason);

  return ProjectDomainGapRepairReasonSet(
    target: target,
    reasons: List.unmodifiable(reasons),
  );
}

ProjectDomainGapRepairReason _priorityReason(
  ProjectDomainGapRepairTarget target,
) {
  final domain = _domainLabel(target.project.businessDomain);

  switch (target.priority) {
    case ProjectDomainGapRepairPriority.requiredField:
      return ProjectDomainGapRepairReason(
        kind: ProjectDomainGapRepairReasonKind.requiredField,
        label: 'Mandatory context',
        detail:
            '${target.fieldLabel} is required for the $domain project profile.',
      );
    case ProjectDomainGapRepairPriority.riskSignal:
      return ProjectDomainGapRepairReason(
        kind: ProjectDomainGapRepairReasonKind.riskSignal,
        label: 'Watched risk field',
        detail: '${target.fieldLabel} is watched by the $domain risk template.',
      );
    case ProjectDomainGapRepairPriority.recommended:
      return ProjectDomainGapRepairReason(
        kind: ProjectDomainGapRepairReasonKind.recommendedField,
        label: 'Recommended context',
        detail: '${target.fieldLabel} improves the $domain operating picture.',
      );
    case ProjectDomainGapRepairPriority.coverageGap:
      return ProjectDomainGapRepairReason(
        kind: ProjectDomainGapRepairReasonKind.coverageGap,
        label: 'Coverage completion',
        detail:
            '${target.fieldLabel} completes adaptive table coverage for this project.',
      );
  }
}

List<ProjectDomainGapRepairReason> _healthReasons(
  ProjectDomainGapRepairTarget target,
) {
  switch (target.project.health) {
    case ProjectHealth.blocked:
      return [
        ProjectDomainGapRepairReason(
          kind: ProjectDomainGapRepairReasonKind.blockedProject,
          label: 'Blocked project',
          detail:
              '${target.projectLabel} is blocked, so missing context can slow recovery decisions.',
        ),
      ];
    case ProjectHealth.atRisk:
      return [
        ProjectDomainGapRepairReason(
          kind: ProjectDomainGapRepairReasonKind.atRiskProject,
          label: 'At-risk project',
          detail:
              '${target.projectLabel} is at risk, so this field helps clarify the next intervention.',
        ),
      ];
    case ProjectHealth.onTrack:
      return const [];
  }
}

ProjectDomainGapRepairReason? _dueReason({
  required ProjectDomainGapRepairTarget target,
  required DateTime today,
  required int dueSoonDays,
}) {
  final dueDate = _dateOnly(target.project.endDate);
  final asOf = _dateOnly(today);
  final daysUntilDue = dueDate.difference(asOf).inDays;

  if (daysUntilDue < 0) {
    final days = daysUntilDue.abs();
    return ProjectDomainGapRepairReason(
      kind: ProjectDomainGapRepairReasonKind.overdue,
      label: '${days}d overdue',
      detail:
          '${target.projectLabel} passed its target date ${_dayLabel(days)} ago.',
    );
  }

  if (daysUntilDue == 0) {
    return ProjectDomainGapRepairReason(
      kind: ProjectDomainGapRepairReasonKind.dueSoon,
      label: 'Due today',
      detail: '${target.projectLabel} reaches its target date today.',
    );
  }

  if (daysUntilDue <= dueSoonDays) {
    return ProjectDomainGapRepairReason(
      kind: ProjectDomainGapRepairReasonKind.dueSoon,
      label: 'Due in ${daysUntilDue}d',
      detail:
          '${target.projectLabel} reaches its target date in ${_dayLabel(daysUntilDue)}.',
    );
  }

  return null;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _dayLabel(int days) {
  return '$days day${days == 1 ? '' : 's'}';
}

String _domainLabel(String value) {
  final domain = value.trim();
  return domain.isEmpty ? 'General Business' : domain;
}
