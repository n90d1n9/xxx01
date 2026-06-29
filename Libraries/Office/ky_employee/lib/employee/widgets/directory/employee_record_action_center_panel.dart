import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_record_action_models.dart';
import '../../states/employee_directory_provider.dart';
import '../../states/employee_record_action_provider.dart';
import 'employee_record_action_tiles.dart';

class EmployeeRecordActionCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeRecordActionCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeRecordActionCenterPanel> createState() =>
      _EmployeeRecordActionCenterPanelState();
}

class _EmployeeRecordActionCenterPanelState
    extends ConsumerState<EmployeeRecordActionCenterPanel> {
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _managerController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _positionController.dispose();
    _departmentController.dispose();
    _managerController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final draft = ref.watch(employeeRecordActionDraftProvider(employeeId));
    final requests = ref.watch(
      employeeRecordActionsForEmployeeProvider(employeeId),
    );
    final summary = ref.watch(employeeRecordActionSummaryProvider(employeeId));

    if (draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_positionController, draft.targetPosition);
    _sync(_departmentController, draft.targetDepartment);
    _sync(_managerController, draft.targetManager);
    _sync(_reasonController, draft.reason);

    return HrisSectionPanel(
      icon: Icons.edit_note_outlined,
      title: 'Record action center',
      subtitle: summary.nextAction,
      children: [
        _ActionSummaryStrip(summary: summary),
        _ActionDraftForm(
          draft: draft,
          positionController: _positionController,
          departmentController: _departmentController,
          managerController: _managerController,
          reasonController: _reasonController,
          onSelectType:
              ref
                  .read(employeeRecordActionDraftProvider(employeeId).notifier)
                  .setActionType,
          onPositionChanged:
              ref
                  .read(employeeRecordActionDraftProvider(employeeId).notifier)
                  .setTargetPosition,
          onDepartmentChanged:
              ref
                  .read(employeeRecordActionDraftProvider(employeeId).notifier)
                  .setTargetDepartment,
          onManagerChanged:
              ref
                  .read(employeeRecordActionDraftProvider(employeeId).notifier)
                  .setTargetManager,
          onReasonChanged:
              ref
                  .read(employeeRecordActionDraftProvider(employeeId).notifier)
                  .setReason,
          onSelectDate: () => _selectEffectiveDate(draft),
          onSubmit: () => _submitDraft(draft),
        ),
        if (requests.isEmpty)
          const HrisListSurface(
            child: Text('No employee record actions submitted yet.'),
          )
        else
          ...requests.map(
            (request) => EmployeeRecordActionRequestTile(
              request: request,
              onApprove:
                  () => ref
                      .read(employeeRecordActionRequestsProvider.notifier)
                      .approve(request.id),
              onApply: () => _applyRequest(request),
            ),
          ),
      ],
    );
  }

  Future<void> _selectEffectiveDate(EmployeeRecordActionDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.effectiveDate ?? draft.asOfDate.add(const Duration(days: 7)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeeRecordActionDraftProvider(draft.employeeId).notifier)
        .setEffectiveDate(picked);
  }

  void _submitDraft(EmployeeRecordActionDraft draft) {
    try {
      final request = ref
          .read(employeeRecordActionRequestsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(employeeRecordActionDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${request.id} submitted for ${request.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _applyRequest(EmployeeRecordActionRequest request) {
    final members = ref.read(employeeDirectoryMembersProvider);
    final member = members.firstWhere((item) => item.id == request.employeeId);
    ref
        .read(employeeDirectoryMembersProvider.notifier)
        .updateMember(request.applyTo(member));
    ref
        .read(employeeRecordActionRequestsProvider.notifier)
        .markApplied(request.id);
    _showMessage('${request.id} applied to ${request.employeeName}');
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

class _ActionDraftForm extends StatelessWidget {
  final EmployeeRecordActionDraft draft;
  final TextEditingController positionController;
  final TextEditingController departmentController;
  final TextEditingController managerController;
  final TextEditingController reasonController;
  final ValueChanged<EmployeeRecordActionType> onSelectType;
  final ValueChanged<String> onPositionChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onManagerChanged;
  final ValueChanged<String> onReasonChanged;
  final VoidCallback onSelectDate;
  final VoidCallback onSubmit;

  const _ActionDraftForm({
    required this.draft,
    required this.positionController,
    required this.departmentController,
    required this.managerController,
    required this.reasonController,
    required this.onSelectType,
    required this.onPositionChanged,
    required this.onDepartmentChanged,
    required this.onManagerChanged,
    required this.onReasonChanged,
    required this.onSelectDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<EmployeeRecordActionType>(
            segments:
                EmployeeRecordActionType.values
                    .map(
                      (type) =>
                          ButtonSegment(value: type, label: Text(type.label)),
                    )
                    .toList(),
            selected: {draft.actionType},
            onSelectionChanged: (selection) => onSelectType(selection.single),
          ),
          const SizedBox(height: 12),
          if (draft.actionType != EmployeeRecordActionType.managerChange)
            _ActionTextField(
              controller: positionController,
              label: 'Target position',
              icon: Icons.work_outline,
              onChanged: onPositionChanged,
            ),
          if (draft.actionType != EmployeeRecordActionType.managerChange)
            const SizedBox(height: 12),
          if (draft.actionType == EmployeeRecordActionType.transfer) ...[
            _ActionTextField(
              controller: departmentController,
              label: 'Target department',
              icon: Icons.apartment_outlined,
              onChanged: onDepartmentChanged,
            ),
            const SizedBox(height: 12),
          ],
          if (draft.actionType != EmployeeRecordActionType.promotion) ...[
            _ActionTextField(
              controller: managerController,
              label: 'Target manager',
              icon: Icons.supervisor_account_outlined,
              onChanged: onManagerChanged,
            ),
            const SizedBox(height: 12),
          ],
          _EffectiveDateField(draft: draft, onTap: onSelectDate),
          const SizedBox(height: 12),
          _ActionTextField(
            controller: reasonController,
            label: 'Reason',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onReasonChanged,
          ),
          const SizedBox(height: 12),
          EmployeeRecordActionImpactPreview(impacts: draft.impacts),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                draft.isReadyToSubmit
                    ? const Color(0xFF15803D)
                    : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% ready',
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: draft.isReadyToSubmit ? onSubmit : null,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Submit action'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionSummaryStrip extends StatelessWidget {
  final EmployeeRecordActionSummary summary;

  const _ActionSummaryStrip({required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Submitted',
          value: '${summary.submittedCount}',
        ),
        HrisMetricStripItem(
          label: 'Approved',
          value: '${summary.approvedCount}',
        ),
        HrisMetricStripItem(label: 'Applied', value: '${summary.appliedCount}'),
      ],
    );
  }
}

class _ActionTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int minLines;
  final ValueChanged<String> onChanged;

  const _ActionTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : 4,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
    );
  }
}

class _EffectiveDateField extends StatelessWidget {
  final EmployeeRecordActionDraft draft;
  final VoidCallback onTap;

  const _EffectiveDateField({required this.draft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Effective date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_available_outlined),
        ),
        child: Text(
          draft.effectiveDate == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(draft.effectiveDate!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color:
                draft.effectiveDate == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}
