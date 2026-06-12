import '../accounting_path.dart';
import '../models/accounting_menu_catalog.dart';
import '../models/accounting_menu_search.dart';
import '../models/accounting_workspace_role_preset.dart';
import '../models/accounting_workspace_work_queue.dart';
import '../models/accounting_workspace_work_queue_accounting_impact.dart';
import '../models/accounting_workspace_work_queue_clearance_checklist.dart';
import '../models/accounting_workspace_work_queue_close_readiness.dart';
import '../models/accounting_workspace_work_queue_compliance_guardrail.dart';
import '../models/accounting_workspace_work_queue_detail.dart';
import '../models/accounting_workspace_work_queue_escalation_plan.dart';
import '../models/accounting_workspace_work_queue_focus.dart';
import '../models/accounting_workspace_work_queue_health.dart';
import '../models/accounting_workspace_work_queue_owner_summary.dart';
import '../models/accounting_workspace_work_queue_risk_summary.dart';
import '../models/accounting_workspace_work_queue_sort.dart';
import '../models/accounting_workspace_work_queue_sla_summary.dart';
import 'accounting_workspace_work_queue_accounting_impact_resolver.dart';
import 'accounting_workspace_work_queue_activity_builder.dart';
import 'accounting_workspace_work_queue_evidence_request_builder.dart';

class AccountingWorkspaceWorkQueueService {
  const AccountingWorkspaceWorkQueueService();

  static const _accountingImpactResolver =
      AccountingWorkspaceWorkQueueAccountingImpactResolver();
  static const _activityBuilder = AccountingWorkspaceWorkQueueActivityBuilder();
  static const _evidenceRequestBuilder =
      AccountingWorkspaceWorkQueueEvidenceRequestBuilder();

  List<AccountingWorkspaceWorkQueue> queuesFor({
    required AccountingWorkspaceRolePreset rolePreset,
    String query = '',
    AccountingMenuSearchScope scope = AccountingMenuSearchScope.all,
    Iterable<AccountingMenuDestination>? destinations,
  }) {
    final effectiveDestinations = destinations ?? accountingMenuDestinations;
    final destinationByPath = {
      for (final destination in effectiveDestinations)
        destination.path: destination,
    };
    final queues = <AccountingWorkspaceWorkQueue>[];

    for (final template in _templatesForRole(rolePreset)) {
      final destination = destinationByPath[template.path];
      if (destination == null || !_matchesScope(destination, scope)) continue;

      final queue = AccountingWorkspaceWorkQueue(
        id: template.id,
        title: template.title,
        description: template.description,
        count: template.count,
        severity: template.severity,
        ownerLabel: template.ownerLabel,
        dueInDays: template.dueInDays,
        icon: destination.icon,
        path: destination.path,
        registerRoute: destination.registerRoute,
      );
      if (_matchesQuery(queue, destination, query)) {
        queues.add(queue);
      }
    }

    return List<AccountingWorkspaceWorkQueue>.unmodifiable(queues);
  }

  List<AccountingWorkspaceWorkQueue> filterByFocus(
    Iterable<AccountingWorkspaceWorkQueue> queues,
    AccountingWorkspaceWorkQueueFocus focus,
  ) {
    return List<AccountingWorkspaceWorkQueue>.unmodifiable(
      queues.where((queue) => _matchesFocus(queue, focus)),
    );
  }

  List<AccountingWorkspaceWorkQueue> filterByOwner(
    Iterable<AccountingWorkspaceWorkQueue> queues,
    String? ownerLabel,
  ) {
    final normalizedOwnerLabel = ownerLabel?.trim().toLowerCase();
    if (normalizedOwnerLabel == null || normalizedOwnerLabel.isEmpty) {
      return List<AccountingWorkspaceWorkQueue>.unmodifiable(queues);
    }

    return List<AccountingWorkspaceWorkQueue>.unmodifiable(
      queues.where(
        (queue) =>
            queue.ownerLabel.trim().toLowerCase() == normalizedOwnerLabel,
      ),
    );
  }

  List<AccountingWorkspaceWorkQueue> sortQueues(
    Iterable<AccountingWorkspaceWorkQueue> queues,
    AccountingWorkspaceWorkQueueSort sort,
  ) {
    final sortedQueues = queues.toList();
    switch (sort) {
      case AccountingWorkspaceWorkQueueSort.workflow:
        return List<AccountingWorkspaceWorkQueue>.unmodifiable(sortedQueues);
      case AccountingWorkspaceWorkQueueSort.urgent:
        sortedQueues.sort(_compareQueuesByUrgency);
      case AccountingWorkspaceWorkQueueSort.largest:
        sortedQueues.sort(_compareQueuesByLargestLoad);
      case AccountingWorkspaceWorkQueueSort.owner:
        sortedQueues.sort(_compareQueuesByOwner);
    }

    return List<AccountingWorkspaceWorkQueue>.unmodifiable(sortedQueues);
  }

  AccountingWorkspaceWorkQueueDetail detailFor(
    AccountingWorkspaceWorkQueue queue,
  ) {
    final rootCause = _detailRootCause(queue);
    final evidenceNeeded = _detailEvidenceNeeded(queue);
    final controlObjective = _detailControlObjective(queue);
    final recommendedAction = _detailRecommendedAction(queue);
    final riskSummary = _detailRiskSummary(queue);
    final escalationPlan = _detailEscalationPlan(
      queue: queue,
      riskSummary: riskSummary,
    );
    final clearanceChecklist = _detailClearanceChecklist(
      queue: queue,
      evidenceNeeded: evidenceNeeded,
      riskSummary: riskSummary,
      escalationPlan: escalationPlan,
    );
    final complianceGuardrail = _detailComplianceGuardrail(queue);
    final accountingImpact = _accountingImpactResolver.resolve(queue);
    final evidenceRequest = _evidenceRequestBuilder.build(
      queue: queue,
      evidenceNeeded: evidenceNeeded,
      recommendedAction: recommendedAction,
      riskSummary: riskSummary,
      escalationPlan: escalationPlan,
      complianceGuardrail: complianceGuardrail,
      accountingImpact: accountingImpact,
    );
    final activityTrail = _activityBuilder.build(
      queue: queue,
      riskSummary: riskSummary,
      escalationPlan: escalationPlan,
      clearanceChecklist: clearanceChecklist,
      complianceGuardrail: complianceGuardrail,
      accountingImpact: accountingImpact,
      evidenceRequest: evidenceRequest,
    );

    return AccountingWorkspaceWorkQueueDetail(
      queueId: queue.id,
      rootCause: rootCause,
      evidenceNeeded: evidenceNeeded,
      controlObjective: controlObjective,
      recommendedAction: recommendedAction,
      riskSummary: riskSummary,
      escalationPlan: escalationPlan,
      clearanceChecklist: clearanceChecklist,
      complianceGuardrail: complianceGuardrail,
      accountingImpact: accountingImpact,
      evidenceRequest: evidenceRequest,
      activityTrail: activityTrail,
      ownerBrief: _detailOwnerBrief(
        queue: queue,
        rootCause: rootCause,
        evidenceNeeded: evidenceNeeded,
        controlObjective: controlObjective,
        recommendedAction: recommendedAction,
        riskSummary: riskSummary,
        escalationPlan: escalationPlan,
        clearanceChecklist: clearanceChecklist,
        complianceGuardrail: complianceGuardrail,
        accountingImpact: accountingImpact,
      ),
      checkpoints: _detailCheckpoints(queue),
    );
  }

