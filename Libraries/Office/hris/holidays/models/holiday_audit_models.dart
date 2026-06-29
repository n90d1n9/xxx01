import 'holiday_models.dart';

enum HolidayAuditAction {
  created('Created'),
  updated('Updated'),
  deleted('Deleted');

  final String label;

  const HolidayAuditAction(this.label);
}

enum HolidayAuditSensitivity {
  standard('Standard'),
  releaseSensitive('Release sensitive');

  final String label;

  const HolidayAuditSensitivity(this.label);
}

class HolidayAuditEntry {
  final String id;
  final String holidayId;
  final String holidayName;
  final HolidayAuditAction action;
  final HolidayAuditSensitivity sensitivity;
  final DateTime recordedAt;
  final String actor;
  final String summary;
  final List<String> details;

  const HolidayAuditEntry({
    required this.id,
    required this.holidayId,
    required this.holidayName,
    required this.action,
    required this.sensitivity,
    required this.recordedAt,
    required this.actor,
    required this.summary,
    required this.details,
  });

  bool get isReleaseSensitive {
    return sensitivity == HolidayAuditSensitivity.releaseSensitive;
  }

  factory HolidayAuditEntry.created({
    required int sequence,
    required HolidayRecord holiday,
    required DateTime recordedAt,
    required String actor,
  }) {
    return HolidayAuditEntry(
      id: _auditId(sequence),
      holidayId: holiday.id,
      holidayName: holiday.name,
      action: HolidayAuditAction.created,
      sensitivity: _sensitivityForHoliday(holiday),
      recordedAt: recordedAt,
      actor: actor,
      summary:
          'Added ${holiday.type.label} holiday for ${_safeScope(holiday.scope)}.',
      details: _holidaySnapshotDetails(holiday),
    );
  }

  static HolidayAuditEntry? updated({
    required int sequence,
    required HolidayRecord previous,
    required HolidayRecord current,
    required DateTime recordedAt,
    required String actor,
  }) {
    final changes = _changedFieldDetails(previous, current);
    if (changes.isEmpty) return null;

    return HolidayAuditEntry(
      id: _auditId(sequence),
      holidayId: current.id,
      holidayName: current.name,
      action: HolidayAuditAction.updated,
      sensitivity: _sensitivityForUpdate(previous, current, changes),
      recordedAt: recordedAt,
      actor: actor,
      summary:
          'Updated ${changes.length} ${_pluralize('field', changes.length)} for ${current.name}.',
      details: changes,
    );
  }

  factory HolidayAuditEntry.deleted({
    required int sequence,
    required HolidayRecord holiday,
    required DateTime recordedAt,
    required String actor,
  }) {
    return HolidayAuditEntry(
      id: _auditId(sequence),
      holidayId: holiday.id,
      holidayName: holiday.name,
      action: HolidayAuditAction.deleted,
      sensitivity: _sensitivityForHoliday(holiday),
      recordedAt: recordedAt,
      actor: actor,
      summary: 'Removed ${holiday.name} from the holiday calendar.',
      details: _holidaySnapshotDetails(holiday),
    );
  }
}

class HolidayAuditSummary {
  final List<HolidayAuditEntry> entries;
  final int maxVisibleEntries;
  final int totalRecordedCount;
  final int createdCount;
  final int updatedCount;
  final int deletedCount;
  final int releaseSensitiveCount;

  const HolidayAuditSummary({
    required this.entries,
    required this.maxVisibleEntries,
    required this.totalRecordedCount,
    required this.createdCount,
    required this.updatedCount,
    required this.deletedCount,
    required this.releaseSensitiveCount,
  });

  factory HolidayAuditSummary.fromEntries({
    required Iterable<HolidayAuditEntry> entries,
    int maxVisibleEntries = 5,
  }) {
    final sortedEntries = entries.toList()..sort(_compareAuditEntries);

    return HolidayAuditSummary(
      entries: sortedEntries.take(maxVisibleEntries).toList(),
      maxVisibleEntries: maxVisibleEntries,
      totalRecordedCount: sortedEntries.length,
      createdCount: _countAction(sortedEntries, HolidayAuditAction.created),
      updatedCount: _countAction(sortedEntries, HolidayAuditAction.updated),
      deletedCount: _countAction(sortedEntries, HolidayAuditAction.deleted),
      releaseSensitiveCount:
          sortedEntries.where((entry) => entry.isReleaseSensitive).length,
    );
  }

  int get totalCount => totalRecordedCount;

