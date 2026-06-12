/// Execution note category used to classify accounting work queue follow-up.
enum AccountingWorkspaceWorkQueueNoteType {
  note,
  handoff,
  evidence,
  risk,
  decision,
}

/// Draft payload captured by the work queue note composer before persistence.
class AccountingWorkspaceWorkQueueNoteDraft {
  const AccountingWorkspaceWorkQueueNoteDraft({
    required this.body,
    this.type = AccountingWorkspaceWorkQueueNoteType.note,
  });

  final String body;
  final AccountingWorkspaceWorkQueueNoteType type;

  bool get canSubmit => body.trim().isNotEmpty;
}

/// Persisted accounting work queue note for owner handoffs and audit history.
class AccountingWorkspaceWorkQueueNote {
  const AccountingWorkspaceWorkQueueNote({
    required this.id,
    required this.queueId,
    required this.authorLabel,
    required this.body,
    required this.createdAt,
    this.type = AccountingWorkspaceWorkQueueNoteType.note,
  });

  factory AccountingWorkspaceWorkQueueNote.create({
    required String queueId,
    required String authorLabel,
    required String body,
    required DateTime createdAt,
    AccountingWorkspaceWorkQueueNoteType type =
        AccountingWorkspaceWorkQueueNoteType.note,
    String? id,
  }) {
    final normalizedQueueId = queueId.trim();

    return AccountingWorkspaceWorkQueueNote(
      id:
          _normalizedStringValue(id) ??
          '$normalizedQueueId-${createdAt.microsecondsSinceEpoch}',
      queueId: normalizedQueueId,
      authorLabel: authorLabel.trim(),
      body: body.trim(),
      createdAt: createdAt,
      type: type,
    );
  }

  factory AccountingWorkspaceWorkQueueNote.fromJson(Map<String, Object?> json) {
    final createdAt = _dateTimeValue(json['createdAt']);

    return AccountingWorkspaceWorkQueueNote(
      id: _stringValue(json['id']).trim(),
      queueId: _stringValue(json['queueId']).trim(),
      authorLabel: _stringValue(json['authorLabel']).trim(),
      body: _stringValue(json['body']).trim(),
      createdAt: createdAt,
      type: accountingWorkspaceWorkQueueNoteTypeFromStorage(json['type']),
    );
  }

  final String id;
  final String queueId;
  final String authorLabel;
  final String body;
  final DateTime createdAt;
  final AccountingWorkspaceWorkQueueNoteType type;

  bool get isPersistable =>
      id.trim().isNotEmpty &&
      queueId.trim().isNotEmpty &&
      body.trim().isNotEmpty;

  String get typeLabel {
    switch (type) {
      case AccountingWorkspaceWorkQueueNoteType.note:
        return 'Note';
      case AccountingWorkspaceWorkQueueNoteType.handoff:
        return 'Handoff';
      case AccountingWorkspaceWorkQueueNoteType.evidence:
        return 'Evidence';
      case AccountingWorkspaceWorkQueueNoteType.risk:
        return 'Risk';
      case AccountingWorkspaceWorkQueueNoteType.decision:
        return 'Decision';
    }
  }

  String get authorDisplayLabel {
    final normalizedAuthor = authorLabel.trim();
    if (normalizedAuthor.isEmpty) return 'Accounting workspace';

    return normalizedAuthor;
  }

  String get timeLabel => _dateTimeLabel(createdAt);

  String get auditLine {
    return '$typeLabel: $body - $authorDisplayLabel - $timeLabel';
  }

  AccountingWorkspaceWorkQueueNote copyWith({
    String? id,
    String? queueId,
    String? authorLabel,
    String? body,
    DateTime? createdAt,
    AccountingWorkspaceWorkQueueNoteType? type,
  }) {
    return AccountingWorkspaceWorkQueueNote(
      id: id ?? this.id,
      queueId: queueId ?? this.queueId,
      authorLabel: authorLabel ?? this.authorLabel,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'queueId': queueId,
      'authorLabel': authorLabel,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'type': type.storageValue,
    };
  }
}

extension AccountingWorkspaceWorkQueueNoteTypeStorage
    on AccountingWorkspaceWorkQueueNoteType {
  String get label {
    switch (this) {
      case AccountingWorkspaceWorkQueueNoteType.note:
        return 'Note';
      case AccountingWorkspaceWorkQueueNoteType.handoff:
        return 'Handoff';
      case AccountingWorkspaceWorkQueueNoteType.evidence:
        return 'Evidence';
      case AccountingWorkspaceWorkQueueNoteType.risk:
        return 'Risk';
      case AccountingWorkspaceWorkQueueNoteType.decision:
        return 'Decision';
    }
  }

  String get storageValue {
    switch (this) {
      case AccountingWorkspaceWorkQueueNoteType.note:
        return 'note';
      case AccountingWorkspaceWorkQueueNoteType.handoff:
        return 'handoff';
      case AccountingWorkspaceWorkQueueNoteType.evidence:
        return 'evidence';
      case AccountingWorkspaceWorkQueueNoteType.risk:
        return 'risk';
      case AccountingWorkspaceWorkQueueNoteType.decision:
        return 'decision';
    }
  }
}

AccountingWorkspaceWorkQueueNote? accountingWorkspaceWorkQueueNoteFromJson(
  Map<String, Object?> json,
) {
  final note = AccountingWorkspaceWorkQueueNote.fromJson(json);
  if (!note.isPersistable) return null;

  return note;
}

AccountingWorkspaceWorkQueueNoteType
accountingWorkspaceWorkQueueNoteTypeFromStorage(Object? value) {
  switch (_stringValue(value).trim().toLowerCase()) {
    case 'handoff':
    case 'owner-handoff':
    case 'owner_handoff':
      return AccountingWorkspaceWorkQueueNoteType.handoff;
    case 'evidence':
    case 'support':
      return AccountingWorkspaceWorkQueueNoteType.evidence;
    case 'risk':
    case 'blocker':
      return AccountingWorkspaceWorkQueueNoteType.risk;
    case 'decision':
    case 'signoff':
    case 'sign-off':
      return AccountingWorkspaceWorkQueueNoteType.decision;
    default:
      return AccountingWorkspaceWorkQueueNoteType.note;
  }
}

String accountingWorkspaceWorkQueueNotesBrief({
  required String queueTitle,
  required Iterable<AccountingWorkspaceWorkQueueNote> notes,
}) {
  final persistedNotes = [
    for (final note in notes)
      if (note.isPersistable) note,
  ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  final lines = [
    'Execution notes: $queueTitle',
    if (persistedNotes.isEmpty)
      'No execution notes captured.'
    else
      for (var index = 0; index < persistedNotes.length; index += 1)
        '${index + 1}. ${persistedNotes[index].auditLine}',
  ];

  return lines.join('\n');
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
