import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_console_audit_access_models.dart';
import '../../models/employee_payroll_run_console_audit_decision_models.dart';
import '../../models/employee_payroll_run_console_audit_decision_receipt_models.dart';
import '../../models/employee_payroll_run_console_audit_handoff_models.dart';
import '../../models/employee_payroll_run_console_audit_models.dart';
import '../../models/employee_payroll_run_console_audit_package_models.dart';
import '../../models/employee_payroll_run_console_command_models.dart';
import 'employee_payroll_run_console_audit_decision_form.dart';
import 'employee_payroll_run_console_audit_decision_receipt.dart';
import 'employee_payroll_run_console_audit_handoff_form.dart';
import 'employee_payroll_run_console_audit_handoff_tiles.dart';

/// Governed handoff form for payroll console audit evidence packages.
class EmployeePayrollRunConsoleAuditHandoffPanel extends StatefulWidget {
  final EmployeePayrollRunConsoleAuditEvidencePackage package;
  final EmployeePayrollRunConsoleAuditRole? role;
  final ValueChanged<EmployeePayrollRunConsoleAuditHandoffReview>?
  onReviewChanged;

  const EmployeePayrollRunConsoleAuditHandoffPanel({
    super.key,
    required this.package,
    this.role,
    this.onReviewChanged,
  });

  @override
  State<EmployeePayrollRunConsoleAuditHandoffPanel> createState() =>
      _EmployeePayrollRunConsoleAuditHandoffPanelState();
}

