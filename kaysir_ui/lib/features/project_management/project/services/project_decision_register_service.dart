import 'package:flutter/material.dart';

import '../data/project_domain_registry.dart';
import '../models/project_custom_attribute.dart';
import '../models/project_decision_record.dart';
import '../models/project_portfolio_item.dart';
import 'project_decision_governance_service.dart';
import 'project_next_decision_service.dart';
import 'project_status_update_service.dart';

/// Filter lens for browsing project decision register records.
enum ProjectDecisionRegisterLens {
  all,
  urgent,
  awaiting,
  governance,
  risks,
  milestones,
  domain,
  closed,
}

/// Filterable project decision register with counts used by the UI.
class ProjectDecisionRegisterSummary {
  const ProjectDecisionRegisterSummary({
    required this.project,
    required this.records,
    required this.today,
  });

  final ProjectPortfolioItem project;
  final List<ProjectDecisionRecord> records;
  final DateTime today;

  int get recordCount => records.length;
  int get openCount => records.where((record) => record.isOpen).length;
  int get blockedCount =>
      records
          .where((record) => record.status == ProjectDecisionStatus.blocked)
          .length;
  int get awaitingDecisionCount =>
      records
          .where(
            (record) =>
                record.status == ProjectDecisionStatus.awaitingDecision ||
                record.status == ProjectDecisionStatus.inReview,
          )
          .length;
  int get overdueCount =>
      records.where((record) => record.isOverdue(today)).length;

  ProjectDecisionRecord? get priorityRecord {
    if (records.isEmpty) return null;

    return records.first;
  }

  List<ProjectDecisionRecord> recordsFor(ProjectDecisionRegisterLens lens) {
    return records.where((record) => lens.matches(record, today)).toList();
  }

  int countFor(ProjectDecisionRegisterLens lens) => recordsFor(lens).length;
}

/// Builds a register from generated decisions, governance, risks, milestones, and domain fields.
ProjectDecisionRegisterSummary buildProjectDecisionRegisterSummary({
  required ProjectPortfolioItem project,
  required ProjectNextDecisionSummary nextDecisionSummary,
  required ProjectDecisionGovernanceSummary governanceSummary,
  DateTime? today,
}) {
  final referenceDate = DateUtils.dateOnly(today ?? DateTime.now());
  final nextOpenMilestone = _nextOpenMilestone(project.milestones);
  final records = [
    for (var index = 0; index < nextDecisionSummary.decisions.length; index++)
      _nextDecisionRecord(
        project: project,
        decision: nextDecisionSummary.decisions[index],
        index: index,
        fallbackDueDate: nextOpenMilestone?.dueDate ?? project.endDate,
      ),
    for (var index = 0; index < governanceSummary.items.length; index++)
      _governanceRecord(
        project: project,
        item: governanceSummary.items[index],
        summary: governanceSummary,
        index: index,
        dueDate: nextOpenMilestone?.dueDate ?? project.endDate,
      ),
    for (var index = 0; index < project.risks.length; index++)
      if (project.risks[index].severity != ProjectHealth.onTrack)
        _riskRecord(
          project: project,
          risk: project.risks[index],
          index: index,
          dueDate: nextOpenMilestone?.dueDate ?? project.endDate,
        ),
    for (final entry in _milestoneRecords(
      project: project,
      today: referenceDate,
    ))
      entry,
    for (final entry in _domainExtensionRecords(
      project: project,
      dueDate: nextOpenMilestone?.dueDate ?? project.endDate,
    ))
      entry,
  ]..sort((left, right) => _compareRecords(left, right, referenceDate));

  return ProjectDecisionRegisterSummary(
    project: project,
    records: List.unmodifiable(records),
    today: referenceDate,
  );
}