  AccountingWorkspaceWorkQueueHealth summarize(
    Iterable<AccountingWorkspaceWorkQueue> queues,
  ) {
    var queueCount = 0;
    var totalItems = 0;
    var blockedItems = 0;
    var reviewItems = 0;
    var monitorItems = 0;

    for (final queue in queues) {
      queueCount += 1;
      totalItems += queue.count;

      switch (queue.severity) {
        case AccountingWorkspaceWorkQueueSeverity.critical:
          blockedItems += queue.count;
        case AccountingWorkspaceWorkQueueSeverity.warning:
          reviewItems += queue.count;
        case AccountingWorkspaceWorkQueueSeverity.info:
          monitorItems += queue.count;
      }
    }

    return AccountingWorkspaceWorkQueueHealth(
      queueCount: queueCount,
      totalItems: totalItems,
      blockedItems: blockedItems,
      reviewItems: reviewItems,
      monitorItems: monitorItems,
    );
  }

  AccountingWorkspaceWorkQueueSlaSummary summarizeSla(
    Iterable<AccountingWorkspaceWorkQueue> queues,
  ) {
    var queueCount = 0;
    var overdueQueueCount = 0;
    var dueTodayQueueCount = 0;
    var onTrackQueueCount = 0;
    var overdueItems = 0;
    var dueTodayItems = 0;
    var onTrackItems = 0;
    var worstOverdueDays = 0;

    for (final queue in queues) {
      queueCount += 1;

      switch (queue.slaStatus) {
        case AccountingWorkspaceWorkQueueSlaStatus.overdue:
          overdueQueueCount += 1;
          overdueItems += queue.count;
          final overdueDays = queue.dueInDays.abs();
          if (overdueDays > worstOverdueDays) {
            worstOverdueDays = overdueDays;
          }
        case AccountingWorkspaceWorkQueueSlaStatus.dueToday:
          dueTodayQueueCount += 1;
          dueTodayItems += queue.count;
        case AccountingWorkspaceWorkQueueSlaStatus.onTrack:
          onTrackQueueCount += 1;
          onTrackItems += queue.count;
      }
    }

    return AccountingWorkspaceWorkQueueSlaSummary(
      queueCount: queueCount,
      overdueQueueCount: overdueQueueCount,
      dueTodayQueueCount: dueTodayQueueCount,
      onTrackQueueCount: onTrackQueueCount,
      overdueItems: overdueItems,
      dueTodayItems: dueTodayItems,
      onTrackItems: onTrackItems,
      worstOverdueDays: worstOverdueDays,
    );
  }

  AccountingWorkspaceWorkQueueOwnerSummary summarizeOwners(
    Iterable<AccountingWorkspaceWorkQueue> queues,
  ) {
    final owners = <String, _AccountingWorkspaceWorkQueueOwnerAccumulator>{};

    for (final queue in queues) {
      owners
          .putIfAbsent(
            queue.ownerLabel,
            () => _AccountingWorkspaceWorkQueueOwnerAccumulator(
              ownerLabel: queue.ownerLabel,
            ),
          )
          .record(queue);
    }

    final loads =
        owners.values.map((owner) => owner.toOwnerLoad()).toList()
          ..sort(_compareOwnerLoads);

    return AccountingWorkspaceWorkQueueOwnerSummary(
      owners: List<AccountingWorkspaceWorkQueueOwnerLoad>.unmodifiable(loads),
    );
  }

  AccountingWorkspaceWorkQueueCloseReadiness summarizeCloseReadiness(
    Iterable<AccountingWorkspaceWorkQueue> queues,
  ) {
    var queueCount = 0;
    var totalItems = 0;
    var releaseBlockerItems = 0;
    var evidenceRequestItems = 0;
    var postingGateItems = 0;
    final nextQueueCandidates = <_CloseReadinessNextQueueCandidate>[];

    for (final queue in queues) {
      queueCount += 1;
      totalItems += queue.count;

      if (queue.severity == AccountingWorkspaceWorkQueueSeverity.critical) {
        releaseBlockerItems += queue.count;
      }

      if (queue.slaStatus != AccountingWorkspaceWorkQueueSlaStatus.onTrack) {
        evidenceRequestItems += queue.count;
      }

      final impact = _accountingImpactResolver.resolve(queue);
      if (impact.requiresPostingGate) {
        postingGateItems += queue.count;
      }

      final candidate = _closeReadinessNextQueueCandidate(
        queue,
        requiresPostingGate: impact.requiresPostingGate,
      );
      nextQueueCandidates.add(candidate);
    }

    final rankedCandidates =
        (nextQueueCandidates..sort(_compareCloseReadinessNextQueueCandidates))
            .take(3)
            .toList();
    final actionPlan = [
      for (var index = 0; index < rankedCandidates.length; index++)
        rankedCandidates[index].toNextAction(rank: index + 1),
    ];

    return AccountingWorkspaceWorkQueueCloseReadiness(
      queueCount: queueCount,
      totalItems: totalItems,
      releaseBlockerItems: releaseBlockerItems,
      evidenceRequestItems: evidenceRequestItems,
      postingGateItems: postingGateItems,
      actionPlan: actionPlan,
    );
  }
}

_CloseReadinessNextQueueCandidate _closeReadinessNextQueueCandidate(
  AccountingWorkspaceWorkQueue queue, {
  required bool requiresPostingGate,
}) {
  var priorityScore = queue.count;
  var reasonLabel = 'Readiness watch';
  var urgencyLabel = 'Monitor';

  switch (queue.severity) {
    case AccountingWorkspaceWorkQueueSeverity.critical:
      priorityScore += 100;
      reasonLabel = 'Release blocker';
      urgencyLabel = 'Critical';
    case AccountingWorkspaceWorkQueueSeverity.warning:
      priorityScore += 45;
      reasonLabel = 'Review queue';
    case AccountingWorkspaceWorkQueueSeverity.info:
      priorityScore += 10;
  }

  switch (queue.slaStatus) {
    case AccountingWorkspaceWorkQueueSlaStatus.overdue:
      priorityScore += 60 + queue.dueInDays.abs();
      if (queue.severity != AccountingWorkspaceWorkQueueSeverity.critical) {
        reasonLabel = 'Evidence overdue';
        urgencyLabel = 'Overdue';
      } else {
        urgencyLabel = 'Critical overdue';
      }
    case AccountingWorkspaceWorkQueueSlaStatus.dueToday:
      priorityScore += 35;
      if (queue.severity != AccountingWorkspaceWorkQueueSeverity.critical) {
        reasonLabel = 'Evidence due today';
        urgencyLabel = 'Due today';
      } else {
        urgencyLabel = 'Critical due today';
      }
    case AccountingWorkspaceWorkQueueSlaStatus.onTrack:
      break;
  }

  if (requiresPostingGate) {
    priorityScore += 25;
    if (queue.severity == AccountingWorkspaceWorkQueueSeverity.info &&
        queue.slaStatus == AccountingWorkspaceWorkQueueSlaStatus.onTrack) {
      reasonLabel = 'Posting gate';
    }
    if (urgencyLabel == 'Monitor') {
      urgencyLabel = 'Posting review';
    }
  }

  return _CloseReadinessNextQueueCandidate(
    queue: queue,
    priorityScore: priorityScore,
    urgencyLabel: urgencyLabel,
    reasonLabel: reasonLabel,
  );
}