/// Coordinates local payroll audit handoff draft input and history actions.
class _EmployeePayrollRunConsoleAuditHandoffPanelState
    extends State<EmployeePayrollRunConsoleAuditHandoffPanel> {
  late EmployeePayrollRunConsoleAuditHandoffDraft _draft;
  late final TextEditingController _reviewerController;
  late final TextEditingController _approverController;
  late final TextEditingController _noteController;
  late final TextEditingController _decisionNoteController;
  List<EmployeePayrollRunConsoleAuditHandoffRecord> _handoffs = const [];
  EmployeePayrollRunConsoleAuditDecisionDraft _decisionDraft =
      const EmployeePayrollRunConsoleAuditDecisionDraft();

  @override
  void initState() {
    super.initState();
    _draft = _initialDraft(widget.package);
    _reviewerController = TextEditingController(text: _draft.reviewer);
    _approverController = TextEditingController(text: _draft.approver);
    _noteController = TextEditingController(text: _draft.note);
    _decisionNoteController = TextEditingController();
    _scheduleReviewChanged();
  }

  @override
  void didUpdateWidget(EmployeePayrollRunConsoleAuditHandoffPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.package.packageReference != widget.package.packageReference) {
      _draft = _initialDraft(widget.package);
      _handoffs = const [];
      _decisionDraft = const EmployeePayrollRunConsoleAuditDecisionDraft();
      _syncControllers();
      _scheduleReviewChanged();
    } else if (oldWidget.onReviewChanged != widget.onReviewChanged) {
      _scheduleReviewChanged();
    }
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _approverController.dispose();
    _noteController.dispose();
    _decisionNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = _review;
    final latest = review.latestHandoff;
    final accessReview =
        widget.role == null
            ? null
            : EmployeePayrollRunConsoleAuditAccessReview(
              role: widget.role!,
              handoffReview: review,
            );
    final submitPermission = accessReview?.submitHandoffPermission;
    final approvePermission = accessReview?.approveHandoffPermission;
    final returnPermission = accessReview?.returnHandoffPermission;
    final canSubmit = review.canSubmit && (submitPermission?.allowed ?? true);
    final showDecisionForm =
        latest?.canApprove == true &&
        (widget.role == null ||
            widget.role == EmployeePayrollRunConsoleAuditRole.payrollApprover);
    final canApproveDecision =
        showDecisionForm &&
        (approvePermission?.allowed ?? true) &&
        _decisionDraft.canApprove;
    final canReturnDecision =
        showDecisionForm &&
        (returnPermission?.allowed ?? true) &&
        _decisionDraft.canReturn;
    final status =
        latest?.status ??
        (review.canSubmit
            ? EmployeePayrollRunConsoleAuditHandoffStatus.readyForReview
            : EmployeePayrollRunConsoleAuditHandoffStatus.draft);
    final statusLabel = latest?.statusLabel ?? review.statusLabel;
    final statusColor = _statusColor(status);

    return Column(
      key: const ValueKey('employee-payroll-audit-handoff-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'Payroll close handoff',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            HrisStatusPill(label: statusLabel, color: statusColor),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _handoffDescription(latest, submitPermission),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
        const SizedBox(height: 10),
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Package',
              value: widget.package.readinessLabel,
            ),
            HrisMetricStripItem(
              label: 'Commands',
              value:
                  '${widget.package.evidencedCommandCount}/'
                  '${widget.package.totalCommandCount}',
            ),
            HrisMetricStripItem(
              label: 'Review',
              value: '${review.reviewEventCount}',
            ),
            HrisMetricStripItem(
              label: 'Handoffs',
              value: '${_handoffs.length}',
            ),
          ],
        ),
        if (latest != null) ...[
          const SizedBox(height: 12),
          EmployeePayrollRunConsoleAuditHandoffRecordTile(
            key: ValueKey('employee-payroll-audit-handoff-${latest.id}'),
            record: latest,
            showActions: false,
          ),
          if (latest.isDecided) ...[
            const SizedBox(height: 12),
            EmployeePayrollRunConsoleAuditDecisionReceiptCard(
              receipt: EmployeePayrollRunConsoleAuditDecisionReceipt(
                record: latest,
              ),
            ),
          ],
          if (showDecisionForm) ...[
            const SizedBox(height: 12),
            EmployeePayrollRunConsoleAuditDecisionForm(
              noteController: _decisionNoteController,
              draft: _decisionDraft,
              onDraftChanged: (draft) => setState(() => _decisionDraft = draft),
              onApprove: canApproveDecision ? _approveLatestHandoff : null,
              onReturn: canReturnDecision ? _returnLatestHandoff : null,
            ),
          ],
        ],
        const SizedBox(height: 12),
        EmployeePayrollRunConsoleAuditHandoffForm(
          review: review,
          reviewerController: _reviewerController,
          approverController: _approverController,
          noteController: _noteController,
          visibleError: _visibleHandoffError(review, submitPermission),
          onReviewerChanged: (value) {
            setState(() => _draft = _draft.copyWith(reviewer: value));
            _scheduleReviewChanged();
          },
          onApproverChanged: (value) {
            setState(() => _draft = _draft.copyWith(approver: value));
            _scheduleReviewChanged();
          },
          onNoteChanged: (value) {
            setState(() => _draft = _draft.copyWith(note: value));
            _scheduleReviewChanged();
          },
          onSelectDueDate: _selectDueDate,
          onSubmit: canSubmit ? _submitHandoff : null,
          onClear: _draft.hasInput ? _clearDraft : null,
        ),
      ],
    );
  }

  EmployeePayrollRunConsoleAuditHandoffReview get _review {
    return EmployeePayrollRunConsoleAuditHandoffReview.fromState(
      package: widget.package,
      draft: _draft,
      handoffs: _handoffs,
    );
  }

  Future<void> _selectDueDate() async {
    final initialDate = _draft.dueDate ?? _defaultDueDate(widget.package);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate.subtract(const Duration(days: 365)),
      lastDate: initialDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    setState(() => _draft = _draft.copyWith(dueDate: picked));
    _scheduleReviewChanged();
  }

  void _submitHandoff() {
    final review = _review;
    if (!review.canSubmit) return;

    final record = review.toRecord(
      id: _nextHandoffId(),
      submittedAt: DateTime.now(),
    );

    setState(() {
      _handoffs = [record, ..._handoffs];
      _draft = _initialDraft(widget.package);
      _decisionDraft = const EmployeePayrollRunConsoleAuditDecisionDraft();
    });
    _syncControllers();
    _scheduleReviewChanged();
  }

  void _approveLatestHandoff() {
    if (_handoffs.isEmpty) return;
    setState(() {
      _handoffs = [
        _handoffs.first.approve(
          approvedAt: DateTime.now(),
          attestations: _decisionDraft.attestations,
          note: _decisionDraft.decisionNote,
        ),
        ..._handoffs.skip(1),
      ];
      _decisionDraft = const EmployeePayrollRunConsoleAuditDecisionDraft();
    });
    _syncDecisionController();
    _scheduleReviewChanged();
  }

  void _returnLatestHandoff() {
    if (_handoffs.isEmpty) return;
    final reason =
        _decisionDraft.decisionNote.isEmpty
            ? 'Approver requested evidence refresh before close archive.'
            : _decisionDraft.decisionNote;
    setState(() {
      _handoffs = [
        _handoffs.first.returnForRevision(
          returnedAt: DateTime.now(),
          reason: reason,
        ),
        ..._handoffs.skip(1),
      ];
      _decisionDraft = const EmployeePayrollRunConsoleAuditDecisionDraft();
    });
    _syncDecisionController();
    _scheduleReviewChanged();
  }

  void _clearDraft() {
    setState(() => _draft = _initialDraft(widget.package));
    _syncControllers();
    _scheduleReviewChanged();
  }

  String _nextHandoffId() {
    final count = (_handoffs.length + 1).toString().padLeft(2, '0');
    return 'PAH-${widget.package.packageReference}-$count';
  }

  void _syncControllers() {
    _syncController(_reviewerController, _draft.reviewer);
    _syncController(_approverController, _draft.approver);
    _syncController(_noteController, _draft.note);
    _syncDecisionController();
  }

  void _syncDecisionController() {
    _syncController(_decisionNoteController, _decisionDraft.note);
  }

  void _scheduleReviewChanged() {
    final onReviewChanged = widget.onReviewChanged;
    if (onReviewChanged == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      onReviewChanged(_review);
    });
  }
}

