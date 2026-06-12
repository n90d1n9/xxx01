import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_probation_plan.dart';
import 'company_status_styles.dart';

class CompanyProbationPlanRegistryPanel extends StatelessWidget {
  final List<CompanyProbationPlan> plans;
  final DateTime asOfDate;
  final ValueChanged<String> onActivate;
  final ValueChanged<String> onMarkReviewed;

  const CompanyProbationPlanRegistryPanel({
    super.key,
    required this.plans,
    required this.asOfDate,
    required this.onActivate,
    required this.onMarkReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final readyCount =
        plans.where((plan) => !plan.requiresAttention(asOfDate)).length;

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Probation Plan Registry',
      subtitle: '$readyCount ready of ${plans.length} plans',
      emptyMessage: 'No matching probation plans',
      children:
          plans
              .map(
                (plan) => _ProbationPlanTile(
                  plan: plan,
                  asOfDate: asOfDate,
                  onActivate: () => onActivate(plan.id),
                  onMarkReviewed: () => onMarkReviewed(plan.id),
                ),
              )
              .toList(),
    );
  }
}

class _ProbationPlanTile extends StatelessWidget {
  final CompanyProbationPlan plan;
  final DateTime asOfDate;
  final VoidCallback onActivate;
  final VoidCallback onMarkReviewed;

  const _ProbationPlanTile({
    required this.plan,
    required this.asOfDate,
    required this.onActivate,
    required this.onMarkReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final issues = plan.issues(asOfDate);
    final statusColor = companyProbationPlanStatusColor(plan.status);

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
                      plan.planName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.entityName} - ${plan.type.label}',
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
              HrisStatusPill(label: plan.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Job',
                value:
                    plan.jobProfileCode.trim().isEmpty
                        ? 'Missing'
                        : plan.jobProfileCode,
              ),
              HrisMetricStripItem(
                label: 'Checkpoints',
                value:
                    plan.checkpointCount <= 0
                        ? 'Missing'
                        : '${plan.checkpointCount}',
              ),
              HrisMetricStripItem(
                label: 'Cadence',
                value:
                    plan.reviewCadenceDays <= 0
                        ? 'Missing'
                        : '${plan.reviewCadenceDays}d',
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Owner',
                value:
                    plan.ownerName.trim().isEmpty ? 'Missing' : plan.ownerName,
              ),
              HrisMetricStripItem(
                label: 'Manager',
                value:
                    plan.managerRole.trim().isEmpty
                        ? 'Missing'
                        : plan.managerRole,
              ),
              HrisMetricStripItem(label: 'Review', value: _reviewLabel()),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            plan.onboardingPackName.trim().isEmpty
                ? 'Onboarding pack missing'
                : plan.onboardingPackName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.successCriteria.trim().isEmpty
                ? 'Success criteria missing'
                : plan.successCriteria,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              HrisStatusPill(
                label:
                    plan.firstReviewDueDays <= 0
                        ? 'First review missing'
                        : 'First ${plan.firstReviewDueDays}d',
                color: Colors.indigo,
              ),
              HrisStatusPill(
                label:
                    plan.finalDecisionDueDays <= 0
                        ? 'Decision missing'
                        : 'Decision ${plan.finalDecisionDueDays}d',
                color: Colors.blueGrey,
              ),
              HrisStatusPill(
                label:
                    plan.feedbackTemplate.trim().isEmpty
                        ? 'Feedback missing'
                        : 'Feedback template',
                color: Colors.teal,
              ),
            ],
          ),
          if (plan.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              plan.notes,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
          ],
          if (issues.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  issues
                      .map(
                        (issue) => HrisStatusPill(
                          label: issue.label,
                          color:
                              issue == CompanyProbationPlanIssue.reviewOverdue
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onMarkReviewed,
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Mark reviewed'),
                ),
                FilledButton.icon(
                  onPressed: onActivate,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Activate plan'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _reviewLabel() {
    final days = plan.daysUntilReview(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    final month = plan.nextReviewDate.month.toString().padLeft(2, '0');
    final day = plan.nextReviewDate.day.toString().padLeft(2, '0');
    return '${plan.nextReviewDate.year}-$month-$day (${days}d)';
  }
}