int _compareCloseReadinessNextQueueCandidates(
  _CloseReadinessNextQueueCandidate a,
  _CloseReadinessNextQueueCandidate b,
) {
  final scoreComparison = b.priorityScore.compareTo(a.priorityScore);
  if (scoreComparison != 0) return scoreComparison;

  final countComparison = b.queue.count.compareTo(a.queue.count);
  if (countComparison != 0) return countComparison;

  return a.queue.dueInDays.compareTo(b.queue.dueInDays);
}

class _CloseReadinessNextQueueCandidate {
  const _CloseReadinessNextQueueCandidate({
    required this.queue,
    required this.priorityScore,
    required this.urgencyLabel,
    required this.reasonLabel,
  });

  final AccountingWorkspaceWorkQueue queue;
  final int priorityScore;
  final String urgencyLabel;
  final String reasonLabel;

  AccountingWorkspaceWorkQueueCloseReadinessNextAction toNextAction({
    required int rank,
  }) {
    return AccountingWorkspaceWorkQueueCloseReadinessNextAction(
      rank: rank,
      queueId: queue.id,
      title: queue.title,
      urgencyLabel: urgencyLabel,
      ownerLabel: queue.ownerLabel,
      dueLabel: queue.dueLabel,
      reasonLabel: reasonLabel,
    );
  }
}

int _compareOwnerLoads(
  AccountingWorkspaceWorkQueueOwnerLoad a,
  AccountingWorkspaceWorkQueueOwnerLoad b,
) {
  final overdueComparison = b.overdueItems.compareTo(a.overdueItems);
  if (overdueComparison != 0) return overdueComparison;

  final dueTodayComparison = b.dueTodayItems.compareTo(a.dueTodayItems);
  if (dueTodayComparison != 0) return dueTodayComparison;

  final criticalComparison = b.criticalItems.compareTo(a.criticalItems);
  if (criticalComparison != 0) return criticalComparison;

  final totalComparison = b.totalItems.compareTo(a.totalItems);
  if (totalComparison != 0) return totalComparison;

  return a.ownerLabel.compareTo(b.ownerLabel);
}

class _AccountingWorkspaceWorkQueueOwnerAccumulator {
  _AccountingWorkspaceWorkQueueOwnerAccumulator({required this.ownerLabel});

  final String ownerLabel;
  var queueCount = 0;
  var totalItems = 0;
  var overdueItems = 0;
  var dueTodayItems = 0;
  var onTrackItems = 0;
  var criticalItems = 0;
  var worstOverdueDays = 0;

  void record(AccountingWorkspaceWorkQueue queue) {
    queueCount += 1;
    totalItems += queue.count;

    if (queue.severity == AccountingWorkspaceWorkQueueSeverity.critical) {
      criticalItems += queue.count;
    }

    switch (queue.slaStatus) {
      case AccountingWorkspaceWorkQueueSlaStatus.overdue:
        overdueItems += queue.count;
        final overdueDays = queue.dueInDays.abs();
        if (overdueDays > worstOverdueDays) {
          worstOverdueDays = overdueDays;
        }
      case AccountingWorkspaceWorkQueueSlaStatus.dueToday:
        dueTodayItems += queue.count;
      case AccountingWorkspaceWorkQueueSlaStatus.onTrack:
        onTrackItems += queue.count;
    }
  }

  AccountingWorkspaceWorkQueueOwnerLoad toOwnerLoad() {
    return AccountingWorkspaceWorkQueueOwnerLoad(
      ownerLabel: ownerLabel,
      queueCount: queueCount,
      totalItems: totalItems,
      overdueItems: overdueItems,
      dueTodayItems: dueTodayItems,
      onTrackItems: onTrackItems,
      criticalItems: criticalItems,
      worstOverdueDays: worstOverdueDays,
    );
  }
}

int _compareQueuesByUrgency(
  AccountingWorkspaceWorkQueue a,
  AccountingWorkspaceWorkQueue b,
) {
  final dueComparison = a.dueInDays.compareTo(b.dueInDays);
  if (dueComparison != 0) return dueComparison;

  final severityComparison = _severityRank(
    b.severity,
  ).compareTo(_severityRank(a.severity));
  if (severityComparison != 0) return severityComparison;

  final countComparison = b.count.compareTo(a.count);
  if (countComparison != 0) return countComparison;

  return a.title.compareTo(b.title);
}

int _compareQueuesByLargestLoad(
  AccountingWorkspaceWorkQueue a,
  AccountingWorkspaceWorkQueue b,
) {
  final countComparison = b.count.compareTo(a.count);
  if (countComparison != 0) return countComparison;

  return _compareQueuesByUrgency(a, b);
}

int _compareQueuesByOwner(
  AccountingWorkspaceWorkQueue a,
  AccountingWorkspaceWorkQueue b,
) {
  final ownerComparison = a.ownerLabel.compareTo(b.ownerLabel);
  if (ownerComparison != 0) return ownerComparison;

  return _compareQueuesByUrgency(a, b);
}

int _severityRank(AccountingWorkspaceWorkQueueSeverity severity) {
  switch (severity) {
    case AccountingWorkspaceWorkQueueSeverity.info:
      return 1;
    case AccountingWorkspaceWorkQueueSeverity.warning:
      return 2;
    case AccountingWorkspaceWorkQueueSeverity.critical:
      return 3;
  }
}

bool _matchesFocus(
  AccountingWorkspaceWorkQueue queue,
  AccountingWorkspaceWorkQueueFocus focus,
) {
  switch (focus) {
    case AccountingWorkspaceWorkQueueFocus.all:
      return true;
    case AccountingWorkspaceWorkQueueFocus.blocked:
      return queue.severity == AccountingWorkspaceWorkQueueSeverity.critical;
    case AccountingWorkspaceWorkQueueFocus.review:
      return queue.severity == AccountingWorkspaceWorkQueueSeverity.warning;
    case AccountingWorkspaceWorkQueueFocus.monitor:
      return queue.severity == AccountingWorkspaceWorkQueueSeverity.info;
  }
}

bool _matchesScope(
  AccountingMenuDestination destination,
  AccountingMenuSearchScope scope,
) {
  switch (scope) {
    case AccountingMenuSearchScope.all:
      return true;
    case AccountingMenuSearchScope.screens:
      return destination.registerRoute;
    case AccountingMenuSearchScope.shortcuts:
      return !destination.registerRoute;
  }
}

bool _matchesQuery(
  AccountingWorkspaceWorkQueue queue,
  AccountingMenuDestination destination,
  String query,
) {
  final terms =
      query
          .trim()
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((term) => term.isNotEmpty)
          .toList();
  if (terms.isEmpty) return true;

  final haystack =
      [
        queue.title,
        queue.description,
        queue.ownerLabel,
        queue.dueLabel,
        queue.path,
        destination.name,
        destination.subtitle,
      ].join(' ').toLowerCase();

  return terms.every(haystack.contains);
}

