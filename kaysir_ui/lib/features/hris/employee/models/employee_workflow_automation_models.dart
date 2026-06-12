import 'employee_directory_models.dart';

enum EmployeeWorkflowAutomationTrigger {
  nextActionSignal('Next-action signal'),
  approvalPolicyIssue('Approval policy issue'),
  approvalCoverageGap('Approval coverage gap'),
  managerChangeBlocker('Manager change blocker'),
  jobHistoryEvidence('Job history evidence'),
  recordActionApproved('Record action approved'),
  exitReadinessBlocker('Exit readiness blocker');

  final String label;

  const EmployeeWorkflowAutomationTrigger(this.label);
}

enum EmployeeWorkflowAutomationDelivery {
  createWorkflowTask('Create workflow task'),
  notifyOwner('Notify owner'),
  addChecklistItem('Add checklist item'),
  blockQueue('Block approval queue'),
  escalateOwner('Escalate owner');

  final String label;

  const EmployeeWorkflowAutomationDelivery(this.label);
}

enum EmployeeWorkflowAutomationStatus {
  active('Active'),
  draft('Draft'),
  paused('Paused'),
  failed('Failed');

  final String label;

  const EmployeeWorkflowAutomationStatus(this.label);
}

enum EmployeeWorkflowAutomationRisk {
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeeWorkflowAutomationRisk(this.label);
}

class EmployeeWorkflowAutomationHook {
  final String id;
  final String employeeId;
  final String name;
  final EmployeeWorkflowAutomationTrigger trigger;
  final EmployeeWorkflowAutomationDelivery delivery;
  final String owner;
  final String sourceLabel;
  final String generatedTaskTitle;
  final int slaHours;
  final EmployeeWorkflowAutomationStatus status;
  final EmployeeWorkflowAutomationRisk risk;
  final DateTime? lastRunAt;
  final DateTime nextRunAt;
  final int generatedTaskCount;
  final String failureReason;
  final String notes;

  const EmployeeWorkflowAutomationHook({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.trigger,
    required this.delivery,
    required this.owner,
    required this.sourceLabel,
    required this.generatedTaskTitle,
    required this.slaHours,
    required this.status,
    required this.risk,
    required this.lastRunAt,
    required this.nextRunAt,
    required this.generatedTaskCount,
    required this.failureReason,
    required this.notes,
  });

  bool get isActive => status == EmployeeWorkflowAutomationStatus.active;

  bool get isDraft => status == EmployeeWorkflowAutomationStatus.draft;

  bool get isPaused => status == EmployeeWorkflowAutomationStatus.paused;

  bool get isFailed => status == EmployeeWorkflowAutomationStatus.failed;

  bool get isHighRisk => risk == EmployeeWorkflowAutomationRisk.high;

  bool isDue(DateTime asOfDate) {
    return isActive && !nextRunAt.isAfter(_dateOnly(asOfDate));
  }

  bool isDueSoon(DateTime asOfDate) {
    if (!isActive || isDue(asOfDate)) return false;
    final today = _dateOnly(asOfDate);
    final horizon = today.add(const Duration(days: 3));
    return !nextRunAt.isBefore(today) && !nextRunAt.isAfter(horizon);
  }

  bool needsAttention(DateTime asOfDate) {
    return isFailed || isPaused || isDraft || isDue(asOfDate);
  }

  EmployeeWorkflowAutomationHook copyWith({
    EmployeeWorkflowAutomationStatus? status,
    DateTime? lastRunAt,
    DateTime? nextRunAt,
    int? generatedTaskCount,
    String? failureReason,
    String? notes,
  }) {
    return EmployeeWorkflowAutomationHook(
      id: id,
      employeeId: employeeId,
      name: name,
      trigger: trigger,
      delivery: delivery,
      owner: owner,
      sourceLabel: sourceLabel,
      generatedTaskTitle: generatedTaskTitle,
      slaHours: slaHours,
      status: status ?? this.status,
      risk: risk,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      generatedTaskCount: generatedTaskCount ?? this.generatedTaskCount,
      failureReason: failureReason ?? this.failureReason,
      notes: notes ?? this.notes,
    );
  }
}

class EmployeeWorkflowAutomationProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeWorkflowAutomationHook> hooks;

  const EmployeeWorkflowAutomationProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.hooks,
  });

  EmployeeWorkflowAutomationProfile copyWith({
    List<EmployeeWorkflowAutomationHook>? hooks,
  }) {
    return EmployeeWorkflowAutomationProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      hooks: hooks ?? this.hooks,
    );
  }

  List<EmployeeWorkflowAutomationHook> get sortedHooks {
    final sorted = [...hooks]..sort((a, b) {
      final attentionCompare = _attentionRank(
        a,
        asOfDate,
      ).compareTo(_attentionRank(b, asOfDate));
      if (attentionCompare != 0) return attentionCompare;

      final riskCompare = _riskRank(a.risk).compareTo(_riskRank(b.risk));
      if (riskCompare != 0) return riskCompare;

      return a.nextRunAt.compareTo(b.nextRunAt);
    });
    return sorted;
  }

  int get activeCount => hooks.where((hook) => hook.isActive).length;

  int get draftCount => hooks.where((hook) => hook.isDraft).length;

  int get pausedCount => hooks.where((hook) => hook.isPaused).length;

  int get failedCount => hooks.where((hook) => hook.isFailed).length;

  int get dueCount {
    return hooks.where((hook) => hook.isDue(asOfDate)).length;
  }

  int get dueSoonCount {
    return hooks.where((hook) => hook.isDueSoon(asOfDate)).length;
  }

  int get highRiskCount {
    return hooks.where((hook) => hook.isHighRisk && !hook.isPaused).length;
  }

  int get generatedTaskCount {
    return hooks.fold<int>(0, (total, hook) => total + hook.generatedTaskCount);
  }

  int get attentionCount {
    return hooks.where((hook) => hook.needsAttention(asOfDate)).length;
  }

  double get activeRatio {
    if (hooks.isEmpty) return 0;
    return activeCount / hooks.length;
  }

  EmployeeWorkflowAutomationHook? get nextHook {
    final attention = sortedHooks.where(
      (hook) => hook.needsAttention(asOfDate),
    );
    if (attention.isNotEmpty) return attention.first;
    if (sortedHooks.isEmpty) return null;
    return sortedHooks.first;
  }

  String get nextAction {
    if (failedCount > 0) {
      return 'Repair $failedCount failed workflow automation hook${failedCount == 1 ? '' : 's'}.';
    }
    if (dueCount > 0) {
      return 'Run $dueCount workflow automation hook${dueCount == 1 ? '' : 's'} due now.';
    }
    if (pausedCount > 0) {
      return 'Review $pausedCount paused workflow automation hook${pausedCount == 1 ? '' : 's'}.';
    }
    if (draftCount > 0) {
      return 'Activate $draftCount drafted workflow automation hook${draftCount == 1 ? '' : 's'}.';
    }
    if (hooks.isEmpty) {
      return 'Create workflow automation hooks for this employee.';
    }
    return 'Workflow automation hooks are healthy.';
  }
}

class EmployeeWorkflowAutomationHookDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String name;
  final EmployeeWorkflowAutomationTrigger trigger;
  final EmployeeWorkflowAutomationDelivery delivery;
  final String owner;
  final String sourceLabel;
  final String generatedTaskTitle;
  final int slaHours;
  final EmployeeWorkflowAutomationRisk risk;
  final DateTime? nextRunAt;
  final String notes;

  const EmployeeWorkflowAutomationHookDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.name,
    required this.trigger,
    required this.delivery,
    required this.owner,
    required this.sourceLabel,
    required this.generatedTaskTitle,
    required this.slaHours,
    required this.risk,
    required this.nextRunAt,
    required this.notes,
  });

  factory EmployeeWorkflowAutomationHookDraft.fromMember({
    required EmployeeDirectoryMember member,
    required DateTime asOfDate,
  }) {
    final today = _dateOnly(asOfDate);
    return EmployeeWorkflowAutomationHookDraft(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: today,
      name: '',
      trigger: EmployeeWorkflowAutomationTrigger.nextActionSignal,
      delivery: EmployeeWorkflowAutomationDelivery.createWorkflowTask,
      owner: 'People Operations',
      sourceLabel: 'Next best actions',
      generatedTaskTitle: '',
      slaHours: 24,
      risk: EmployeeWorkflowAutomationRisk.medium,
      nextRunAt: today.add(const Duration(days: 1)),
      notes: '',
    );
  }

  EmployeeWorkflowAutomationHookDraft copyWith({
    String? name,
    EmployeeWorkflowAutomationTrigger? trigger,
    EmployeeWorkflowAutomationDelivery? delivery,
    String? owner,
    String? sourceLabel,
    String? generatedTaskTitle,
    int? slaHours,
    EmployeeWorkflowAutomationRisk? risk,
    DateTime? nextRunAt,
    String? notes,
  }) {
    return EmployeeWorkflowAutomationHookDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      name: name ?? this.name,
      trigger: trigger ?? this.trigger,
      delivery: delivery ?? this.delivery,
      owner: owner ?? this.owner,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      generatedTaskTitle: generatedTaskTitle ?? this.generatedTaskTitle,
      slaHours: slaHours ?? this.slaHours,
      risk: risk ?? this.risk,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      notes: notes ?? this.notes,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (name.trim().length < 4) {
      errors.add('Automation name must be at least 4 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    if (sourceLabel.trim().length < 3) {
      errors.add('Source label is required');
    }
    if (generatedTaskTitle.trim().length < 6) {
      errors.add('Generated task title must be at least 6 characters');
    }
    if (slaHours < 1 || slaHours > 168) {
      errors.add('SLA window must be between 1 and 168 hours');
    }
    final runAt = nextRunAt;
    if (runAt == null) {
      errors.add('Next run date is required');
    } else if (runAt.isBefore(asOfDate)) {
      errors.add('Next run date cannot be before today');
    }
    if (notes.trim().length < 10) {
      errors.add('Notes must be at least 10 characters');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          name.trim().length >= 4,
          owner.trim().length >= 3,
          sourceLabel.trim().length >= 3,
          generatedTaskTitle.trim().length >= 6,
          slaHours >= 1 && slaHours <= 168,
          nextRunAt != null && !nextRunAt!.isBefore(asOfDate),
          notes.trim().length >= 10,
        ].where((item) => item).length;
    return completed / 7;
  }

  EmployeeWorkflowAutomationHook toHook({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeWorkflowAutomationHook(
      id: id,
      employeeId: employeeId,
      name: name.trim(),
      trigger: trigger,
      delivery: delivery,
      owner: owner.trim(),
      sourceLabel: sourceLabel.trim(),
      generatedTaskTitle: generatedTaskTitle.trim(),
      slaHours: slaHours,
      status: EmployeeWorkflowAutomationStatus.draft,
      risk: risk,
      lastRunAt: null,
      nextRunAt: _dateOnly(nextRunAt!),
      generatedTaskCount: 0,
      failureReason: '',
      notes: notes.trim(),
    );
  }
}

int _attentionRank(EmployeeWorkflowAutomationHook hook, DateTime asOfDate) {
  if (hook.isFailed) return 0;
  if (hook.isDue(asOfDate)) return 1;
  if (hook.isPaused) return 2;
  if (hook.isDraft) return 3;
  if (hook.isDueSoon(asOfDate)) return 4;
  if (hook.isHighRisk) return 5;
  return 6;
}

int _riskRank(EmployeeWorkflowAutomationRisk risk) {
  return switch (risk) {
    EmployeeWorkflowAutomationRisk.high => 0,
    EmployeeWorkflowAutomationRisk.medium => 1,
    EmployeeWorkflowAutomationRisk.low => 2,
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