ProjectDecisionRecord _nextDecisionRecord({
  required ProjectPortfolioItem project,
  required ProjectNextDecision decision,
  required int index,
  required DateTime fallbackDueDate,
}) {
  final priority = _priorityForNextDecision(decision.level);
  final owner =
      decision.level == ProjectNextDecisionLevel.critical
          ? _sponsorOrOwner(project)
          : _ownerOrFallback(project.owner, project);

  return ProjectDecisionRecord(
    id: _recordId('next', decision.title, index),
    projectId: project.id,
    title: decision.title,
    detail: decision.detail,
    ownerLabel:
        decision.level == ProjectNextDecisionLevel.critical
            ? 'Sponsor'
            : 'Owner',
    owner: owner,
    status:
        decision.level == ProjectNextDecisionLevel.healthy
            ? ProjectDecisionStatus.completed
            : ProjectDecisionStatus.awaitingDecision,
    priority: priority,
    source: ProjectDecisionSource.nextDecision,
    dueDate: decision.task?.endDate ?? fallbackDueDate,
    evidenceLabel: decision.kind.label,
    domainLabel: project.businessDomain,
  );
}

ProjectDecisionRecord _governanceRecord({
  required ProjectPortfolioItem project,
  required ProjectDecisionGovernanceItem item,
  required ProjectDecisionGovernanceSummary summary,
  required int index,
  required DateTime dueDate,
}) {
  final owner = _ownerForGovernanceLevel(project, item.level);

  return ProjectDecisionRecord(
    id: _recordId('governance', item.title, index),
    projectId: project.id,
    title: item.title,
    detail: item.detail,
    ownerLabel:
        item.level == ProjectDecisionGovernanceLevel.escalate ||
                item.level == ProjectDecisionGovernanceLevel.approve
            ? 'Sponsor'
            : 'Owner',
    owner: owner,
    status: _statusForGovernanceLevel(item.level),
    priority: _priorityForGovernanceLevel(item.level),
    source: ProjectDecisionSource.governance,
    dueDate: dueDate,
    evidenceLabel: summary.decisionRoute,
    domainLabel: summary.vocabulary.label,
    customAttributes: {
      'Audience': summary.audience.label,
      'Route': summary.decisionRoute,
    },
  );
}

ProjectDecisionRecord _riskRecord({
  required ProjectPortfolioItem project,
  required ProjectDeliveryRisk risk,
  required int index,
  required DateTime dueDate,
}) {
  return ProjectDecisionRecord(
    id: _recordId('risk', risk.title, index),
    projectId: project.id,
    title: risk.title,
    detail: risk.detail,
    ownerLabel: 'Owner',
    owner: _ownerOrFallback(project.owner, project),
    status:
        risk.severity == ProjectHealth.blocked
            ? ProjectDecisionStatus.blocked
            : ProjectDecisionStatus.inReview,
    priority:
        risk.severity == ProjectHealth.blocked
            ? ProjectDecisionPriority.critical
            : ProjectDecisionPriority.high,
    source: ProjectDecisionSource.risk,
    dueDate: dueDate,
    evidenceLabel: 'Risk register',
    domainLabel: project.businessDomain,
  );
}

List<ProjectDecisionRecord> _milestoneRecords({
  required ProjectPortfolioItem project,
  required DateTime today,
}) {
  final milestones = [
    for (final milestone in project.milestones)
      if (!milestone.isComplete) milestone,
  ]..sort((left, right) => left.dueDate.compareTo(right.dueDate));

  return [
    for (var index = 0; index < milestones.take(3).length; index++)
      _milestoneRecord(
        project: project,
        milestone: milestones[index],
        index: index,
        today: today,
      ),
  ];
}