String _detailRootCause(AccountingWorkspaceWorkQueue queue) {
  final itemLabel = _workQueueItemLabel(queue.count);

  switch (queue.slaStatus) {
    case AccountingWorkspaceWorkQueueSlaStatus.overdue:
      return '${queue.ownerLabel} has $itemLabel past SLA, so close or report release cannot move cleanly until the support is resolved.';
    case AccountingWorkspaceWorkQueueSlaStatus.dueToday:
      return '${queue.ownerLabel} has $itemLabel due today; reviewer action is needed before the queue becomes an SLA breach.';
    case AccountingWorkspaceWorkQueueSlaStatus.onTrack:
      return '${queue.ownerLabel} is carrying $itemLabel that still needs monitoring and evidence hygiene before the due date.';
  }
}

String _detailEvidenceNeeded(AccountingWorkspaceWorkQueue queue) {
  switch (queue.path) {
    case AccountingPath.reportReleaseEvidence:
      return 'Release manifest support, source schedules, reviewer notes, and audit-ready retention reference.';
    case AccountingPath.reportReleaseSignOff:
      return 'Approval matrix, reviewer sign-off notes, management representation, and release checklist support.';
    case AccountingPath.reportReleaseStatutoryFiling:
      return 'SPT or PPN support, statutory filing checklist, tax reconciliation, and submission evidence.';
    case AccountingPath.bankReconciliation:
      return 'Bank statement lines, matching rationale, timing difference aging, and resolution owner notes.';
    case AccountingPath.periodClose:
      return 'Close checklist evidence, blocker owner update, lock decision, and unresolved exception summary.';
    case AccountingPath.reportPack:
      return 'Report pack schedule, variance explanation, export control evidence, and reviewer exception notes.';
    case AccountingPath.financialNotes:
      return 'Disclosure checklist, note support schedule, reviewer evidence, and IFRS/SAK mapping reference.';
    case AccountingPath.entryHistory:
    case AccountingPath.gl:
      return 'Journal source document, preparer and reviewer trail, account mapping, and posting evidence.';
    case AccountingPath.accPayable:
      return 'Supplier bill support, payment approval, withholding tax check, and payable reconciliation note.';
    case AccountingPath.accReceivable:
      return 'Invoice support, collection action note, customer correspondence, and receivable aging evidence.';
    case AccountingPath.policy:
      return 'Policy decision note, entity setup review, tax treatment support, and approval evidence.';
    case AccountingPath.finStatement:
      return 'Statement mapping, trial balance support, disclosure tie-out, and Indonesian reporting controls.';
    default:
      return 'Source document, reviewer note, owner response, and close-ready supporting evidence.';
  }
}

String _detailControlObjective(AccountingWorkspaceWorkQueue queue) {
  switch (queue.path) {
    case AccountingPath.reportReleaseEvidence:
    case AccountingPath.reportReleaseSignOff:
    case AccountingPath.reportReleaseStatutoryFiling:
      return 'Release only complete, approved, retained, and IFRS/SAK-aligned reporting evidence.';
    case AccountingPath.bankReconciliation:
      return 'Reconcile cash differences to supported, approved, and timely clearing actions.';
    case AccountingPath.periodClose:
      return 'Lock the period only after critical blockers are evidenced, owned, and approved.';
    case AccountingPath.reportPack:
    case AccountingPath.financialNotes:
    case AccountingPath.finStatement:
      return 'Keep statements, schedules, and disclosures traceable to reviewed IFRS/SAK support.';
    case AccountingPath.accPayable:
      return 'Pay only validated supplier obligations with tax, approval, and reconciliation evidence.';
    case AccountingPath.accReceivable:
      return 'Recover and report receivables with supported invoices, collections, and aging controls.';
    case AccountingPath.policy:
      return 'Apply accounting policy consistently across entity, currency, tax, and close controls.';
    case AccountingPath.entryHistory:
    case AccountingPath.gl:
      return 'Post only supported, reviewed, and auditable journal activity to the ledger.';
    default:
      return 'Keep accounting work traceable, reviewed, and ready for close or reporting.';
  }
}

String _detailRecommendedAction(AccountingWorkspaceWorkQueue queue) {
  if (queue.severity == AccountingWorkspaceWorkQueueSeverity.critical ||
      queue.slaStatus == AccountingWorkspaceWorkQueueSlaStatus.overdue) {
    return 'Escalate with ${queue.ownerLabel}, clear the highest-risk items first, then open the workspace to record evidence.';
  }

  if (queue.severity == AccountingWorkspaceWorkQueueSeverity.warning ||
      queue.slaStatus == AccountingWorkspaceWorkQueueSlaStatus.dueToday) {
    return 'Review exceptions with ${queue.ownerLabel}, attach missing support, and update reviewer notes before SLA end.';
  }

  return 'Monitor ${queue.ownerLabel} progress, keep evidence current, and open the workspace when item status changes.';
}

AccountingWorkspaceWorkQueueRiskSummary _detailRiskSummary(
  AccountingWorkspaceWorkQueue queue,
) {
  final rawScore =
      _severityRiskScore(queue.severity) +
      _slaRiskScore(queue) +
      _loadRiskScore(queue.count) +
      _domainRiskScore(queue.path);
  final score = rawScore > 100 ? 100 : rawScore;
  final level = _riskLevelForScore(score);

  return AccountingWorkspaceWorkQueueRiskSummary(
    level: level,
    score: score,
    exposureLabel: _riskExposureLabel(level, queue),
    materialityLabel: _materialityLabel(queue),
    controlRiskLabel: _controlRiskLabel(queue),
    auditResponse: _auditResponseLabel(level, queue),
  );
}

AccountingWorkspaceWorkQueueEscalationPlan _detailEscalationPlan({
  required AccountingWorkspaceWorkQueue queue,
  required AccountingWorkspaceWorkQueueRiskSummary riskSummary,
}) {
  final tier = _escalationTierFor(queue: queue, riskSummary: riskSummary);

  return AccountingWorkspaceWorkQueueEscalationPlan(
    tier: tier,
    escalationOwner: _escalationOwner(queue: queue, tier: tier),
    cadenceLabel: _escalationCadenceLabel(queue: queue, tier: tier),
    deadlineLabel: _escalationDeadlineLabel(queue),
    governanceNote: _escalationGovernanceNote(tier),
  );
}

AccountingWorkspaceWorkQueueClearanceChecklist _detailClearanceChecklist({
  required AccountingWorkspaceWorkQueue queue,
  required String evidenceNeeded,
  required AccountingWorkspaceWorkQueueRiskSummary riskSummary,
  required AccountingWorkspaceWorkQueueEscalationPlan escalationPlan,
}) {
  return AccountingWorkspaceWorkQueueClearanceChecklist(
    steps: [
      AccountingWorkspaceWorkQueueClearanceStep(
        id: '${queue.id}-owner-acknowledgement',
        title: 'Owner acknowledgement',
        ownerLabel: queue.ownerLabel,
        evidenceLabel: 'Owner response and due-date confirmation',
        status: _ownerAcknowledgementStatus(queue),
      ),
      AccountingWorkspaceWorkQueueClearanceStep(
        id: '${queue.id}-evidence-pack',
        title: 'Evidence pack',
        ownerLabel: queue.ownerLabel,
        evidenceLabel: evidenceNeeded,
        status: _evidencePackStatus(queue),
      ),
      AccountingWorkspaceWorkQueueClearanceStep(
        id: '${queue.id}-reviewer-signoff',
        title: 'Reviewer sign-off',
        ownerLabel: _reviewerOwnerLabel(queue),
        evidenceLabel: 'Reviewer note, exception response, and sign-off trail',
        status: _reviewerSignOffStatus(riskSummary),
      ),
      AccountingWorkspaceWorkQueueClearanceStep(
        id: '${queue.id}-gate-decision',
        title: 'Release or close gate',
        ownerLabel: escalationPlan.escalationOwner,
        evidenceLabel: _gateEvidenceLabel(queue),
        status: _gateDecisionStatus(escalationPlan),
      ),
    ],
  );
}

