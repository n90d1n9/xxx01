import 'package:flutter_riverpod/legacy.dart';

import '../models/holiday_audit_models.dart';
import '../models/holiday_models.dart';

class HolidayAuditLogNotifier extends StateNotifier<List<HolidayAuditEntry>> {
  final DateTime Function() timestampReader;
  final String actor;
  int _sequence = 0;

  HolidayAuditLogNotifier({
    required this.timestampReader,
    this.actor = 'HR Admin',
  }) : super(const []);

  void recordCreated(HolidayRecord holiday) {
    _append(
      HolidayAuditEntry.created(
        sequence: _nextSequence(),
        holiday: holiday,
        recordedAt: _nextTimestamp(),
        actor: actor,
      ),
    );
  }

  void recordUpdated({
    required HolidayRecord previous,
    required HolidayRecord current,
  }) {
    final sequence = _nextSequence();
    final entry = HolidayAuditEntry.updated(
      sequence: sequence,
      previous: previous,
      current: current,
      recordedAt: _timestampForSequence(sequence),
      actor: actor,
    );
    if (entry == null) {
      _sequence--;
      return;
    }

    _append(entry);
  }

  void recordDeleted(HolidayRecord holiday) {
    _append(
      HolidayAuditEntry.deleted(
        sequence: _nextSequence(),
        holiday: holiday,
        recordedAt: _nextTimestamp(),
        actor: actor,
      ),
    );
  }

  int _nextSequence() {
    _sequence += 1;
    return _sequence;
  }

  DateTime _nextTimestamp() {
    return _timestampForSequence(_sequence);
  }

  DateTime _timestampForSequence(int sequence) {
    return timestampReader().add(Duration(minutes: sequence));
  }

  void _append(HolidayAuditEntry entry) {
    state = [entry, ...state].take(50).toList();
  }
}
