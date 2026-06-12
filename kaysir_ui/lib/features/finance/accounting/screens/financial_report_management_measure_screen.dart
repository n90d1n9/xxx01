import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../widgets/ui/app_dialog_actions.dart';
import '../accounting_path.dart';
import '../models/financial_report_management_measure.dart';
import '../models/financial_report_management_measure_release_readiness.dart';
import '../states/fin_statement/financial_provider.dart';
import '../states/fin_statement/financial_report_management_measure_reconciliation_provider.dart';
import '../states/fin_statement/financial_report_management_measure_provider.dart';
import '../states/fin_statement/financial_report_management_measure_release_readiness_provider.dart';
import '../states/fin_statement/financial_report_pack_provider.dart';
import '../widgets/financial_report_focus_highlight.dart';
import '../widgets/financial_report_management_measure_audit_trail.dart';
import '../widgets/financial_report_management_measure_components.dart';
import '../widgets/financial_report_management_measure_dialog.dart';
import '../widgets/financial_report_management_measure_release_checklist.dart';

enum FinancialReportManagementMeasureFocus {
  register,
  releaseChecklist,
  approvalCheck,
  reconciliationCheck,
  exportEvidenceCheck,
  auditTrail,
}

FinancialReportManagementMeasureFocus
financialReportManagementMeasureFocusFromQuery(String? value) {
  switch (value) {
    case AccountingPath.managementMeasuresReleaseChecklistFocus:
    case 'checklist':
    case 'releaseChecklist':
      return FinancialReportManagementMeasureFocus.releaseChecklist;
    case AccountingPath.managementMeasuresApprovalFocus:
    case 'approvalCheck':
      return FinancialReportManagementMeasureFocus.approvalCheck;
    case AccountingPath.managementMeasuresReconciliationFocus:
    case 'reconciliationCheck':
      return FinancialReportManagementMeasureFocus.reconciliationCheck;
    case AccountingPath.managementMeasuresExportEvidenceFocus:
    case 'exportEvidence':
    case 'exportEvidenceCheck':
      return FinancialReportManagementMeasureFocus.exportEvidenceCheck;
    case AccountingPath.managementMeasuresAuditFocus:
    case 'auditTrail':
      return FinancialReportManagementMeasureFocus.auditTrail;
    default:
      return FinancialReportManagementMeasureFocus.register;
  }
}

class FinancialReportManagementMeasureScreen extends ConsumerStatefulWidget {
  const FinancialReportManagementMeasureScreen({
    this.initialFocus = FinancialReportManagementMeasureFocus.register,
    super.key,
  });

  final FinancialReportManagementMeasureFocus initialFocus;

  @override
  ConsumerState<FinancialReportManagementMeasureScreen> createState() =>
      _FinancialReportManagementMeasureScreenState();
}

