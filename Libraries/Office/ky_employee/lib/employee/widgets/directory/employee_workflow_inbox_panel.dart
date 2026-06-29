import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../data/employee_management_seed_data.dart';
import '../../models/employee_directory_models.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_workflow_inbox_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_action_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_audit_export_access_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_audit_export_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_models.dart';
import '../../states/employee_action_workflow_provider.dart';
import '../../states/employee_data_correction_provider.dart';
import '../../states/employee_job_assignment_provider.dart';
import '../../states/employee_profile_change_governance_provider.dart';
import '../../states/employee_workflow_inbox_provider.dart';
import '../../states/employee_workflow_inbox_receipt_export_provider.dart';
import '../../states/employee_workflow_inbox_receipt_provider.dart';
import '../../states/employee_workflow_inbox_sla_playbook_action_provider.dart';
import '../../states/employee_workflow_inbox_sla_playbook_audit_delivery_provider.dart';
import '../../states/employee_workflow_inbox_sla_playbook_audit_export_provider.dart';
import '../../states/employee_workflow_inbox_sla_playbook_provider.dart';
import '../../states/employee_workflow_inbox_sla_provider.dart';
import 'employee_workflow_inbox_receipt_export_preview_panel.dart';
import 'employee_workflow_inbox_receipt_tiles.dart';
import 'employee_workflow_inbox_sla_playbook_action_dialog.dart';
import 'employee_workflow_inbox_sla_playbook_action_timeline.dart';
import 'employee_workflow_inbox_sla_playbook_audit_delivery_history.dart';
import 'employee_workflow_inbox_sla_playbook_audit_export_preview_panel.dart';
import 'employee_workflow_inbox_sla_playbook_reason_correction_dialog.dart';
import 'employee_workflow_inbox_sla_playbook_tiles.dart';
import 'employee_workflow_inbox_sla_tiles.dart';
import 'employee_workflow_inbox_tiles.dart';

/// Unified inbox panel for active employee HR workflow items.
class EmployeeWorkflowInboxPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;
  final int maxItems;

  const EmployeeWorkflowInboxPanel({
    super.key,
    required this.snapshot,
    this.maxItems = 6,
  });

  @override
  ConsumerState<EmployeeWorkflowInboxPanel> createState() =>
      _EmployeeWorkflowInboxPanelState();
}

