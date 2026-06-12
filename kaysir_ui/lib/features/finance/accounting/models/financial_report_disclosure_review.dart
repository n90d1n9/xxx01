import 'financial_report_pack.dart';

enum FinancialReportDisclosureRequirementPriority { required, advisory }

extension FinancialReportDisclosureRequirementPriorityLabel
    on FinancialReportDisclosureRequirementPriority {
  String get label {
    switch (this) {
      case FinancialReportDisclosureRequirementPriority.required:
        return 'Required';
      case FinancialReportDisclosureRequirementPriority.advisory:
        return 'Advisory';
    }
  }
}

enum FinancialReportDisclosureResolutionStatus { prepared, approved, deferred }

extension FinancialReportDisclosureResolutionStatusLabel
    on FinancialReportDisclosureResolutionStatus {
  String get label {
    switch (this) {
      case FinancialReportDisclosureResolutionStatus.prepared:
        return 'Prepared';
      case FinancialReportDisclosureResolutionStatus.approved:
        return 'Approved';
      case FinancialReportDisclosureResolutionStatus.deferred:
        return 'Deferred';
    }
  }
}

class FinancialReportDisclosureRequirement {
  final String id;
  final String noteNumber;
  final String title;
  final String description;
  final List<String> standardReferences;
  final String owner;
  final FinancialReportDisclosureRequirementPriority priority;

  const FinancialReportDisclosureRequirement({
    required this.id,
    required this.noteNumber,
    required this.title,
    required this.description,
    required this.standardReferences,
    required this.owner,
    required this.priority,
  });

  bool get blocksClose =>
      priority == FinancialReportDisclosureRequirementPriority.required;

  String get referenceLabel {
    if (standardReferences.isEmpty) {
      return 'Disclosure';
    }
    return standardReferences.join(' / ');
  }
}

class FinancialReportDisclosureResolution {
  final String requirementId;
  final FinancialReportDisclosureResolutionStatus status;
  final String reviewer;
  final DateTime reviewedAt;
  final String note;
  final String? evidenceReference;

  const FinancialReportDisclosureResolution({
    required this.requirementId,
    required this.status,
    required this.reviewer,
    required this.reviewedAt,
    required this.note,
    this.evidenceReference,
  });

  factory FinancialReportDisclosureResolution.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinancialReportDisclosureResolution(
      requirementId: json['requirementId'] as String,
      status: _statusFromJson(json['status'] as String?),
      reviewer: json['reviewer'] as String? ?? '',
      reviewedAt: _dateTimeFromJson(json['reviewedAt']) ?? DateTime.now(),
      note: json['note'] as String? ?? '',
      evidenceReference: json['evidenceReference'] as String?,
    );
  }

  bool get clearsCloseReview {
    switch (status) {
      case FinancialReportDisclosureResolutionStatus.prepared:
      case FinancialReportDisclosureResolutionStatus.approved:
        return true;
      case FinancialReportDisclosureResolutionStatus.deferred:
        return false;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'requirementId': requirementId,
      'status': status.name,
      'reviewer': reviewer,
      'reviewedAt': reviewedAt.toIso8601String(),
      'note': note,
      'evidenceReference': evidenceReference,
    };
  }
}

class FinancialReportDisclosureReviewItem {
  final FinancialReportDisclosureRequirement requirement;
  final FinancialReportDisclosureResolution? resolution;

  const FinancialReportDisclosureReviewItem({
    required this.requirement,
    this.resolution,
  });

  String get id => requirement.id;

  bool get isResolved => resolution?.clearsCloseReview ?? false;

  bool get isDeferred =>
      resolution?.status == FinancialReportDisclosureResolutionStatus.deferred;

  bool get needsReview => requirement.blocksClose && !isResolved;

  bool get blocksClose => requirement.blocksClose && !isResolved;

  FinancialReportDisclosureRequirementPriority get priority =>
      requirement.priority;
}

String disclosureRequirementIdFor(FinancialReportDisclosureNote note) {
  return 'note-${note.number}-${_slug(note.title)}';
}

String _slug(String value) {
  final normalized = value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return normalized.isEmpty ? 'disclosure' : normalized;
}

DateTime? _dateTimeFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value as String);
}

FinancialReportDisclosureResolutionStatus _statusFromJson(String? value) {
  switch (value) {
    case 'prepared':
      return FinancialReportDisclosureResolutionStatus.prepared;
    case 'deferred':
      return FinancialReportDisclosureResolutionStatus.deferred;
    case 'approved':
    default:
      return FinancialReportDisclosureResolutionStatus.approved;
  }
}