AccountingWorkspaceWorkQueueComplianceGuardrail _detailComplianceGuardrail(
  AccountingWorkspaceWorkQueue queue,
) {
  switch (queue.path) {
    case AccountingPath.reportReleaseStatutoryFiling:
      return const AccountingWorkspaceWorkQueueComplianceGuardrail(
        frameworkLabel: 'SAK Indonesia reporting package',
        localRuleLabel: 'DJP statutory filing and tax reconciliation',
        retentionLabel: 'Retain filing proof, tax support, and approval pack',
        filingImpactLabel: 'Direct statutory filing impact',
      );
    case AccountingPath.reportReleaseEvidence:
    case AccountingPath.reportReleaseSignOff:
      return const AccountingWorkspaceWorkQueueComplianceGuardrail(
        frameworkLabel: 'IFRS-aligned SAK Indonesia release evidence',
        localRuleLabel: 'OJK/IDX-style release governance and audit trail',
        retentionLabel: 'Retain signed release pack and evidence manifest',
        filingImpactLabel: 'Blocks report release readiness',
      );
    case AccountingPath.reportPack:
    case AccountingPath.financialNotes:
    case AccountingPath.finStatement:
      return const AccountingWorkspaceWorkQueueComplianceGuardrail(
        frameworkLabel: 'IFRS-aligned SAK Indonesia presentation',
        localRuleLabel: 'Indonesian financial statement disclosure controls',
        retentionLabel:
            'Retain statement mapping, schedules, and reviewer notes',
        filingImpactLabel: 'Affects financial statement completeness',
      );
    case AccountingPath.bankReconciliation:
      return const AccountingWorkspaceWorkQueueComplianceGuardrail(
        frameworkLabel: 'Cash evidence and cut-off controls',
        localRuleLabel: 'Bank statement tie-out and Indonesian audit support',
        retentionLabel:
            'Retain bank statements, timing support, and tie-out logs',
        filingImpactLabel: 'Supports cash and liquidity assertions',
      );
    case AccountingPath.accPayable:
      return const AccountingWorkspaceWorkQueueComplianceGuardrail(
        frameworkLabel: 'Liability recognition and payment controls',
        localRuleLabel: 'PPN/PPh supplier documentation and approval evidence',
        retentionLabel:
            'Retain supplier invoice, tax, payment, and approval support',
        filingImpactLabel: 'Can affect VAT/WHT and liability reporting',
      );
    case AccountingPath.accReceivable:
      return const AccountingWorkspaceWorkQueueComplianceGuardrail(
        frameworkLabel: 'Revenue, receivable, and impairment controls',
        localRuleLabel: 'Faktur pajak and customer collection documentation',
        retentionLabel:
            'Retain invoice, tax invoice, collection, and aging evidence',
        filingImpactLabel: 'Can affect VAT output and receivable reporting',
      );
    case AccountingPath.periodClose:
      return const AccountingWorkspaceWorkQueueComplianceGuardrail(
        frameworkLabel: 'Period close governance controls',
        localRuleLabel: 'Indonesian close approval and audit trail discipline',
        retentionLabel:
            'Retain close checklist, blocker notes, and lock approval',
        filingImpactLabel: 'Blocks period lock readiness',
      );
    case AccountingPath.entryHistory:
    case AccountingPath.gl:
      return const AccountingWorkspaceWorkQueueComplianceGuardrail(
        frameworkLabel: 'Journal posting and ledger integrity controls',
        localRuleLabel: 'Source document, approval, and audit trail support',
        retentionLabel:
            'Retain journal source, posting evidence, and reviewer trail',
        filingImpactLabel: 'Can affect trial balance and statement mapping',
      );
    case AccountingPath.policy:
      return const AccountingWorkspaceWorkQueueComplianceGuardrail(
        frameworkLabel: 'SAK Indonesia accounting policy governance',
        localRuleLabel: 'Entity, currency, tax, and close policy approval',
        retentionLabel: 'Retain policy decision memo and approval evidence',
        filingImpactLabel: 'Can affect measurement and disclosure policy',
      );
    default:
      return const AccountingWorkspaceWorkQueueComplianceGuardrail(
        frameworkLabel: 'Accounting control documentation',
        localRuleLabel: 'Indonesian accounting evidence discipline',
        retentionLabel: 'Retain source support and reviewer notes',
        filingImpactLabel: 'Supports accounting workflow readiness',
      );
  }
}

String _detailOwnerBrief({
  required AccountingWorkspaceWorkQueue queue,
  required String rootCause,
  required String evidenceNeeded,
  required String controlObjective,
  required String recommendedAction,
  required AccountingWorkspaceWorkQueueRiskSummary riskSummary,
  required AccountingWorkspaceWorkQueueEscalationPlan escalationPlan,
  required AccountingWorkspaceWorkQueueClearanceChecklist clearanceChecklist,
  required AccountingWorkspaceWorkQueueComplianceGuardrail complianceGuardrail,
  required AccountingWorkspaceWorkQueueAccountingImpact accountingImpact,
}) {
  return [
    'Work queue: ${queue.title}',
    'Owner: ${queue.ownerLabel}',
    'SLA: ${queue.dueLabel}',
    'Open items: ${queue.count}',
    'Status: ${_severityLabel(queue.severity)}',
    'Risk: ${riskSummary.levelLabel} (${riskSummary.score}/100)',
    'Materiality: ${riskSummary.materialityLabel}',
    'Control risk: ${riskSummary.controlRiskLabel}',
    'Escalation: ${escalationPlan.tierLabel}',
    'Escalation owner: ${escalationPlan.escalationOwner}',
    'Cadence: ${escalationPlan.cadenceLabel}',
    'Deadline: ${escalationPlan.deadlineLabel}',
    'Clearance: ${clearanceChecklist.summaryLabel}',
    'Framework: ${complianceGuardrail.frameworkLabel}',
    'Local rule: ${complianceGuardrail.localRuleLabel}',
    'Retention: ${complianceGuardrail.retentionLabel}',
    'Filing impact: ${complianceGuardrail.filingImpactLabel}',
    'Statement area: ${accountingImpact.statementAreaLabel}',
    'Assertion: ${accountingImpact.assertionLabel}',
    'Tax impact: ${accountingImpact.taxImpactLabel}',
    'Close gate: ${accountingImpact.closeGateLabel}',
    'Journal action: ${accountingImpact.journalActionLabel}',
    'Ledger focus: ${accountingImpact.ledgerFocusLabel}',
    'Posting gate: ${accountingImpact.postingGateLabel}',
    'Root cause: $rootCause',
    'Evidence needed: $evidenceNeeded',
    'Control objective: $controlObjective',
    'Next action: $recommendedAction',
  ].join('\n');
}

