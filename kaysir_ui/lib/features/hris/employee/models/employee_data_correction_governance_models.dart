import 'employee_data_correction_models.dart';
import 'employee_data_quality_models.dart';

enum EmployeeDataCorrectionGovernanceRuleType {
  reviewerSeparation('Reviewer separation'),
  evidence('Evidence'),
  severityGate('Severity gate'),
  sla('SLA'),
  valueChange('Value change');

  final String label;

  const EmployeeDataCorrectionGovernanceRuleType(this.label);
}

enum EmployeeDataCorrectionGovernanceStatus {
  passed('Passed'),
  warning('Warning'),
  blocked('Blocked'),
  waived('Waived');

  final String label;

  const EmployeeDataCorrectionGovernanceStatus(this.label);
}

class EmployeeDataCorrectionGovernanceRule {
  final String id;
  final String requestId;
  final String requestField;
  final String title;
  final String detail;
  final String owner;
  final EmployeeDataCorrectionGovernanceRuleType type;
  final EmployeeDataCorrectionGovernanceStatus status;

  const EmployeeDataCorrectionGovernanceRule({
    required this.id,
    required this.requestId,
    required this.requestField,
    required this.title,
    required this.detail,
    required this.owner,
    required this.type,
    required this.status,
  });

  bool get isBlocked =>
      status == EmployeeDataCorrectionGovernanceStatus.blocked;

  bool get isWarning =>
      status == EmployeeDataCorrectionGovernanceStatus.warning;

  bool get needsAttention => isBlocked || isWarning;
}

class EmployeeDataCorrectionEvidence {
  final String id;
  final String employeeId;
  final String requestId;
  final String author;
  final String summary;
  final DateTime createdAt;

  const EmployeeDataCorrectionEvidence({
    required this.id,
    required this.employeeId,
    required this.requestId,
    required this.author,
    required this.summary,
    required this.createdAt,
  });
}

class EmployeeDataCorrectionGovernanceProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeDataCorrectionRequest> requests;
  final List<EmployeeDataCorrectionEvidence> evidence;
  final Set<String> waivedRuleIds;

  const EmployeeDataCorrectionGovernanceProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.requests,
    required this.evidence,
    required this.waivedRuleIds,
  });

  EmployeeDataCorrectionGovernanceProfile copyWith({
    List<EmployeeDataCorrectionEvidence>? evidence,
    Set<String>? waivedRuleIds,
  }) {
    return EmployeeDataCorrectionGovernanceProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      requests: requests,
      evidence: evidence ?? this.evidence,
      waivedRuleIds: waivedRuleIds ?? this.waivedRuleIds,
    );
  }

  List<EmployeeDataCorrectionGovernanceRule> get rules {
    final results = <EmployeeDataCorrectionGovernanceRule>[];
    for (final request in requests.where((request) => request.isOpen)) {
      results.addAll(
        _rulesForRequest(
          request: request,
          asOfDate: asOfDate,
          evidence: evidence,
          waivedRuleIds: waivedRuleIds,
        ),
      );
    }
    return results;
  }

  List<EmployeeDataCorrectionGovernanceRule> get sortedRules {
    final sorted = [...rules]..sort((a, b) {
      final statusCompare = _statusRank(
        a.status,
      ).compareTo(_statusRank(b.status));
      if (statusCompare != 0) return statusCompare;

      return _typeRank(a.type).compareTo(_typeRank(b.type));
    });
    return sorted;
  }

  List<EmployeeDataCorrectionEvidence> get latestEvidence {
    final sorted = [...evidence]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(4).toList();
  }

  int get blockedCount => rules.where((rule) => rule.isBlocked).length;

  int get warningCount => rules.where((rule) => rule.isWarning).length;

  int get passedCount {
    return rules
        .where(
          (rule) =>
              rule.status == EmployeeDataCorrectionGovernanceStatus.passed,
        )
        .length;
  }

  int get waivedCount {
    return rules
        .where(
          (rule) =>
              rule.status == EmployeeDataCorrectionGovernanceStatus.waived,
        )
        .length;
  }

  int get evidenceCount => evidence.length;

  int get attentionCount => blockedCount + warningCount;

  String get nextAction {
    if (blockedCount > 0) {
      return 'Clear $blockedCount blocked correction governance rule${blockedCount == 1 ? '' : 's'}.';
    }
    if (warningCount > 0) {
      return 'Review $warningCount correction governance warning${warningCount == 1 ? '' : 's'}.';
    }
    if (requests.any((request) => request.isOpen)) {
      return 'Correction governance checks are clear.';
    }
    return 'No correction governance checks pending.';
  }
}

class EmployeeDataCorrectionEvidenceDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String requestId;
  final String author;
  final String summary;

  const EmployeeDataCorrectionEvidenceDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.requestId,
    required this.author,
    required this.summary,
  });

  EmployeeDataCorrectionEvidenceDraft copyWith({
    String? requestId,
    String? author,
    String? summary,
  }) {
    return EmployeeDataCorrectionEvidenceDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      requestId: requestId ?? this.requestId,
      author: author ?? this.author,
      summary: summary ?? this.summary,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (requestId.trim().isEmpty) {
      errors.add('Select a correction request');
    }
    if (author.trim().length < 3) {
      errors.add('Enter an evidence author');
    }
    if (summary.trim().length < 12) {
      errors.add('Evidence summary must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var complete = 0;
    if (requestId.trim().isNotEmpty) complete++;
    if (author.trim().length >= 3) complete++;
    if (summary.trim().length >= 12) complete++;
    return complete / 3;
  }

  EmployeeDataCorrectionEvidence toEvidence({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeDataCorrectionEvidence(
      id: id,
      employeeId: employeeId,
      requestId: requestId,
      author: author.trim(),
      summary: summary.trim(),
      createdAt: _dateOnly(asOfDate),
    );
  }
}

List<EmployeeDataCorrectionGovernanceRule> _rulesForRequest({
  required EmployeeDataCorrectionRequest request,
  required DateTime asOfDate,
  required List<EmployeeDataCorrectionEvidence> evidence,
  required Set<String> waivedRuleIds,
}) {
  final hasEvidence = evidence.any((item) => item.requestId == request.id);

  return [
    _rule(
      request: request,
      type: EmployeeDataCorrectionGovernanceRuleType.reviewerSeparation,
      title: 'Reviewer must differ from requester',
      detail:
          request.requester.trim().toLowerCase() ==
                  request.reviewer.trim().toLowerCase()
              ? 'Requester and reviewer are both ${request.reviewer}.'
              : '${request.reviewer} is separated from ${request.requester}.',
      owner: 'People Operations',
      status:
          request.requester.trim().toLowerCase() ==
                  request.reviewer.trim().toLowerCase()
              ? EmployeeDataCorrectionGovernanceStatus.blocked
              : EmployeeDataCorrectionGovernanceStatus.passed,
      waivedRuleIds: waivedRuleIds,
    ),
    _rule(
      request: request,
      type: EmployeeDataCorrectionGovernanceRuleType.evidence,
      title: 'Evidence must support the correction',
      detail:
          hasEvidence
              ? 'Evidence has been attached for this correction.'
              : 'Attach evidence before applying this correction.',
      owner: request.reviewer,
      status:
          hasEvidence
              ? EmployeeDataCorrectionGovernanceStatus.passed
              : request.status == EmployeeDataCorrectionStatus.approved
              ? EmployeeDataCorrectionGovernanceStatus.blocked
              : EmployeeDataCorrectionGovernanceStatus.warning,
      waivedRuleIds: waivedRuleIds,
    ),
    _rule(
      request: request,
      type: EmployeeDataCorrectionGovernanceRuleType.severityGate,
      title: 'High-risk corrections require HR reviewer',
      detail: _severityDetail(request),
      owner: 'HR Business Partner',
      status: _severityStatus(request),
      waivedRuleIds: waivedRuleIds,
    ),
    _rule(
      request: request,
      type: EmployeeDataCorrectionGovernanceRuleType.sla,
      title: 'Correction must stay within SLA',
      detail:
          request.isOverdue(asOfDate)
              ? 'Correction is past its due date.'
              : 'Correction is within SLA.',
      owner: request.reviewer,
      status:
          request.isOverdue(asOfDate)
              ? EmployeeDataCorrectionGovernanceStatus.blocked
              : EmployeeDataCorrectionGovernanceStatus.passed,
      waivedRuleIds: waivedRuleIds,
    ),
    _rule(
      request: request,
      type: EmployeeDataCorrectionGovernanceRuleType.valueChange,
      title: 'Proposed value must be concrete',
      detail:
          _hasConcreteValue(request.proposedValue)
              ? 'Proposed value is concrete and reviewable.'
              : 'Replace placeholder proposed value before applying.',
      owner: request.requester,
      status:
          _hasConcreteValue(request.proposedValue)
              ? EmployeeDataCorrectionGovernanceStatus.passed
              : EmployeeDataCorrectionGovernanceStatus.warning,
      waivedRuleIds: waivedRuleIds,
    ),
  ];
}

EmployeeDataCorrectionGovernanceRule _rule({
  required EmployeeDataCorrectionRequest request,
  required EmployeeDataCorrectionGovernanceRuleType type,
  required String title,
  required String detail,
  required String owner,
  required EmployeeDataCorrectionGovernanceStatus status,
  required Set<String> waivedRuleIds,
}) {
  final id = '${request.id}-${type.name}';
  return EmployeeDataCorrectionGovernanceRule(
    id: id,
    requestId: request.id,
    requestField: request.field,
    title: title,
    detail: detail,
    owner: owner,
    type: type,
    status:
        waivedRuleIds.contains(id)
            ? EmployeeDataCorrectionGovernanceStatus.waived
            : status,
  );
}

EmployeeDataCorrectionGovernanceStatus _severityStatus(
  EmployeeDataCorrectionRequest request,
) {
  if (request.severity == EmployeeDataQualitySeverity.low ||
      request.severity == EmployeeDataQualitySeverity.medium) {
    return EmployeeDataCorrectionGovernanceStatus.passed;
  }

  final reviewer = request.reviewer.toLowerCase();
  final hasHrReviewer =
      reviewer.contains('people') ||
      reviewer.contains('business partner') ||
      reviewer.contains('operations') ||
      reviewer.contains('officer');

  return hasHrReviewer
      ? EmployeeDataCorrectionGovernanceStatus.passed
      : EmployeeDataCorrectionGovernanceStatus.warning;
}

String _severityDetail(EmployeeDataCorrectionRequest request) {
  if (request.severity == EmployeeDataQualitySeverity.low ||
      request.severity == EmployeeDataQualitySeverity.medium) {
    return '${request.severity.label} correction does not need an elevated reviewer.';
  }
  if (_severityStatus(request) ==
      EmployeeDataCorrectionGovernanceStatus.passed) {
    return '${request.reviewer} can review ${request.severity.label.toLowerCase()} corrections.';
  }
  return '${request.severity.label} correction should be reviewed by HR governance.';
}

bool _hasConcreteValue(String value) {
  final normalized = value.trim().toLowerCase();
  return normalized.length >= 4 &&
      !normalized.startsWith('pending') &&
      !normalized.contains('tbd');
}

int _statusRank(EmployeeDataCorrectionGovernanceStatus status) {
  return switch (status) {
    EmployeeDataCorrectionGovernanceStatus.blocked => 0,
    EmployeeDataCorrectionGovernanceStatus.warning => 1,
    EmployeeDataCorrectionGovernanceStatus.passed => 2,
    EmployeeDataCorrectionGovernanceStatus.waived => 3,
  };
}

int _typeRank(EmployeeDataCorrectionGovernanceRuleType type) {
  return switch (type) {
    EmployeeDataCorrectionGovernanceRuleType.evidence => 0,
    EmployeeDataCorrectionGovernanceRuleType.reviewerSeparation => 1,
    EmployeeDataCorrectionGovernanceRuleType.sla => 2,
    EmployeeDataCorrectionGovernanceRuleType.severityGate => 3,
    EmployeeDataCorrectionGovernanceRuleType.valueChange => 4,
  };
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
