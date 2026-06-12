import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_exception_event.dart';
import '../models/follow_up_work_action_state.dart';
import '../models/follow_up_work_item.dart';
import '../models/follow_up_work_queue_filter.dart';
import '../utils/billing_policy_presets.dart';
import '../utils/exception_relief_planner.dart';
import '../utils/follow_up_work_queue_registry.dart';
import '../utils/relief_application_packet_builder.dart';
import '../utils/relief_approval_guidance_resolver.dart';
import '../utils/relief_execution_plan_builder.dart';
import '../utils/relief_follow_up_work_items.dart';
import '../utils/relief_impact_analyzer.dart';
import '../utils/relief_monitoring_plan_builder.dart';
import 'follow_up_work_queue_filter_bar.dart';
import 'follow_up_work_queue_panel.dart';

/// Unified operational panel for billing follow-up work across sources.
class BillingWorkCenterPanel extends StatelessWidget {
  final BillingFollowUpWorkQueue queue;
  final int maxVisibleItems;
  final ValueChanged<BillingFollowUpWorkItem>? onItemSelected;
  final BillingFollowUpWorkActionLabelBuilder? actionLabelBuilder;
  final BillingFollowUpWorkActionStateBuilder? actionStateBuilder;
  final BillingFollowUpWorkQueueFilter filter;
  final ValueChanged<BillingFollowUpWorkStatus?>? onStatusFilterChanged;
  final ValueChanged<BillingFollowUpWorkSource?>? onSourceFilterChanged;
  final ValueChanged<String?>? onOwnerRoleFilterChanged;
  final VoidCallback? onResetFilters;

  const BillingWorkCenterPanel({
    super.key,
    required this.queue,
    this.maxVisibleItems = 6,
    this.onItemSelected,
    this.actionLabelBuilder,
    this.actionStateBuilder,
    this.filter = const BillingFollowUpWorkQueueFilter(),
    this.onStatusFilterChanged,
    this.onSourceFilterChanged,
    this.onOwnerRoleFilterChanged,
    this.onResetFilters,
  }) : assert(maxVisibleItems > 0);

  @override
  Widget build(BuildContext context) {
    final filteredQueue = filter.applyTo(queue);
    final canFilter =
        queue.isNotEmpty &&
        (onStatusFilterChanged != null ||
            onSourceFilterChanged != null ||
            onOwnerRoleFilterChanged != null);
    final sources =
        queue.items.map((item) => item.source).toSet().toList()
          ..sort((a, b) => a.label.compareTo(b.label));

    return Column(
      key: const ValueKey('billing-work-center-panel'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.space_dashboard_outlined,
                color: Color(0xFF1D4ED8),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Billing work center',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    queue.summaryLabel,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _WorkCenterMetricChip(
              icon: Icons.playlist_add_check_circle_outlined,
              label: 'Ready',
              value: '${queue.readyCount}',
            ),
            _WorkCenterMetricChip(
              icon: Icons.lock_outline_rounded,
              label: 'Blocked',
              value: '${queue.blockedCount}',
            ),
            _WorkCenterMetricChip(
              icon: Icons.hub_outlined,
              label: 'Sources',
              value: '${queue.sourceCount}',
            ),
            _WorkCenterMetricChip(
              icon: Icons.groups_2_outlined,
              label: 'Owners',
              value: '${queue.ownerCount}',
            ),
          ],
        ),
        if (sources.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final source in sources)
                _WorkCenterSourceChip(label: source.label),
            ],
          ),
        ],
        if (canFilter) ...[
          const SizedBox(height: 12),
          BillingFollowUpWorkQueueFilterBar(
            queue: queue,
            filter: filter,
            onStatusChanged: onStatusFilterChanged,
            onSourceChanged: onSourceFilterChanged,
            onOwnerRoleChanged: onOwnerRoleFilterChanged,
            onReset: onResetFilters,
          ),
        ],
        const SizedBox(height: 14),
        BillingFollowUpWorkQueuePanel(
          queue: filteredQueue,
          maxVisibleItems: maxVisibleItems,
          onItemSelected: onItemSelected,
          actionLabelBuilder: actionLabelBuilder,
          actionStateBuilder: actionStateBuilder,
        ),
      ],
    );
  }
}

@Preview(name: 'Billing work center panel')
Widget billingWorkCenterPanelPreview() {
  final reliefPlan = planBillingExceptionRelief(
    config: constructionBillingPolicyConfig(),
    kind: BillingExceptionEventKind.forceMajeure,
    affectedInvoiceCount: 12,
    openAmount: 42600,
    reliefDurationDays: 21,
    approvalGranted: true,
    evidenceCaptured: true,
  );
  final packet = buildBillingExceptionReliefApplicationPacket(
    plan: reliefPlan,
    requestedBy: 'Ops lead',
    requestedAt: DateTime.utc(2026, 1, 15, 9),
  );
  final summary = summarizeBillingExceptionReliefImpact(packet: packet);
  final guidance = resolveBillingExceptionReliefApprovalGuidance(
    summary: summary,
  );
  final executionPlan = buildBillingExceptionReliefExecutionPlan(
    guidance: guidance,
  );
  final monitoringPlan = buildBillingExceptionReliefMonitoringPlan(
    executionPlan: executionPlan,
  );
  final registry = BillingFollowUpWorkQueueRegistry(
    adapters: [
      BillingFollowUpWorkQueueSourceAdapter(
        id: 'relief-monitoring',
        label: 'Relief monitoring',
        buildQueue:
            () => buildReliefMonitoringFollowUpWorkQueue(plan: monitoringPlan),
      ),
    ],
  );

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: SizedBox(
            width: 820,
            child: BillingWorkCenterPanel(queue: registry.buildQueue()),
          ),
        ),
      ),
    ),
  );
}

class _WorkCenterMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WorkCenterMetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF475569), size: 15),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkCenterSourceChip extends StatelessWidget {
  final String label;

  const _WorkCenterSourceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
