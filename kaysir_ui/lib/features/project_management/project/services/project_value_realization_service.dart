import 'package:flutter/material.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../models/project_portfolio_item.dart';
import 'project_status_update_service.dart';
import 'project_timeline_health_service.dart';

enum ProjectValueRealizationLevel { recover, protect, validate, realizing }

enum ProjectValueRealizationKind {
  domainOutcome,
  deliveryPath,
  budgetValue,
  acceptanceProof,
  audienceSignal,
}

class ProjectValueRealizationItem {
  const ProjectValueRealizationItem({
    required this.title,
    required this.detail,
    required this.icon,
    required this.level,
    required this.kind,
  });

  final String title;
  final String detail;
  final IconData icon;
  final ProjectValueRealizationLevel level;
  final ProjectValueRealizationKind kind;
}

class ProjectValueRealizationSummary {
  const ProjectValueRealizationSummary({
    required this.vocabulary,
    required this.audience,
    required this.title,
    required this.subtitle,
    required this.valueThesis,
    required this.items,
    this.briefText = '',
  });

  final ProjectStatusUpdateVocabulary vocabulary;
  final ProjectStatusUpdateAudience audience;
  final String title;
  final String subtitle;
  final String valueThesis;
  final List<ProjectValueRealizationItem> items;
  final String briefText;

  int get recoverCount =>
      items
          .where((item) => item.level == ProjectValueRealizationLevel.recover)
          .length;

  int get protectCount =>
      items
          .where((item) => item.level == ProjectValueRealizationLevel.protect)
          .length;

  int get validateCount =>
      items
          .where((item) => item.level == ProjectValueRealizationLevel.validate)
          .length;

  int get realizingCount =>
      items
          .where((item) => item.level == ProjectValueRealizationLevel.realizing)
          .length;

  ProjectValueRealizationLevel get level {
    if (recoverCount > 0) return ProjectValueRealizationLevel.recover;
    if (protectCount > 0) return ProjectValueRealizationLevel.protect;
    if (validateCount > 0) return ProjectValueRealizationLevel.validate;

    return ProjectValueRealizationLevel.realizing;
  }

  ProjectValueRealizationItem get primaryItem {
    return items.firstWhere(
      (item) => item.level == level,
      orElse: () => items.first,
    );
  }
}

ProjectValueRealizationSummary buildProjectValueRealization({
  required ProjectPortfolioItem project,
  required List<gantt.GanttTask> timelineTasks,
  List<gantt.GanttTask>? dependencyTasks,
  ProjectStatusUpdateVocabulary vocabulary =
      ProjectStatusUpdateVocabulary.general,
  ProjectStatusUpdateAudience audience =
      ProjectStatusUpdateAudience.stakeholder,
  DateTime? today,
}) {
  final referenceDate = DateUtils.dateOnly(today ?? DateTime.now());
  final timelineHealth = buildProjectTimelineHealthRollup(
    tasks: timelineTasks,
    dependencyTasks: dependencyTasks,
    today: referenceDate,
  );
  final overdueMilestoneCount =
      project.milestones.where((milestone) {
        return !milestone.isComplete &&
            DateUtils.dateOnly(milestone.dueDate).isBefore(referenceDate);
      }).length;
  final nextMilestone = _nextOpenMilestone(project.milestones);
  final nextMilestoneDays =
      nextMilestone == null
          ? null
          : DateUtils.dateOnly(
            nextMilestone.dueDate,
          ).difference(referenceDate).inDays;
  final activeRiskCount =
      project.risks
          .where((risk) => risk.severity != ProjectHealth.onTrack)
          .length;
  final blockedRiskCount =
      project.risks
          .where((risk) => risk.severity == ProjectHealth.blocked)
          .length;
  final budgetDrift = project.budgetUsed - project.progress;
  final spec =
      _domainValueSpecs[vocabulary.id] ?? _domainValueSpecs['general']!;
  final level = _summaryLevel(
    project: project,
    timelineHealth: timelineHealth,
    overdueMilestoneCount: overdueMilestoneCount,
    blockedRiskCount: blockedRiskCount,
    activeRiskCount: activeRiskCount,
    budgetDrift: budgetDrift,
  );
  final items = [
    _domainOutcomeItem(spec: spec, level: level),
    _deliveryPathItem(
      vocabulary: vocabulary,
      timelineHealth: timelineHealth,
      dependencyBlockCount: timelineHealth.dependencyBlockCount,
    ),
    _budgetValueItem(vocabulary: vocabulary, project: project),
    _acceptanceProofItem(
      vocabulary: vocabulary,
      nextMilestone: nextMilestone,
      nextMilestoneDays: nextMilestoneDays,
      overdueMilestoneCount: overdueMilestoneCount,
    ),
    _audienceSignalItem(
      project: project,
      vocabulary: vocabulary,
      audience: audience,
      level: level,
    ),
  ];
  final title =
      vocabulary == ProjectStatusUpdateVocabulary.general
          ? 'Delivery value realization'
          : '${vocabulary.label} value realization';

  return ProjectValueRealizationSummary(
    vocabulary: vocabulary,
    audience: audience,
    title: title,
    subtitle: '${level.label} - ${spec.valueName} - ${items.length} signals',
    valueThesis: spec.valueThesis(project),
    items: List.unmodifiable(items),
    briefText: _valueRealizationBriefText(
      project: project,
      vocabulary: vocabulary,
      audience: audience,
      title: title,
      level: level,
      valueThesis: spec.valueThesis(project),
      items: items,
    ),
  );
}

