import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_performance_support_models.dart';
import '../../states/employee_directory_provider.dart';
import '../../states/employee_performance_support_provider.dart';
import 'employee_performance_support_milestone_form.dart';
import 'employee_performance_support_tiles.dart';

class EmployeePerformanceSupportCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeePerformanceSupportCenterPanel({
    super.key,
    required this.snapshot,
  });

  @override
  ConsumerState<EmployeePerformanceSupportCenterPanel> createState() =>
      _EmployeePerformanceSupportCenterPanelState();
}

class _EmployeePerformanceSupportCenterPanelState
    extends ConsumerState<EmployeePerformanceSupportCenterPanel> {
  final _planTitleController = TextEditingController();
  final _hrPartnerController = TextEditingController();
  final _milestoneTitleController = TextEditingController();
  final _milestoneOwnerController = TextEditingController();
  final _milestoneMetricController = TextEditingController();
  final _milestoneNotesController = TextEditingController();

  @override
  void dispose() {
    _planTitleController.dispose();
    _hrPartnerController.dispose();
    _milestoneTitleController.dispose();
    _milestoneOwnerController.dispose();
    _milestoneMetricController.dispose();
    _milestoneNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final plan = ref.watch(employeePerformanceSupportPlanProvider(employeeId));
    final draft = ref.watch(
      employeePerformanceSupportMilestoneDraftProvider(employeeId),
    );

    if (plan == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_planTitleController, plan.title);
    _sync(_hrPartnerController, plan.hrPartner);
    _sync(_milestoneTitleController, draft.title);
    _sync(_milestoneOwnerController, draft.owner);
    _sync(_milestoneMetricController, draft.successMetric);
    _sync(_milestoneNotesController, draft.notes);

    return HrisSectionPanel(
      icon: Icons.health_and_safety_outlined,
      title: 'Performance support plan',
      subtitle: plan.nextAction,
      children: [
        EmployeePerformanceSupportSummaryStrip(plan: plan),
        EmployeePerformanceSupportPlanCard(
          plan: plan,
          titleController: _planTitleController,
          hrPartnerController: _hrPartnerController,
          onStatusChanged:
              ref
                  .read(
                    employeePerformanceSupportPlanProvider(employeeId).notifier,
                  )
                  .setStatus,
          onTitleChanged:
              ref
                  .read(
                    employeePerformanceSupportPlanProvider(employeeId).notifier,
                  )
                  .setTitle,
          onHrPartnerChanged:
              ref
                  .read(
                    employeePerformanceSupportPlanProvider(employeeId).notifier,
                  )
                  .setHrPartner,
          onSelectEndDate: () => _selectPlanEndDate(plan),
          onReset:
              ref
                  .read(
                    employeePerformanceSupportPlanProvider(employeeId).notifier,
                  )
                  .resetToPreset,
        ),
        EmployeePerformanceSupportMilestoneForm(
          draft: draft,
          titleController: _milestoneTitleController,
          ownerController: _milestoneOwnerController,
          metricController: _milestoneMetricController,
          notesController: _milestoneNotesController,
          onTypeChanged:
              ref
                  .read(
                    employeePerformanceSupportMilestoneDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setType,
          onTitleChanged:
              ref
                  .read(
                    employeePerformanceSupportMilestoneDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setTitle,
          onOwnerChanged:
              ref
                  .read(
                    employeePerformanceSupportMilestoneDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setOwner,
          onRiskChanged:
              ref
                  .read(
                    employeePerformanceSupportMilestoneDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setRisk,
          onMetricChanged:
              ref
                  .read(
                    employeePerformanceSupportMilestoneDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setSuccessMetric,
          onNotesChanged:
              ref
                  .read(
                    employeePerformanceSupportMilestoneDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setNotes,
          onSelectDueDate: () => _selectMilestoneDueDate(draft),
          onAdd: () => _addMilestone(draft),
        ),
        if (plan.milestones.isEmpty)
          const HrisEmptyState(message: 'No support milestones yet')
        else
          ...plan.sortedMilestones.map(
            (milestone) => EmployeePerformanceSupportMilestoneTile(
              milestone: milestone,
              asOfDate: plan.asOfDate,
              onStatusChanged:
                  (status) => ref
                      .read(
                        employeePerformanceSupportPlanProvider(
                          employeeId,
                        ).notifier,
                      )
                      .updateMilestoneStatus(milestone.id, status),
              onRiskChanged:
                  (risk) => ref
                      .read(
                        employeePerformanceSupportPlanProvider(
                          employeeId,
                        ).notifier,
                      )
                      .updateMilestoneRisk(milestone.id, risk),
              onSchedule: () => _scheduleMilestone(milestone),
              onComplete:
                  () => ref
                      .read(
                        employeePerformanceSupportPlanProvider(
                          employeeId,
                        ).notifier,
                      )
                      .completeMilestone(milestone.id),
              onWaive:
                  () => ref
                      .read(
                        employeePerformanceSupportPlanProvider(
                          employeeId,
                        ).notifier,
                      )
                      .waiveMilestone(milestone.id),
              onRemove:
                  () => ref
                      .read(
                        employeePerformanceSupportPlanProvider(
                          employeeId,
                        ).notifier,
                      )
                      .removeMilestone(milestone.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectPlanEndDate(EmployeePerformanceSupportPlan plan) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          plan.endDate.isBefore(plan.asOfDate) ? plan.asOfDate : plan.endDate,
      firstDate: plan.asOfDate,
      lastDate: plan.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeePerformanceSupportPlanProvider(plan.employeeId).notifier)
        .setEndDate(picked);
  }

  Future<void> _selectMilestoneDueDate(
    EmployeePerformanceSupportMilestoneDraft draft,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate.add(const Duration(days: 7)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(
          employeePerformanceSupportMilestoneDraftProvider(
            draft.employeeId,
          ).notifier,
        )
        .setDueDate(picked);
  }

  Future<void> _scheduleMilestone(
    EmployeePerformanceSupportMilestone milestone,
  ) async {
    final asOfDate = ref.read(employeeDirectoryAsOfDateProvider);
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final picked = await showDatePicker(
      context: context,
      initialDate:
          milestone.dueDate.isBefore(today) ? today : milestone.dueDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(
          employeePerformanceSupportPlanProvider(milestone.employeeId).notifier,
        )
        .scheduleMilestone(milestone.id, picked);
  }

  void _addMilestone(EmployeePerformanceSupportMilestoneDraft draft) {
    try {
      final milestone = ref
          .read(
            employeePerformanceSupportPlanProvider(draft.employeeId).notifier,
          )
          .addMilestone(draft);
      ref
          .read(
            employeePerformanceSupportMilestoneDraftProvider(
              draft.employeeId,
            ).notifier,
          )
          .reset();
      _showMessage('${milestone.title} added to support plan');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
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
