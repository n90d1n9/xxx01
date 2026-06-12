import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_data_quality_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_data_quality_provider.dart';
import 'employee_data_quality_form.dart';
import 'employee_data_quality_tiles.dart';

class EmployeeDataQualityPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeDataQualityPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeDataQualityPanel> createState() =>
      _EmployeeDataQualityPanelState();
}

class _EmployeeDataQualityPanelState
    extends ConsumerState<EmployeeDataQualityPanel> {
  final _titleController = TextEditingController();
  final _fieldController = TextEditingController();
  final _ownerController = TextEditingController();
  final _detailController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _fieldController.dispose();
    _ownerController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeDataQualityProvider(employeeId));
    final draft = ref.watch(employeeDataQualityIssueDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_fieldController, draft.field);
    _sync(_ownerController, draft.owner);
    _sync(_detailController, draft.detail);

    return HrisSectionPanel(
      icon: Icons.rule_folder_outlined,
      title: 'Data quality center',
      subtitle: profile.nextAction,
      children: [
        EmployeeDataQualityScoreCard(profile: profile),
        EmployeeDataQualitySummaryStrip(profile: profile),
        EmployeeDataQualityIssueForm(
          draft: draft,
          titleController: _titleController,
          fieldController: _fieldController,
          ownerController: _ownerController,
          detailController: _detailController,
          onTitleChanged:
              ref
                  .read(
                    employeeDataQualityIssueDraftProvider(employeeId).notifier,
                  )
                  .setTitle,
          onFieldChanged:
              ref
                  .read(
                    employeeDataQualityIssueDraftProvider(employeeId).notifier,
                  )
                  .setField,
          onOwnerChanged:
              ref
                  .read(
                    employeeDataQualityIssueDraftProvider(employeeId).notifier,
                  )
                  .setOwner,
          onDetailChanged:
              ref
                  .read(
                    employeeDataQualityIssueDraftProvider(employeeId).notifier,
                  )
                  .setDetail,
          onTypeChanged:
              ref
                  .read(
                    employeeDataQualityIssueDraftProvider(employeeId).notifier,
                  )
                  .setType,
          onSeverityChanged:
              ref
                  .read(
                    employeeDataQualityIssueDraftProvider(employeeId).notifier,
                  )
                  .setSeverity,
          onPickDueDate: () => _pickDueDate(employeeId),
          onAdd: () => _addIssue(draft),
        ),
        if (profile.sortedIssues.isEmpty)
          const HrisEmptyState(message: 'No employee data quality issues')
        else
          ...profile.sortedIssues.map(
            (issue) => EmployeeDataQualityIssueTile(
              issue: issue,
              asOfDate: profile.asOfDate,
              onReview: () => _review(issue),
              onResolve: () => _resolve(issue),
              onWaive: () => _waive(issue),
              onReopen: () => _reopen(issue),
            ),
          ),
      ],
    );
  }

  Future<void> _pickDueDate(String employeeId) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.snapshot.asOfDate.add(const Duration(days: 7)),
      firstDate: widget.snapshot.asOfDate,
      lastDate: widget.snapshot.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(employeeDataQualityIssueDraftProvider(employeeId).notifier)
        .setDueDate(picked);
  }

  void _addIssue(EmployeeDataQualityIssueDraft draft) {
    try {
      final issue = ref
          .read(employeeDataQualityProvider(draft.employeeId).notifier)
          .addDraft(draft);
      ref
          .read(
            employeeDataQualityIssueDraftProvider(draft.employeeId).notifier,
          )
          .reset();
      _showMessage('${issue.title} added');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _review(EmployeeDataQualityIssue issue) {
    ref
        .read(employeeDataQualityProvider(issue.employeeId).notifier)
        .reviewIssue(issue.id);
    _showMessage('${issue.title} reviewed');
  }

  void _resolve(EmployeeDataQualityIssue issue) {
    ref
        .read(employeeDataQualityProvider(issue.employeeId).notifier)
        .resolveIssue(issue.id);
    _showMessage('${issue.title} resolved');
  }

  void _waive(EmployeeDataQualityIssue issue) {
    ref
        .read(employeeDataQualityProvider(issue.employeeId).notifier)
        .waiveIssue(issue.id);
    _showMessage('${issue.title} waived');
  }

  void _reopen(EmployeeDataQualityIssue issue) {
    ref
        .read(employeeDataQualityProvider(issue.employeeId).notifier)
        .reopenIssue(issue.id);
    _showMessage('${issue.title} reopened');
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