  HolidayAuditEntry? get latestEntry {
    if (entries.isEmpty) return null;
    return entries.first;
  }

  bool get hasActivity => entries.isNotEmpty;
}

String _auditId(int sequence) {
  return 'holiday-audit-${sequence.toString().padLeft(4, '0')}';
}

HolidayAuditSensitivity _sensitivityForHoliday(HolidayRecord holiday) {
  if (holiday.requiresCoveragePlan ||
      !holiday.isPaid ||
      holiday.type == HolidayType.custom ||
      holiday.isObservedShifted) {
    return HolidayAuditSensitivity.releaseSensitive;
  }

  return HolidayAuditSensitivity.standard;
}

HolidayAuditSensitivity _sensitivityForUpdate(
  HolidayRecord previous,
  HolidayRecord current,
  List<String> changes,
) {
  if (_sensitivityForHoliday(previous) ==
      HolidayAuditSensitivity.releaseSensitive) {
    return HolidayAuditSensitivity.releaseSensitive;
  }
  if (_sensitivityForHoliday(current) ==
      HolidayAuditSensitivity.releaseSensitive) {
    return HolidayAuditSensitivity.releaseSensitive;
  }
  if (changes.any(_isReleaseSensitiveChange)) {
    return HolidayAuditSensitivity.releaseSensitive;
  }

  return HolidayAuditSensitivity.standard;
}

bool _isReleaseSensitiveChange(String detail) {
  return detail.startsWith('Date') ||
      detail.startsWith('Observed') ||
      detail.startsWith('Scope') ||
      detail.startsWith('Paid') ||
      detail.startsWith('Coverage');
}

List<String> _holidaySnapshotDetails(HolidayRecord holiday) {
  return [
    'Type: ${holiday.type.label}',
    'Scope: ${_safeScope(holiday.scope)}',
    'Effective: ${_formatDate(holiday.effectiveDate)}',
  ];
}

List<String> _changedFieldDetails(
  HolidayRecord previous,
  HolidayRecord current,
) {
  final details = <String>[];
  if (previous.name != current.name) {
    details.add('Name changed from ${previous.name} to ${current.name}');
  }
  if (previous.type != current.type) {
    details.add(
      'Type changed from ${previous.type.label} to ${current.type.label}',
    );
  }
  if (!_isSameDate(previous.date, current.date)) {
    details.add(
      'Date changed from ${_formatDate(previous.date)} to ${_formatDate(current.date)}',
    );
  }
  if (!_isSameNullableDate(previous.observedDate, current.observedDate)) {
    details.add(
      'Observed date changed from ${_formatNullableDate(previous.observedDate)} to ${_formatNullableDate(current.observedDate)}',
    );
  }
  if (previous.scope != current.scope) {
    details.add(
      'Scope changed from ${_safeScope(previous.scope)} to ${_safeScope(current.scope)}',
    );
  }
  if (previous.description != current.description) {
    details.add('Description updated');
  }
  if (previous.isPaid != current.isPaid) {
    details.add('Paid status changed to ${current.isPaid ? 'paid' : 'unpaid'}');
  }
  if (previous.isRecurring != current.isRecurring) {
    details.add(
      'Recurrence changed to ${current.isRecurring ? 'recurring' : 'one-time'}',
    );
  }
  if (previous.requiresCoveragePlan != current.requiresCoveragePlan) {
    details.add(
      'Coverage planning changed to ${current.requiresCoveragePlan ? 'required' : 'not required'}',
    );
  }

  return details;
}

int _compareAuditEntries(HolidayAuditEntry a, HolidayAuditEntry b) {
  final recordedCompared = b.recordedAt.compareTo(a.recordedAt);
  if (recordedCompared != 0) return recordedCompared;

  return b.id.compareTo(a.id);
}

int _countAction(
  Iterable<HolidayAuditEntry> entries,
  HolidayAuditAction action,
) {
  return entries.where((entry) => entry.action == action).length;
}

String _safeScope(String scope) {
  final trimmed = scope.trim();
  if (trimmed.isEmpty) return 'Unscoped';
  return trimmed;
}

String _formatNullableDate(DateTime? value) {
  if (value == null) return 'none';
  return _formatDate(value);
}

String _formatDate(DateTime value) {
  return '${_months[value.month - 1]} ${value.day}, ${value.year}';
}

bool _isSameNullableDate(DateTime? a, DateTime? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;

  return _isSameDate(a, b);
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _pluralize(String singular, int count) {
  if (count == 1) return singular;
  return '${singular}s';
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
