import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_compensation_band.dart';
import '../models/company_cost_center.dart';
import '../models/company_job_profile.dart';
import '../models/company_position_control.dart';
import '../models/company_workforce_plan.dart';

/// Workforce planning queue for headcount, budget, and job architecture review.
class CompanyWorkforcePlanPanel extends StatelessWidget {
  final CompanyWorkforcePlan plan;
  final ValueChanged<String>? onApprovePosition;
  final ValueChanged<String>? onCloseRecruiting;
  final ValueChanged<String>? onReviewCostCenter;

  const CompanyWorkforcePlanPanel({
    super.key,
    required this.plan,
    this.onApprovePosition,
    this.onCloseRecruiting,
    this.onReviewCostCenter,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.groups_2_outlined,
      title: 'Workforce Plan',
      subtitle:
          plan.isEmpty
              ? 'No workforce demand'
              : '${plan.actionableCount} actions, ${plan.openSeatCount} open seats',
      emptyMessage: 'No workforce planning items',
      children:
          plan.isEmpty
              ? const []
              : [
                _WorkforcePlanSummary(plan: plan),
                if (plan.priorityItems.isEmpty)
                  const HrisEmptyState(message: 'Workforce plan is aligned'),
                for (final item in plan.priorityItems)
                  _WorkforcePlanTile(
                    item: item,
                    onApprovePosition:
                        onApprovePosition == null || !item.canApprovePosition
                            ? null
                            : () => onApprovePosition!(item.position.id),
                    onCloseRecruiting:
                        onCloseRecruiting == null || !item.canCloseRecruiting
                            ? null
                            : () => onCloseRecruiting!(item.position.id),
                    onReviewCostCenter:
                        onReviewCostCenter == null || !item.canReviewCostCenter
                            ? null
                            : () => onReviewCostCenter!(item.costCenter!.id),
                  ),
              ],
    );
  }
}

/// Compact workforce plan totals for leaders scanning the queue.
class _WorkforcePlanSummary extends StatelessWidget {
  final CompanyWorkforcePlan plan;

  const _WorkforcePlanSummary({required this.plan});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Critical', value: '${plan.criticalCount}'),
        HrisMetricStripItem(
          label: 'Open seats',
          value: '${plan.openSeatCount}',
        ),
        HrisMetricStripItem(
          label: 'Overfilled',
          value: '${plan.overfilledSeatCount}',
        ),
        HrisMetricStripItem(
          label: 'Architecture',
          value: '${plan.architectureRiskCount}',
        ),
      ],
    );
  }
}

/// One ranked workforce planning decision with linked readiness context.
class _WorkforcePlanTile extends StatelessWidget {
  final CompanyWorkforcePlanItem item;
  final VoidCallback? onApprovePosition;
  final VoidCallback? onCloseRecruiting;
  final VoidCallback? onReviewCostCenter;

  const _WorkforcePlanTile({
    required this.item,
    required this.onApprovePosition,
    required this.onCloseRecruiting,
    required this.onReviewCostCenter,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor(item.risk);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.position.entityName} - ${item.position.orgUnitName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: item.risk.label, color: riskColor),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Seats',
                value:
                    '${item.position.filledSeats}/${item.position.authorizedSeats}',
              ),
              HrisMetricStripItem(label: 'Open', value: '${item.openSeats}'),
              HrisMetricStripItem(
                label: 'Status',
                value: item.position.status.label,
              ),
              HrisMetricStripItem(label: 'Review', value: item.reviewLabel),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.rationale,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              HrisStatusPill(
                label: item.costCenterLabel,
                color: item.hasBudgetRisk ? Colors.orange : Colors.green,
              ),
              HrisStatusPill(
                label: item.compensationBandLabel,
                color: item.hasArchitectureRisk ? Colors.orange : Colors.green,
              ),
              HrisStatusPill(
                label: item.jobProfileLabel,
                color: item.hasArchitectureRisk ? Colors.orange : Colors.green,
              ),
            ],
          ),
          if (onApprovePosition != null ||
              onCloseRecruiting != null ||
              onReviewCostCenter != null) ...[
            const SizedBox(height: 12),
            _WorkforcePlanActions(
              item: item,
              onApprovePosition: onApprovePosition,
              onCloseRecruiting: onCloseRecruiting,
              onReviewCostCenter: onReviewCostCenter,
            ),
          ],
        ],
      ),
    );
  }
}

/// Action row for one workforce planning item.
class _WorkforcePlanActions extends StatelessWidget {
  final CompanyWorkforcePlanItem item;
  final VoidCallback? onApprovePosition;
  final VoidCallback? onCloseRecruiting;
  final VoidCallback? onReviewCostCenter;