List<String> _detailCheckpoints(AccountingWorkspaceWorkQueue queue) {
  final checkpoints = <String>[
    'Confirm owner and due date',
    _domainCheckpoint(queue.path),
    'Document reviewer sign-off',
  ];

  if (queue.slaStatus == AccountingWorkspaceWorkQueueSlaStatus.overdue) {
    checkpoints.insert(1, 'Record escalation note');
  }

  return checkpoints;
}

AccountingWorkspaceWorkQueueEscalationTier _escalationTierFor({
  required AccountingWorkspaceWorkQueue queue,
  required AccountingWorkspaceWorkQueueRiskSummary riskSummary,
}) {
  if (riskSummary.level == AccountingWorkspaceWorkQueueRiskLevel.critical &&
      queue.slaStatus == AccountingWorkspaceWorkQueueSlaStatus.overdue) {
    return AccountingWorkspaceWorkQueueEscalationTier.releaseBlocker;
  }

  if (riskSummary.level == AccountingWorkspaceWorkQueueRiskLevel.critical ||
      riskSummary.level == AccountingWorkspaceWorkQueueRiskLevel.high) {
    return AccountingWorkspaceWorkQueueEscalationTier.managementEscalation;
  }

  if (queue.slaStatus == AccountingWorkspaceWorkQueueSlaStatus.dueToday ||
      queue.severity == AccountingWorkspaceWorkQueueSeverity.warning) {
    return AccountingWorkspaceWorkQueueEscalationTier.ownerFollowUp;
  }

  return AccountingWorkspaceWorkQueueEscalationTier.monitor;
}

String _escalationOwner({
  required AccountingWorkspaceWorkQueue queue,
  required AccountingWorkspaceWorkQueueEscalationTier tier,
}) {
  switch (tier) {
    case AccountingWorkspaceWorkQueueEscalationTier.releaseBlocker:
      return '${queue.ownerLabel} + Controller';
    case AccountingWorkspaceWorkQueueEscalationTier.managementEscalation:
      return '${queue.ownerLabel} + Reporting lead';
    case AccountingWorkspaceWorkQueueEscalationTier.ownerFollowUp:
      return queue.ownerLabel;
    case AccountingWorkspaceWorkQueueEscalationTier.monitor:
      return queue.ownerLabel;
  }
}

String _escalationCadenceLabel({
  required AccountingWorkspaceWorkQueue queue,
  required AccountingWorkspaceWorkQueueEscalationTier tier,
}) {
  switch (tier) {
    case AccountingWorkspaceWorkQueueEscalationTier.releaseBlocker:
      return 'Daily until cleared';
    case AccountingWorkspaceWorkQueueEscalationTier.managementEscalation:
      return 'Every close checkpoint';
    case AccountingWorkspaceWorkQueueEscalationTier.ownerFollowUp:
      return queue.slaStatus == AccountingWorkspaceWorkQueueSlaStatus.dueToday
          ? 'Same-day owner follow-up'
          : 'Next business day';
    case AccountingWorkspaceWorkQueueEscalationTier.monitor:
      return 'Routine review cadence';
  }
}

String _escalationDeadlineLabel(AccountingWorkspaceWorkQueue queue) {
  switch (queue.slaStatus) {
    case AccountingWorkspaceWorkQueueSlaStatus.overdue:
      return 'Today before release or close lock';
    case AccountingWorkspaceWorkQueueSlaStatus.dueToday:
      return 'Today';
    case AccountingWorkspaceWorkQueueSlaStatus.onTrack:
      return queue.dueLabel;
  }
}

String _escalationGovernanceNote(
  AccountingWorkspaceWorkQueueEscalationTier tier,
) {
  switch (tier) {
    case AccountingWorkspaceWorkQueueEscalationTier.releaseBlocker:
      return 'Block release or close lock until evidence and reviewer sign-off are recorded.';
    case AccountingWorkspaceWorkQueueEscalationTier.managementEscalation:
      return 'Require management review notes before approval can clear.';
    case AccountingWorkspaceWorkQueueEscalationTier.ownerFollowUp:
      return 'Owner must update evidence status and reviewer notes before SLA end.';
    case AccountingWorkspaceWorkQueueEscalationTier.monitor:
      return 'Keep evidence current and re-check before the next close checkpoint.';
  }
}

AccountingWorkspaceWorkQueueClearanceStatus _ownerAcknowledgementStatus(
  AccountingWorkspaceWorkQueue queue,
) {
  switch (queue.slaStatus) {
    case AccountingWorkspaceWorkQueueSlaStatus.overdue:
      return AccountingWorkspaceWorkQueueClearanceStatus.blocked;
    case AccountingWorkspaceWorkQueueSlaStatus.dueToday:
      return AccountingWorkspaceWorkQueueClearanceStatus.waiting;
    case AccountingWorkspaceWorkQueueSlaStatus.onTrack:
      return AccountingWorkspaceWorkQueueClearanceStatus.ready;
  }
}

AccountingWorkspaceWorkQueueClearanceStatus _evidencePackStatus(
  AccountingWorkspaceWorkQueue queue,
) {
  switch (queue.severity) {
    case AccountingWorkspaceWorkQueueSeverity.critical:
      return AccountingWorkspaceWorkQueueClearanceStatus.blocked;
    case AccountingWorkspaceWorkQueueSeverity.warning:
      return AccountingWorkspaceWorkQueueClearanceStatus.waiting;
    case AccountingWorkspaceWorkQueueSeverity.info:
      return AccountingWorkspaceWorkQueueClearanceStatus.ready;
  }
}

AccountingWorkspaceWorkQueueClearanceStatus _reviewerSignOffStatus(
  AccountingWorkspaceWorkQueueRiskSummary riskSummary,
) {
  switch (riskSummary.level) {
    case AccountingWorkspaceWorkQueueRiskLevel.critical:
    case AccountingWorkspaceWorkQueueRiskLevel.high:
    case AccountingWorkspaceWorkQueueRiskLevel.medium:
      return AccountingWorkspaceWorkQueueClearanceStatus.waiting;
    case AccountingWorkspaceWorkQueueRiskLevel.low:
      return AccountingWorkspaceWorkQueueClearanceStatus.ready;
  }
}

AccountingWorkspaceWorkQueueClearanceStatus _gateDecisionStatus(
  AccountingWorkspaceWorkQueueEscalationPlan escalationPlan,
) {
  switch (escalationPlan.tier) {
    case AccountingWorkspaceWorkQueueEscalationTier.releaseBlocker:
      return AccountingWorkspaceWorkQueueClearanceStatus.blocked;
    case AccountingWorkspaceWorkQueueEscalationTier.managementEscalation:
    case AccountingWorkspaceWorkQueueEscalationTier.ownerFollowUp:
      return AccountingWorkspaceWorkQueueClearanceStatus.waiting;
    case AccountingWorkspaceWorkQueueEscalationTier.monitor:
      return AccountingWorkspaceWorkQueueClearanceStatus.ready;
  }
}

