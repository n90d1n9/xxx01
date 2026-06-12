import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../utils/billing_release_gate.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_domain_module_readiness_metric_strip.dart';

/// Shows aggregate launch readiness across billing route release gates.
class BillingReleaseGatePanel extends StatelessWidget {
  final BillingReleaseGateReport report;
  final int maxVisibleLanes;
  final ValueChanged<BillingReleaseGateLane>? onLaneSelected;
  final bool Function(BillingReleaseGateLane lane)? canSelectLane;

  const BillingReleaseGatePanel({
    super.key,
    required this.report,
    this.maxVisibleLanes = 4,
    this.onLaneSelected,
    this.canSelectLane,
  }) : assert(maxVisibleLanes > 0);

  @override
  Widget build(BuildContext context) {
    final visuals = _ReleaseGateVisuals.fromStatus(report.status);

    return BillingReadinessPanelScaffold(
      key: const ValueKey('billing-release-gate-panel'),
      title: 'Release gate',
      summary: report.summaryLabel,
      icon: visuals.icon,
      iconColor: visuals.color,
      iconBackgroundColor: visuals.backgroundColor,
      metrics: [
        BillingReadinessMetric(
          label: 'Lanes',
          value: report.laneCount.toString(),
          icon: Icons.view_week_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Ready',
          value: report.readyLanes.length.toString(),
          icon: Icons.verified_outlined,
          color: const Color(0xFF047857),
        ),
        BillingReadinessMetric(
          label: 'Blockers',
          value: report.blockerCount.toString(),
          icon: Icons.report_gmailerrorred_outlined,
          color: const Color(0xFFDC2626),
        ),
        BillingReadinessMetric(
          label: 'Warnings',
          value: report.warningCount.toString(),
          icon: Icons.info_outline_rounded,
          color: const Color(0xFFD97706),
        ),
        BillingReadinessMetric(
          label: 'Actions',
          value: report.actionCount.toString(),
          icon: Icons.playlist_add_check_rounded,
          color: const Color(0xFF7C3AED),
        ),
      ],
      child: _ReleaseGateLaneList(
        lanes: report.lanes,
        maxVisibleLanes: maxVisibleLanes,
        onLaneSelected: onLaneSelected,
        canSelectLane: canSelectLane ?? _releaseGateLaneAlwaysSelectable,
      ),
    );
  }
}

/// Lists release gate lanes with compact status and action indicators.
class _ReleaseGateLaneList extends StatelessWidget {
  final List<BillingReleaseGateLane> lanes;
  final int maxVisibleLanes;
  final ValueChanged<BillingReleaseGateLane>? onLaneSelected;
  final bool Function(BillingReleaseGateLane lane) canSelectLane;

  const _ReleaseGateLaneList({
    required this.lanes,
    required this.maxVisibleLanes,
    required this.canSelectLane,
    this.onLaneSelected,
  });

