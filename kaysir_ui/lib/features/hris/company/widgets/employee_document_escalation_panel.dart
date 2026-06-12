import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/employee_document_escalation_filter.dart';
import '../models/employee_document_escalation_plan.dart';
import 'employee_document_escalation_filter_bar.dart';

/// Shows ranked employee document owner lanes that need HR escalation.
class EmployeeDocumentEscalationPanel extends StatefulWidget {
  final List<EmployeeDocumentEscalationPlan> plans;
  final ValueChanged<String> onEscalateOwner;
  final ValueChanged<List<String>> onEscalateOwners;

  const EmployeeDocumentEscalationPanel({
    super.key,
    required this.plans,
    required this.onEscalateOwner,
    required this.onEscalateOwners,
  });

  @override
  State<EmployeeDocumentEscalationPanel> createState() =>
      _EmployeeDocumentEscalationPanelState();
}

class _EmployeeDocumentEscalationPanelState
    extends State<EmployeeDocumentEscalationPanel> {
  EmployeeDocumentEscalationFilter _filter =
      EmployeeDocumentEscalationFilter.all;

  @override
  Widget build(BuildContext context) {
    final filteredPlans = filterEmployeeDocumentEscalationPlans(
      plans: widget.plans,
      filter: _filter,
    );
    final readyPlans =
        filteredPlans.where((plan) => !plan.escalationCoolingDown).toList();
    final criticalCount =
        widget.plans
            .where(
              (plan) =>
                  plan.priority == EmployeeDocumentEscalationPriority.critical,
            )
            .length;
    final digestDueCount = widget.plans.where((plan) => plan.digestDue).length;
    final coolingDownCount = filteredPlans.length - readyPlans.length;
    final filterCounts = countEmployeeDocumentEscalationFilters(widget.plans);

    return HrisSectionPanel(
      icon: Icons.priority_high_outlined,
      title: 'Owner Escalations',
      subtitle:
          widget.plans.isEmpty
              ? 'No blocked employee document owner lanes'
              : '$criticalCount critical lanes, $digestDueCount digests due',
      emptyMessage: 'No employee document owner escalations',
      children:
          widget.plans.isEmpty
              ? const []
              : [
                EmployeeDocumentEscalationFilterBar(
                  selectedFilter: _filter,
                  counts: filterCounts,
                  visibleCount: filteredPlans.length,
                  totalCount: widget.plans.length,
                  onFilterChanged: (filter) {
                    setState(() {
                      _filter = filter;
                    });
                  },
                ),
                _EscalationSummaryStrip(plans: filteredPlans),
                _EscalationBatchTile(
                  totalCount: filteredPlans.length,
                  readyCount: readyPlans.length,
                  coolingDownCount: coolingDownCount,
                  onEscalateReady:
                      readyPlans.isEmpty
                          ? null
                          : () => widget.onEscalateOwners([
                            for (final plan in readyPlans) plan.ownerName,
                          ]),
                ),
                if (filteredPlans.isEmpty)
                  HrisEmptyState(
                    message: 'No escalation lanes match ${_filter.label}',
                  )
                else
                  for (final plan in filteredPlans)
                    _EscalationPlanTile(
                      plan: plan,
                      onEscalateOwner:
                          () => widget.onEscalateOwner(plan.ownerName),
                    ),
              ],
    );
  }
}

/// Batch action row for owner escalations that are not in cooldown.
class _EscalationBatchTile extends StatelessWidget {
  final int totalCount;
  final int readyCount;
  final int coolingDownCount;
  final VoidCallback? onEscalateReady;

  const _EscalationBatchTile({
    required this.totalCount,
    required this.readyCount,
    required this.coolingDownCount,
    required this.onEscalateReady,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = readyCount == 0 ? Colors.green : Colors.red;
    final statusLabel = readyCount == 0 ? 'All reviewed' : '$readyCount ready';

    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final summary = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notification_important_outlined,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escalation dispatch',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$readyCount ready of $totalCount owner lanes'
                      '${coolingDownCount == 0 ? '' : ', $coolingDownCount cooling down'}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: statusLabel, color: statusColor),
            ],
          );
          final action = FilledButton.icon(
            onPressed: onEscalateReady,
            icon: const Icon(Icons.priority_high_outlined),
            label: const Text('Escalate ready lanes'),
          );

          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: action),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: summary),
              const SizedBox(width: 12),
              action,
            ],
          );
        },
      ),
    );
  }
}

/// Summary metrics for the current escalation plan list.
class _EscalationSummaryStrip extends StatelessWidget {
  final List<EmployeeDocumentEscalationPlan> plans;

  const _EscalationSummaryStrip({required this.plans});

  @override
  Widget build(BuildContext context) {
    final missingCount = plans.fold<int>(
      0,
      (total, plan) => total + plan.missingDocumentCount,
    );
    final openRequestCount = plans.fold<int>(
      0,
      (total, plan) => total + plan.openRequestCount,
    );
    final criticalCount =
        plans
            .where(
              (plan) =>
                  plan.priority == EmployeeDocumentEscalationPriority.critical,
            )
            .length;

    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Owners', value: '${plans.length}'),
        HrisMetricStripItem(label: 'Critical', value: '$criticalCount'),
        HrisMetricStripItem(label: 'Missing', value: '$missingCount'),
        HrisMetricStripItem(label: 'Requests', value: '$openRequestCount'),
      ],
    );
  }
}

