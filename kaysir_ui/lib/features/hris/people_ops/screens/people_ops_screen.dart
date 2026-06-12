import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/hr_action_provider.dart';
import '../states/people_ops_provider.dart';
import '../widgets/compliance_queue_panel.dart';
import '../widgets/engagement_pulse_panel.dart';
import '../widgets/hr_action_queue_panel.dart';
import '../widgets/hr_action_request_form_panel.dart';
import '../widgets/onboarding_tracker_panel.dart';
import '../widgets/people_ops_summary_grid.dart';
import '../widgets/workforce_plan_panel.dart';

class PeopleOpsScreen extends ConsumerWidget {
  const PeopleOpsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(peopleOpsDepartmentsProvider);
    final selectedDepartment = ref.watch(peopleOpsDepartmentProvider);
    final riskOnly = ref.watch(peopleOpsRiskOnlyProvider);
    final summary = ref.watch(peopleOpsSummaryProvider);
    final workforcePlans = ref.watch(filteredWorkforcePlansProvider);
    final onboardingMilestones = ref.watch(
      filteredOnboardingMilestonesProvider,
    );
    final complianceItems = ref.watch(filteredComplianceItemsProvider);
    final engagementPulses = ref.watch(filteredEngagementPulsesProvider);
    final hrActionDraft = ref.watch(peopleOpsHrActionDraftProvider);
    final hrActionRequests = ref.watch(
      filteredPeopleOpsHrActionRequestsProvider,
    );
    final hrActionSummary = ref.watch(peopleOpsHrActionQueueSummaryProvider);
    final asOfDate = ref.watch(peopleOpsAsOfDateProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('People Operations'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(workforcePlansProvider);
              ref.invalidate(onboardingMilestonesProvider);
              ref.invalidate(complianceItemsProvider);
              ref.invalidate(engagementPulsesProvider);
              ref.invalidate(peopleOpsHrActionDraftProvider);
              ref.invalidate(peopleOpsHrActionRequestsProvider);
            },
          ),
          IconButton(
            tooltip: 'Export',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('People ops snapshot exported')),
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
                icon: Icons.groups_2_outlined,
                title: 'People Ops Command Center',
                subtitle:
                    'Workforce, onboarding, compliance, and engagement signals',
                departments: departments,
                selectedDepartment: selectedDepartment,
                attentionOnly: riskOnly,
                attentionLabel: 'Risk view',
                onDepartmentChanged: (value) {
                  if (value != null) {
                    ref.read(peopleOpsDepartmentProvider.notifier).state =
                        value;
                  }
                },
                onAttentionChanged: (value) {
                  ref.read(peopleOpsRiskOnlyProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 16),
              PeopleOpsSummaryGrid(summary: summary),
              const SizedBox(height: 16),
              HrisResponsivePanelGrid(
                breakpoint: 920,
                panels: [
                  HrActionRequestFormPanel(
                    draft: hrActionDraft,
                    departments: departments,
                    onEmployeeNameChanged:
                        ref
                            .read(peopleOpsHrActionDraftProvider.notifier)
                            .setEmployeeName,
                    onDepartmentChanged:
                        ref
                            .read(peopleOpsHrActionDraftProvider.notifier)
                            .setDepartment,
                    onActionTypeChanged:
                        ref
                            .read(peopleOpsHrActionDraftProvider.notifier)
                            .setActionType,
                    onTargetRoleChanged:
                        ref
                            .read(peopleOpsHrActionDraftProvider.notifier)
                            .setTargetRole,
                    onSelectEffectiveDate:
                        () => _selectHrActionDate(context, ref),
                    onManagerNameChanged:
                        ref
                            .read(peopleOpsHrActionDraftProvider.notifier)
                            .setManagerName,
                    onOwnerNameChanged:
                        ref
                            .read(peopleOpsHrActionDraftProvider.notifier)
                            .setOwnerName,
                    onReasonChanged:
                        ref
                            .read(peopleOpsHrActionDraftProvider.notifier)
                            .setReason,
                    onPayrollReviewChanged:
                        ref
                            .read(peopleOpsHrActionDraftProvider.notifier)
                            .setPayrollReviewRequired,
                    onPriorityChanged:
                        ref
                            .read(peopleOpsHrActionDraftProvider.notifier)
                            .setPriority,
                    onSubmit: () => _submitHrAction(context, ref),
                    onClear:
                        ref.read(peopleOpsHrActionDraftProvider.notifier).clear,
                  ),
                  HrActionQueuePanel(
                    requests: hrActionRequests,
                    summary: hrActionSummary,
                    asOfDate: asOfDate,
                    onAdvance:
                        ref
                            .read(peopleOpsHrActionRequestsProvider.notifier)
                            .advanceStatus,
                    onBlock:
                        ref
                            .read(peopleOpsHrActionRequestsProvider.notifier)
                            .blockRequest,
                  ),
                  WorkforcePlanPanel(plans: workforcePlans),
                  OnboardingTrackerPanel(milestones: onboardingMilestones),
                  ComplianceQueuePanel(items: complianceItems),
                  EngagementPulsePanel(pulses: engagementPulses),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectHrActionDate(BuildContext context, WidgetRef ref) async {
    final draft = ref.read(peopleOpsHrActionDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.effectiveDate ?? draft.asOfDate.add(const Duration(days: 7)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref.read(peopleOpsHrActionDraftProvider.notifier).setEffectiveDate(picked);
  }

  void _submitHrAction(BuildContext context, WidgetRef ref) {
    try {
      final request = ref
          .read(peopleOpsHrActionRequestsProvider.notifier)
          .submitDraft(ref.read(peopleOpsHrActionDraftProvider));
      ref.read(peopleOpsHrActionDraftProvider.notifier).clear();
      _showMessage(
        context,
        '${request.id} submitted for ${request.employeeName}',
      );
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
