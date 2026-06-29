import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_case_log_seed_data.dart';
import '../models/employee_case_log_models.dart';
import '../models/employee_directory_models.dart';
import 'employee_directory_provider.dart';

final employeeHrCaseLogProvider = StateNotifierProvider.family<
  EmployeeHrCaseLogNotifier,
  EmployeeHrCaseLog?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeHrCaseLogNotifier(null);
  }

  return EmployeeHrCaseLogNotifier(
    buildEmployeeHrCaseLog(member: member, asOfDate: asOfDate),
  );
});

final employeeHrCaseNoteDraftProvider = StateNotifierProvider.family<
  EmployeeHrCaseNoteDraftNotifier,
  EmployeeHrCaseNoteDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeHrCaseNoteDraftNotifier(null);
  }

  return EmployeeHrCaseNoteDraftNotifier(
    buildEmployeeHrCaseNoteDraft(member: member, asOfDate: asOfDate),
  );
});

final employeeHrCaseIntakeDraftProvider = StateNotifierProvider.family<
  EmployeeHrCaseIntakeDraftNotifier,
  EmployeeHrCaseIntakeDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeHrCaseIntakeDraftNotifier(null);
  }

  return EmployeeHrCaseIntakeDraftNotifier(
    buildEmployeeHrCaseIntakeDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeHrCaseLogNotifier extends StateNotifier<EmployeeHrCaseLog?> {
  EmployeeHrCaseLogNotifier(super.state);

  EmployeeHrCaseRecord createCase(EmployeeHrCaseIntakeDraft draft) {
    final log = state;
    if (log == null) {
      throw StateError('Employee HR case log is unavailable');
    }

    final record = draft.toRecord(id: _nextCaseId(log));
    state = log.copyWith(cases: [record, ...log.cases]);
    return record;
  }

  EmployeeHrCaseNote addNote(EmployeeHrCaseNoteDraft draft) {
    final log = state;
    if (log == null) {
      throw StateError('Employee HR case log is unavailable');
    }
    if (!log.cases.any((record) => record.id == draft.caseId)) {
      throw StateError('Selected HR case is unavailable');
    }

    final note = draft.toNote(id: _nextNoteId(log));
    state = log.copyWith(notes: [note, ...log.notes]);
    return note;
  }

  void updateCaseStatus(String caseId, EmployeeHrCaseStatus status) {
    final log = state;
    if (log == null) return;

    state = log.copyWith(
      cases:
          log.cases.map((record) {
            if (record.id == caseId) {
              return record.copyWith(status: status);
            }
            return record;
          }).toList(),
    );
  }

  void resolveCase(String caseId) {
    updateCaseStatus(caseId, EmployeeHrCaseStatus.resolved);
  }

  void scheduleFollowUp(String caseId, DateTime followUpDate) {
    final log = state;
    if (log == null) return;

    state = log.copyWith(
      cases:
          log.cases.map((record) {
            if (record.id == caseId) {
              return record.copyWith(
                followUpDate: DateTime(
                  followUpDate.year,
                  followUpDate.month,
                  followUpDate.day,
                ),
              );
            }
            return record;
          }).toList(),
    );
  }

  String _nextNoteId(EmployeeHrCaseLog log) {
    return 'HCN-${log.employeeId}-${(log.notes.length + 1).toString().padLeft(3, '0')}';
  }

  String _nextCaseId(EmployeeHrCaseLog log) {
    var index = log.cases.length + 1;
    while (true) {
      final id = 'HRC-${log.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!log.cases.any((record) => record.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeHrCaseIntakeDraftNotifier
    extends StateNotifier<EmployeeHrCaseIntakeDraft?> {
  final EmployeeHrCaseIntakeDraft? _initialDraft;

  EmployeeHrCaseIntakeDraftNotifier(super.state) : _initialDraft = state;

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setSummary(String value) {
    state = state?.copyWith(summary: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setType(EmployeeHrCaseType value) {
    state = state?.copyWith(type: value);
  }

  void setPriority(EmployeeHrCasePriority value) {
    state = state?.copyWith(priority: value);
  }

  void setConfidentiality(EmployeeHrCaseConfidentiality value) {
    state = state?.copyWith(confidentiality: value);
  }

  void setFollowUpDate(DateTime value) {
    state = state?.copyWith(
      followUpDate: DateTime(value.year, value.month, value.day),
    );
  }

  void reset() {
    state = _initialDraft;
  }
}

class EmployeeHrCaseNoteDraftNotifier
    extends StateNotifier<EmployeeHrCaseNoteDraft?> {
  final EmployeeHrCaseNoteDraft? _initialDraft;

  EmployeeHrCaseNoteDraftNotifier(super.state) : _initialDraft = state;

  void setCaseId(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(caseId: value);
  }

  void setAuthor(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(author: value);
  }

  void setBody(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(body: value);
  }

  void setConfidential(bool value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(confidential: value);
  }

  void reset() {
    state = _initialDraft;
  }
}

EmployeeDirectoryMember? _findMember(
  List<EmployeeDirectoryMember> members,
  String employeeId,
) {
  for (final member in members) {
    if (member.id == employeeId) {
      return member;
    }
  }
  return null;
}