ProjectValueRealizationLevel _summaryLevel({
  required ProjectPortfolioItem project,
  required ProjectTimelineHealthRollup timelineHealth,
  required int overdueMilestoneCount,
  required int blockedRiskCount,
  required int activeRiskCount,
  required double budgetDrift,
}) {
  if (project.health == ProjectHealth.blocked ||
      blockedRiskCount > 0 ||
      timelineHealth.dependencyBlockCount > 0 ||
      timelineHealth.overdueCount > 0 ||
      overdueMilestoneCount > 0) {
    return ProjectValueRealizationLevel.recover;
  }

  if (project.health == ProjectHealth.atRisk ||
      activeRiskCount > 0 ||
      budgetDrift >= 0.15 ||
      (project.budgetUsed >= 0.9 && project.progress < 0.85)) {
    return ProjectValueRealizationLevel.protect;
  }

  if (timelineHealth.totalTasks == 0 ||
      project.progress < 0.7 ||
      project.openMilestoneCount > 0) {
    return ProjectValueRealizationLevel.validate;
  }

  return ProjectValueRealizationLevel.realizing;
}

ProjectValueRealizationItem _domainOutcomeItem({
  required _DomainValueSpec spec,
  required ProjectValueRealizationLevel level,
}) {
  return ProjectValueRealizationItem(
    title: spec.titleFor(level),
    detail: spec.detailFor(level),
    icon: spec.icon,
    level: level,
    kind: ProjectValueRealizationKind.domainOutcome,
  );
}

