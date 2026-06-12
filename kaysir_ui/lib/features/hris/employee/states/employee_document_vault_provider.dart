import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_document_vault_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_document_request_coverage_models.dart';
import '../models/employee_document_request_models.dart';
import '../models/employee_document_vault_models.dart';
import 'employee_directory_provider.dart';

final employeeDocumentVaultProfileProvider = StateNotifierProvider.family<
  EmployeeDocumentVaultProfileNotifier,
  EmployeeDocumentVaultProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeDocumentVaultProfileNotifier(null);
  }

  return EmployeeDocumentVaultProfileNotifier(
    buildEmployeeDocumentVaultProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeDocumentVaultDraftProvider = StateNotifierProvider.family<
  EmployeeDocumentVaultDraftNotifier,
  EmployeeDocumentVaultDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeDocumentVaultDraftNotifier(null);
  }

  return EmployeeDocumentVaultDraftNotifier(
    buildEmployeeDocumentVaultDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeDocumentVaultProfileNotifier
    extends StateNotifier<EmployeeDocumentVaultProfile?> {
  EmployeeDocumentVaultProfileNotifier(super.state);

  EmployeeDocumentVaultRecord submitDraft(EmployeeDocumentVaultDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee document vault profile is unavailable');
    }
    if (!draft.isReadyToAdd) {
      throw StateError(draft.validationErrors.first);
    }

    final record = draft.toRecord(id: _nextRecordId(profile));
    state = profile.copyWith(records: [record, ...profile.records]);
    return record;
  }

  void verify(String recordId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      records:
          profile.records.map((record) {
            if (record.id != recordId || !record.canVerify) return record;
            return record.copyWith(
              status: EmployeeDocumentVaultStatus.verified,
              verifiedAt: profile.asOfDate,
              summary: '${record.summary} Verified by ${record.owner}.',
            );
          }).toList(),
    );
  }

  void reject(String recordId) {
    _updateRecord(recordId, (record) {
      if (!record.canReject) return record;
      return record.copyWith(
        status: EmployeeDocumentVaultStatus.rejected,
        clearVerifiedAt: true,
      );
    });
  }

  void requestUpload(String recordId) {
    _updateRecord(recordId, (record) {
      if (!record.canRequestUpload) return record;
      return record.copyWith(
        status: EmployeeDocumentVaultStatus.needsUpload,
        clearVerifiedAt: true,
      );
    });
  }

  void archive(String recordId) {
    _updateRecord(recordId, (record) {
      if (!record.canArchive) return record;
      return record.copyWith(status: EmployeeDocumentVaultStatus.archived);
    });
  }

  EmployeeDocumentVaultRecord fulfillCoverageRequest(
    EmployeeDocumentRequest request,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee document vault profile is unavailable');
    }

    final category = EmployeeDocumentCoverageRequestFactory.categoryForRequest(
      request,
    );
    if (category == null) {
      throw StateError('Document request is not linked to vault coverage');
    }

    final existing = _activeRecordForCategory(profile, category);
    final fulfilled = EmployeeDocumentCoverageRequestFactory.buildVaultRecord(
      request: request,
      id: existing?.id ?? _nextRecordId(profile),
      asOfDate: profile.asOfDate,
    );

    if (existing == null) {
      state = profile.copyWith(records: [fulfilled, ...profile.records]);
      return fulfilled;
    }

    state = profile.copyWith(
      records:
          profile.records.map((record) {
            if (record.id != existing.id) return record;
            return record.copyWith(
              status: fulfilled.status,
              access: fulfilled.access,
              title: fulfilled.title,
              owner: fulfilled.owner,
              source: fulfilled.source,
              uploadedAt: fulfilled.uploadedAt,
              expiresAt: fulfilled.expiresAt,
              clearExpiresAt: fulfilled.expiresAt == null,
              verifiedAt: fulfilled.verifiedAt,
              clearVerifiedAt: fulfilled.verifiedAt == null,
              summary: fulfilled.summary,
            );
          }).toList(),
    );
    return fulfilled;
  }

  void _updateRecord(
    String recordId,
    EmployeeDocumentVaultRecord Function(EmployeeDocumentVaultRecord record)
    update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      records:
          profile.records.map((record) {
            if (record.id != recordId) return record;
            return update(record);
          }).toList(),
    );
  }

  String _nextRecordId(EmployeeDocumentVaultProfile profile) {
    var index = profile.records.length + 1;
    while (true) {
      final id =
          'EDV-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.records.any((record) => record.id == id)) {
        return id;
      }
      index++;
    }
  }

  EmployeeDocumentVaultRecord? _activeRecordForCategory(
    EmployeeDocumentVaultProfile profile,
    EmployeeDocumentVaultCategory category,
  ) {
    final records =
        profile.records
            .where(
              (record) =>
                  record.category == category &&
                  record.status != EmployeeDocumentVaultStatus.archived,
            )
            .toList()
          ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return records.isEmpty ? null : records.first;
  }
}

class EmployeeDocumentVaultDraftNotifier
    extends StateNotifier<EmployeeDocumentVaultDraft?> {
  final EmployeeDocumentVaultDraft? _initialDraft;

  EmployeeDocumentVaultDraftNotifier(super.state) : _initialDraft = state;

  void setCategory(EmployeeDocumentVaultCategory value) {
    state = state?.copyWith(category: value);
  }

  void setAccess(EmployeeDocumentVaultAccess value) {
    state = state?.copyWith(access: value);
  }

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setExpiresAt(DateTime value) {
    state = state?.copyWith(expiresAt: _dateOnly(value));
  }

  void clearExpiresAt() {
    state = state?.copyWith(clearExpiresAt: true);
  }

  void setSummary(String value) {
    state = state?.copyWith(summary: value);
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

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
