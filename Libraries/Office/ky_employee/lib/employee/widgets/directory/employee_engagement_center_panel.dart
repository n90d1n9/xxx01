import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_engagement_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_engagement_provider.dart';
import 'employee_engagement_pulse_form.dart';
import 'employee_engagement_tiles.dart';

class EmployeeEngagementCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeEngagementCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeEngagementCenterPanel> createState() =>
      _EmployeeEngagementCenterPanelState();
}

class _EmployeeEngagementCenterPanelState
    extends ConsumerState<EmployeeEngagementCenterPanel> {
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
    final plan = ref.watch(employeeEngagementPlanProvider(employeeId));
    final draft = ref.watch(employeeEngagementPulseDraftProvider(employeeId));

    if (plan == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_summaryController, draft.summary);
    _sync(_nextStepController, draft.nextStep);

    final signals = [...plan.signals]..sort((a, b) {
      final aAttention = a.needsAttention(plan.asOfDate);
      final bAttention = b.needsAttention(plan.asOfDate);
      if (aAttention != bAttention) return aAttention ? -1 : 1;
      if (a.isResolved != b.isResolved) return a.isResolved ? 1 : -1;
      return b.severity.compareTo(a.severity);
    });
    final pulses = [...plan.pulses]..sort((a, b) => b.date.compareTo(a.date));
    final recognition = [...plan.recognition]
      ..sort((a, b) => b.date.compareTo(a.date));

    return HrisSectionPanel(
      icon: Icons.favorite_border_outlined,
      title: 'Engagement and retention',
      subtitle: plan.nextAction,
      children: [
        EmployeeEngagementSummaryStrip(plan: plan),
        EmployeeEngagementPulseForm(
          draft: draft,
          summaryController: _summaryController,
          nextStepController: _nextStepController,
          onSentimentChanged:
              ref
                  .read(
                    employeeEngagementPulseDraftProvider(employeeId).notifier,
                  )
                  .setSentiment,
          onScoreChanged:
              ref
                  .read(
                    employeeEngagementPulseDraftProvider(employeeId).notifier,
                  )
                  .setScore,
          onSummaryChanged:
              ref
                  .read(
                    employeeEngagementPulseDraftProvider(employeeId).notifier,
                  )
                  .setSummary,
          onNextStepChanged:
              ref
                  .read(
                    employeeEngagementPulseDraftProvider(employeeId).notifier,
                  )
                  .setNextStep,
          onAdd: () => _addPulse(draft),
        ),
        if (signals.isEmpty)
          const HrisListSurface(child: Text('No open retention signals.'))
        else
          ...signals.map(
            (signal) => EmployeeRetentionSignalTile(
              signal: signal,
              asOfDate: plan.asOfDate,
              onStart:
                  () => ref
                      .read(employeeEngagementPlanProvider(employeeId).notifier)
                      .updateSignalStatus(
                        signal.id,
                        EmployeeRetentionSignalStatus.inProgress,
                      ),
              onResolve: () => _resolveSignal(signal),
            ),
          ),
        ...pulses
            .take(3)
            .map((pulse) => EmployeeEngagementPulseTile(pulse: pulse)),
        if (recognition.isEmpty)
          const HrisListSurface(child: Text('No recognition notes yet.'))
        else
          ...recognition.map((note) => EmployeeRecognitionNoteTile(note: note)),
      ],
    );
  }

  void _addPulse(EmployeeEngagementPulseDraft draft) {
    try {
      ref
          .read(employeeEngagementPlanProvider(draft.employeeId).notifier)
          .addPulse(draft);
      ref
          .read(employeeEngagementPulseDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('Pulse added for ${draft.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _resolveSignal(EmployeeRetentionSignal signal) {
    ref
        .read(employeeEngagementPlanProvider(signal.employeeId).notifier)
        .resolveSignal(signal.id);
    _showMessage('${signal.title} resolved');
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
