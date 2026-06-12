import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_exception_event.dart';
import '../models/relief_impact_summary.dart';
import '../utils/billing_formatters.dart';
import '../utils/billing_policy_presets.dart';
import '../utils/exception_relief_planner.dart';
import '../utils/relief_application_packet_builder.dart';
import '../utils/relief_impact_analyzer.dart';

/// Presents the business impact of an exception relief application packet.
class BillingExceptionReliefImpactSummaryPanel extends StatelessWidget {
  final BillingExceptionReliefImpactSummary summary;

  const BillingExceptionReliefImpactSummaryPanel({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _ImpactVisuals.fromSummary(summary);

    return Container(
      key: const ValueKey('billing-exception-relief-impact-summary'),
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
                          'Relief impact',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        _ImpactStatusPill(
                          label: summary.statusLabel,
                          color: visuals.iconColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      summary.summaryLabel,
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
              _ImpactMetricChip(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Deferred cash',
                value: formatBillingCurrency(summary.deferredCashAmount),
              ),
              _ImpactMetricChip(
                icon: Icons.trending_flat_outlined,
                label: 'Daily delay',
                value: formatBillingCurrency(
                  summary.estimatedDailyCashDeferral,
                ),
              ),
              _ImpactMetricChip(
                icon: Icons.radar_outlined,
                label: 'Signals',
                value: '${summary.signalCount}',
              ),
            ],
          ),
          if (summary.signals.isNotEmpty) ...[
            const SizedBox(height: 14),
            Column(
              children: [
                for (final signal in summary.signals)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ImpactSignalTile(signal: signal),
                  ),
              ],
            ),
          ],
          if (summary.blockers.isNotEmpty) ...[
            const SizedBox(height: 4),
            _ImpactBlockerList(blockers: summary.blockers),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Relief impact summary panel')
Widget billingExceptionReliefImpactSummaryPanelPreview() {
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

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SizedBox(
          width: 660,
          child: BillingExceptionReliefImpactSummaryPanel(
            summary: summarizeBillingExceptionReliefImpact(packet: packet),
          ),
        ),
      ),
    ),
  );
}

class _ImpactSignalTile extends StatelessWidget {
  final BillingExceptionReliefImpactSignal signal;

  const _ImpactSignalTile({required this.signal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _iconForSignal(signal.kind),
            color: const Color(0xFF0F766E),
            size: 18,
          ),
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
                    Text(
                      signal.label,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (signal.hasAmount)
                      Text(
                        formatBillingCurrency(signal.amount),
                        style: const TextStyle(
                          color: Color(0xFF0F766E),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  signal.description,
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

class _ImpactBlockerList extends StatelessWidget {
  final List<String> blockers;

  const _ImpactBlockerList({required this.blockers});

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

class _ImpactMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ImpactMetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
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

class _ImpactStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _ImpactStatusPill({required this.label, required this.color});

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

class _ImpactVisuals {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _ImpactVisuals({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  factory _ImpactVisuals.fromSummary(
    BillingExceptionReliefImpactSummary summary,
  ) {
    return switch (summary.riskLevel) {
      BillingExceptionReliefImpactRiskLevel.blocked => const _ImpactVisuals(
        icon: Icons.lock_outline_rounded,
        iconColor: Color(0xFFB45309),
        iconBackgroundColor: Color(0xFFFEF3C7),
        backgroundColor: Color(0xFFFFFBEB),
        borderColor: Color(0xFFFDE68A),
      ),
      BillingExceptionReliefImpactRiskLevel.high => const _ImpactVisuals(
        icon: Icons.warning_amber_rounded,
        iconColor: Color(0xFFB45309),
        iconBackgroundColor: Color(0xFFFEF3C7),
        backgroundColor: Color(0xFFFFFBEB),
        borderColor: Color(0xFFFDE68A),
      ),
      BillingExceptionReliefImpactRiskLevel.medium => const _ImpactVisuals(
        icon: Icons.monitor_heart_outlined,
        iconColor: Color(0xFF7C3AED),
        iconBackgroundColor: Color(0xFFF3E8FF),
        backgroundColor: Color(0xFFFAF5FF),
        borderColor: Color(0xFFE9D5FF),
      ),
      BillingExceptionReliefImpactRiskLevel.low => const _ImpactVisuals(
        icon: Icons.insights_outlined,
        iconColor: Color(0xFF047857),
        iconBackgroundColor: Color(0xFFD1FAE5),
        backgroundColor: Color(0xFFF0FDF4),
        borderColor: Color(0xFFBBF7D0),
      ),
    };
  }
}

IconData _iconForSignal(BillingExceptionReliefImpactSignalKind kind) {
  return switch (kind) {
    BillingExceptionReliefImpactSignalKind.cashDeferral =>
      Icons.account_balance_wallet_outlined,
    BillingExceptionReliefImpactSignalKind.collectionHold =>
      Icons.notifications_paused_outlined,
    BillingExceptionReliefImpactSignalKind.lateFeeSuppression =>
      Icons.money_off_csred_outlined,
    BillingExceptionReliefImpactSignalKind.recoverySchedule =>
      Icons.event_repeat_outlined,
    BillingExceptionReliefImpactSignalKind.issuanceFreeze =>
      Icons.ac_unit_outlined,
  };
}