String _reviewerOwnerLabel(AccountingWorkspaceWorkQueue queue) {
  switch (queue.path) {
    case AccountingPath.reportReleaseEvidence:
    case AccountingPath.reportReleaseSignOff:
    case AccountingPath.reportReleaseStatutoryFiling:
      return 'Report reviewer';
    case AccountingPath.bankReconciliation:
      return 'Treasury reviewer';
    case AccountingPath.accPayable:
      return 'AP reviewer';
    case AccountingPath.accReceivable:
      return 'AR reviewer';
    case AccountingPath.periodClose:
      return 'Close reviewer';
    default:
      return 'Accounting reviewer';
  }
}

String _gateEvidenceLabel(AccountingWorkspaceWorkQueue queue) {
  switch (queue.path) {
    case AccountingPath.reportReleaseEvidence:
    case AccountingPath.reportReleaseSignOff:
    case AccountingPath.reportReleaseStatutoryFiling:
      return 'Release gate decision and retained approval trail';
    case AccountingPath.periodClose:
      return 'Close lock decision and blocker clearance note';
    case AccountingPath.bankReconciliation:
      return 'Reconciliation exception clearance and cash tie-out';
    default:
      return 'Workflow gate decision and reviewer clearance note';
  }
}

int _severityRiskScore(AccountingWorkspaceWorkQueueSeverity severity) {
  switch (severity) {
    case AccountingWorkspaceWorkQueueSeverity.info:
      return 8;
    case AccountingWorkspaceWorkQueueSeverity.warning:
      return 22;
    case AccountingWorkspaceWorkQueueSeverity.critical:
      return 38;
  }
}

int _slaRiskScore(AccountingWorkspaceWorkQueue queue) {
  switch (queue.slaStatus) {
    case AccountingWorkspaceWorkQueueSlaStatus.overdue:
      final overdueDays = queue.dueInDays.abs();
      final cappedDays = overdueDays > 4 ? 4 : overdueDays;
      return 24 + cappedDays * 3;
    case AccountingWorkspaceWorkQueueSlaStatus.dueToday:
      return 16;
    case AccountingWorkspaceWorkQueueSlaStatus.onTrack:
      return 6;
  }
}

int _loadRiskScore(int count) {
  if (count >= 8) return 14;
  if (count >= 4) return 10;

  return 5;
}

int _domainRiskScore(String path) {
  switch (path) {
    case AccountingPath.reportReleaseEvidence:
    case AccountingPath.reportReleaseSignOff:
    case AccountingPath.reportReleaseStatutoryFiling:
    case AccountingPath.finStatement:
    case AccountingPath.reportPack:
    case AccountingPath.financialNotes:
      return 15;
    case AccountingPath.bankReconciliation:
    case AccountingPath.accPayable:
    case AccountingPath.accReceivable:
      return 12;
    case AccountingPath.entryHistory:
    case AccountingPath.gl:
      return 10;
    case AccountingPath.periodClose:
      return 14;
    case AccountingPath.policy:
      return 8;
    default:
      return 6;
  }
}

AccountingWorkspaceWorkQueueRiskLevel _riskLevelForScore(int score) {
  if (score >= 82) return AccountingWorkspaceWorkQueueRiskLevel.critical;
  if (score >= 60) return AccountingWorkspaceWorkQueueRiskLevel.high;
  if (score >= 36) return AccountingWorkspaceWorkQueueRiskLevel.medium;

  return AccountingWorkspaceWorkQueueRiskLevel.low;
}

String _riskExposureLabel(
  AccountingWorkspaceWorkQueueRiskLevel level,
  AccountingWorkspaceWorkQueue queue,
) {
  switch (level) {
    case AccountingWorkspaceWorkQueueRiskLevel.critical:
      return 'Board-ready exposure: ${queue.count} items can block release or close.';
    case AccountingWorkspaceWorkQueueRiskLevel.high:
      return 'High exposure: ${queue.count} items need owner response before review can clear.';
    case AccountingWorkspaceWorkQueueRiskLevel.medium:
      return 'Moderate exposure: ${queue.count} items need evidence before SLA pressure rises.';
    case AccountingWorkspaceWorkQueueRiskLevel.low:
      return 'Low exposure: monitor ${queue.count} open items and keep support current.';
  }
}

String _materialityLabel(AccountingWorkspaceWorkQueue queue) {
  switch (queue.path) {
    case AccountingPath.reportReleaseEvidence:
    case AccountingPath.reportReleaseSignOff:
    case AccountingPath.reportReleaseStatutoryFiling:
    case AccountingPath.finStatement:
    case AccountingPath.reportPack:
    case AccountingPath.financialNotes:
      return 'High reporting materiality';
    case AccountingPath.bankReconciliation:
      return 'Cash and bank materiality';
    case AccountingPath.accPayable:
      return 'Supplier liability materiality';
    case AccountingPath.accReceivable:
      return 'Customer receivable materiality';
    case AccountingPath.periodClose:
      return 'Close governance materiality';
    case AccountingPath.entryHistory:
    case AccountingPath.gl:
      return 'Ledger posting materiality';
    case AccountingPath.policy:
      return 'Policy setup materiality';
    default:
      return 'Operational accounting materiality';
  }
}

String _controlRiskLabel(AccountingWorkspaceWorkQueue queue) {
  switch (queue.path) {
    case AccountingPath.reportReleaseEvidence:
    case AccountingPath.reportReleaseSignOff:
    case AccountingPath.reportReleaseStatutoryFiling:
      return 'Release control risk';
    case AccountingPath.bankReconciliation:
      return 'Cash reconciliation control risk';
    case AccountingPath.periodClose:
      return 'Close lock control risk';
    case AccountingPath.accPayable:
      return 'Payable approval control risk';
    case AccountingPath.accReceivable:
      return 'Receivable collection control risk';
    case AccountingPath.entryHistory:
    case AccountingPath.gl:
      return 'Journal posting control risk';
    case AccountingPath.reportPack:
    case AccountingPath.financialNotes:
    case AccountingPath.finStatement:
      return 'Financial statement control risk';
    case AccountingPath.policy:
      return 'Policy configuration control risk';
    default:
      return 'Accounting workflow control risk';
  }
}

String _auditResponseLabel(
  AccountingWorkspaceWorkQueueRiskLevel level,
  AccountingWorkspaceWorkQueue queue,
) {
  switch (level) {
    case AccountingWorkspaceWorkQueueRiskLevel.critical:
      return 'Escalate today, preserve evidence, and require reviewer sign-off before release.';
    case AccountingWorkspaceWorkQueueRiskLevel.high:
      return 'Assign owner follow-up and perform targeted evidence review before approval.';
    case AccountingWorkspaceWorkQueueRiskLevel.medium:
      return 'Track evidence completion and sample support before the next close checkpoint.';
    case AccountingWorkspaceWorkQueueRiskLevel.low:
      return 'Monitor status and keep support ready for routine review.';
  }
}

String _domainCheckpoint(String path) {
  switch (path) {
    case AccountingPath.reportReleaseEvidence:
    case AccountingPath.reportReleaseSignOff:
    case AccountingPath.reportReleaseStatutoryFiling:
      return 'Tie evidence to release manifest';
    case AccountingPath.bankReconciliation:
      return 'Age unresolved timing differences';
    case AccountingPath.periodClose:
      return 'Clear lock-blocking checklist items';
    case AccountingPath.reportPack:
    case AccountingPath.financialNotes:
    case AccountingPath.finStatement:
      return 'Tie schedules to statement lines';
    case AccountingPath.accPayable:
      return 'Validate supplier and tax support';
    case AccountingPath.accReceivable:
      return 'Validate collection action evidence';
    case AccountingPath.entryHistory:
    case AccountingPath.gl:
      return 'Trace journal support to ledger posting';
    case AccountingPath.policy:
      return 'Confirm policy reference and approval';
    default:
      return 'Attach source support and reviewer note';
  }
}

