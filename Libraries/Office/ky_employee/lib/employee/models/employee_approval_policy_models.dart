import 'employee_directory_models.dart';

enum EmployeeApprovalPolicyArea {
  timeOff('Time off'),
  expense('Expense'),
  payroll('Payroll'),
  access('Access'),
  documents('Documents'),
  performance('Performance'),
  jobChange('Job change'),
  compensation('Compensation');

  final String label;

  const EmployeeApprovalPolicyArea(this.label);
}

enum EmployeeApprovalRoute {
  directManager('Direct manager'),
  departmentHead('Department head'),
  hrBusinessPartner('HR business partner'),
  financePartner('Finance partner'),
  securityOwner('Security owner'),
  executiveSponsor('Executive sponsor'),
  customDelegate('Custom delegate');

  final String label;

  const EmployeeApprovalRoute(this.label);
}

enum EmployeeApprovalPolicyStatus {
  active('Active'),
  draft('Draft'),
  reviewRequired('Review required'),
  suspended('Suspended');

  final String label;

  const EmployeeApprovalPolicyStatus(this.label);
}

enum EmployeeApprovalPolicyRisk {
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeeApprovalPolicyRisk(this.label);
}

enum EmployeeApprovalEscalationMode {
  autoEscalate('Auto-escalate'),
  notifyOnly('Notify only'),
  holdQueue('Hold queue'),
  fallbackDelegate('Fallback delegate');

  final String label;

  const EmployeeApprovalEscalationMode(this.label);
}

class EmployeeApprovalPolicyRule {
  final String id;
  final String employeeId;
  final EmployeeApprovalPolicyArea area;
  final String name;
  final EmployeeApprovalRoute primaryRoute;
  final EmployeeApprovalRoute fallbackRoute;
  final String owner;
  final String thresholdLabel;
  final int escalationHours;
  final EmployeeApprovalEscalationMode escalationMode;
  final DateTime expiresOn;
  final EmployeeApprovalPolicyStatus status;
  final EmployeeApprovalPolicyRisk risk;
  final String notes;

  const EmployeeApprovalPolicyRule({
    required this.id,
    required this.employeeId,
    required this.area,
    required this.name,
    required this.primaryRoute,
    required this.fallbackRoute,
    required this.owner,
    required this.thresholdLabel,
    required this.escalationHours,
    required this.escalationMode,
    required this.expiresOn,
    required this.status,
    required this.risk,
    required this.notes,
  });

  bool get isActive => status == EmployeeApprovalPolicyStatus.active;

  bool get isDraft => status == EmployeeApprovalPolicyStatus.draft;

  bool get needsReview {
    return status == EmployeeApprovalPolicyStatus.reviewRequired;
  }

  bool get isSuspended => status == EmployeeApprovalPolicyStatus.suspended;

  bool get isHighRisk => risk == EmployeeApprovalPolicyRisk.high;

  bool isExpired(DateTime asOfDate) {
    return !isSuspended && expiresOn.isBefore(_dateOnly(asOfDate));
  }

  bool expiresWithin(DateTime asOfDate, int days) {
    if (!isActive || isExpired(asOfDate)) return false;
    final today = _dateOnly(asOfDate);
    final horizon = today.add(Duration(days: days));
    return !expiresOn.isBefore(today) && !expiresOn.isAfter(horizon);
  }

  bool needsAttention(DateTime asOfDate) {
    return isSuspended ||
        isDraft ||
        needsReview ||
        isExpired(asOfDate) ||
        expiresWithin(asOfDate, 14);
  }

  EmployeeApprovalPolicyRule copyWith({
    DateTime? expiresOn,
    EmployeeApprovalPolicyStatus? status,
    String? notes,
  }) {
    return EmployeeApprovalPolicyRule(
      id: id,
      employeeId: employeeId,
      area: area,
      name: name,
      primaryRoute: primaryRoute,
      fallbackRoute: fallbackRoute,
      owner: owner,
      thresholdLabel: thresholdLabel,
      escalationHours: escalationHours,
      escalationMode: escalationMode,
      expiresOn: expiresOn ?? this.expiresOn,
      status: status ?? this.status,
      risk: risk,
      notes: notes ?? this.notes,
    );
  }
}