ProjectDecisionRecord _milestoneRecord({
  required ProjectPortfolioItem project,
  required ProjectMilestone milestone,
  required int index,
  required DateTime today,
}) {
  final dueDate = DateUtils.dateOnly(milestone.dueDate);
  final daysUntilDue = dueDate.difference(today).inDays;
  final isOverdue = daysUntilDue < 0;
  final priority =
      isOverdue
          ? ProjectDecisionPriority.critical
          : daysUntilDue <= 7
          ? ProjectDecisionPriority.high
          : ProjectDecisionPriority.medium;

  return ProjectDecisionRecord(
    id: _recordId('milestone', milestone.label, index),
    projectId: project.id,
    title: 'Confirm ${milestone.label}',
    detail:
        isOverdue
            ? '${milestone.label} is overdue and needs a recovery decision.'
            : '${milestone.label} needs acceptance owner, evidence, and next-step confirmation.',
    ownerLabel: 'Owner',
    owner: _ownerOrFallback(project.owner, project),
    status:
        isOverdue
            ? ProjectDecisionStatus.blocked
            : ProjectDecisionStatus.inReview,
    priority: priority,
    source: ProjectDecisionSource.milestone,
    dueDate: milestone.dueDate,
    evidenceLabel: 'Milestone proof',
    domainLabel: project.businessDomain,
  );
}

List<ProjectDecisionRecord> _domainExtensionRecords({
  required ProjectPortfolioItem project,
  required DateTime dueDate,
}) {
  final pack = projectDomainPackForBusinessDomain(project.businessDomain);
  final attributesByKey = {
    for (final attribute in project.customAttributes) attribute.key: attribute,
  };
  final requiredTemplates = pack.customAttributeTemplates.where(
    (template) =>
        template.importance == ProjectCustomAttributeImportance.requiredField,
  );
  final missingRequiredRecords = [
    for (final template in requiredTemplates)
      if (!(attributesByKey[template.key]?.hasValue ?? false))
        ProjectDecisionRecord(
          id: _recordId(
            'domain-required',
            template.label,
            template.key.hashCode,
          ),
          projectId: project.id,
          title: 'Capture ${template.label}',
          detail:
              '${pack.label} work needs ${template.label.toLowerCase()} before the project record is governance-ready.',
          ownerLabel: 'Owner',
          owner: _ownerOrFallback(project.owner, project),
          status: ProjectDecisionStatus.awaitingDecision,
          priority: ProjectDecisionPriority.high,
          source: ProjectDecisionSource.domainExtension,
          dueDate: dueDate,
          evidenceLabel: 'Required domain field',
          domainLabel: pack.label,
          customAttributes: {'Field': template.label},
        ),
  ];
  final capturedRecords = [
    for (
      var index = 0;
      index < project.pinnedCustomAttributes.take(3).length;
      index++
    )
      _capturedDomainRecord(
        project: project,
        attribute: project.pinnedCustomAttributes.elementAt(index),
        index: index,
        packLabel: pack.label,
      ),
  ];

  return [...missingRequiredRecords, ...capturedRecords];
}

ProjectDecisionRecord _capturedDomainRecord({
  required ProjectPortfolioItem project,
  required ProjectCustomAttribute attribute,
  required int index,
  required String packLabel,
}) {
  return ProjectDecisionRecord(
    id: _recordId('domain-captured', attribute.label, index),
    projectId: project.id,
    title: 'Confirm ${attribute.label}',
    detail:
        '${attribute.label} is captured as ${attribute.displayValue}; keep this field aligned with project decisions and evidence.',
    ownerLabel: 'Owner',
    owner: _ownerOrFallback(project.owner, project),
    status: ProjectDecisionStatus.approved,
    priority: ProjectDecisionPriority.low,
    source: ProjectDecisionSource.domainExtension,
    evidenceLabel: 'Domain field evidence',
    domainLabel: packLabel,
    customAttributes: {attribute.label: attribute.displayValue},
  );
}

ProjectMilestone? _nextOpenMilestone(List<ProjectMilestone> milestones) {
  final openMilestones = [
    for (final milestone in milestones)
      if (!milestone.isComplete) milestone,
  ]..sort((left, right) => left.dueDate.compareTo(right.dueDate));

  if (openMilestones.isEmpty) return null;

  return openMilestones.first;
}

