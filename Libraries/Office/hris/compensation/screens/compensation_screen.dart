import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/compensation_provider.dart';
import '../widgets/allowance_budget_panel.dart';
import '../widgets/benefit_enrollment_panel.dart';
import '../widgets/compensation_review_panel.dart';
import '../widgets/compensation_summary_grid.dart';
import '../widgets/incentive_payout_panel.dart';

class CompensationScreen extends ConsumerWidget {
  const CompensationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(compensationDepartmentsProvider);
    final selectedDepartment = ref.watch(compensationDepartmentProvider);
    final attentionOnly = ref.watch(compensationAttentionOnlyProvider);
    final summary = ref.watch(compensationSummaryProvider);
    final reviews = ref.watch(filteredCompensationReviewsProvider);
    final benefits = ref.watch(filteredBenefitEnrollmentsProvider);
    final allowances = ref.watch(filteredAllowanceBudgetsProvider);
    final incentives = ref.watch(filteredIncentivePayoutsProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Compensation & Benefits'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(compensationReviewsProvider);
              ref.invalidate(benefitEnrollmentsProvider);
              ref.invalidate(allowanceBudgetsProvider);
              ref.invalidate(incentivePayoutsProvider);
            },
          ),
          IconButton(
            tooltip: 'Start comp review',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compensation review draft created'),
                ),
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
                icon: Icons.payments_outlined,
                title: 'Compensation Command Center',
                subtitle: 'Reviews, benefits, allowances, and incentives',
                departments: departments,
                selectedDepartment: selectedDepartment,
                attentionOnly: attentionOnly,
                onDepartmentChanged: (value) {
                  if (value != null) {
                    ref.read(compensationDepartmentProvider.notifier).state =
                        value;
                  }
                },
                onAttentionChanged: (value) {
                  ref.read(compensationAttentionOnlyProvider.notifier).state =
                      value;
                },
              ),
              const SizedBox(height: 16),
              CompensationSummaryGrid(summary: summary),
              const SizedBox(height: 16),
              HrisResponsivePanelGrid(
                breakpoint: 920,
                panels: [
                  CompensationReviewPanel(reviews: reviews),
                  BenefitEnrollmentPanel(benefits: benefits),
                  AllowanceBudgetPanel(allowances: allowances),
                  IncentivePayoutPanel(incentives: incentives),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
