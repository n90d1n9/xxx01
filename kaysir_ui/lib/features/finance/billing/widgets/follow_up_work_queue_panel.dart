import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_exception_event.dart';
import '../models/follow_up_work_action_state.dart';
import '../models/follow_up_work_item.dart';
import '../utils/billing_policy_presets.dart';
import '../utils/exception_relief_planner.dart';
import '../utils/relief_application_packet_builder.dart';
import '../utils/relief_approval_guidance_resolver.dart';
import '../utils/relief_execution_plan_builder.dart';
import '../utils/relief_follow_up_work_items.dart';
import '../utils/relief_impact_analyzer.dart';
import '../utils/relief_monitoring_plan_builder.dart';

/// Builds the visible action label for a follow-up work item.
typedef BillingFollowUpWorkActionLabelBuilder =
    String Function(BillingFollowUpWorkItem item);

/// Reusable queue panel for billing follow-up work across business domains.
class BillingFollowUpWorkQueuePanel extends StatelessWidget {
  final BillingFollowUpWorkQueue queue;
  final int maxVisibleItems;
  final ValueChanged<BillingFollowUpWorkItem>? onItemSelected;
  final BillingFollowUpWorkActionLabelBuilder? actionLabelBuilder;
  final BillingFollowUpWorkActionStateBuilder? actionStateBuilder;

  const BillingFollowUpWorkQueuePanel({
    super.key,
    required this.queue,
    this.maxVisibleItems = 4,
    this.onItemSelected,
    this.actionLabelBuilder,
    this.actionStateBuilder,
  }) : assert(maxVisibleItems > 0);

  @override
  Widget build(BuildContext context) {
    final visuals = _QueueVisuals.fromQueue(queue);
    final visibleItems = queue.items.take(maxVisibleItems).toList();
    final hiddenItemCount = queue.totalCount - visibleItems.length;

    return Container(
      key: const ValueKey('billing-follow-up-work-queue-panel'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: visuals.iconBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(visuals.icon, color: visuals.iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Follow-up queue',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        _QueuePill(
                          label: queue.sourceLabel,
                          color: visuals.iconColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      queue.summaryLabel,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QueueMetricChip(
                icon: Icons.playlist_add_check_circle_outlined,
                label: 'Ready',
                value: '${queue.readyCount}',
              ),
              _QueueMetricChip(
                icon: Icons.lock_outline_rounded,
                label: 'Blocked',
                value: '${queue.blockedCount}',
              ),
              _QueueMetricChip(
                icon: Icons.groups_2_outlined,
                label: 'Owners',
                value: '${queue.ownerCount}',
              ),
              _QueueMetricChip(
                icon: Icons.event_available_outlined,
                label: 'Window',
                value: '${queue.workWindowDays}d',
              ),
            ],
          ),
          if (queue.hasBlockers) ...[
            const SizedBox(height: 12),
            _QueueBlockerList(blockers: queue.blockers),
          ],
          const SizedBox(height: 12),
          if (queue.isEmpty)
            const _QueueEmptyState()
          else ...[
            _QueueItemGrid(
              items: visibleItems,
              onItemSelected: onItemSelected,
              actionLabelBuilder: actionLabelBuilder,
              actionStateBuilder: actionStateBuilder,
            ),
            if (hiddenItemCount > 0) ...[
              const SizedBox(height: 10),
              _QueueOverflowNote(hiddenItemCount: hiddenItemCount),
            ],
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Follow-up work queue panel')
Widget billingFollowUpWorkQueuePanelPreview() {
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

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SizedBox(
          width: 760,
          child: BillingFollowUpWorkQueuePanel(
            queue: buildReliefMonitoringFollowUpWorkQueue(plan: monitoringPlan),
          ),
        ),
      ),
    ),
  );
}

class _QueueItemGrid extends StatelessWidget {
  final List<BillingFollowUpWorkItem> items;
  final ValueChanged<BillingFollowUpWorkItem>? onItemSelected;
  final BillingFollowUpWorkActionLabelBuilder? actionLabelBuilder;
  final BillingFollowUpWorkActionStateBuilder? actionStateBuilder;

  const _QueueItemGrid({
    required this.items,
    this.onItemSelected,
    this.actionLabelBuilder,
    this.actionStateBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            constraints.maxWidth >= 720
                ? (constraints.maxWidth - 8) / 2
                : constraints.maxWidth;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _QueueItemTile(
                  item: item,
                  actionState: _actionStateFor(item),
                  onTap:
                      onItemSelected == null
                          ? null
                          : () => onItemSelected?.call(item),
                ),
              ),
          ],
        );
      },
    );
  }

  BillingFollowUpWorkActionState? _actionStateFor(
    BillingFollowUpWorkItem item,
  ) {
    final actionState = actionStateBuilder?.call(item)?.normalized();
    if (actionState != null) return actionState;

    return BillingFollowUpWorkActionState.fromLabel(
      actionLabelBuilder?.call(item),
    );
  }
}

class _QueueItemTile extends StatelessWidget {
  final BillingFollowUpWorkItem item;
  final BillingFollowUpWorkActionState? actionState;
  final VoidCallback? onTap;

  const _QueueItemTile({required this.item, this.actionState, this.onTap});