class _FinancialReportManagementMeasureScreenState
    extends ConsumerState<FinancialReportManagementMeasureScreen> {
  final _releaseChecklistKey = GlobalKey();
  final _auditTrailKey = GlobalKey();
  var _didApplyInitialFocus = false;

  @override
  void didUpdateWidget(FinancialReportManagementMeasureScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFocus != widget.initialFocus) {
      _didApplyInitialFocus = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pack = ref.watch(financialReportPackProvider);
    final period = ref.watch(selectedFinancialPeriodProvider);
    final reconciliations = ref.watch(
      currentFinancialReportManagementMeasureReconciliationsProvider,
    );
    final auditEvents = ref.watch(
      currentFinancialReportManagementMeasureAuditProvider,
    );
    final releaseReadiness = ref.watch(
      currentFinancialReportManagementMeasureReleaseReadinessProvider,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final shouldShowAuditTrail =
        auditEvents.isNotEmpty ||
        widget.initialFocus == FinancialReportManagementMeasureFocus.auditTrail;
    final auditEvidenceCandidate = _auditEvidenceCandidate(reconciliations);
    _scheduleInitialFocus();

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Management Measures'),
        actions: [
          IconButton(
            tooltip: 'Add UKTM measure',
            onPressed: () => _openMeasureDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
          ),
          IconButton(
            tooltip: 'Reset UKTM register',
            onPressed: () => _confirmResetRegister(context, ref),
            icon: const Icon(Icons.restore_rounded),
          ),
          IconButton(
            tooltip: 'Report pack',
            onPressed: () => context.go(AccountingPath.reportPack),
            icon: const Icon(Icons.inventory_2_rounded),
          ),
          IconButton(
            tooltip: 'Report release',
            onPressed: () => context.go(AccountingPath.reportRelease),
            icon: const Icon(Icons.verified_user_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _ManagementMeasureHeader(
            periodLabel: period.label,
            frameworkName: pack.frameworkName,
          ),
          const SizedBox(height: 14),
          FinancialReportManagementMeasureSummary(
            reconciliations: reconciliations,
          ),
          const SizedBox(height: 14),
          KeyedSubtree(
            key: _releaseChecklistKey,
            child: FinancialReportFocusHighlight(
              active:
                  widget.initialFocus ==
                  FinancialReportManagementMeasureFocus.releaseChecklist,
              child: FinancialReportManagementMeasureReleaseChecklistStrip(
                summary: releaseReadiness,
                focusedKind: _focusedReleaseCheckKind(widget.initialFocus),
              ),
            ),
          ),
          if (shouldShowAuditTrail) ...[
            const SizedBox(height: 14),
            KeyedSubtree(
              key: _auditTrailKey,
              child: FinancialReportFocusHighlight(
                active:
                    widget.initialFocus ==
                    FinancialReportManagementMeasureFocus.auditTrail,
                child: FinancialReportManagementMeasureAuditTrail(
                  events: auditEvents,
                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                  emptyActionLabel: _auditEvidenceActionLabel(
                    auditEvidenceCandidate,
                  ),
                  onCreateAuditEvidence:
                      auditEvidenceCandidate == null
                          ? null
                          : () => _createAuditEvidence(
                            context,
                            ref,
                            auditEvidenceCandidate,
                          ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          for (final reconciliation in reconciliations) ...[
            FinancialReportManagementMeasureCard(
              reconciliation: reconciliation,
              onEdit:
                  () => _openMeasureDialog(
                    context,
                    ref,
                    initialMeasure: reconciliation.measure,
                  ),
              onRemove:
                  reconciliations.length <= 1
                      ? null
                      : () => _confirmRemoveMeasure(
                        context,
                        ref,
                        reconciliation.measure,
                      ),
              onApprove:
                  () => _updateStatus(
                    ref,
                    reconciliation.measure.id,
                    FinancialReportManagementMeasureApprovalStatus.approved,
                    'Approved for the current report release.',
                  ),
              onMarkInReview:
                  () => _updateStatus(
                    ref,
                    reconciliation.measure.id,
                    FinancialReportManagementMeasureApprovalStatus.inReview,
                    'Submitted for management review.',
                  ),
              onReturn:
                  () => _updateStatus(
                    ref,
                    reconciliation.measure.id,
                    FinancialReportManagementMeasureApprovalStatus.returned,
                    'Returned for reconciliation update.',
                  ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  void _scheduleInitialFocus() {
    if (_didApplyInitialFocus ||
        widget.initialFocus == FinancialReportManagementMeasureFocus.register) {
      return;
    }
    _didApplyInitialFocus = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final targetContext = _focusKey(widget.initialFocus).currentContext;
      if (targetContext == null) {
        return;
      }
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
  }

  GlobalKey _focusKey(FinancialReportManagementMeasureFocus focus) {
    switch (focus) {
      case FinancialReportManagementMeasureFocus.register:
      case FinancialReportManagementMeasureFocus.releaseChecklist:
      case FinancialReportManagementMeasureFocus.approvalCheck:
      case FinancialReportManagementMeasureFocus.reconciliationCheck:
      case FinancialReportManagementMeasureFocus.exportEvidenceCheck:
        return _releaseChecklistKey;
      case FinancialReportManagementMeasureFocus.auditTrail:
        return _auditTrailKey;
    }
  }

  FinancialReportManagementMeasureReleaseCheckKind? _focusedReleaseCheckKind(
    FinancialReportManagementMeasureFocus focus,
  ) {
    switch (focus) {
      case FinancialReportManagementMeasureFocus.approvalCheck:
        return FinancialReportManagementMeasureReleaseCheckKind.approval;
      case FinancialReportManagementMeasureFocus.reconciliationCheck:
        return FinancialReportManagementMeasureReleaseCheckKind.reconciliation;
      case FinancialReportManagementMeasureFocus.exportEvidenceCheck:
        return FinancialReportManagementMeasureReleaseCheckKind.exportEvidence;
      case FinancialReportManagementMeasureFocus.register:
      case FinancialReportManagementMeasureFocus.releaseChecklist:
      case FinancialReportManagementMeasureFocus.auditTrail:
        return null;
    }
  }

  FinancialReportManagementMeasureReconciliation? _auditEvidenceCandidate(
    List<FinancialReportManagementMeasureReconciliation> reconciliations,
  ) {
    if (reconciliations.isEmpty) {
      return null;
    }
    for (final reconciliation in reconciliations) {
      if (!reconciliation.hasOpenVariance) {
        return reconciliation;
      }
    }
    return reconciliations.first;
  }

  String? _auditEvidenceActionLabel(
    FinancialReportManagementMeasureReconciliation? reconciliation,
  ) {
    if (reconciliation == null) {
      return null;
    }
    return reconciliation.hasOpenVariance
        ? 'Submit UKTM Review'
        : 'Approve UKTM Evidence';
  }

  void _createAuditEvidence(
    BuildContext context,
    WidgetRef ref,
    FinancialReportManagementMeasureReconciliation reconciliation,
  ) {
    final status =
        reconciliation.hasOpenVariance
            ? FinancialReportManagementMeasureApprovalStatus.inReview
            : FinancialReportManagementMeasureApprovalStatus.approved;
    final note =
        status == FinancialReportManagementMeasureApprovalStatus.approved
            ? 'Approved from release evidence manifest to create UKTM audit evidence.'
            : 'Submitted from release evidence manifest to create UKTM audit evidence.';
    _updateStatus(ref, reconciliation.measure.id, status, note);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${reconciliation.measure.label} ${status.label}.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmRemoveMeasure(
    BuildContext context,
    WidgetRef ref,
    FinancialReportManagementMeasure measure,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove UKTM Measure'),
            content: Text(
              'Remove ${measure.label}? This will also remove its adjustment evidence from the current period register.',
            ),
            actions: [
              AppDialogActions(
                cancelLabel: 'Cancel',
                confirmLabel: 'Remove',
                cancelIcon: Icons.close_rounded,
                confirmIcon: Icons.delete_outline_rounded,
                onCancel: () => Navigator.of(context).pop(false),
                onConfirm: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    ref
        .read(financialReportManagementMeasuresProvider.notifier)
        .remove(measure.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${measure.label} removed.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmResetRegister(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset UKTM Register'),
            content: const Text(
              'Reset this period to the default operating performance measure?',
            ),
            actions: [
              AppDialogActions(
                cancelLabel: 'Cancel',
                confirmLabel: 'Reset',
                cancelIcon: Icons.close_rounded,
                confirmIcon: Icons.restore_rounded,
                onCancel: () => Navigator.of(context).pop(false),
                onConfirm: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    ref
        .read(financialReportManagementMeasuresProvider.notifier)
        .resetDemoRegister();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('UKTM register reset.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openMeasureDialog(
    BuildContext context,
    WidgetRef ref, {
    FinancialReportManagementMeasure? initialMeasure,
  }) async {
    final measure = await showDialog<FinancialReportManagementMeasure>(
      context: context,
      builder:
          (context) => FinancialReportManagementMeasureDialog(
            initialMeasure: initialMeasure,
          ),
    );
    if (measure == null || !context.mounted) {
      return;
    }

    ref
        .read(financialReportManagementMeasuresProvider.notifier)
        .upsert(measure);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${measure.label} saved.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateStatus(
    WidgetRef ref,
    String measureId,
    FinancialReportManagementMeasureApprovalStatus status,
    String note,
  ) {
    ref
        .read(financialReportManagementMeasuresProvider.notifier)
        .updateStatus(id: measureId, status: status, note: note);
  }
}

class _ManagementMeasureHeader extends StatelessWidget {
  const _ManagementMeasureHeader({
    required this.periodLabel,
    required this.frameworkName,
  });

  final String periodLabel;
  final String frameworkName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.speed_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    periodLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'UKTM Register',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    frameworkName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