ProjectDecisionPriority _priorityForNextDecision(
  ProjectNextDecisionLevel level,
) {
  switch (level) {
    case ProjectNextDecisionLevel.critical:
      return ProjectDecisionPriority.critical;
    case ProjectNextDecisionLevel.warning:
      return ProjectDecisionPriority.high;
    case ProjectNextDecisionLevel.action:
      return ProjectDecisionPriority.medium;
    case ProjectNextDecisionLevel.healthy:
      return ProjectDecisionPriority.low;
  }
}

ProjectDecisionStatus _statusForGovernanceLevel(
  ProjectDecisionGovernanceLevel level,
) {
  switch (level) {
    case ProjectDecisionGovernanceLevel.escalate:
      return ProjectDecisionStatus.awaitingDecision;
    case ProjectDecisionGovernanceLevel.approve:
      return ProjectDecisionStatus.inReview;
    case ProjectDecisionGovernanceLevel.coordinate:
      return ProjectDecisionStatus.delegated;
    case ProjectDecisionGovernanceLevel.delegated:
      return ProjectDecisionStatus.approved;
  }
}

ProjectDecisionPriority _priorityForGovernanceLevel(
  ProjectDecisionGovernanceLevel level,
) {
  switch (level) {
    case ProjectDecisionGovernanceLevel.escalate:
      return ProjectDecisionPriority.critical;
    case ProjectDecisionGovernanceLevel.approve:
      return ProjectDecisionPriority.high;
    case ProjectDecisionGovernanceLevel.coordinate:
      return ProjectDecisionPriority.medium;
    case ProjectDecisionGovernanceLevel.delegated:
      return ProjectDecisionPriority.low;
  }
}

String _ownerForGovernanceLevel(
  ProjectPortfolioItem project,
  ProjectDecisionGovernanceLevel level,
) {
  switch (level) {
    case ProjectDecisionGovernanceLevel.escalate:
    case ProjectDecisionGovernanceLevel.approve:
      return _sponsorOrOwner(project);
    case ProjectDecisionGovernanceLevel.coordinate:
    case ProjectDecisionGovernanceLevel.delegated:
      return _ownerOrFallback(project.owner, project);
  }
}

String _sponsorOrOwner(ProjectPortfolioItem project) {
  return _ownerOrFallback(project.sponsor, project);
}

String _ownerOrFallback(String preferredOwner, ProjectPortfolioItem project) {
  final normalizedOwner = preferredOwner.trim();
  if (normalizedOwner.isNotEmpty) return normalizedOwner;

  return project.owner.trim().isEmpty ? 'Project Owner' : project.owner.trim();
}

int _compareRecords(
  ProjectDecisionRecord left,
  ProjectDecisionRecord right,
  DateTime today,
) {
  final overdueComparison = _overduePriority(
    left,
    today,
  ).compareTo(_overduePriority(right, today));
  if (overdueComparison != 0) return overdueComparison;

  final statusComparison = _statusPriority(
    left.status,
  ).compareTo(_statusPriority(right.status));
  if (statusComparison != 0) return statusComparison;

  final priorityComparison = _prioritySortValue(
    left.priority,
  ).compareTo(_prioritySortValue(right.priority));
  if (priorityComparison != 0) return priorityComparison;

  final leftDueDate = left.dueDate;
  final rightDueDate = right.dueDate;
  if (leftDueDate != null && rightDueDate != null) {
    final dueDateComparison = leftDueDate.compareTo(rightDueDate);
    if (dueDateComparison != 0) return dueDateComparison;
  } else if (leftDueDate != null) {
    return -1;
  } else if (rightDueDate != null) {
    return 1;
  }

  return left.title.compareTo(right.title);
}

int _overduePriority(ProjectDecisionRecord record, DateTime today) {
  return record.isOverdue(today) ? 0 : 1;
}

