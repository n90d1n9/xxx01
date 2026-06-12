import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_exception_event.dart';
import '../models/relief_monitoring_plan.dart';
import '../utils/billing_policy_presets.dart';
import '../utils/exception_relief_planner.dart';
import '../utils/relief_application_packet_builder.dart';
import '../utils/relief_approval_guidance_resolver.dart';
import '../utils/relief_execution_plan_builder.dart';
import '../utils/relief_impact_analyzer.dart';
import '../utils/relief_monitoring_plan_builder.dart';

/// Presents post-relief checkpoints for monitoring active exception relief.
class BillingExceptionReliefMonitoringPlanPanel extends StatelessWidget {
  final BillingExceptionReliefMonitoringPlan plan;

  const BillingExceptionReliefMonitoringPlanPanel({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _MonitoringVisuals.fromPlan(plan);

    return Container(
      key: const ValueKey('billing-exception-relief-monitoring-plan'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: visuals.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: visuals.borderColor),
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
                          'Monitoring plan',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        _MonitoringStatusPill(
                          label: plan.statusLabel,
                          color: visuals.iconColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      plan.summaryLabel,
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
              _MonitoringMetricChip(
                icon: Icons.event_available_outlined,
                label: 'Window',
                value: '${plan.monitoringWindowDays}d',
              ),
              _MonitoringMetricChip(
                icon: Icons.checklist_rtl_outlined,
                label: 'Checkpoints',
                value: '${plan.checkpointCount}',
              ),
              _MonitoringMetricChip(
                icon: Icons.lock_outline_rounded,
                label: 'Blocked',
                value: '${plan.blockedCheckpointCount}',
              ),
            ],
          ),
          if (plan.hasBlockers) ...[
            const SizedBox(height: 12),
            _MonitoringBlockerList(blockers: plan.blockers),
          ],
          if (plan.hasCheckpoints) ...[
            const SizedBox(height: 12),
            _MonitoringCheckpointGrid(checkpoints: plan.checkpoints),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Relief monitoring plan panel')
Widget billingExceptionReliefMonitoringPlanPanelPreview() {
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
  final impactSummary = summarizeBillingExceptionReliefImpact(packet: packet);
  final guidance = resolveBillingExceptionReliefApprovalGuidance(
    summary: impactSummary,
  );
  final executionPlan = buildBillingExceptionReliefExecutionPlan(
    guidance: guidance,
  );

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SizedBox(
          width: 760,
          child: BillingExceptionReliefMonitoringPlanPanel(
            plan: buildBillingExceptionReliefMonitoringPlan(
              executionPlan: executionPlan,
            ),
          ),
        ),
      ),
    ),
  );
}

class _MonitoringCheckpointGrid extends StatelessWidget {
  final List<BillingExceptionReliefMonitoringCheckpoint> checkpoints;

  const _MonitoringCheckpointGrid({required this.checkpoints});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            constraints.maxWidth >= 720
                ? (constraints.maxWidth - 8) / 2
                : constraints.maxWidth;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final checkpoint in checkpoints)
              SizedBox(
                width: cardWidth,
                child: _MonitoringCheckpointTile(checkpoint: checkpoint),
              ),
          ],
        );
      },
    );
  }
}

class _MonitoringCheckpointTile extends StatelessWidget {
  final BillingExceptionReliefMonitoringCheckpoint checkpoint;

  const _MonitoringCheckpointTile({required this.checkpoint});

  @override
  Widget build(BuildContext context) {
    final color =
        checkpoint.isBlocked
            ? const Color(0xFFB45309)
            : checkpoint.isRequired
            ? const Color(0xFF1D4ED8)
            : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconForCheckpoint(checkpoint.kind), color: color, size: 18),
          const SizedBox(width: 9),
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
                      checkpoint.label,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    _MonitoringStatusPill(
                      label: checkpoint.dueLabel,
                      color: const Color(0xFF64748B),
                    ),
                    _MonitoringStatusPill(
                      label: checkpoint.statusLabel,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  checkpoint.ownerRole,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  checkpoint.description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
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

class _MonitoringBlockerList extends StatelessWidget {
  final List<String> blockers;

  const _MonitoringBlockerList({required this.blockers});

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

class _MonitoringMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MonitoringMetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
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

class _MonitoringStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MonitoringStatusPill({required this.label, required this.color});

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

class _MonitoringVisuals {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _MonitoringVisuals({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  factory _MonitoringVisuals.fromPlan(
    BillingExceptionReliefMonitoringPlan plan,
  ) {
    return switch (plan.status) {
      BillingExceptionReliefMonitoringStatus.blocked =>
        const _MonitoringVisuals(
          icon: Icons.lock_outline_rounded,
          iconColor: Color(0xFFB45309),
          iconBackgroundColor: Color(0xFFFEF3C7),
          backgroundColor: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFDE68A),
        ),
      BillingExceptionReliefMonitoringStatus.escalationWatch =>
        const _MonitoringVisuals(
          icon: Icons.radar_outlined,
          iconColor: Color(0xFFB91C1C),
          iconBackgroundColor: Color(0xFFFEE2E2),
          backgroundColor: Color(0xFFFEF2F2),
          borderColor: Color(0xFFFECACA),
        ),
      BillingExceptionReliefMonitoringStatus.activeWatch =>
        const _MonitoringVisuals(
          icon: Icons.monitor_heart_outlined,
          iconColor: Color(0xFF1D4ED8),
          iconBackgroundColor: Color(0xFFDBEAFE),
          backgroundColor: Color(0xFFF8FAFC),
          borderColor: Color(0xFFBFDBFE),
        ),
      BillingExceptionReliefMonitoringStatus.standardWatch =>
        const _MonitoringVisuals(
          icon: Icons.task_alt_rounded,
          iconColor: Color(0xFF047857),
          iconBackgroundColor: Color(0xFFD1FAE5),
          backgroundColor: Color(0xFFF0FDF4),
          borderColor: Color(0xFFBBF7D0),
        ),
    };
  }
}

IconData _iconForCheckpoint(
  BillingExceptionReliefMonitoringCheckpointKind kind,
) {
  return switch (kind) {
    BillingExceptionReliefMonitoringCheckpointKind.unblock =>
      Icons.lock_open_outlined,
    BillingExceptionReliefMonitoringCheckpointKind.escalationReview =>
      Icons.priority_high_rounded,
    BillingExceptionReliefMonitoringCheckpointKind.executionStart =>
      Icons.playlist_add_check_circle_outlined,
    BillingExceptionReliefMonitoringCheckpointKind.cashForecastReview =>
      Icons.insights_outlined,
    BillingExceptionReliefMonitoringCheckpointKind.collectionsReview =>
      Icons.notifications_paused_outlined,
    BillingExceptionReliefMonitoringCheckpointKind.customerFollowUp =>
      Icons.campaign_outlined,
    BillingExceptionReliefMonitoringCheckpointKind.recoveryKickoff =>
      Icons.event_repeat_outlined,
    BillingExceptionReliefMonitoringCheckpointKind.feeWaiverReconciliation =>
      Icons.description_outlined,
    BillingExceptionReliefMonitoringCheckpointKind.reliefCloseout =>
      Icons.archive_outlined,
  };
}
