import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_models.dart';
import '../models/employee_document_lifecycle_audit_models.dart';
import '../models/employee_document_request_models.dart';
import '../models/employee_document_vault_models.dart';
import 'employee_directory_provider.dart';

/// Stores the document lifecycle audit stream for one employee.
final employeeDocumentLifecycleAuditProvider = StateNotifierProvider.family<
  EmployeeDocumentLifecycleAuditNotifier,
  EmployeeDocumentLifecycleAuditProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeDocumentLifecycleAuditNotifier(null);
  }

  return EmployeeDocumentLifecycleAuditNotifier(
    EmployeeDocumentLifecycleAuditProfile(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: _dateOnly(asOfDate),
      entries: const [],
    ),
  );
});

/// Mutates local document lifecycle audit entries.
class EmployeeDocumentLifecycleAuditNotifier
    extends StateNotifier<EmployeeDocumentLifecycleAuditProfile?> {
  EmployeeDocumentLifecycleAuditNotifier(super.state);

  EmployeeDocumentLifecycleAuditEntry recordRequest({
    required EmployeeDocumentRequest request,
    required EmployeeDocumentLifecycleAuditEventType type,
    String actor = 'People Operations',
    String detail = '',
  }) {
    return _record(
      type: type,
      subjectId: request.id,
      title: request.title,
      actor: _actor(actor),
      owner: request.owner,
      detail: detail.isEmpty ? _requestDetail(request, type) : detail,
      correlationId: request.correlationId,
    );
  }

  EmployeeDocumentLifecycleAuditEntry recordVault({
    required EmployeeDocumentVaultRecord record,
    required EmployeeDocumentLifecycleAuditEventType type,
    String actor = 'People Operations',
    String detail = '',
  }) {
    return _record(
      type: type,
      subjectId: record.id,
      title: record.title,
      actor: _actor(actor),
      owner: record.owner,
      detail: detail.isEmpty ? _vaultDetail(record, type) : detail,
      correlationId: '',
    );
  }

  EmployeeDocumentLifecycleAuditEntry _record({
    required EmployeeDocumentLifecycleAuditEventType type,
    required String subjectId,
    required String title,
    required String actor,
    required String owner,
    required String detail,
    required String correlationId,
  }) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee document lifecycle audit is unavailable');
    }

    final entry = EmployeeDocumentLifecycleAuditEntry(
      id: _nextEntryId(profile),
      employeeId: profile.employeeId,
      employeeName: profile.employeeName,
      type: type,
      subjectId: subjectId,
      title: title,
      actor: actor,
      owner: owner,
      detail: detail,
      correlationId: correlationId,
      occurredAt: profile.asOfDate,
    );

    state = profile.copyWith(entries: [entry, ...profile.entries]);
    return entry;
  }

  String _nextEntryId(EmployeeDocumentLifecycleAuditProfile profile) {
    var index = profile.entries.length + 1;
    while (true) {
      final id =
          'EDLA-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.entries.any((entry) => entry.id == id)) {
        return id;
      }
      index++;
    }
  }

  String _actor(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'People Operations' : trimmed;
  }
}

String _requestDetail(
  EmployeeDocumentRequest request,
  EmployeeDocumentLifecycleAuditEventType type,
) {
  return switch (type) {
    EmployeeDocumentLifecycleAuditEventType.requestCreated =>
      '${request.type.label} requested via ${request.deliveryMethod.label}.',
    EmployeeDocumentLifecycleAuditEventType.requestReviewing =>
      '${request.id} moved to review by ${request.owner}.',
    EmployeeDocumentLifecycleAuditEventType.requestIssued =>
      '${request.id} issued through ${request.deliveryMethod.label}.',
    EmployeeDocumentLifecycleAuditEventType.requestAcknowledged =>
      '${request.id} acknowledged by ${request.employeeName}.',
    EmployeeDocumentLifecycleAuditEventType.requestRejected =>
      '${request.id} rejected before issue.',
    EmployeeDocumentLifecycleAuditEventType.vaultUploaded ||
    EmployeeDocumentLifecycleAuditEventType.vaultUploadRequested ||
    EmployeeDocumentLifecycleAuditEventType.vaultVerified ||
    EmployeeDocumentLifecycleAuditEventType.vaultRejected ||
    EmployeeDocumentLifecycleAuditEventType.vaultArchived ||
    EmployeeDocumentLifecycleAuditEventType.vaultFulfilled => request.purpose,
  };
}

String _vaultDetail(
  EmployeeDocumentVaultRecord record,
  EmployeeDocumentLifecycleAuditEventType type,
) {
  return switch (type) {
    EmployeeDocumentLifecycleAuditEventType.vaultUploaded =>
      '${record.category.label} uploaded from ${record.source}.',
    EmployeeDocumentLifecycleAuditEventType.vaultUploadRequested =>
      '${record.title} marked for employee upload.',
    EmployeeDocumentLifecycleAuditEventType.vaultVerified =>
      '${record.title} verified for document vault coverage.',
    EmployeeDocumentLifecycleAuditEventType.vaultRejected =>
      '${record.title} rejected during HR review.',
    EmployeeDocumentLifecycleAuditEventType.vaultArchived =>
      '${record.title} archived from active records.',
    EmployeeDocumentLifecycleAuditEventType.vaultFulfilled =>
      '${record.title} fulfilled from ${record.source}.',
    EmployeeDocumentLifecycleAuditEventType.requestCreated ||
    EmployeeDocumentLifecycleAuditEventType.requestReviewing ||
    EmployeeDocumentLifecycleAuditEventType.requestIssued ||
    EmployeeDocumentLifecycleAuditEventType.requestAcknowledged ||
    EmployeeDocumentLifecycleAuditEventType.requestRejected => record.summary,
  };
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
