import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_performance_models.dart';
import '../../states/employee_performance_provider.dart';
import 'employee_performance_check_in_form.dart';
import 'employee_performance_tiles.dart';

class EmployeePerformanceReviewPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeePerformanceReviewPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeePerformanceReviewPanel> createState() =>
      _EmployeePerformanceReviewPanelState();
}

class _EmployeePerformanceReviewPanelState
    extends ConsumerState<EmployeePerformanceReviewPanel> {
  final _summaryController = TextEditingController();
  final _nextStepController = TextEditingController();

  @override
  void dispose() {
    _summaryController.dispose();
    _nextStepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final plan = ref.watch(employeePerformancePlanProvider(employeeId));
    final draft = ref.watch(
      employeePerformanceCheckInDraftProvider(employeeId),
    );

    if (plan == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_summaryController, draft.summary);
    _sync(_nextStepController, draft.nextStep);

    final goals = [...plan.goals]..sort((a, b) {
      if (a.isComplete != b.isComplete) {
        return a.isComplete ? 1 : -1;
      }
      if (a.needsAttention != b.needsAttention) {
        return a.needsAttention ? -1 : 1;
      }
      return a.targetDate.compareTo(b.targetDate);
    });
    final checkIns = [...plan.checkIns]
      ..sort((a, b) => b.date.compareTo(a.date));

    return HrisSectionPanel(
      icon: Icons.insights_outlined,
      title: 'Performance and goals',
      subtitle: plan.nextAction,
      children: [
        EmployeePerformanceSummaryStrip(plan: plan),
        EmployeePerformanceCycleCard(plan: plan),
        EmployeePerformanceCheckInForm(
          draft: draft,
          summaryController: _summaryController,
          nextStepController: _nextStepController,
          onSentimentChanged:
              ref
                  .read(
                    employeePerformanceCheckInDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setSentiment,
          onSummaryChanged:
              ref
                  .read(
                    employeePerformanceCheckInDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setSummary,
          onNextStepChanged:
              ref
                  .read(
                    employeePerformanceCheckInDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setNextStep,
          onSubmit: () => _addCheckIn(draft),
        ),
        ...goals.map(
          (goal) => EmployeePerformanceGoalTile(
            goal: goal,
            asOfDate: plan.asOfDate,
            onNudgeProgress:
                () => ref
                    .read(employeePerformancePlanProvider(employeeId).notifier)
                    .updateGoalProgress(goal.id, goal.progress + 0.1),
            onComplete:
                () => ref
                    .read(employeePerformancePlanProvider(employeeId).notifier)
                    .updateGoalStatus(
                      goal.id,
                      EmployeePerformanceGoalStatus.complete,
                    ),
            onStatusChanged:
                (status) => ref
                    .read(employeePerformancePlanProvider(employeeId).notifier)
                    .updateGoalStatus(goal.id, status),
          ),
        ),
        if (checkIns.isEmpty)
          const HrisListSurface(
            child: Text('No performance check-ins recorded yet.'),
          )
        else
          ...checkIns
              .take(3)
              .map(
                (checkIn) => EmployeePerformanceCheckInTile(checkIn: checkIn),
              ),
      ],
    );
  }

  void _addCheckIn(EmployeePerformanceCheckInDraft draft) {
    try {
      final checkIn = ref
          .read(employeePerformancePlanProvider(draft.employeeId).notifier)
          .addCheckIn(draft);
      ref
          .read(
            employeePerformanceCheckInDraftProvider(draft.employeeId).notifier,
          )
          .reset();
      _showMessage('${checkIn.id} recorded for ${draft.employeeName}');
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