ProjectValueRealizationItem _deliveryPathItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectTimelineHealthRollup timelineHealth,
  required int dependencyBlockCount,
}) {
  if (dependencyBlockCount > 0) {
    return ProjectValueRealizationItem(
      title: 'Recover blocked ${vocabulary.scheduleLabel} value path',
      detail:
          '$dependencyBlockCount dependency blocker${dependencyBlockCount == 1 ? '' : 's'} must be cleared before value can move safely.',
      icon: Icons.account_tree_outlined,
      level: ProjectValueRealizationLevel.recover,
      kind: ProjectValueRealizationKind.deliveryPath,
    );
  }

  if (timelineHealth.overdueCount > 0) {
    return ProjectValueRealizationItem(
      title: 'Recover delayed ${vocabulary.scheduleLabel} value path',
      detail:
          '${timelineHealth.overdueCount} overdue ${vocabulary.scheduleItemLabel}${timelineHealth.overdueCount == 1 ? '' : 's'} are delaying the outcome path.',
      icon: Icons.event_busy_outlined,
      level: ProjectValueRealizationLevel.recover,
      kind: ProjectValueRealizationKind.deliveryPath,
    );
  }

  if (timelineHealth.totalTasks == 0) {
    return ProjectValueRealizationItem(
      title: 'Map value workstream',
      detail:
          'Attach ${vocabulary.scheduleItemLabel}s so progress can be linked to outcome proof.',
      icon: Icons.add_link_outlined,
      level: ProjectValueRealizationLevel.validate,
      kind: ProjectValueRealizationKind.deliveryPath,
    );
  }

  if (timelineHealth.averageProgress >= 0.85) {
    return ProjectValueRealizationItem(
      title: 'Convert delivery into outcome proof',
      detail:
          '${(timelineHealth.averageProgress * 100).round()}% linked ${vocabulary.scheduleLabel} progress is ready to be turned into proof and handoff notes.',
      icon: Icons.workspace_premium_outlined,
      level: ProjectValueRealizationLevel.realizing,
      kind: ProjectValueRealizationKind.deliveryPath,
    );
  }

  return ProjectValueRealizationItem(
    title: 'Validate ${vocabulary.scheduleLabel} value path',
    detail:
        '${timelineHealth.totalTasks} linked ${vocabulary.scheduleItemLabel}${timelineHealth.totalTasks == 1 ? '' : 's'} show ${(timelineHealth.averageProgress * 100).round()}% delivery progress.',
    icon: Icons.timeline_outlined,
    level: ProjectValueRealizationLevel.validate,
    kind: ProjectValueRealizationKind.deliveryPath,
  );
}

ProjectValueRealizationItem _budgetValueItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectPortfolioItem project,
}) {
  final budgetDrift = project.budgetUsed - project.progress;

  if (project.budgetUsed >= 0.9 && project.progress < 0.85) {
    return ProjectValueRealizationItem(
      title: 'Recover ${vocabulary.budgetLabel} value leakage',
      detail:
          '${(project.budgetUsed * 100).round()}% spend with ${(project.progress * 100).round()}% progress needs value-protection action.',
      icon: Icons.account_balance_wallet_outlined,
      level: ProjectValueRealizationLevel.recover,
      kind: ProjectValueRealizationKind.budgetValue,
    );
  }

  if (budgetDrift >= 0.15) {
    return ProjectValueRealizationItem(
      title: 'Protect ${vocabulary.budgetLabel} value',
      detail:
          '${(budgetDrift * 100).round()} point spend/progress drift needs a benefit-backed decision.',
      icon: Icons.receipt_long_outlined,
      level: ProjectValueRealizationLevel.protect,
      kind: ProjectValueRealizationKind.budgetValue,
    );
  }

  return ProjectValueRealizationItem(
    title: 'Keep ${vocabulary.budgetLabel} value healthy',
    detail:
        '${(project.budgetUsed * 100).round()}% spend against ${(project.progress * 100).round()}% progress keeps value tracking lightweight.',
    icon: Icons.savings_outlined,
    level: ProjectValueRealizationLevel.realizing,
    kind: ProjectValueRealizationKind.budgetValue,
  );
}

ProjectValueRealizationItem _acceptanceProofItem({
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectMilestone? nextMilestone,
  required int? nextMilestoneDays,
  required int overdueMilestoneCount,
}) {
  if (overdueMilestoneCount > 0) {
    return ProjectValueRealizationItem(
      title: 'Recover overdue ${vocabulary.milestoneLabel} proof',
      detail:
          '$overdueMilestoneCount overdue ${vocabulary.milestoneLabel}${overdueMilestoneCount == 1 ? '' : 's'} need outcome evidence before value can be claimed.',
      icon: Icons.assignment_late_outlined,
      level: ProjectValueRealizationLevel.recover,
      kind: ProjectValueRealizationKind.acceptanceProof,
    );
  }

  if (nextMilestone == null) {
    return ProjectValueRealizationItem(
      title: 'Package completion evidence',
      detail:
          'All ${vocabulary.milestoneLabel}s are complete; keep proof ready for value reporting.',
      icon: Icons.inventory_2_outlined,
      level: ProjectValueRealizationLevel.realizing,
      kind: ProjectValueRealizationKind.acceptanceProof,
    );
  }

  if (nextMilestoneDays != null && nextMilestoneDays <= 14) {
    return ProjectValueRealizationItem(
      title: 'Validate ${nextMilestone.label} value proof',
      detail:
          'The next ${vocabulary.milestoneLabel} is due ${nextMilestoneDays < 0 ? 'now' : 'in ${nextMilestoneDays}d'}; prepare acceptance proof before the update.',
      icon: Icons.fact_check_outlined,
      level: ProjectValueRealizationLevel.protect,
      kind: ProjectValueRealizationKind.acceptanceProof,
    );
  }

  return ProjectValueRealizationItem(
    title: 'Keep ${vocabulary.milestoneLabel} value proof moving',
    detail:
        '${nextMilestone.label} is the next proof point for outcome reporting.',
    icon: Icons.flag_outlined,
    level: ProjectValueRealizationLevel.validate,
    kind: ProjectValueRealizationKind.acceptanceProof,
  );
}