/// Displays one employee document owner escalation recommendation.
class _EscalationPlanTile extends StatelessWidget {
  final EmployeeDocumentEscalationPlan plan;
  final VoidCallback onEscalateOwner;

  const _EscalationPlanTile({
    required this.plan,
    required this.onEscalateOwner,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(plan.priority);

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
                      plan.ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.entitySummary} - ${plan.primaryEmployeeLabel}',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  HrisStatusPill(
                    label: plan.priority.label,
                    color: priorityColor,
                  ),
                  const SizedBox(height: 6),
                  HrisStatusPill(
                    label: plan.digestDue ? 'Digest due' : 'Digest fresh',
                    color: plan.digestDue ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(height: 6),
                  HrisStatusPill(
                    label: plan.escalationFreshnessLabel,
                    color:
                        plan.escalationCoolingDown
                            ? Colors.green
                            : Colors.blueGrey,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Gaps', value: '${plan.gapCount}'),
              HrisMetricStripItem(
                label: 'Missing',
                value: '${plan.missingDocumentCount}',
              ),
              HrisMetricStripItem(
                label: 'Requests',
                value: '${plan.openRequestCount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Risk',
                value: '${plan.criticalCount + plan.highCount}',
              ),
              HrisMetricStripItem(
                label: 'Due risk',
                value: '${plan.overdueCount + plan.dueSoonCount}',
              ),
              HrisMetricStripItem(
                label: 'Digest',
                value: plan.digestCadenceLabel,
              ),
              HrisMetricStripItem(
                label: 'Escalations',
                value: '${plan.escalationCount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final action = FilledButton.icon(
                key: Key('employee-escalate-owner-${plan.ownerName}'),
                onPressed: plan.escalationCoolingDown ? null : onEscalateOwner,
                icon: const Icon(Icons.priority_high_outlined),
                label: Text(
                  plan.escalationCoolingDown
                      ? 'Escalated today'
                      : 'Escalate owner',
                ),
              );
              final summary = _EscalationRationale(
                plan: plan,
                priorityColor: priorityColor,
              );

              if (constraints.maxWidth < 560) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [summary, const SizedBox(height: 12), action],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: summary),
                  const SizedBox(width: 12),
                  action,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Context block that explains why the owner lane is escalated.
class _EscalationRationale extends StatelessWidget {
  final EmployeeDocumentEscalationPlan plan;
  final Color priorityColor;

  const _EscalationRationale({required this.plan, required this.priorityColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: priorityColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: priorityColor.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.report_problem_outlined, color: priorityColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${plan.rationale} ${plan.digestFreshnessLabel}.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _priorityColor(EmployeeDocumentEscalationPriority priority) {
  switch (priority) {
    case EmployeeDocumentEscalationPriority.critical:
      return Colors.red;
    case EmployeeDocumentEscalationPriority.high:
      return Colors.orange;
    case EmployeeDocumentEscalationPriority.watchlist:
      return Colors.blueGrey;
  }
}

@Preview(name: 'Employee document escalation panel')
Widget employeeDocumentEscalationPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: EmployeeDocumentEscalationPanel(
          plans: const [
            EmployeeDocumentEscalationPlan(
              ownerName: 'Fajar Prakoso',
              entitySummary: 'PT Kaysir Nusantara',
              priority: EmployeeDocumentEscalationPriority.critical,
              workloadScore: 186,
              gapCount: 2,
              criticalCount: 1,
              highCount: 1,
              overdueCount: 1,
              dueSoonCount: 1,
              missingDocumentCount: 9,
              openRequestCount: 2,
              actionLabel: 'Review rejected evidence',
              primaryEmployeeName: 'David Kim',
              digestFreshnessLabel: 'Digest due',
              digestCadenceLabel: 'Daily',
              digestDue: true,
              escalationFreshnessLabel: 'Escalated today',
              lastEscalationAuditEventId: 'audit-escalation-preview',
              escalationCount: 1,
              escalationCoolingDown: true,
              rationale:
                  '1 critical and 1 overdue document gap need owner escalation.',
            ),
            EmployeeDocumentEscalationPlan(
              ownerName: 'People Operations',
              entitySummary: '2 entities',
              priority: EmployeeDocumentEscalationPriority.high,
              workloadScore: 72,
              gapCount: 1,
              criticalCount: 0,
              highCount: 1,
              overdueCount: 0,
              dueSoonCount: 1,
              missingDocumentCount: 4,
              openRequestCount: 1,
              actionLabel: 'Generate request',
              primaryEmployeeName: 'Alya Rahman',
              digestFreshnessLabel: 'Due tomorrow',
              digestCadenceLabel: 'Every 3d',
              digestDue: false,
              rationale: '1 high-risk document gap needs owner follow-up.',
            ),
          ],
          onEscalateOwner: _previewEscalateOwner,
          onEscalateOwners: _previewEscalateOwners,
        ),
      ),
    ),
  );
}

void _previewEscalateOwner(String ownerName) {}

void _previewEscalateOwners(List<String> ownerNames) {}
