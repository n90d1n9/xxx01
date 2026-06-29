import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_document_lifecycle_audit_models.dart';
import '../../models/employee_document_request_coverage_models.dart';
import '../../models/employee_document_request_models.dart';
import '../../models/employee_document_vault_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_document_lifecycle_audit_provider.dart';
import '../../states/employee_document_request_provider.dart';
import '../../states/employee_document_vault_provider.dart';
import 'employee_document_request_form.dart';
import 'employee_document_request_tiles.dart';

/// Center panel for requesting, issuing, and fulfilling employee documents.
class EmployeeDocumentRequestCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeDocumentRequestCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeDocumentRequestCenterPanel> createState() =>
      _EmployeeDocumentRequestCenterPanelState();
}

class _EmployeeDocumentRequestCenterPanelState
    extends ConsumerState<EmployeeDocumentRequestCenterPanel> {
  final _titleController = TextEditingController();
  final _requestedByController = TextEditingController();
  final _ownerController = TextEditingController();
  final _purposeController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _requestedByController.dispose();
    _ownerController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(
      employeeDocumentRequestProfileProvider(employeeId),
    );
    final draft = ref.watch(employeeDocumentRequestDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_requestedByController, draft.requestedBy);
    _sync(_ownerController, draft.owner);
    _sync(_purposeController, draft.purpose);

    final requests = [...profile.requests]..sort((a, b) {
      final overdueCompare = _overdueRank(
        a,
        profile.asOfDate,
      ).compareTo(_overdueRank(b, profile.asOfDate));
      if (overdueCompare != 0) return overdueCompare;
      final statusCompare = _statusRank(
        a.status,
      ).compareTo(_statusRank(b.status));
      if (statusCompare != 0) return statusCompare;
      return a.dueDate.compareTo(b.dueDate);
    });

    return HrisSectionPanel(
      icon: Icons.description_outlined,
      title: 'Document request center',
      subtitle: profile.nextAction,
      children: [
        EmployeeDocumentRequestSummaryStrip(profile: profile),
        EmployeeDocumentRequestForm(
          draft: draft,
          titleController: _titleController,
          requestedByController: _requestedByController,
          ownerController: _ownerController,
          purposeController: _purposeController,
          onTypeChanged:
              ref
                  .read(
                    employeeDocumentRequestDraftProvider(employeeId).notifier,
                  )
                  .setType,
          onTitleChanged:
              ref
                  .read(
                    employeeDocumentRequestDraftProvider(employeeId).notifier,
                  )
                  .setTitle,
          onRequestedByChanged:
              ref
                  .read(
                    employeeDocumentRequestDraftProvider(employeeId).notifier,
                  )
                  .setRequestedBy,
          onOwnerChanged:
              ref
                  .read(
                    employeeDocumentRequestDraftProvider(employeeId).notifier,
                  )
                  .setOwner,
          onPurposeChanged:
              ref
                  .read(
                    employeeDocumentRequestDraftProvider(employeeId).notifier,
                  )
                  .setPurpose,
          onDeliveryChanged:
              ref
                  .read(
                    employeeDocumentRequestDraftProvider(employeeId).notifier,
                  )
                  .setDeliveryMethod,
          onAcknowledgementChanged:
              ref
                  .read(
                    employeeDocumentRequestDraftProvider(employeeId).notifier,
                  )
                  .setRequiresAcknowledgement,
          onSelectDueDate: () => _selectDueDate(draft),
          onSubmit: () => _submitDraft(draft),
        ),
        if (requests.isEmpty)
          const HrisListSurface(child: Text('No document requests submitted.'))
        else
          ...requests.map(
            (request) => EmployeeDocumentRequestTile(
              request: request,
              asOfDate: profile.asOfDate,
              onReview: () => _markReviewing(request),
              onIssue: () => _issueRequest(request),
              onAcknowledge: () => _acknowledgeRequest(request),
              onReject: () => _rejectRequest(request),
            ),
          ),
      ],
    );
  }

  Future<void> _selectDueDate(EmployeeDocumentRequestDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(employeeDocumentRequestDraftProvider(draft.employeeId).notifier)
        .setDueDate(picked);
  }

  void _submitDraft(EmployeeDocumentRequestDraft draft) {
    try {
      final request = ref
          .read(
            employeeDocumentRequestProfileProvider(draft.employeeId).notifier,
          )
          .submitDraft(draft);
      ref
          .read(employeeDocumentRequestDraftProvider(draft.employeeId).notifier)
          .reset();
      _recordRequestAudit(
        request,
        EmployeeDocumentLifecycleAuditEventType.requestCreated,
      );
      _showMessage('${request.id} submitted for ${request.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _markReviewing(EmployeeDocumentRequest request) {
    ref
        .read(
          employeeDocumentRequestProfileProvider(request.employeeId).notifier,
        )
        .markReviewing(request.id);
    final updated = _requestById(request.employeeId, request.id);
    if (updated == null) return;
    _recordRequestAudit(
      updated,
      EmployeeDocumentLifecycleAuditEventType.requestReviewing,
    );
    _showMessage('${updated.id} moved to review');
  }

  void _issueRequest(EmployeeDocumentRequest request) {
    try {
      ref
          .read(
            employeeDocumentRequestProfileProvider(request.employeeId).notifier,
          )
          .issueRequest(request.id);
      final updated = _requestById(request.employeeId, request.id);
      if (updated == null) return;
      _recordRequestAudit(
        updated,
        EmployeeDocumentLifecycleAuditEventType.requestIssued,
      );
      final fulfilled = _fulfillLinkedVaultRequest(updated);
      if (fulfilled != null) {
        _recordVaultAudit(
          fulfilled,
          EmployeeDocumentLifecycleAuditEventType.vaultFulfilled,
        );
      }
      _showMessage(
        fulfilled == null
            ? '${updated.id} issued'
            : '${fulfilled.title} fulfilled in document vault',
      );
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _acknowledgeRequest(EmployeeDocumentRequest request) {
    try {
      ref
          .read(
            employeeDocumentRequestProfileProvider(request.employeeId).notifier,
          )
          .acknowledgeRequest(request.id);
      final updated = _requestById(request.employeeId, request.id);
      if (updated == null) return;
      _recordRequestAudit(
        updated,
        EmployeeDocumentLifecycleAuditEventType.requestAcknowledged,
      );
      final fulfilled = _fulfillLinkedVaultRequest(updated);
      if (fulfilled != null) {
        _recordVaultAudit(
          fulfilled,
          EmployeeDocumentLifecycleAuditEventType.vaultFulfilled,
        );
      }
      _showMessage(
        fulfilled == null
            ? '${updated.id} acknowledged'
            : '${fulfilled.title} verified in document vault',
      );
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _rejectRequest(EmployeeDocumentRequest request) {
    ref
        .read(
          employeeDocumentRequestProfileProvider(request.employeeId).notifier,
        )
        .rejectRequest(request.id);
    final updated = _requestById(request.employeeId, request.id);
    if (updated == null) return;
    _recordRequestAudit(
      updated,
      EmployeeDocumentLifecycleAuditEventType.requestRejected,
    );
    _showMessage('${updated.id} rejected');
  }

  EmployeeDocumentRequest? _requestById(String employeeId, String requestId) {
    final profile = ref.read(
      employeeDocumentRequestProfileProvider(employeeId),
    );
    if (profile == null) return null;
    for (final request in profile.requests) {
      if (request.id == requestId) return request;
    }
    return null;
  }

  EmployeeDocumentVaultRecord? _fulfillLinkedVaultRequest(
    EmployeeDocumentRequest request,
  ) {
    if (!EmployeeDocumentCoverageRequestFactory.isCoverageRequest(request)) {
      return null;
    }
    return ref
        .read(employeeDocumentVaultProfileProvider(request.employeeId).notifier)
        .fulfillCoverageRequest(request);
  }

  void _recordRequestAudit(
    EmployeeDocumentRequest request,
    EmployeeDocumentLifecycleAuditEventType type,
  ) {
    ref
        .read(
          employeeDocumentLifecycleAuditProvider(request.employeeId).notifier,
        )
        .recordRequest(request: request, type: type);
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

  int _overdueRank(EmployeeDocumentRequest request, DateTime asOfDate) {
    return request.isOverdue(asOfDate) ? 0 : 1;
  }

  int _statusRank(EmployeeDocumentRequestStatus status) {
    return switch (status) {
      EmployeeDocumentRequestStatus.requested => 0,
      EmployeeDocumentRequestStatus.reviewing => 1,
      EmployeeDocumentRequestStatus.issued => 2,
      EmployeeDocumentRequestStatus.acknowledged => 3,
      EmployeeDocumentRequestStatus.rejected => 4,
    };
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