  const _WorkforcePlanActions({
    required this.item,
    required this.onApprovePosition,
    required this.onCloseRecruiting,
    required this.onReviewCostCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.end,
        children: [
          if (onReviewCostCenter != null)
            OutlinedButton.icon(
              key: Key('company-workforce-plan-cost-${item.position.id}'),
              onPressed: onReviewCostCenter,
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Review cost center'),
            ),
          if (onCloseRecruiting != null)
            OutlinedButton.icon(
              key: Key('company-workforce-plan-close-${item.position.id}'),
              onPressed: onCloseRecruiting,
              icon: const Icon(Icons.done_all_outlined),
              label: const Text('Close recruiting'),
            ),
          if (onApprovePosition != null)
            FilledButton.icon(
              key: Key('company-workforce-plan-approve-${item.position.id}'),
              onPressed: onApprovePosition,
              icon: const Icon(Icons.verified_outlined),
              label: Text(item.action.label),
            ),
        ],
      ),
    );
  }
}

Color _riskColor(CompanyWorkforcePlanRisk risk) {
  switch (risk) {
    case CompanyWorkforcePlanRisk.critical:
      return Colors.red;
    case CompanyWorkforcePlanRisk.needsReview:
      return Colors.orange;
    case CompanyWorkforcePlanRisk.healthy:
      return Colors.green;
  }
}

@Preview(name: 'Company workforce plan panel')
Widget companyWorkforcePlanPanelPreview() {
  final asOfDate = DateTime(2026, 6, 12);
  final positions = [
    CompanyPositionControl(
      id: 'position-retail-supervisor',
      positionTitle: 'Retail Supervisor',
      entityName: 'Kaysir Retail Services',
      orgUnitName: 'Retail Operations',
      type: CompanyPositionControlType.permanent,
      status: CompanyPositionControlStatus.pendingApproval,
      ownerName: 'Dewi Lestari',
      authorizedSeats: 4,
      filledSeats: 5,
      fte: 1,
      compensationBand: 'OPS-4',
      nextReviewDate: DateTime(2026, 6, 10),
      hiringPlan: 'Reconcile outlet supervisor coverage',
      linkedRequisition: 'REQ-OPS-2026-07',
    ),
  ];

  final plan = buildCompanyWorkforcePlan(
    positions: positions,
    costCenters: const [
      CompanyCostCenter(
        id: 'cc-retail-ops',
        code: 'CC-OPS',
        name: 'Retail Operations',
        entityName: 'Kaysir Retail Services',
        orgUnitName: 'Retail Operations',
        ownerName: 'Dewi Lestari',
        annualBudget: 3100000000,
        allocatedHeadcount: 38,
        activeHeadcount: 42,
        status: CompanyCostCenterStatus.needsReview,
      ),
    ],
    compensationBands: [
      CompanyCompensationBand(
        id: 'band-ops-4',
        bandCode: 'OPS-4',
        entityName: 'Kaysir Retail Services',
        family: CompanyCompensationBandFamily.operations,
        levelName: 'Supervisor',
        status: CompanyCompensationBandStatus.needsReview,
        minSalary: 132000000,
        midpointSalary: 168000000,
        maxSalary: 204000000,
        currency: 'IDR',
        ownerName: 'Dewi Lestari',
        approverName: 'Retail Director',
        effectiveDate: DateTime(2025, 10, 1),
        nextReviewDate: DateTime(2026, 5, 20),
        linkedPolicy: 'Retail supervisor coverage',
      ),
    ],
    jobProfiles: [
      CompanyJobProfile(
        id: 'job-retail-supervisor',
        jobCode: 'OPS-JP-04',
        jobTitle: 'Retail Supervisor',
        entityName: 'Kaysir Retail Services',
        orgUnitName: 'Retail Operations',
        family: CompanyJobFamily.operations,
        levelName: 'Supervisor',
        status: CompanyJobProfileStatus.needsReview,
        compensationBand: 'OPS-4',
        ownerName: 'Dewi Lestari',
        nextReviewDate: DateTime(2026, 5, 25),
        jobDescription: 'Leads outlet scheduling and coverage.',
        skillsSummary: 'Outlet operations, shift planning',
        linkedPolicy: 'Retail supervisor coverage',
      ),
    ],
    asOfDate: asOfDate,
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompanyWorkforcePlanPanel(
          plan: plan,
          onApprovePosition: _previewPositionAction,
          onCloseRecruiting: _previewPositionAction,
          onReviewCostCenter: _previewPositionAction,
        ),
      ),
    ),
  );
}

void _previewPositionAction(String id) {}
