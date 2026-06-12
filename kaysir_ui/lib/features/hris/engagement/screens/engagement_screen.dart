import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/engagement_provider.dart';
import '../widgets/engagement_action_plan_panel.dart';
import '../widgets/engagement_summary_grid.dart';
import '../widgets/engagement_survey_panel.dart';
import '../widgets/pulse_topic_panel.dart';
import '../widgets/recognition_panel.dart';
import '../widgets/wellbeing_panel.dart';

class EngagementScreen extends ConsumerWidget {
  const EngagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(engagementDepartmentsProvider);
    final selectedDepartment = ref.watch(engagementDepartmentProvider);
    final attentionOnly = ref.watch(engagementAttentionOnlyProvider);
    final summary = ref.watch(engagementSummaryProvider);
    final surveys = ref.watch(filteredEngagementSurveysProvider);
    final pulses = ref.watch(filteredPulseTopicsProvider);
    final recognition = ref.watch(filteredRecognitionMomentsProvider);
    final wellbeing = ref.watch(filteredWellbeingRisksProvider);
    final actionPlans = ref.watch(filteredEngagementActionPlansProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Engagement & Wellbeing'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(engagementSurveysProvider);
              ref.invalidate(pulseTopicsProvider);
              ref.invalidate(recognitionMomentsProvider);
              ref.invalidate(wellbeingRisksProvider);
              ref.invalidate(engagementActionPlansProvider);
            },
          ),
          IconButton(
            tooltip: 'Launch pulse',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pulse survey draft created')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisCommandHeader(
                icon: Icons.favorite_border,
                title: 'Engagement Command Center',
                subtitle: 'Pulse, recognition, wellbeing, and action plans',
                departments: departments,
                selectedDepartment: selectedDepartment,
                attentionOnly: attentionOnly,
                onDepartmentChanged: (value) {
                  if (value != null) {
                    ref.read(engagementDepartmentProvider.notifier).state =
                        value;
                  }
                },
                onAttentionChanged: (value) {
                  ref.read(engagementAttentionOnlyProvider.notifier).state =
                      value;
                },
              ),
              const SizedBox(height: 16),
              EngagementSummaryGrid(summary: summary),
              const SizedBox(height: 16),
              HrisResponsivePanelGrid(
                breakpoint: 920,
                panels: [
                  EngagementSurveyPanel(surveys: surveys),
                  PulseTopicPanel(pulses: pulses),
                  RecognitionPanel(recognition: recognition),
                  WellbeingPanel(risks: wellbeing),
                ],
              ),
              const SizedBox(height: 16),
              EngagementActionPlanPanel(plans: actionPlans),
            ],
          ),
        ),
      ),
    );
  }
}