class EmployeeApprovalPolicyProfile {
  final String employeeId;
  final String employeeName;
  final String department;
  final String manager;
  final DateTime asOfDate;
  final List<EmployeeApprovalPolicyRule> rules;

  const EmployeeApprovalPolicyProfile({
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.manager,
    required this.asOfDate,
    required this.rules,
  });

  EmployeeApprovalPolicyProfile copyWith({
    List<EmployeeApprovalPolicyRule>? rules,
  }) {
    return EmployeeApprovalPolicyProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      department: department,
      manager: manager,
      asOfDate: asOfDate,
      rules: rules ?? this.rules,
    );
  }

  List<EmployeeApprovalPolicyRule> get sortedRules {
    final sorted = [...rules]..sort((a, b) {
      final attentionCompare = _attentionRank(
        a,
        asOfDate,
      ).compareTo(_attentionRank(b, asOfDate));
      if (attentionCompare != 0) return attentionCompare;

      final riskCompare = _riskRank(a.risk).compareTo(_riskRank(b.risk));
      if (riskCompare != 0) return riskCompare;

      return a.expiresOn.compareTo(b.expiresOn);
    });
    return sorted;
  }

  int get activeCount {
    return rules
        .where((rule) => rule.isActive && !rule.isExpired(asOfDate))
        .length;
  }

  int get draftCount => rules.where((rule) => rule.isDraft).length;

  int get reviewRequiredCount {
    return rules.where((rule) => rule.needsReview).length;
  }

  int get suspendedCount => rules.where((rule) => rule.isSuspended).length;

  int get expiredCount {
    return rules.where((rule) => rule.isExpired(asOfDate)).length;
  }

  int get expiringSoonCount {
    return rules.where((rule) => rule.expiresWithin(asOfDate, 14)).length;
  }

  int get highRiskActiveCount {
    return rules.where((rule) => rule.isActive && rule.isHighRisk).length;
  }

  int get attentionCount {
    return rules.where((rule) => rule.needsAttention(asOfDate)).length;
  }

  double get activeRatio {
    if (rules.isEmpty) return 0;
    return activeCount / rules.length;
  }

  EmployeeApprovalPolicyRule? get nextRule {
    final attention = sortedRules.where(
      (rule) => rule.needsAttention(asOfDate),
    );
    if (attention.isNotEmpty) return attention.first;
    if (sortedRules.isEmpty) return null;
    return sortedRules.first;
  }

  String get nextAction {
    if (suspendedCount > 0) {
      return 'Reinstate or replace $suspendedCount suspended approval policy rule${suspendedCount == 1 ? '' : 's'}.';
    }
    if (expiredCount > 0) {
      return 'Renew $expiredCount expired approval policy rule${expiredCount == 1 ? '' : 's'}.';
    }
    if (reviewRequiredCount > 0) {
      return 'Review $reviewRequiredCount approval policy rule${reviewRequiredCount == 1 ? '' : 's'}.';
    }
    if (draftCount > 0) {
      return 'Activate $draftCount drafted approval policy rule${draftCount == 1 ? '' : 's'}.';
    }
    if (expiringSoonCount > 0) {
      return 'Refresh $expiringSoonCount approval policy rule${expiringSoonCount == 1 ? '' : 's'} expiring soon.';
    }
    if (rules.isEmpty) {
      return 'Create approval policy rules for this employee.';
    }
    return 'Approval policy routing is healthy.';
  }
}

class EmployeeApprovalPolicyRuleDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeApprovalPolicyArea area;
  final String name;
  final EmployeeApprovalRoute primaryRoute;
  final EmployeeApprovalRoute fallbackRoute;
  final String owner;
  final String thresholdLabel;
  final int escalationHours;
  final EmployeeApprovalEscalationMode escalationMode;
  final DateTime? expiresOn;
  final EmployeeApprovalPolicyRisk risk;
  final String notes;

  const EmployeeApprovalPolicyRuleDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.area,
    required this.name,
    required this.primaryRoute,
    required this.fallbackRoute,
    required this.owner,
    required this.thresholdLabel,
    required this.escalationHours,
    required this.escalationMode,
    required this.expiresOn,
    required this.risk,
    required this.notes,
  });

  factory EmployeeApprovalPolicyRuleDraft.fromMember({
    required EmployeeDirectoryMember member,
    required DateTime asOfDate,
  }) {
    final today = _dateOnly(asOfDate);
    return EmployeeApprovalPolicyRuleDraft(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: today,
      area: EmployeeApprovalPolicyArea.timeOff,
      name: '',
      primaryRoute: EmployeeApprovalRoute.directManager,
      fallbackRoute: EmployeeApprovalRoute.hrBusinessPartner,
      owner: 'People Operations',
      thresholdLabel: 'Standard employee requests',
      escalationHours: 24,
      escalationMode: EmployeeApprovalEscalationMode.fallbackDelegate,
      expiresOn: today.add(const Duration(days: 90)),
      risk: EmployeeApprovalPolicyRisk.medium,
      notes: '',
    );
  }

  EmployeeApprovalPolicyRuleDraft copyWith({
    EmployeeApprovalPolicyArea? area,
    String? name,
    EmployeeApprovalRoute? primaryRoute,
    EmployeeApprovalRoute? fallbackRoute,
    String? owner,
    String? thresholdLabel,
    int? escalationHours,
    EmployeeApprovalEscalationMode? escalationMode,
    DateTime? expiresOn,
    EmployeeApprovalPolicyRisk? risk,
    String? notes,
  }) {
    return EmployeeApprovalPolicyRuleDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      area: area ?? this.area,
      name: name ?? this.name,
      primaryRoute: primaryRoute ?? this.primaryRoute,
      fallbackRoute: fallbackRoute ?? this.fallbackRoute,
      owner: owner ?? this.owner,
      thresholdLabel: thresholdLabel ?? this.thresholdLabel,
      escalationHours: escalationHours ?? this.escalationHours,
      escalationMode: escalationMode ?? this.escalationMode,
      expiresOn: expiresOn ?? this.expiresOn,
      risk: risk ?? this.risk,
      notes: notes ?? this.notes,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (name.trim().length < 4) {
      errors.add('Policy rule name must be at least 4 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    if (thresholdLabel.trim().length < 4) {
      errors.add('Threshold is required');
    }
    if (primaryRoute == fallbackRoute) {
      errors.add('Fallback route must differ from primary route');
    }
    if (escalationHours < 1 || escalationHours > 168) {
      errors.add('Escalation window must be between 1 and 168 hours');
    }
    final expiry = expiresOn;
    if (expiry == null) {
      errors.add('Expiry date is required');
    } else if (expiry.isBefore(asOfDate)) {
      errors.add('Expiry date cannot be before today');
    }
    if (notes.trim().length < 12) {
      errors.add('Notes must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          name.trim().length >= 4,
          owner.trim().length >= 3,
          thresholdLabel.trim().length >= 4,
          primaryRoute != fallbackRoute,
          escalationHours >= 1 && escalationHours <= 168,
          expiresOn != null && !expiresOn!.isBefore(asOfDate),
          notes.trim().length >= 12,
        ].where((item) => item).length;
    return completed / 7;
  }

  EmployeeApprovalPolicyRule toRule({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeApprovalPolicyRule(
      id: id,
      employeeId: employeeId,
      area: area,
      name: name.trim(),
      primaryRoute: primaryRoute,
      fallbackRoute: fallbackRoute,
      owner: owner.trim(),
      thresholdLabel: thresholdLabel.trim(),
      escalationHours: escalationHours,
      escalationMode: escalationMode,
      expiresOn: expiresOn!,
      status: EmployeeApprovalPolicyStatus.draft,
      risk: risk,
      notes: notes.trim(),
    );
  }
}

int _attentionRank(EmployeeApprovalPolicyRule rule, DateTime asOfDate) {
  if (rule.isSuspended) return 0;
  if (rule.isExpired(asOfDate)) return 1;
  if (rule.needsReview) return 2;
  if (rule.isDraft) return 3;
  if (rule.expiresWithin(asOfDate, 14)) return 4;
  if (rule.isHighRisk) return 5;
  return 6;
}

int _riskRank(EmployeeApprovalPolicyRisk risk) {
  return switch (risk) {
    EmployeeApprovalPolicyRisk.high => 0,
    EmployeeApprovalPolicyRisk.medium => 1,
    EmployeeApprovalPolicyRisk.low => 2,
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