@Preview(name: 'Employee payroll audit handoff panel')
Widget employeePayrollRunConsoleAuditHandoffPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeePayrollRunConsoleAuditHandoffPanel(
          package: EmployeePayrollRunConsoleAuditEvidencePackage(
            report: EmployeePayrollRunConsoleAuditEvidenceReport(
              summary: EmployeePayrollRunConsoleAuditSummary(
                events: [
                  _previewEvent(
                    id: 'payroll-console-audit-1',
                    type: EmployeePayrollRunConsoleCommandType.prepareExport,
                    completedCount: 3,
                    skippedCount: 0,
                  ),
                  _previewEvent(
                    id: 'payroll-console-audit-2',
                    type: EmployeePayrollRunConsoleCommandType.settlePayment,
                    completedCount: 3,
                    skippedCount: 0,
                  ),
                  _previewEvent(
                    id: 'payroll-console-audit-3',
                    type: EmployeePayrollRunConsoleCommandType.publishPayslip,
                    completedCount: 3,
                    skippedCount: 0,
                  ),
                  _previewEvent(
                    id: 'payroll-console-audit-4',
                    type: EmployeePayrollRunConsoleCommandType.closePeriod,
                    completedCount: 1,
                    skippedCount: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

EmployeePayrollRunConsoleAuditHandoffDraft _initialDraft(
  EmployeePayrollRunConsoleAuditEvidencePackage package,
) {
  return EmployeePayrollRunConsoleAuditHandoffDraft(
    dueDate: _defaultDueDate(package),
  );
}

DateTime _defaultDueDate(
  EmployeePayrollRunConsoleAuditEvidencePackage package,
) {
  final closedAt = package.closedAt;
  if (closedAt != null) return closedAt.add(const Duration(days: 1));
  return DateTime.now().add(const Duration(days: 1));
}

String? _visibleError(EmployeePayrollRunConsoleAuditHandoffReview review) {
  for (final error in review.errors) {
    if (_isPackageError(error)) return error;
  }
  if (!review.draft.hasInput || review.errors.isEmpty) return null;
  return review.errors.first;
}

String? _visibleHandoffError(
  EmployeePayrollRunConsoleAuditHandoffReview review,
  EmployeePayrollRunConsoleAuditPermission? submitPermission,
) {
  final error = _visibleError(review);
  if (error != null) return error;
  if (submitPermission == null ||
      submitPermission.allowed ||
      !review.canSubmit) {
    return null;
  }
  return submitPermission.reason;
}

String _handoffDescription(
  EmployeePayrollRunConsoleAuditHandoffRecord? latest,
  EmployeePayrollRunConsoleAuditPermission? submitPermission,
) {
  if (latest != null) {
    return 'Latest handoff captured for ${latest.approver}.';
  }
  if (submitPermission != null &&
      !submitPermission.allowed &&
      _isRoleBlock(submitPermission.reason)) {
    return submitPermission.reason;
  }
  return 'Submit a ready evidence package to payroll close review.';
}

bool _isRoleBlock(String reason) {
  return reason.startsWith('Switch') || reason.startsWith('Auditor');
}

bool _isPackageError(String error) {
  return error.startsWith('Capture') ||
      error.startsWith('Resolve') ||
      error.startsWith('Complete');
}

Color _statusColor(EmployeePayrollRunConsoleAuditHandoffStatus status) {
  return switch (status) {
    EmployeePayrollRunConsoleAuditHandoffStatus.approved => const Color(
      0xFF15803D,
    ),
    EmployeePayrollRunConsoleAuditHandoffStatus.returned => const Color(
      0xFFB91C1C,
    ),
    EmployeePayrollRunConsoleAuditHandoffStatus.submitted ||
    EmployeePayrollRunConsoleAuditHandoffStatus
        .readyForReview => HrisColors.primary,
    EmployeePayrollRunConsoleAuditHandoffStatus.draft => HrisColors.muted,
  };
}

void _syncController(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.text = value;
}

EmployeePayrollRunConsoleAuditEvent _previewEvent({
  required String id,
  required EmployeePayrollRunConsoleCommandType type,
  required int completedCount,
  required int skippedCount,
}) {
  return EmployeePayrollRunConsoleAuditEvent(
    id: id,
    runReference: 'RUN-202605-001',
    commandType: type,
    scopeLabel: 'All 5 run employees',
    operatorName: 'Payroll Lead',
    occurredAt: DateTime(2026, 5, 30, 9, 30),
    targetEmployeeCount: completedCount + skippedCount,
    completedCount: completedCount,
    skippedCount: skippedCount,
    errors: const [],
    message: '${type.label} audit evidence captured.',
  );
}