int _statusPriority(ProjectDecisionStatus status) {
  switch (status) {
    case ProjectDecisionStatus.blocked:
      return 0;
    case ProjectDecisionStatus.awaitingDecision:
      return 1;
    case ProjectDecisionStatus.inReview:
      return 2;
    case ProjectDecisionStatus.delegated:
      return 3;
    case ProjectDecisionStatus.approved:
      return 4;
    case ProjectDecisionStatus.completed:
      return 5;
  }
}

int _prioritySortValue(ProjectDecisionPriority priority) {
  switch (priority) {
    case ProjectDecisionPriority.critical:
      return 0;
    case ProjectDecisionPriority.high:
      return 1;
    case ProjectDecisionPriority.medium:
      return 2;
    case ProjectDecisionPriority.low:
      return 3;
  }
}

String _recordId(String prefix, String title, Object index) {
  final slug = title
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  return '$prefix-$index-${slug.isEmpty ? 'record' : slug}';
}

extension ProjectDecisionRegisterLensPresentation
    on ProjectDecisionRegisterLens {
  /// User-facing label for a project decision register lens.
  String get label {
    switch (this) {
      case ProjectDecisionRegisterLens.all:
        return 'All';
      case ProjectDecisionRegisterLens.urgent:
        return 'Urgent';
      case ProjectDecisionRegisterLens.awaiting:
        return 'Awaiting';
      case ProjectDecisionRegisterLens.governance:
        return 'Governance';
      case ProjectDecisionRegisterLens.risks:
        return 'Risks';
      case ProjectDecisionRegisterLens.milestones:
        return 'Milestones';
      case ProjectDecisionRegisterLens.domain:
        return 'Domain';
      case ProjectDecisionRegisterLens.closed:
        return 'Closed';
    }
  }

  /// Icon for a project decision register lens.
  IconData get icon {
    switch (this) {
      case ProjectDecisionRegisterLens.all:
        return Icons.view_list_outlined;
      case ProjectDecisionRegisterLens.urgent:
        return Icons.priority_high_rounded;
      case ProjectDecisionRegisterLens.awaiting:
        return Icons.pending_actions_outlined;
      case ProjectDecisionRegisterLens.governance:
        return Icons.account_tree_outlined;
      case ProjectDecisionRegisterLens.risks:
        return Icons.health_and_safety_outlined;
      case ProjectDecisionRegisterLens.milestones:
        return Icons.flag_outlined;
      case ProjectDecisionRegisterLens.domain:
        return Icons.extension_outlined;
      case ProjectDecisionRegisterLens.closed:
        return Icons.verified_outlined;
    }
  }

  /// Whether this lens should include the given decision register record.
  bool matches(ProjectDecisionRecord record, DateTime today) {
    switch (this) {
      case ProjectDecisionRegisterLens.all:
        return true;
      case ProjectDecisionRegisterLens.urgent:
        return record.isOverdue(today) ||
            record.status == ProjectDecisionStatus.blocked ||
            record.priority == ProjectDecisionPriority.critical ||
            record.priority == ProjectDecisionPriority.high;
      case ProjectDecisionRegisterLens.awaiting:
        return record.status == ProjectDecisionStatus.awaitingDecision ||
            record.status == ProjectDecisionStatus.inReview ||
            record.status == ProjectDecisionStatus.blocked;
      case ProjectDecisionRegisterLens.governance:
        return record.source == ProjectDecisionSource.governance;
      case ProjectDecisionRegisterLens.risks:
        return record.source == ProjectDecisionSource.risk;
      case ProjectDecisionRegisterLens.milestones:
        return record.source == ProjectDecisionSource.milestone;
      case ProjectDecisionRegisterLens.domain:
        return record.source == ProjectDecisionSource.domainExtension;
      case ProjectDecisionRegisterLens.closed:
        return !record.isOpen;
    }
  }
}
