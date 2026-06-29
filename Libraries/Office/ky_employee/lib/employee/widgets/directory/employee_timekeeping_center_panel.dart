import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_timekeeping_models.dart';
import '../../states/employee_timekeeping_provider.dart';
import 'employee_timekeeping_exception_form.dart';
import 'employee_timekeeping_tiles.dart';

class EmployeeTimekeepingCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeTimekeepingCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeTimekeepingCenterPanel> createState() =>
      _EmployeeTimekeepingCenterPanelState();
}

class _EmployeeTimekeepingCenterPanelState
    extends ConsumerState<EmployeeTimekeepingCenterPanel> {
  final _ownerController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _ownerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeTimekeepingProvider(employeeId));
    final draft = ref.watch(
      employeeTimekeepingExceptionDraftProvider(employeeId),
    );

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_ownerController, draft.owner);
    _sync(_noteController, draft.note);

    return HrisSectionPanel(
      icon: Icons.punch_clock_outlined,
      title: 'Timekeeping and timesheets',
      subtitle: profile.nextAction,
      children: [
        EmployeeTimekeepingSummaryStrip(profile: profile),
        EmployeeTimekeepingExceptionForm(
          draft: draft,
          ownerController: _ownerController,
          noteController: _noteController,
          onTypeChanged:
              ref
                  .read(
                    employeeTimekeepingExceptionDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setType,
          onSeverityChanged:
              ref
                  .read(
                    employeeTimekeepingExceptionDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setSeverity,
          onOwnerChanged:
              ref
                  .read(
                    employeeTimekeepingExceptionDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setOwner,
          onMinutesImpactChanged:
              ref
                  .read(
                    employeeTimekeepingExceptionDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setMinutesImpact,
          onPayrollImpactChanged:
              ref
                  .read(
                    employeeTimekeepingExceptionDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setPayrollImpact,
          onNoteChanged:
              ref
                  .read(
                    employeeTimekeepingExceptionDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setNote,
          onSelectWorkDate: () => _selectWorkDate(draft),
          onAdd: () => _addException(draft),
        ),
        ...profile.sortedEntries.map(
          (entry) => EmployeeTimesheetEntryTile(
            entry: entry,
            onApprove: () => _approveEntry(entry),
            onPayrollReady: () => _markPayrollReady(entry),
            onReject: () => _rejectEntry(entry),
          ),
        ),
        if (profile.exceptions.isEmpty)
          const HrisListSurface(child: Text('No timekeeping exceptions.'))
        else
          ...profile.sortedExceptions.map(
            (exception) => EmployeeTimekeepingExceptionTile(
              exception: exception,
              asOfDate: profile.asOfDate,
              onReview: () => _reviewException(exception),
              onResolve: () => _resolveException(exception),
              onWaive: () => _waiveException(exception),
            ),
          ),
      ],
    );
  }

  Future<void> _selectWorkDate(EmployeeTimekeepingExceptionDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.workDate ?? draft.asOfDate.subtract(const Duration(days: 1)),
      firstDate: draft.asOfDate.subtract(const Duration(days: 45)),
      lastDate: draft.asOfDate,
    );
    if (picked == null) return;
    ref
        .read(
          employeeTimekeepingExceptionDraftProvider(draft.employeeId).notifier,
        )
        .setWorkDate(picked);
  }

  void _addException(EmployeeTimekeepingExceptionDraft draft) {
    try {
      final exception = ref
          .read(employeeTimekeepingProvider(draft.employeeId).notifier)
          .addException(draft);
      ref
          .read(
            employeeTimekeepingExceptionDraftProvider(
              draft.employeeId,
            ).notifier,
          )
          .reset();
      _showMessage('${exception.type.label} exception added');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _approveEntry(EmployeeTimesheetEntry entry) {
    ref
        .read(employeeTimekeepingProvider(entry.employeeId).notifier)
        .approveEntry(entry.id, widget.snapshot.member.manager);
    _showMessage('Timesheet entry approved');
  }

  void _markPayrollReady(EmployeeTimesheetEntry entry) {
    ref
        .read(employeeTimekeepingProvider(entry.employeeId).notifier)
        .markPayrollReady(entry.id);
    _showMessage('Timesheet entry marked payroll ready');
  }

  void _rejectEntry(EmployeeTimesheetEntry entry) {
    ref
        .read(employeeTimekeepingProvider(entry.employeeId).notifier)
        .rejectEntry(entry.id, 'Returned for employee correction.');
    _showMessage('Timesheet entry rejected');
  }

  void _reviewException(EmployeeTimekeepingException exception) {
    ref
        .read(employeeTimekeepingProvider(exception.employeeId).notifier)
        .reviewException(exception.id);
    _showMessage('${exception.type.label} moved to review');
  }

  void _resolveException(EmployeeTimekeepingException exception) {
    ref
        .read(employeeTimekeepingProvider(exception.employeeId).notifier)
        .resolveException(exception.id);
    _showMessage('${exception.type.label} resolved');
  }

  void _waiveException(EmployeeTimekeepingException exception) {
    ref
        .read(employeeTimekeepingProvider(exception.employeeId).notifier)
        .waiveException(exception.id);
    _showMessage('${exception.type.label} waived');
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