ProjectValueRealizationItem _audienceSignalItem({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectStatusUpdateAudience audience,
  required ProjectValueRealizationLevel level,
}) {
  switch (audience) {
    case ProjectStatusUpdateAudience.stakeholder:
      return ProjectValueRealizationItem(
        title: 'Publish stakeholder value signal',
        detail:
            'Connect ${vocabulary.workLabel} progress to outcome, proof, and the next decision.',
        icon: audience.icon,
        level:
            level == ProjectValueRealizationLevel.realizing
                ? ProjectValueRealizationLevel.validate
                : level,
        kind: ProjectValueRealizationKind.audienceSignal,
      );
    case ProjectStatusUpdateAudience.sponsor:
      return ProjectValueRealizationItem(
        title: 'Confirm sponsor value decision',
        detail:
            'Show ${project.sponsor.isEmpty ? project.owner : project.sponsor} where value is protected, delayed, or ready to claim.',
        icon: audience.icon,
        level:
            level == ProjectValueRealizationLevel.recover
                ? ProjectValueRealizationLevel.protect
                : level,
        kind: ProjectValueRealizationKind.audienceSignal,
      );
    case ProjectStatusUpdateAudience.team:
      return ProjectValueRealizationItem(
        title: 'Turn value signals into team actions',
        detail:
            'Translate outcome risk into owner-ready ${vocabulary.scheduleItemLabel}s for ${project.owner}.',
        icon: audience.icon,
        level: ProjectValueRealizationLevel.validate,
        kind: ProjectValueRealizationKind.audienceSignal,
      );
    case ProjectStatusUpdateAudience.client:
      return ProjectValueRealizationItem(
        title: 'Confirm client value story',
        detail:
            'Show ${project.client} what changed, what proof exists, and what outcome is still being protected.',
        icon: audience.icon,
        level:
            level == ProjectValueRealizationLevel.realizing
                ? ProjectValueRealizationLevel.validate
                : level,
        kind: ProjectValueRealizationKind.audienceSignal,
      );
  }
}

ProjectMilestone? _nextOpenMilestone(List<ProjectMilestone> milestones) {
  final openMilestones =
      milestones.where((milestone) => !milestone.isComplete).toList()
        ..sort((first, second) => first.dueDate.compareTo(second.dueDate));

  if (openMilestones.isEmpty) return null;

  return openMilestones.first;
}

String _valueRealizationBriefText({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectStatusUpdateAudience audience,
  required String title,
  required ProjectValueRealizationLevel level,
  required String valueThesis,
  required List<ProjectValueRealizationItem> items,
}) {
  final primaryItem = items.firstWhere(
    (item) => item.level == level,
    orElse: () => items.first,
  );

  return [
    '$title brief',
    'Status: ${level.label}',
    'Audience: ${audience.summaryLabel(vocabulary)}',
    'Owner: ${project.owner}',
    'Value thesis: $valueThesis',
    '',
    'Primary value signal',
    '- ${primaryItem.title}: ${primaryItem.detail}',
    '',
    'Outcome proof path',
    for (final item in items)
      if (item != primaryItem) '- ${item.title}: ${item.detail}',
    '',
    'Value rule',
    '- Only claim value when ${vocabulary.scheduleLabel}, ${vocabulary.milestoneLabel}, ${vocabulary.budgetLabel}, and audience proof tell the same story.',
  ].join('\n');
}