  @override
  Widget build(BuildContext context) {
    final visibleLanes = lanes.take(maxVisibleLanes).toList(growable: false);
    final hiddenCount = lanes.length - visibleLanes.length;

    return Column(
      key: const ValueKey('billing-release-gate-lanes'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final lane in visibleLanes) ...[
          _ReleaseGateLaneTile(
            lane: lane,
            canSelectLane: canSelectLane,
            onLaneSelected: onLaneSelected,
          ),
          if (lane != visibleLanes.last) const SizedBox(height: 10),
        ],
        if (hiddenCount > 0) ...[
          const SizedBox(height: 10),
          Text(
            '+$hiddenCount more ${_plural(hiddenCount, 'lane')} hidden',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}

/// Renders one lane in the release gate readiness checklist.
class _ReleaseGateLaneTile extends StatelessWidget {
  final BillingReleaseGateLane lane;
  final ValueChanged<BillingReleaseGateLane>? onLaneSelected;
  final bool Function(BillingReleaseGateLane lane) canSelectLane;

  const _ReleaseGateLaneTile({
    required this.lane,
    required this.canSelectLane,
    this.onLaneSelected,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _ReleaseGateVisuals.fromStatus(lane.status);
    final hasLaneAction = onLaneSelected != null && canSelectLane(lane);

    return Container(
      key: ValueKey('billing-release-gate-lane-${lane.id}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: visuals.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: visuals.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(visuals.icon, color: visuals.color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _ReleaseGateStatusPill(
                      label: _statusLabel(lane.status),
                      color: visuals.color,
                    ),
                    Text(
                      lane.title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  lane.summaryLabel,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ReleaseGateCountChip(
                      label: 'Blockers',
                      value: lane.blockerCount,
                      color: const Color(0xFFDC2626),
                    ),
                    _ReleaseGateCountChip(
                      label: 'Warnings',
                      value: lane.warningCount,
                      color: const Color(0xFFD97706),
                    ),
                    _ReleaseGateCountChip(
                      label: 'Actions',
                      value: lane.actionCount,
                      color: const Color(0xFF7C3AED),
                    ),
                  ],
                ),
                if (hasLaneAction) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: ValueKey(
                        'billing-release-gate-lane-action-${lane.id}',
                      ),
                      onPressed: () => onLaneSelected?.call(lane),
                      icon: Icon(_laneActionIcon(lane.status), size: 16),
                      label: Text(_laneActionLabel(lane.status)),
                      style: TextButton.styleFrom(
                        foregroundColor: visuals.color,
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small colored badge for a release gate lane status.
class _ReleaseGateStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _ReleaseGateStatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

/// Compact count marker used by each release gate lane row.
class _ReleaseGateCountChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ReleaseGateCountChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Visual tokens for a release gate aggregate or lane status.
class _ReleaseGateVisuals {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _ReleaseGateVisuals({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  factory _ReleaseGateVisuals.fromStatus(BillingReleaseGateStatus status) {
    return switch (status) {
      BillingReleaseGateStatus.ready => const _ReleaseGateVisuals(
        icon: Icons.verified_outlined,
        color: Color(0xFF047857),
        backgroundColor: Color(0xFFD1FAE5),
      ),
      BillingReleaseGateStatus.hardening => const _ReleaseGateVisuals(
        icon: Icons.rule_folder_outlined,
        color: Color(0xFFD97706),
        backgroundColor: Color(0xFFFEF3C7),
      ),
      BillingReleaseGateStatus.blocked => const _ReleaseGateVisuals(
        icon: Icons.error_outline_rounded,
        color: Color(0xFFDC2626),
        backgroundColor: Color(0xFFFEE2E2),
      ),
    };
  }
}

String _statusLabel(BillingReleaseGateStatus status) {
  return switch (status) {
    BillingReleaseGateStatus.ready => 'Ready',
    BillingReleaseGateStatus.hardening => 'Hardening',
    BillingReleaseGateStatus.blocked => 'Blocked',
  };
}

String _laneActionLabel(BillingReleaseGateStatus status) {
  return switch (status) {
    BillingReleaseGateStatus.ready => 'View details',
    BillingReleaseGateStatus.hardening => 'Review hardening',
    BillingReleaseGateStatus.blocked => 'Review blockers',
  };
}

IconData _laneActionIcon(BillingReleaseGateStatus status) {
  return switch (status) {
    BillingReleaseGateStatus.ready => Icons.arrow_forward_rounded,
    BillingReleaseGateStatus.hardening => Icons.rule_folder_outlined,
    BillingReleaseGateStatus.blocked => Icons.manage_search_outlined,
  };
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}

bool _releaseGateLaneAlwaysSelectable(BillingReleaseGateLane lane) {
  return true;
}

@Preview(name: 'Billing release gate panel')
Widget billingReleaseGatePanelPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: BillingReleaseGatePanel(
            report: BillingReleaseGateReport(
              lanes: const [
                BillingReleaseGateLane(
                  id: billingReleaseGateRouteContractLaneId,
                  title: 'Route contract',
                  status: BillingReleaseGateStatus.ready,
                  summaryLabel:
                      'Billing route contract is complete across 10 routes.',
                  blockerCount: 0,
                  warningCount: 0,
                  actionCount: 0,
                  priority: 100,
                ),
                BillingReleaseGateLane(
                  id: billingReleaseGateRouteExecutionLaneId,
                  title: 'Route execution',
                  status: BillingReleaseGateStatus.blocked,
                  summaryLabel:
                      'Billing route execution has 1 builder blocker.',
                  blockerCount: 1,
                  warningCount: 0,
                  actionCount: 1,
                  priority: 200,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
