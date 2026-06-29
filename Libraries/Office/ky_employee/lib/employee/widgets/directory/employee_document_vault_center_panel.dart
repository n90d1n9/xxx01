import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../data/employee_management_seed_data.dart';
import '../../models/employee_directory_models.dart';
import '../../models/employee_document_lifecycle_audit_models.dart';
import '../../models/employee_document_vault_coverage_models.dart';
import '../../models/employee_document_vault_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_document_lifecycle_audit_provider.dart';
import '../../states/employee_document_request_provider.dart';
import '../../states/employee_document_vault_coverage_provider.dart';
import '../../states/employee_document_vault_provider.dart';
import 'employee_document_vault_coverage_panel.dart';
import 'employee_document_vault_form.dart';
import 'employee_document_vault_tiles.dart';

/// Center panel for managing an employee's HR document vault.
class EmployeeDocumentVaultCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeDocumentVaultCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeDocumentVaultCenterPanel> createState() =>
      _EmployeeDocumentVaultCenterPanelState();
}

class _EmployeeDocumentVaultCenterPanelState
    extends ConsumerState<EmployeeDocumentVaultCenterPanel> {
  final _titleController = TextEditingController();
  final _ownerController = TextEditingController();
  final _summaryController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeDocumentVaultProfileProvider(employeeId));
    final draft = ref.watch(employeeDocumentVaultDraftProvider(employeeId));
    final coverage = ref.watch(
      employeeDocumentVaultCoverageProvider(employeeId),
    );
    final requests = ref.watch(
      employeeDocumentRequestProfileProvider(employeeId),
    );

    if (profile == null ||
        draft == null ||
        coverage == null ||
        requests == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_ownerController, draft.owner);
    _sync(_summaryController, draft.summary);

    final records = [...profile.records]..sort((a, b) {
      final attentionCompare = _attentionRank(
        a,
        profile.asOfDate,
      ).compareTo(_attentionRank(b, profile.asOfDate));
      if (attentionCompare != 0) return attentionCompare;
      final statusCompare = _statusRank(
        a.status,
      ).compareTo(_statusRank(b.status));
      if (statusCompare != 0) return statusCompare;
      return _expiryRank(a).compareTo(_expiryRank(b));
    });

    return HrisSectionPanel(
      icon: Icons.folder_special_outlined,
      title: 'Document vault',
      subtitle: profile.nextAction,
      children: [
        EmployeeDocumentVaultSummaryStrip(profile: profile),
        EmployeeDocumentVaultCoveragePanel(
          profile: coverage,
          openCoverageRequestIds:
              requests.requests
                  .where(
                    (request) =>
                        request.correlationId.isNotEmpty && !request.isClosed,
                  )
                  .map((request) => request.correlationId)
                  .toSet(),
          onCreateRequest: _createCoverageRequest,
        ),
        EmployeeDocumentVaultForm(
          draft: draft,
          titleController: _titleController,
          ownerController: _ownerController,
          summaryController: _summaryController,
          onCategoryChanged:
              ref
                  .read(employeeDocumentVaultDraftProvider(employeeId).notifier)
                  .setCategory,
          onAccessChanged:
              ref
                  .read(employeeDocumentVaultDraftProvider(employeeId).notifier)
                  .setAccess,
          onTitleChanged:
              ref
                  .read(employeeDocumentVaultDraftProvider(employeeId).notifier)
                  .setTitle,
          onOwnerChanged:
              ref
                  .read(employeeDocumentVaultDraftProvider(employeeId).notifier)
                  .setOwner,
          onSummaryChanged:
              ref
                  .read(employeeDocumentVaultDraftProvider(employeeId).notifier)
                  .setSummary,
          onSelectExpiryDate: () => _selectExpiryDate(draft),
          onClearExpiryDate:
              ref
                  .read(employeeDocumentVaultDraftProvider(employeeId).notifier)
                  .clearExpiresAt,
          onSubmit: () => _submitDraft(draft),
        ),
        if (records.isEmpty)
          const HrisListSurface(child: Text('No documents in the vault yet.'))
        else
          ...records.map(
            (record) => EmployeeDocumentVaultRecordTile(
              record: record,
              asOfDate: profile.asOfDate,
              onVerify: () => _verify(record),
              onRequestUpload: () => _requestUpload(record),
              onReject: () => _reject(record),
              onArchive: () => _archive(record),
            ),
          ),
      ],
    );
  }

  Future<void> _selectExpiryDate(EmployeeDocumentVaultDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.expiresAt ?? draft.asOfDate.add(const Duration(days: 365)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    ref
        .read(employeeDocumentVaultDraftProvider(draft.employeeId).notifier)
        .setExpiresAt(picked);
  }

  void _submitDraft(EmployeeDocumentVaultDraft draft) {
    try {
      final record = ref
          .read(employeeDocumentVaultProfileProvider(draft.employeeId).notifier)
          .submitDraft(draft);
      ref
          .read(employeeDocumentVaultDraftProvider(draft.employeeId).notifier)
          .reset();
      _recordVaultAudit(
        record,
        EmployeeDocumentLifecycleAuditEventType.vaultUploaded,
      );
      _showMessage('${record.title} added to ${record.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _createCoverageRequest(EmployeeDocumentVaultCoverageItem item) {
    try {
      final request = ref
          .read(
            employeeDocumentRequestProfileProvider(
              widget.snapshot.member.id,
            ).notifier,
          )
          .submitCoverageRequest(item);
      ref
          .read(
            employeeDocumentLifecycleAuditProvider(request.employeeId).notifier,
          )
          .recordRequest(
            request: request,
            type: EmployeeDocumentLifecycleAuditEventType.requestCreated,
            detail:
                'Created from required document coverage gap: ${item.label}.',
          );
      _showMessage('${request.id} created for ${item.label}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _verify(EmployeeDocumentVaultRecord record) {
    ref
        .read(employeeDocumentVaultProfileProvider(record.employeeId).notifier)
        .verify(record.id);
    final updated = _recordById(record.employeeId, record.id);
    if (updated != null) {
      _recordVaultAudit(
        updated,
        EmployeeDocumentLifecycleAuditEventType.vaultVerified,
      );
    }
    _showMessage('${record.title} verified');
  }

  void _requestUpload(EmployeeDocumentVaultRecord record) {
    ref
        .read(employeeDocumentVaultProfileProvider(record.employeeId).notifier)
        .requestUpload(record.id);
    final updated = _recordById(record.employeeId, record.id);
    if (updated != null) {
      _recordVaultAudit(
        updated,
        EmployeeDocumentLifecycleAuditEventType.vaultUploadRequested,
      );
    }
    _showMessage('${record.title} marked for upload');
  }

  void _reject(EmployeeDocumentVaultRecord record) {
    ref
        .read(employeeDocumentVaultProfileProvider(record.employeeId).notifier)
        .reject(record.id);
    final updated = _recordById(record.employeeId, record.id);
    if (updated != null) {
      _recordVaultAudit(
        updated,
        EmployeeDocumentLifecycleAuditEventType.vaultRejected,
      );
    }
    _showMessage('${record.title} rejected');
  }

  void _archive(EmployeeDocumentVaultRecord record) {
    ref
        .read(employeeDocumentVaultProfileProvider(record.employeeId).notifier)
        .archive(record.id);
    final updated = _recordById(record.employeeId, record.id);
    if (updated != null) {
      _recordVaultAudit(
        updated,
        EmployeeDocumentLifecycleAuditEventType.vaultArchived,
      );
    }
    _showMessage('${record.title} archived');
  }

  EmployeeDocumentVaultRecord? _recordById(String employeeId, String recordId) {
    final profile = ref.read(employeeDocumentVaultProfileProvider(employeeId));
    if (profile == null) return null;
    for (final record in profile.records) {
      if (record.id == recordId) return record;
    }
    return null;
  }

  void _recordVaultAudit(
    EmployeeDocumentVaultRecord record,
    EmployeeDocumentLifecycleAuditEventType type,
  ) {
    ref
        .read(
          employeeDocumentLifecycleAuditProvider(record.employeeId).notifier,
        )
        .recordVault(record: record, type: type);
  }

  int _attentionRank(EmployeeDocumentVaultRecord record, DateTime asOfDate) {
    return record.needsAttention(asOfDate) ? 0 : 1;
  }

  int _statusRank(EmployeeDocumentVaultStatus status) {
    return switch (status) {
      EmployeeDocumentVaultStatus.expired => 0,
      EmployeeDocumentVaultStatus.needsUpload => 1,
      EmployeeDocumentVaultStatus.pendingReview => 2,
      EmployeeDocumentVaultStatus.expiringSoon => 3,
      EmployeeDocumentVaultStatus.rejected => 4,
      EmployeeDocumentVaultStatus.verified => 5,
      EmployeeDocumentVaultStatus.archived => 6,
    };
  }

  int _expiryRank(EmployeeDocumentVaultRecord record) {
    return record.expiresAt?.millisecondsSinceEpoch ?? 9999999999999;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}

@Preview(name: 'Employee document vault center')
Widget employeeDocumentVaultCenterPanelPreview() {
  final snapshot = buildEmployeeManagementSnapshot(
    member: EmployeeDirectoryMember(
      id: '4',
      name: 'David Kim',
      position: 'Product Manager',
      department: 'Product',
      avatarUrl: '',
      email: 'david.kim@company.com',
      phone: '+1 (555) 789-0123',
      joiningDate: DateTime(2023, 2, 14),
      performance: 4.3,
      location: 'Jakarta',
      manager: 'Olivia Wilson',
      status: EmployeeDirectoryStatus.watchlist,
    ),
    asOfDate: DateTime(2026, 6, 1),
  );

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: EmployeeDocumentVaultCenterPanel(snapshot: snapshot),
        ),
      ),
    ),
  );
}
