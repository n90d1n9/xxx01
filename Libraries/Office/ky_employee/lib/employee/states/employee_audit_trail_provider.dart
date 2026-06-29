import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_audit_trail_seed_data.dart';
import '../models/employee_audit_trail_models.dart';
import '../models/employee_directory_models.dart';
import 'employee_directory_provider.dart';

final employeeAuditTrailProfileProvider = StateNotifierProvider.family<
  EmployeeAuditTrailProfileNotifier,
  EmployeeAuditTrailProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeAuditTrailProfileNotifier(null);
  }

  return EmployeeAuditTrailProfileNotifier(
    buildEmployeeAuditTrailProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeAuditTrailDraftProvider = StateNotifierProvider.family<
  EmployeeAuditTrailDraftNotifier,
  EmployeeAuditTrailDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeAuditTrailDraftNotifier(null);
  }

  return EmployeeAuditTrailDraftNotifier(
    buildEmployeeAuditTrailDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeAuditTrailProfileNotifier
    extends StateNotifier<EmployeeAuditTrailProfile?> {
  EmployeeAuditTrailProfileNotifier(super.state);

  EmployeeAuditTrailEntry addDraft(EmployeeAuditTrailDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee audit trail profile is unavailable');
    }
    if (!draft.isReadyToAdd) {
      throw StateError(draft.validationErrors.first);
    }

    final entry = draft.toEntry(id: _nextEntryId(profile));
    state = profile.copyWith(entries: [entry, ...profile.entries]);
    return entry;
  }

  void markReviewed(String entryId) {
    _updateEntry(entryId, (entry) {
      if (!entry.canReview) return entry;
      return entry.copyWith(
        reviewStatus: EmployeeAuditTrailReviewStatus.reviewed,
      );
    });
  }

  void escalate(String entryId) {
    _updateEntry(entryId, (entry) {
      if (!entry.canEscalate) return entry;
      return entry.copyWith(
        severity: EmployeeAuditTrailSeverity.critical,
        reviewStatus: EmployeeAuditTrailReviewStatus.escalated,
        detail: '${entry.detail} Escalated for audit review.',
      );
    });
  }

  void archive(String entryId) {
    _updateEntry(entryId, (entry) {
      if (!entry.canArchive) return entry;
      return entry.copyWith(
        reviewStatus: EmployeeAuditTrailReviewStatus.archived,
      );
    });
  }

  void _updateEntry(
    String entryId,
    EmployeeAuditTrailEntry Function(EmployeeAuditTrailEntry entry) update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      entries:
          profile.entries.map((entry) {
            if (entry.id != entryId) return entry;
            return update(entry);
          }).toList(),
    );
  }

  String _nextEntryId(EmployeeAuditTrailProfile profile) {
    var index = profile.entries.length + 1;
    while (true) {
      final id =
          'EAT-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.entries.any((entry) => entry.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeAuditTrailDraftNotifier
    extends StateNotifier<EmployeeAuditTrailDraft?> {
  final EmployeeAuditTrailDraft? _initialDraft;

  EmployeeAuditTrailDraftNotifier(super.state) : _initialDraft = state;

  void setSource(EmployeeAuditTrailSource value) {
    state = state?.copyWith(source: value);
  }

  void setActionType(EmployeeAuditTrailActionType value) {
    state = state?.copyWith(actionType: value);
  }

  void setSeverity(EmployeeAuditTrailSeverity value) {
    state = state?.copyWith(severity: value);
  }

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setDetail(String value) {
    state = state?.copyWith(detail: value);
  }

  void setActor(String value) {
    state = state?.copyWith(actor: value);
  }

  void setContainsSensitiveData(bool value) {
    state = state?.copyWith(containsSensitiveData: value);
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