/// Holds the selected review filter for the employee workflow inbox panel.
class _EmployeeWorkflowInboxPanelState
    extends ConsumerState<EmployeeWorkflowInboxPanel> {
  EmployeeWorkflowInboxFilter _selectedFilter = EmployeeWorkflowInboxFilter.all;
  String? _selectedOwner;

  @override
  Widget build(BuildContext context) {
    final inbox = ref.watch(
      employeeWorkflowInboxProvider(widget.snapshot.member.id),
    );
    if (inbox == null) return const SizedBox.shrink();
    final receipts = ref.watch(
      employeeWorkflowInboxReceiptProvider(widget.snapshot.member.id),
    );
    final receiptExport = ref.watch(
      employeeWorkflowInboxReceiptExportProvider(widget.snapshot.member.id),
    );
    final sla = ref.watch(
      employeeWorkflowInboxSlaProvider(widget.snapshot.member.id),
    );
    final playbook = ref.watch(
      employeeWorkflowInboxSlaPlaybookProvider(widget.snapshot.member.id),
    );
    final playbookActions = ref.watch(
      employeeWorkflowInboxSlaPlaybookActionProvider(widget.snapshot.member.id),
    );
    final playbookAuditExport = ref.watch(
      employeeWorkflowInboxSlaPlaybookAuditExportProvider(
        widget.snapshot.member.id,
      ),
    );
    final playbookAuditDeliveries = ref.watch(
      employeeWorkflowInboxSlaPlaybookAuditDeliveryProvider(
        widget.snapshot.member.id,
      ),
    );

    final activeOwner =
        inbox.ownerLoadFor(_selectedOwner) == null ? null : _selectedOwner;
    final filteredItems = inbox.itemsFor(_selectedFilter, owner: activeOwner);
    final visibleItems = filteredItems.take(widget.maxItems).toList();

    return HrisSectionPanel(
      icon: Icons.inbox_outlined,
      title: 'HR workflow inbox',
      subtitle: inbox.nextActionFor(_selectedFilter, owner: activeOwner),
      children: [
        EmployeeWorkflowInboxSummaryStrip(profile: inbox),
        EmployeeWorkflowInboxFilterStrip(
          profile: inbox,
          selected: _selectedFilter,
          onChanged: (filter) => setState(() => _selectedFilter = filter),
        ),
        EmployeeWorkflowInboxOwnerLoadStrip(
          profile: inbox,
          selectedOwner: activeOwner,
          onChanged: (owner) => setState(() => _selectedOwner = owner),
        ),
        if (sla != null && sla.signals.isNotEmpty) ...[
          Text(
            'Inbox SLA health',
            key: const ValueKey('employee-workflow-inbox-sla-heading'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          EmployeeWorkflowInboxSlaSummaryStrip(profile: sla),
          EmployeeWorkflowInboxSlaOwnerLoadBoard(loads: sla.ownerLoads),
          if (playbook != null && playbook.steps.isNotEmpty) ...[
            Text(
              'SLA recovery playbook',
              key: const ValueKey(
                'employee-workflow-inbox-sla-playbook-heading',
              ),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            EmployeeWorkflowInboxSlaPlaybookSummaryStrip(playbook: playbook),
            ...playbook.topSteps
                .take(2)
                .map(
                  (step) => EmployeeWorkflowInboxSlaPlaybookStepTile(
                    step: step,
                    latestReceipt: playbookActions?.latestForStep(step.id),
                    onPrimaryAction: () => _runPlaybookAction(context, step),
                  ),
                ),
            if (playbookActions != null && playbookActions.hasReceipts)
              EmployeeWorkflowInboxSlaPlaybookActionTimeline(
                profile: playbookActions,
                onCorrectReason: _correctPlaybookReason,
              ),
            if (playbookAuditExport != null &&
                playbookAuditExport.profile.hasReceipts)
              EmployeeWorkflowInboxSlaPlaybookAuditExportPreviewPanel(
                preview: playbookAuditExport,
                onDeliveryRecorded: _recordPlaybookAuditDelivery,
              ),
            if (playbookAuditDeliveries != null &&
                playbookAuditDeliveries.deliveries.isNotEmpty)
              EmployeeWorkflowInboxSlaPlaybookAuditDeliveryHistory(
                profile: playbookAuditDeliveries,
              ),
          ],
          ...sla.topSignals
              .take(2)
              .map(
                (signal) => EmployeeWorkflowInboxSlaSignalTile(signal: signal),
              ),
        ],
        Text(
          'Showing ${_selectedFilter.label} - ${activeOwner ?? 'All owners'} - '
          '${filteredItems.length}/${inbox.totalCount} items',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
        if (visibleItems.isEmpty)
          HrisEmptyState(
            message:
                _selectedFilter == EmployeeWorkflowInboxFilter.all
                    ? 'No active HR workflow items'
                    : 'No ${_selectedFilter.label.toLowerCase()} workflow items',
          )
        else
          ...visibleItems.map(
            (item) => EmployeeWorkflowInboxItemTile(
              item: item,
              asOfDate: inbox.asOfDate,
              onPrimaryAction:
                  item.hasPrimaryAction
                      ? () => _runPrimaryAction(context, item)
                      : null,
            ),
          ),
        if (receipts != null && receipts.receipts.isNotEmpty) ...[
          Text(
            'Inbox action receipts',
            key: const ValueKey('employee-workflow-inbox-receipts-heading'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          EmployeeWorkflowInboxReceiptSummaryStrip(profile: receipts),
          ...receipts.latestReceipts.map(
            (receipt) => EmployeeWorkflowInboxReceiptTile(receipt: receipt),
          ),
          if (receiptExport != null)
            EmployeeWorkflowInboxReceiptExportPreviewPanel(
              preview: receiptExport,
            ),
        ],
      ],
    );
  }

  void _runPrimaryAction(BuildContext context, EmployeeWorkflowInboxItem item) {
    final didRun = _dispatchPrimaryAction(item);
    if (didRun) {
      ref
          .read(employeeWorkflowInboxReceiptProvider(item.employeeId).notifier)
          .recordAction(item);
    }
    final message =
        didRun
            ? '${item.primaryActionLabel}: ${item.title}'
            : 'No available action for ${item.title}';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _runPlaybookAction(
    BuildContext context,
    EmployeeWorkflowInboxSlaPlaybookStep step,
  ) async {
    final reason = await showEmployeeWorkflowInboxSlaPlaybookActionDialog(
      context,
      step: step,
    );
    if (!mounted || reason == null) return;

    final receipt = ref
        .read(
          employeeWorkflowInboxSlaPlaybookActionProvider(
            widget.snapshot.member.id,
          ).notifier,
        )
        .recordAction(step, reason: reason);

    ScaffoldMessenger.of(this.context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${receipt.actionLabel}: ${step.title}')),
      );
  }

  Future<void> _correctPlaybookReason(
    EmployeeWorkflowInboxSlaPlaybookActionReceipt receipt,
  ) async {
    final reason =
        await showEmployeeWorkflowInboxSlaPlaybookReasonCorrectionDialog(
          context,
          receipt: receipt,
        );
    if (!mounted || reason == null) return;

    final correction = ref
        .read(
          employeeWorkflowInboxSlaPlaybookActionProvider(
            widget.snapshot.member.id,
          ).notifier,
        )
        .correctReason(receipt.id, reason: reason);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Reason correction: ${correction.stepTitle}')),
      );
  }

  void _recordPlaybookAuditDelivery(
    EmployeeWorkflowInboxSlaPlaybookAuditExportPreview preview,
    EmployeeWorkflowInboxSlaPlaybookAuditExportRole role,
    EmployeeWorkflowInboxSlaPlaybookAuditExportAction action,
  ) {
    ref
        .read(
          employeeWorkflowInboxSlaPlaybookAuditDeliveryProvider(
            widget.snapshot.member.id,
          ).notifier,
        )
        .recordDelivery(preview: preview, role: role, action: action);
  }

  bool _dispatchPrimaryAction(EmployeeWorkflowInboxItem item) {
    return switch (item.source) {
      EmployeeWorkflowInboxSource.actionWorkflow => _runActionWorkflowAction(
        item,
      ),
      EmployeeWorkflowInboxSource.profileChange => _runProfileChangeAction(
        item,
      ),
      EmployeeWorkflowInboxSource.dataCorrection => _runDataCorrectionAction(
        item,
      ),
      EmployeeWorkflowInboxSource.jobAssignment => _runJobAssignmentAction(
        item,
      ),
    };
  }

  bool _runActionWorkflowAction(EmployeeWorkflowInboxItem item) {
    final notifier = ref.read(
      employeeActionWorkflowProvider(item.employeeId).notifier,
    );
    switch (item.primaryAction) {
      case EmployeeWorkflowInboxAction.start:
        notifier.startTask(item.sourceRecordId);
        return true;
      case EmployeeWorkflowInboxAction.complete:
        notifier.completeTask(item.sourceRecordId);
        return true;
      case EmployeeWorkflowInboxAction.none:
      case EmployeeWorkflowInboxAction.review:
      case EmployeeWorkflowInboxAction.approve:
      case EmployeeWorkflowInboxAction.schedule:
      case EmployeeWorkflowInboxAction.apply:
      case EmployeeWorkflowInboxAction.activate:
        return false;
    }
  }

  bool _runProfileChangeAction(EmployeeWorkflowInboxItem item) {
    final notifier = ref.read(
      employeeProfileChangeGovernanceProvider(item.employeeId).notifier,
    );
    switch (item.primaryAction) {
      case EmployeeWorkflowInboxAction.review:
        notifier.startReview(item.sourceRecordId);
        return true;
      case EmployeeWorkflowInboxAction.approve:
        notifier.approve(item.sourceRecordId);
        return true;
      case EmployeeWorkflowInboxAction.schedule:
        notifier.schedule(item.sourceRecordId);
        return true;
      case EmployeeWorkflowInboxAction.apply:
        notifier.apply(item.sourceRecordId);
        return true;
      case EmployeeWorkflowInboxAction.none:
      case EmployeeWorkflowInboxAction.start:
      case EmployeeWorkflowInboxAction.complete:
      case EmployeeWorkflowInboxAction.activate:
        return false;
    }
  }

  bool _runDataCorrectionAction(EmployeeWorkflowInboxItem item) {
    final notifier = ref.read(
      employeeDataCorrectionProvider(item.employeeId).notifier,
    );
    switch (item.primaryAction) {
      case EmployeeWorkflowInboxAction.review:
        notifier.startReview(item.sourceRecordId);
        return true;
      case EmployeeWorkflowInboxAction.approve:
        notifier.approve(item.sourceRecordId);
        return true;
      case EmployeeWorkflowInboxAction.apply:
        notifier.apply(item.sourceRecordId);
        return true;
      case EmployeeWorkflowInboxAction.none:
      case EmployeeWorkflowInboxAction.start:
      case EmployeeWorkflowInboxAction.complete:
      case EmployeeWorkflowInboxAction.schedule:
      case EmployeeWorkflowInboxAction.activate:
        return false;
    }
  }

  bool _runJobAssignmentAction(EmployeeWorkflowInboxItem item) {
    final notifier = ref.read(
      employeeJobAssignmentProfileProvider(item.employeeId).notifier,
    );
    switch (item.primaryAction) {
      case EmployeeWorkflowInboxAction.approve:
        notifier.approve(item.sourceRecordId);
        return true;
      case EmployeeWorkflowInboxAction.activate:
        notifier.activate(item.sourceRecordId);
        return true;
      case EmployeeWorkflowInboxAction.none:
      case EmployeeWorkflowInboxAction.start:
      case EmployeeWorkflowInboxAction.complete:
      case EmployeeWorkflowInboxAction.review:
      case EmployeeWorkflowInboxAction.schedule:
      case EmployeeWorkflowInboxAction.apply:
        return false;
    }
  }
}

@Preview(name: 'Employee workflow inbox panel')
Widget employeeWorkflowInboxPanelPreview() {
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
          child: EmployeeWorkflowInboxPanel(snapshot: snapshot),
        ),
      ),
    ),
  );
}
