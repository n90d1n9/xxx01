import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_schedule_models.dart';
import '../../states/employee_schedule_provider.dart';
import 'employee_schedule_adjustment_form.dart';
import 'employee_schedule_tiles.dart';

class EmployeeScheduleCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeScheduleCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeScheduleCenterPanel> createState() =>
      _EmployeeScheduleCenterPanelState();
}

class _EmployeeScheduleCenterPanelState
    extends ConsumerState<EmployeeScheduleCenterPanel> {
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _locationController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _locationController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeScheduleProfileProvider(employeeId));
    final draft = ref.watch(
      employeeScheduleAdjustmentDraftProvider(employeeId),
    );

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_startController, draft.startTimeLabel);
    _sync(_endController, draft.endTimeLabel);
    _sync(_locationController, draft.location);
    _sync(_reasonController, draft.reason);

    final signals = [...profile.attendanceSignals]..sort((a, b) {
      if (a.needsAttention != b.needsAttention) {
        return a.needsAttention ? -1 : 1;
      }
      return b.date.compareTo(a.date);
    });
    final adjustments = [...profile.adjustments]..sort((a, b) {
      final statusCompare = _adjustmentRank(
        a.status,
      ).compareTo(_adjustmentRank(b.status));
      if (statusCompare != 0) return statusCompare;
      return b.targetDate.compareTo(a.targetDate);
    });

    return HrisSectionPanel(
      icon: Icons.calendar_month_outlined,
      title: 'Schedule and attendance',
      subtitle: profile.nextAction,
      children: [
        EmployeeScheduleSummaryStrip(profile: profile),
        EmployeeScheduleAssignmentCard(assignment: profile.assignment),
        EmployeeScheduleAdjustmentForm(
          draft: draft,
          startController: _startController,
          endController: _endController,
          locationController: _locationController,
          reasonController: _reasonController,
          onTypeChanged:
              ref
                  .read(
                    employeeScheduleAdjustmentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setType,
          onStartChanged:
              ref
                  .read(
                    employeeScheduleAdjustmentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setStartTime,
          onEndChanged:
              ref
                  .read(
                    employeeScheduleAdjustmentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setEndTime,
          onLocationChanged:
              ref
                  .read(
                    employeeScheduleAdjustmentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setLocation,
          onReasonChanged:
              ref
                  .read(
                    employeeScheduleAdjustmentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setReason,
          onSelectDate: () => _selectTargetDate(draft),
          onAdd: () => _addAdjustment(draft),
        ),
        if (signals.isEmpty)
          const HrisListSurface(child: Text('No attendance signals recorded.'))
        else
          ...signals
              .take(3)
              .map(
                (signal) => EmployeeAttendanceSignalTile(
                  signal: signal,
                  onResolve:
                      () => ref
                          .read(
                            employeeScheduleProfileProvider(
                              employeeId,
                            ).notifier,
                          )
                          .resolveSignal(signal.id),
                ),
              ),
        if (adjustments.isEmpty)
          const HrisListSurface(
            child: Text('No schedule adjustments submitted.'),
          )
        else
          ...adjustments.map(
            (request) => EmployeeScheduleAdjustmentTile(
              request: request,
              onApprove:
                  () => ref
                      .read(
                        employeeScheduleProfileProvider(employeeId).notifier,
                      )
                      .approveAdjustment(request.id),
              onApply:
                  () => ref
                      .read(
                        employeeScheduleProfileProvider(employeeId).notifier,
                      )
                      .applyAdjustment(request.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectTargetDate(EmployeeScheduleAdjustmentDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.targetDate ?? draft.asOfDate.add(const Duration(days: 7)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(
          employeeScheduleAdjustmentDraftProvider(draft.employeeId).notifier,
        )
        .setTargetDate(picked);
  }

  void _addAdjustment(EmployeeScheduleAdjustmentDraft draft) {
    try {
      final request = ref
          .read(employeeScheduleProfileProvider(draft.employeeId).notifier)
          .addDraft(draft);
      ref
          .read(
            employeeScheduleAdjustmentDraftProvider(draft.employeeId).notifier,
          )
          .reset();
      _showMessage('${request.id} added for ${draft.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  int _adjustmentRank(EmployeeScheduleAdjustmentStatus status) {
    return switch (status) {
      EmployeeScheduleAdjustmentStatus.pending => 0,
      EmployeeScheduleAdjustmentStatus.approved => 1,
      EmployeeScheduleAdjustmentStatus.applied => 2,
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
