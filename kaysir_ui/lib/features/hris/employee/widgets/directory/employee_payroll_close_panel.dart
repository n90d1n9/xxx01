import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_payroll_close_models.dart';
import '../../states/employee_payroll_close_provider.dart';
import 'employee_payroll_close_form.dart';
import 'employee_payroll_close_tiles.dart';

class EmployeePayrollClosePanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeePayrollClosePanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeePayrollClosePanel> createState() =>
      _EmployeePayrollClosePanelState();
}

class _EmployeePayrollClosePanelState
    extends ConsumerState<EmployeePayrollClosePanel> {
  final _ownerController = TextEditingController();
  final _journalBatchController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _ownerController.dispose();
    _journalBatchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeePayrollCloseProvider(employeeId));
    final draft = ref.watch(employeePayrollCloseDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(
      _ownerController,
      profile.closeOwner.isEmpty ? draft.owner : profile.closeOwner,
    );
    _sync(
      _journalBatchController,
      profile.journalBatchId.isEmpty
          ? draft.journalBatchId
          : profile.journalBatchId,
    );
    _sync(
      _noteController,
      profile.closeNote.isEmpty ? draft.note : profile.closeNote,
    );

    return HrisSectionPanel(
      icon: Icons.account_tree_outlined,
      title: 'Payroll close',
      subtitle: profile.nextAction,
      children: [
        EmployeePayrollCloseSummaryStrip(profile: profile),
        EmployeePayrollCloseStatusCard(profile: profile),
        EmployeePayrollCloseForm(
          profile: profile,
          draft: draft,
          ownerController: _ownerController,
          journalBatchController: _journalBatchController,
          noteController: _noteController,
          onOwnerChanged:
              ref
                  .read(employeePayrollCloseDraftProvider(employeeId).notifier)
                  .setOwner,
          onJournalBatchChanged:
              ref
                  .read(employeePayrollCloseDraftProvider(employeeId).notifier)
                  .setJournalBatchId,
          onNoteChanged:
              ref
                  .read(employeePayrollCloseDraftProvider(employeeId).notifier)
                  .setNote,
          onPost: () => _postJournal(draft),
          onClose: _closePeriod,
          onReopen: _reopen,
        ),
        ...profile.sortedJournalLines.map(
          (line) => EmployeePayrollJournalLineTile(line: line),
        ),
      ],
    );
  }

  void _postJournal(EmployeePayrollCloseDraft draft) {
    try {
      ref
          .read(employeePayrollCloseProvider(draft.employeeId).notifier)
          .postJournal(draft);
      _showMessage('Payroll journal posted');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _closePeriod() {
    try {
      ref
          .read(
            employeePayrollCloseProvider(widget.snapshot.member.id).notifier,
          )
          .closePeriod();
      _showMessage('Payroll period closed');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _reopen() {
    ref
        .read(employeePayrollCloseProvider(widget.snapshot.member.id).notifier)
        .reopen();
    _showMessage('Payroll close reopened');
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
