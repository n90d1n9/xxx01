import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_compliance_seed_data.dart';
import '../models/employee_compliance_models.dart';
import '../models/employee_directory_models.dart';
import 'employee_directory_provider.dart';

final employeeComplianceRecordsProvider = StateNotifierProvider.family<
  EmployeeComplianceRecordsNotifier,
  List<EmployeeComplianceDocumentRecord>,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeComplianceRecordsNotifier(const []);
  }

  return EmployeeComplianceRecordsNotifier(
    buildEmployeeComplianceRecords(member: member, asOfDate: asOfDate),
  );
});

final employeeComplianceSummaryProvider =
    Provider.family<EmployeeComplianceDocumentSummary, String>((
      ref,
      employeeId,
    ) {
      return EmployeeComplianceDocumentSummary.fromRecords(
        records: ref.watch(employeeComplianceRecordsProvider(employeeId)),
        asOfDate: ref.watch(employeeDirectoryAsOfDateProvider),
      );
    });

final employeeComplianceDocumentDraftProvider = StateNotifierProvider.family<
  EmployeeComplianceDocumentDraftNotifier,
  EmployeeComplianceDocumentDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeComplianceDocumentDraftNotifier(null);
  }

  return EmployeeComplianceDocumentDraftNotifier(
    buildEmployeeComplianceDocumentDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeComplianceRecordsNotifier
    extends StateNotifier<List<EmployeeComplianceDocumentRecord>> {
  EmployeeComplianceRecordsNotifier(super.state);

  EmployeeComplianceDocumentRecord addDraft(
    EmployeeComplianceDocumentDraft draft,
  ) {
    final record = draft.toRecord(id: _nextId(draft.employeeId));
    state = [record, ...state];
    return record;
  }

  void verify(String recordId) {
    _updateStatus(recordId, EmployeeComplianceDocumentStatus.verified);
  }

  void reject(String recordId) {
    _updateStatus(recordId, EmployeeComplianceDocumentStatus.rejected);
  }

  void waive(String recordId) {
    _updateStatus(recordId, EmployeeComplianceDocumentStatus.waived);
  }

  void renew(String recordId, DateTime newExpiryDate) {
    state =
        state.map((record) {
          if (record.id == recordId) {
            return record.copyWith(
              expiresAt: DateTime(
                newExpiryDate.year,
                newExpiryDate.month,
                newExpiryDate.day,
              ),
              status: EmployeeComplianceDocumentStatus.verified,
              notes: '${record.notes} Renewal verified.',
            );
          }
          return record;
        }).toList();
  }

  void _updateStatus(String recordId, EmployeeComplianceDocumentStatus status) {
    state =
        state.map((record) {
          if (record.id == recordId) {
            return record.copyWith(status: status);
          }
          return record;
        }).toList();
  }

  String _nextId(String employeeId) {
    return 'ECD-$employeeId-${(state.length + 1).toString().padLeft(3, '0')}';
  }
}

class EmployeeComplianceDocumentDraftNotifier
    extends StateNotifier<EmployeeComplianceDocumentDraft?> {
  final EmployeeComplianceDocumentDraft? _initialDraft;

  EmployeeComplianceDocumentDraftNotifier(super.state) : _initialDraft = state;

  void setTitle(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(title: value);
  }

  void setType(EmployeeComplianceDocumentType value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(type: value);
  }

  void setOwner(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(owner: value);
  }

  void setDueDate(DateTime value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(
      dueDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setExpiresAt(DateTime value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(
      expiresAt: DateTime(value.year, value.month, value.day),
    );
  }

  void clearExpiresAt() {
    final draft = state;
    if (draft == null) return;
    state = EmployeeComplianceDocumentDraft(
      employeeId: draft.employeeId,
      employeeName: draft.employeeName,
      asOfDate: draft.asOfDate,
      title: draft.title,
      type: draft.type,
      owner: draft.owner,
      dueDate: draft.dueDate,
      expiresAt: null,
      notes: draft.notes,
    );
  }

  void setNotes(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(notes: value);
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