  @override
  Widget build(BuildContext context) {
    final visuals = _ItemVisuals.fromItem(item);

    return Material(
      color: visuals.surfaceColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 116),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: visuals.borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: visuals.badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(visuals.icon, color: visuals.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 7,
                      runSpacing: 5,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        _QueuePill(
                          label: item.status.label,
                          color: visuals.color,
                        ),
                        _QueuePill(
                          label: item.priority.label,
                          color: visuals.priorityColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.ownerRole,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _QueueMetaChip(label: item.dueLabel),
                        for (final tag in item.tags.take(3))
                          _QueueMetaChip(label: tag),
                        if (actionState != null)
                          _QueueActionChip(actionState: actionState!),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  actionState?.isEnabled == false
                      ? Icons.info_outline_rounded
                      : Icons.chevron_right_rounded,
                  color:
                      actionState?.isEnabled == false
                          ? const Color(0xFFB45309)
                          : const Color(0xFF94A3B8),
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueBlockerList extends StatelessWidget {
  final List<String> blockers;

  const _QueueBlockerList({required this.blockers});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final blocker in blockers)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFB45309),
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      blocker,
                      style: const TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 11,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QueueEmptyState extends StatelessWidget {
  const _QueueEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Text(
        'No follow-up work is queued right now.',
        style: TextStyle(
          color: Color(0xFF475569),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _QueueOverflowNote extends StatelessWidget {
  final int hiddenItemCount;

  const _QueueOverflowNote({required this.hiddenItemCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        '$hiddenItemCount more ${hiddenItemCount == 1 ? 'item' : 'items'} staged by due window.',
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _QueueMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _QueueMetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
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

class _QueueMetaChip extends StatelessWidget {
  final String label;

  const _QueueMetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _QueueActionChip extends StatelessWidget {
  final BillingFollowUpWorkActionState actionState;

  const _QueueActionChip({required this.actionState});

  @override
  Widget build(BuildContext context) {
    final isEnabled = actionState.isEnabled;
    final foregroundColor =
        isEnabled ? const Color(0xFF1D4ED8) : const Color(0xFFB45309);
    final backgroundColor =
        isEnabled ? const Color(0xFFEFF6FF) : const Color(0xFFFFFBEB);
    final borderColor =
        isEnabled ? const Color(0xFFBFDBFE) : const Color(0xFFFDE68A);
    final icon =
        isEnabled ? Icons.arrow_outward_rounded : Icons.lock_clock_outlined;
    final tooltipMessage =
        isEnabled
            ? actionState.label
            : actionState.disabledReason ?? 'Action is not available yet.';

    return Tooltip(
      message: tooltipMessage,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foregroundColor, size: 12),
            const SizedBox(width: 4),
            Text(
              actionState.label,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueuePill extends StatelessWidget {
  final String label;
  final Color color;

  const _QueuePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _QueueVisuals {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;

  const _QueueVisuals({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
  });

  factory _QueueVisuals.fromQueue(BillingFollowUpWorkQueue queue) {
    if (queue.blockedCount > 0) {
      return const _QueueVisuals(
        icon: Icons.lock_clock_outlined,
        iconColor: Color(0xFFB45309),
        iconBackgroundColor: Color(0xFFFEF3C7),
      );
    }
    if (queue.readyCount > 0) {
      return const _QueueVisuals(
        icon: Icons.playlist_add_check_circle_outlined,
        iconColor: Color(0xFF1D4ED8),
        iconBackgroundColor: Color(0xFFDBEAFE),
      );
    }
    return const _QueueVisuals(
      icon: Icons.pending_actions_outlined,
      iconColor: Color(0xFF047857),
      iconBackgroundColor: Color(0xFFD1FAE5),
    );
  }
}

class _ItemVisuals {
  final IconData icon;
  final Color color;
  final Color priorityColor;
  final Color badgeColor;
  final Color surfaceColor;
  final Color borderColor;

  const _ItemVisuals({
    required this.icon,
    required this.color,
    required this.priorityColor,
    required this.badgeColor,
    required this.surfaceColor,
    required this.borderColor,
  });

  factory _ItemVisuals.fromItem(BillingFollowUpWorkItem item) {
    final priorityColor = _priorityColor(item.priority);

    return switch (item.status) {
      BillingFollowUpWorkStatus.blocked => _ItemVisuals(
        icon: Icons.lock_outline_rounded,
        color: const Color(0xFFB45309),
        priorityColor: priorityColor,
        badgeColor: const Color(0xFFFEF3C7),
        surfaceColor: const Color(0xFFFFFBEB),
        borderColor: const Color(0xFFFDE68A),
      ),
      BillingFollowUpWorkStatus.ready => _ItemVisuals(
        icon: Icons.play_arrow_rounded,
        color: const Color(0xFF1D4ED8),
        priorityColor: priorityColor,
        badgeColor: const Color(0xFFDBEAFE),
        surfaceColor: const Color(0xFFF8FAFC),
        borderColor: const Color(0xFFBFDBFE),
      ),
      BillingFollowUpWorkStatus.scheduled => _ItemVisuals(
        icon: Icons.event_available_outlined,
        color: const Color(0xFF047857),
        priorityColor: priorityColor,
        badgeColor: const Color(0xFFD1FAE5),
        surfaceColor: const Color(0xFFF7FEFB),
        borderColor: const Color(0xFFA7F3D0),
      ),
      BillingFollowUpWorkStatus.optional => _ItemVisuals(
        icon: Icons.low_priority_rounded,
        color: const Color(0xFF64748B),
        priorityColor: priorityColor,
        badgeColor: const Color(0xFFF1F5F9),
        surfaceColor: const Color(0xFFF8FAFC),
        borderColor: const Color(0xFFE2E8F0),
      ),
    };
  }
}

Color _priorityColor(BillingFollowUpWorkPriority priority) {
  return switch (priority) {
    BillingFollowUpWorkPriority.urgent => const Color(0xFFBE123C),
    BillingFollowUpWorkPriority.high => const Color(0xFFB45309),
    BillingFollowUpWorkPriority.normal => const Color(0xFF2563EB),
    BillingFollowUpWorkPriority.low => const Color(0xFF64748B),
  };
}