extension ProjectValueRealizationLevelPresentation
    on ProjectValueRealizationLevel {
  String get label {
    switch (this) {
      case ProjectValueRealizationLevel.recover:
        return 'Recover';
      case ProjectValueRealizationLevel.protect:
        return 'Protect';
      case ProjectValueRealizationLevel.validate:
        return 'Validate';
      case ProjectValueRealizationLevel.realizing:
        return 'Realizing';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectValueRealizationLevel.recover:
        return Icons.priority_high_rounded;
      case ProjectValueRealizationLevel.protect:
        return Icons.shield_outlined;
      case ProjectValueRealizationLevel.validate:
        return Icons.fact_check_outlined;
      case ProjectValueRealizationLevel.realizing:
        return Icons.workspace_premium_outlined;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectValueRealizationLevel.recover:
        return colorScheme.error;
      case ProjectValueRealizationLevel.protect:
        return Colors.orange.shade700;
      case ProjectValueRealizationLevel.validate:
        return colorScheme.primary;
      case ProjectValueRealizationLevel.realizing:
        return Colors.green.shade700;
    }
  }
}

class _DomainValueSpec {
  const _DomainValueSpec({
    required this.icon,
    required this.valueName,
    required this.valuePhrase,
    required this.recoverTitle,
    required this.protectTitle,
    required this.validateTitle,
    required this.realizingTitle,
    required this.recoverDetail,
    required this.protectDetail,
    required this.validateDetail,
    required this.realizingDetail,
  });

  final IconData icon;
  final String valueName;
  final String valuePhrase;
  final String recoverTitle;
  final String protectTitle;
  final String validateTitle;
  final String realizingTitle;
  final String recoverDetail;
  final String protectDetail;
  final String validateDetail;
  final String realizingDetail;

  String valueThesis(ProjectPortfolioItem project) {
    return '${project.name} should produce $valuePhrase for ${project.client}.';
  }

  String titleFor(ProjectValueRealizationLevel level) {
    switch (level) {
      case ProjectValueRealizationLevel.recover:
        return recoverTitle;
      case ProjectValueRealizationLevel.protect:
        return protectTitle;
      case ProjectValueRealizationLevel.validate:
        return validateTitle;
      case ProjectValueRealizationLevel.realizing:
        return realizingTitle;
    }
  }

  String detailFor(ProjectValueRealizationLevel level) {
    switch (level) {
      case ProjectValueRealizationLevel.recover:
        return recoverDetail;
      case ProjectValueRealizationLevel.protect:
        return protectDetail;
      case ProjectValueRealizationLevel.validate:
        return validateDetail;
      case ProjectValueRealizationLevel.realizing:
        return realizingDetail;
    }
  }
}