String _workQueueItemLabel(int count) {
  return count == 1 ? '1 open item' : '$count open items';
}

String _severityLabel(AccountingWorkspaceWorkQueueSeverity severity) {
  switch (severity) {
    case AccountingWorkspaceWorkQueueSeverity.info:
      return 'Monitor';
    case AccountingWorkspaceWorkQueueSeverity.warning:
      return 'Review';
    case AccountingWorkspaceWorkQueueSeverity.critical:
      return 'Blocked';
  }
}

List<_AccountingWorkspaceWorkQueueTemplate> _templatesForRole(
  AccountingWorkspaceRolePreset rolePreset,
) {
  switch (rolePreset) {
    case AccountingWorkspaceRolePreset.accountant:
      return const [
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'accountant-ledger-exceptions',
          title: 'Ledger exceptions',
          description: 'Entries requiring review before close.',
          path: AccountingPath.gl,
          count: 5,
          severity: AccountingWorkspaceWorkQueueSeverity.warning,
          ownerLabel: 'GL accountant',
          dueInDays: 1,
        ),
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'accountant-close-blockers',
          title: 'Close blockers',
          description: 'Checklist items blocking period lock.',
          path: AccountingPath.periodClose,
          count: 3,
          severity: AccountingWorkspaceWorkQueueSeverity.critical,
          ownerLabel: 'Close owner',
          dueInDays: -1,
        ),
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'accountant-ap-overdue',
          title: 'AP overdue reviews',
          description: 'Supplier bills and payments waiting on review.',
          path: AccountingPath.accPayable,
          count: 8,
          severity: AccountingWorkspaceWorkQueueSeverity.warning,
          ownerLabel: 'AP specialist',
          dueInDays: -2,
        ),
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'accountant-ar-collections',
          title: 'AR collection follow-ups',
          description: 'Customer invoices needing collection action.',
          path: AccountingPath.accReceivable,
          count: 6,
          severity: AccountingWorkspaceWorkQueueSeverity.info,
          ownerLabel: 'AR collector',
          dueInDays: 3,
        ),
      ];
    case AccountingWorkspaceRolePreset.controller:
      return const [
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'controller-close-blockers',
          title: 'Close blockers',
          description: 'Ownership, evidence, and lock issues to clear.',
          path: AccountingPath.periodClose,
          count: 4,
          severity: AccountingWorkspaceWorkQueueSeverity.critical,
          ownerLabel: 'Controller',
          dueInDays: -1,
        ),
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'controller-reconciliation-exceptions',
          title: 'Reconciliation exceptions',
          description: 'Cash timing differences waiting on support.',
          path: AccountingPath.bankReconciliation,
          count: 7,
          severity: AccountingWorkspaceWorkQueueSeverity.warning,
          ownerLabel: 'Treasury lead',
          dueInDays: 0,
        ),
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'controller-release-approvals',
          title: 'Release approvals',
          description: 'Sign-off owners holding report release.',
          path: AccountingPath.reportReleaseSignOff,
          count: 2,
          severity: AccountingWorkspaceWorkQueueSeverity.critical,
          ownerLabel: 'Report approver',
          dueInDays: -2,
        ),
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'controller-report-pack-exceptions',
          title: 'Report pack exceptions',
          description: 'Schedules and exports requiring controller review.',
          path: AccountingPath.reportPack,
          count: 3,
          severity: AccountingWorkspaceWorkQueueSeverity.warning,
          ownerLabel: 'Reporting lead',
          dueInDays: 2,
        ),
      ];
    case AccountingWorkspaceRolePreset.tax:
      return const [
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'tax-statutory-filing-gaps',
          title: 'Statutory filing gaps',
          description: 'SPT Tahunan and filing support still incomplete.',
          path: AccountingPath.reportReleaseStatutoryFiling,
          count: 4,
          severity: AccountingWorkspaceWorkQueueSeverity.critical,
          ownerLabel: 'Tax manager',
          dueInDays: -3,
        ),
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'tax-disclosure-review',
          title: 'Tax disclosure review',
          description: 'Tax schedules and disclosure support to confirm.',
          path: AccountingPath.reportPack,
          count: 3,
          severity: AccountingWorkspaceWorkQueueSeverity.warning,
          ownerLabel: 'Tax reviewer',
          dueInDays: 1,
        ),
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'tax-policy-setup',
          title: 'Tax policy setup',
          description: 'PPN, currency, and entity setup requiring attention.',
          path: AccountingPath.policy,
          count: 1,
          severity: AccountingWorkspaceWorkQueueSeverity.warning,
          ownerLabel: 'Tax ops',
          dueInDays: 0,
        ),
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'tax-statement-controls',
          title: 'Statement tax controls',
          description: 'Statement periods and tax controls to inspect.',
          path: AccountingPath.finStatement,
          count: 2,
          severity: AccountingWorkspaceWorkQueueSeverity.info,
          ownerLabel: 'Statement owner',
          dueInDays: 4,
        ),
      ];
    case AccountingWorkspaceRolePreset.auditor:
      return const [
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'auditor-evidence-gaps',
          title: 'Audit evidence gaps',
          description: 'Release manifest items missing audit evidence.',
          path: AccountingPath.reportReleaseEvidence,
          count: 5,
          severity: AccountingWorkspaceWorkQueueSeverity.critical,
          ownerLabel: 'Audit liaison',
          dueInDays: -2,
        ),
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'auditor-reconciliation-exceptions',
          title: 'Reconciliation exceptions',
          description: 'Cash support and timing differences to inspect.',
          path: AccountingPath.bankReconciliation,
          count: 7,
          severity: AccountingWorkspaceWorkQueueSeverity.warning,
          ownerLabel: 'External audit',
          dueInDays: 0,
        ),
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'auditor-disclosure-review',
          title: 'Disclosure review',
          description: 'Required notes and reviewer evidence awaiting check.',
          path: AccountingPath.financialNotes,
          count: 4,
          severity: AccountingWorkspaceWorkQueueSeverity.warning,
          ownerLabel: 'Audit senior',
          dueInDays: 2,
        ),
        _AccountingWorkspaceWorkQueueTemplate(
          id: 'auditor-journal-samples',
          title: 'Journal samples',
          description: 'Posted entries selected for audit lookup.',
          path: AccountingPath.entryHistory,
          count: 9,
          severity: AccountingWorkspaceWorkQueueSeverity.info,
          ownerLabel: 'Audit sampling',
          dueInDays: 5,
        ),
      ];
  }
}

class _AccountingWorkspaceWorkQueueTemplate {
  const _AccountingWorkspaceWorkQueueTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.path,
    required this.count,
    required this.severity,
    required this.ownerLabel,
    required this.dueInDays,
  });

  final String id;
  final String title;
  final String description;
  final String path;
  final int count;
  final AccountingWorkspaceWorkQueueSeverity severity;
  final String ownerLabel;
  final int dueInDays;
}
