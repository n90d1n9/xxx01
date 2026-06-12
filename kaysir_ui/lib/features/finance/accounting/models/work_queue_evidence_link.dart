import 'work_queue_evidence_review_state.dart';

/// Evidence reference category used by accounting work queue support links.
enum AccountingWorkspaceWorkQueueEvidenceLinkType {
  workpaper,
  sourceDocument,
  approval,
  bankStatement,
  taxFiling,
  other,
}

/// Draft payload captured before an evidence reference is persisted.
class AccountingWorkspaceWorkQueueEvidenceLinkDraft {
  const AccountingWorkspaceWorkQueueEvidenceLinkDraft({
    required this.label,
    required this.reference,
    this.type = AccountingWorkspaceWorkQueueEvidenceLinkType.workpaper,
  });

  final String label;
  final String reference;
  final AccountingWorkspaceWorkQueueEvidenceLinkType type;

  bool get canSubmit => label.trim().isNotEmpty && reference.trim().isNotEmpty;
}

/// Persisted accounting work queue evidence reference for close audit support.
class AccountingWorkspaceWorkQueueEvidenceLink {
  const AccountingWorkspaceWorkQueueEvidenceLink({
    required this.id,
    required this.queueId,
    required this.label,
    required this.reference,
    required this.addedByLabel,
    required this.addedAt,
    this.type = AccountingWorkspaceWorkQueueEvidenceLinkType.workpaper,
  });

  factory AccountingWorkspaceWorkQueueEvidenceLink.create({
    required String queueId,
    required String label,
    required String reference,
    required String addedByLabel,
    required DateTime addedAt,
    AccountingWorkspaceWorkQueueEvidenceLinkType type =
        AccountingWorkspaceWorkQueueEvidenceLinkType.workpaper,
    String? id,
  }) {
    final normalizedQueueId = queueId.trim();

    return AccountingWorkspaceWorkQueueEvidenceLink(
      id:
          _normalizedStringValue(id) ??
          '$normalizedQueueId-evidence-${addedAt.microsecondsSinceEpoch}',
      queueId: normalizedQueueId,
      label: label.trim(),
      reference: reference.trim(),
      addedByLabel: addedByLabel.trim(),
      addedAt: addedAt,
      type: type,
    );
  }

  factory AccountingWorkspaceWorkQueueEvidenceLink.fromJson(
    Map<String, Object?> json,
  ) {
    return AccountingWorkspaceWorkQueueEvidenceLink(
      id: _stringValue(json['id']).trim(),
      queueId: _stringValue(json['queueId']).trim(),
      label: _stringValue(json['label']).trim(),
      reference: _stringValue(json['reference']).trim(),
      addedByLabel: _stringValue(json['addedByLabel']).trim(),
      addedAt: _dateTimeValue(json['addedAt']),
      type: accountingWorkspaceWorkQueueEvidenceLinkTypeFromStorage(
        json['type'],
      ),
    );
  }

  final String id;
  final String queueId;
  final String label;
  final String reference;
  final String addedByLabel;
  final DateTime addedAt;
  final AccountingWorkspaceWorkQueueEvidenceLinkType type;

  bool get isPersistable =>
      id.trim().isNotEmpty &&
      queueId.trim().isNotEmpty &&
      label.trim().isNotEmpty &&
      reference.trim().isNotEmpty;

  String get typeLabel => type.label;

  String get addedByDisplayLabel {
    final normalizedAddedBy = addedByLabel.trim();
    if (normalizedAddedBy.isEmpty) return 'Accounting workspace';

    return normalizedAddedBy;
  }

  String get timeLabel => _dateTimeLabel(addedAt);

  String get auditLine {
    return '$typeLabel: $label - $reference - $addedByDisplayLabel - $timeLabel';
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'queueId': queueId,
      'label': label,
      'reference': reference,
      'addedByLabel': addedByLabel,
      'addedAt': addedAt.toIso8601String(),
      'type': type.storageValue,
    };
  }
}