const _domainValueSpecs = {
  'general': _DomainValueSpec(
    icon: Icons.insights_outlined,
    valueName: 'business outcome',
    valuePhrase: 'measurable business outcome and adoption confidence',
    recoverTitle: 'Recover value promise',
    protectTitle: 'Protect value promise',
    validateTitle: 'Validate value path',
    realizingTitle: 'Realize value promise',
    recoverDetail:
        'Outcome value is blocked or delayed; focus recovery on proof, owner, and decision clarity.',
    protectDetail:
        'Outcome value is exposed; protect the promise with scope, timing, and budget decisions.',
    validateDetail:
        'Outcome value is forming; connect delivery progress to proof and stakeholder acceptance.',
    realizingDetail:
        'Outcome value is ready to claim; package evidence and keep benefit ownership visible.',
  ),
  'construction': _DomainValueSpec(
    icon: Icons.construction_outlined,
    valueName: 'handover outcome',
    valuePhrase: 'site handover confidence, phase readiness, and cost control',
    recoverTitle: 'Recover handover value',
    protectTitle: 'Protect handover value',
    validateTitle: 'Validate phase value path',
    realizingTitle: 'Realize handover value',
    recoverDetail:
        'Site value is blocked; recover phase, supplier, safety, or permit proof before claiming progress.',
    protectDetail:
        'Handover value is exposed; keep cost, phase, and readiness decisions explicit.',
    validateDetail:
        'Phase value is forming; tie work packages to inspection and acceptance proof.',
    realizingDetail:
        'Handover value is ready to show through phase evidence and owner-ready notes.',
  ),
  'software': _DomainValueSpec(
    icon: Icons.code_outlined,
    valueName: 'release outcome',
    valuePhrase: 'release adoption, user readiness, and operational confidence',
    recoverTitle: 'Recover release adoption value',
    protectTitle: 'Protect release outcome',
    validateTitle: 'Validate release value path',
    realizingTitle: 'Realize release impact',
    recoverDetail:
        'Release value is blocked; recover dependency, QA, rollout, or adoption proof first.',
    protectDetail:
        'Release value is exposed; protect adoption with clear scope and acceptance decisions.',
    validateDetail:
        'Release value is forming; tie work items to acceptance, rollout, and user proof.',
    realizingDetail:
        'Release value is ready to claim through adoption evidence and support handoff.',
  ),
  'event-production': _DomainValueSpec(
    icon: Icons.event_outlined,
    valueName: 'show outcome',
    valuePhrase: 'run-of-show confidence, guest experience, and sponsor proof',
    recoverTitle: 'Recover show value',
    protectTitle: 'Protect show value',
    validateTitle: 'Validate production value path',
    realizingTitle: 'Realize show impact',
    recoverDetail:
        'Event value is blocked; recover vendor, venue, talent, or contingency proof first.',
    protectDetail:
        'Show value is exposed; protect the experience with run-sheet and vendor decisions.',
    validateDetail:
        'Production value is forming; connect run-sheet tasks to guest-impact proof.',
    realizingDetail:
        'Show value is ready to claim through run-of-show evidence and sponsor notes.',
  ),
  'government': _DomainValueSpec(
    icon: Icons.account_balance_outlined,
    valueName: 'public outcome',
    valuePhrase: 'public service impact, accountability, and compliance proof',
    recoverTitle: 'Recover public outcome',
    protectTitle: 'Protect public value',
    validateTitle: 'Validate implementation value',
    realizingTitle: 'Realize public impact',
    recoverDetail:
        'Public value is blocked; recover approval, funding, compliance, or accountability proof.',
    protectDetail:
        'Public value is exposed; protect outcome claims with governance-ready decisions.',
    validateDetail:
        'Implementation value is forming; tie program actions to public-impact proof.',
    realizingDetail:
        'Public value is ready to report through compliance evidence and benefit notes.',
  ),
  'education': _DomainValueSpec(
    icon: Icons.school_outlined,
    valueName: 'learning outcome',
    valuePhrase: 'learner readiness, academic continuity, and program proof',
    recoverTitle: 'Recover learning outcome',
    protectTitle: 'Protect learning value',
    validateTitle: 'Validate academic value path',
    realizingTitle: 'Realize learning impact',
    recoverDetail:
        'Learning value is blocked; recover curriculum, faculty, calendar, or learner-support proof.',
    protectDetail:
        'Learning value is exposed; protect academic continuity with explicit decisions.',
    validateDetail:
        'Academic value is forming; tie learning operations tasks to learner proof.',
    realizingDetail:
        'Learning value is ready to claim through academic evidence and support handoff.',
  ),
  'wedding': _DomainValueSpec(
    icon: Icons.celebration_outlined,
    valueName: 'client experience',
    valuePhrase: 'client confidence, guest experience, and vendor readiness',
    recoverTitle: 'Recover wedding experience value',
    protectTitle: 'Protect wedding experience',
    validateTitle: 'Validate planning value path',
    realizingTitle: 'Realize wedding experience',
    recoverDetail:
        'Client experience value is blocked; recover vendor, venue, guest, or day-of proof.',
    protectDetail:
        'Wedding value is exposed; protect the experience with client-visible planning decisions.',
    validateDetail:
        'Planning value is forming; connect planning tasks to vendor and day-of proof.',
    realizingDetail:
        'Wedding value is ready to show through vendor evidence and client-ready notes.',
  ),
};