extension AccountingWorkspaceWorkQueueEvidenceLinkTypeStorage
    on AccountingWorkspaceWorkQueueEvidenceLinkType {
  String get label {
    switch (this) {
      case AccountingWorkspaceWorkQueueEvidenceLinkType.workpaper:
        return 'Workpaper';
      case AccountingWorkspaceWorkQueueEvidenceLinkType.sourceDocument:
        return 'Source document';
      case AccountingWorkspaceWorkQueueEvidenceLinkType.approval:
        return 'Approval';
      case AccountingWorkspaceWorkQueueEvidenceLinkType.bankStatement:
        return 'Bank statement';
      case AccountingWorkspaceWorkQueueEvidenceLinkType.taxFiling:
        return 'Tax filing';
      case AccountingWorkspaceWorkQueueEvidenceLinkType.other:
        return 'Other';
    }
  }

  String get storageValue {
    switch (this) {
      case AccountingWorkspaceWorkQueueEvidenceLinkType.workpaper:
        return 'workpaper';
      case AccountingWorkspaceWorkQueueEvidenceLinkType.sourceDocument:
        return 'source-document';
      case AccountingWorkspaceWorkQueueEvidenceLinkType.approval:
        return 'approval';
      case AccountingWorkspaceWorkQueueEvidenceLinkType.bankStatement:
        return 'bank-statement';
      case AccountingWorkspaceWorkQueueEvidenceLinkType.taxFiling:
        return 'tax-filing';
      case AccountingWorkspaceWorkQueueEvidenceLinkType.other:
        return 'other';
    }
  }
}

AccountingWorkspaceWorkQueueEvidenceLink?
accountingWorkspaceWorkQueueEvidenceLinkFromJson(Map<String, Object?> json) {
  final link = AccountingWorkspaceWorkQueueEvidenceLink.fromJson(json);
  if (!link.isPersistable) return null;

  return link;
}

AccountingWorkspaceWorkQueueEvidenceLinkType
accountingWorkspaceWorkQueueEvidenceLinkTypeFromStorage(Object? value) {
  switch (_stringValue(value).trim().toLowerCase()) {
    case 'source-document':
    case 'source_document':
    case 'source':
    case 'document':
      return AccountingWorkspaceWorkQueueEvidenceLinkType.sourceDocument;
    case 'approval':
    case 'signoff':
    case 'sign-off':
      return AccountingWorkspaceWorkQueueEvidenceLinkType.approval;
    case 'bank-statement':
    case 'bank_statement':
    case 'bank':
      return AccountingWorkspaceWorkQueueEvidenceLinkType.bankStatement;
    case 'tax-filing':
    case 'tax_filing':
    case 'tax':
    case 'spt':
      return AccountingWorkspaceWorkQueueEvidenceLinkType.taxFiling;
    case 'other':
    case 'misc':
      return AccountingWorkspaceWorkQueueEvidenceLinkType.other;
    default:
      return AccountingWorkspaceWorkQueueEvidenceLinkType.workpaper;
  }
}

String accountingWorkspaceWorkQueueEvidenceLinksBrief({
  required String queueTitle,
  required Iterable<AccountingWorkspaceWorkQueueEvidenceLink> links,
  Iterable<AccountingWorkspaceWorkQueueEvidenceReviewState> reviewStates =
      const [],
}) {
  final persistedLinks = [
    for (final link in links)
      if (link.isPersistable) link,
  ]..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  final reviewStateByLinkId = {
    for (final state in reviewStates)
      if (state.linkId.trim().isNotEmpty) state.linkId: state,
  };

  final lines = [
    'Evidence links: $queueTitle',
    if (persistedLinks.isEmpty)
      'No evidence links captured.'
    else
      for (var index = 0; index < persistedLinks.length; index += 1)
        '${index + 1}. ${persistedLinks[index].auditLine} - '
            '${_evidenceReviewBriefLine(reviewStateByLinkId[persistedLinks[index].id])}',
  ];

  return lines.join('\n');
}

String _evidenceReviewBriefLine(
  AccountingWorkspaceWorkQueueEvidenceReviewState? state,
) {
  if (state == null) return 'Review: Review pending';

  final reviewLine = 'Review: ${state.statusLabel}';
  final auditTrail = state.hasReviewTrail ? ' - ${state.reviewTrailLabel}' : '';
  if (!state.hasReviewNote) return '$reviewLine$auditTrail';

  return '$reviewLine$auditTrail - ${state.normalizedReviewNote}';
}

DateTime _dateTimeValue(Object? value) {
  if (value is DateTime) return value;
  if (value is String) {
    return DateTime.tryParse(value)?.toLocal() ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  return DateTime.fromMillisecondsSinceEpoch(0);
}

String _dateTimeLabel(DateTime value) {
  final localValue = value.toLocal();

  return '${localValue.year.toString().padLeft(4, '0')}-'
      '${localValue.month.toString().padLeft(2, '0')}-'
      '${localValue.day.toString().padLeft(2, '0')} '
      '${localValue.hour.toString().padLeft(2, '0')}:'
      '${localValue.minute.toString().padLeft(2, '0')}';
}

String _stringValue(Object? value) => value is String ? value : '';

String? _normalizedStringValue(Object? value) {
  if (value is! String) return null;

  final normalizedValue = value.trim();
  return normalizedValue.isEmpty ? null : normalizedValue;
}
