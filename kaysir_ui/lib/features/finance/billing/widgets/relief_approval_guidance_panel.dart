import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_exception_event.dart';
import '../models/relief_approval_guidance.dart';
import '../utils/billing_policy_presets.dart';
import '../utils/exception_relief_planner.dart';
import '../utils/relief_application_packet_builder.dart';
import '../utils/relief_approval_guidance_resolver.dart';
import '../utils/relief_impact_analyzer.dart';

/// Presents approval guidance and guardrails for exception relief.
class BillingExceptionReliefApprovalGuidancePanel extends StatelessWidget {
  final BillingExceptionReliefApprovalGuidance guidance;

  const BillingExceptionReliefApprovalGuidancePanel({
    super.key,
    required this.guidance,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _ApprovalGuidanceVisuals.fromDecision(guidance.decision);

    return Container(
      key: const ValueKey('billing-exception-relief-approval-guidance'),
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
                          'Approval guidance',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        _ApprovalStatusPill(
                          label: guidance.statusLabel,
                          color: visuals.iconColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      guidance.summaryLabel,
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
              _ApprovalMetricChip(
                icon: Icons.playlist_add_check_circle_outlined,
                label: 'Primary action',
                value: guidance.primaryActionLabel,
              ),
              _ApprovalMetricChip(
                icon: Icons.fact_check_outlined,
                label: 'Required controls',
                value: '${guidance.requiredActionCount}',
              ),
              _ApprovalMetricChip(
                icon: Icons.rule_outlined,
                label: 'Reasons',
                value: '${guidance.reasons.length}',
              ),
            ],
          ),
          if (guidance.hasReasons) ...[
            const SizedBox(height: 12),
            _ApprovalReasonList(reasons: guidance.reasons),
          ],
          if (guidance.hasActions) ...[
            const SizedBox(height: 12),
            _ApprovalActionGrid(actions: guidance.actions),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Relief approval guidance panel')
Widget billingExceptionReliefApprovalGuidancePanelPreview() {
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

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SizedBox(
          width: 680,
          child: BillingExceptionReliefApprovalGuidancePanel(
            guidance: resolveBillingExceptionReliefApprovalGuidance(
              summary: impactSummary,
            ),
          ),
        ),
      ),
    ),
  );
}

class _ApprovalActionGrid extends StatelessWidget {
  final List<BillingExceptionReliefApprovalAction> actions;

  const _ApprovalActionGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            constraints.maxWidth >= 620
                ? (constraints.maxWidth - 8) / 2
                : constraints.maxWidth;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final action in actions)
              SizedBox(
                width: itemWidth,
                child: _ApprovalActionTile(action: action),
              ),
          ],
        );
      },
    );
  }
}

class _ApprovalActionTile extends StatelessWidget {
  final BillingExceptionReliefApprovalAction action;

  const _ApprovalActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final color =
        action.isRequired ? const Color(0xFF1D4ED8) : const Color(0xFF64748B);

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
          Icon(_iconForAction(action.kind), color: color, size: 18),
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
                      action.label,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    _ApprovalStatusPill(
                      label: action.statusLabel,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  action.description,
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

class _ApprovalReasonList extends StatelessWidget {
  final List<String> reasons;

  const _ApprovalReasonList({required this.reasons});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final reason in reasons)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFF047857),
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        color: Color(0xFF475569),
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

class _ApprovalMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ApprovalMetricChip({
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

class _ApprovalStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _ApprovalStatusPill({required this.label, required this.color});

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

class _ApprovalGuidanceVisuals {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _ApprovalGuidanceVisuals({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  factory _ApprovalGuidanceVisuals.fromDecision(
    BillingExceptionReliefApprovalDecision decision,
  ) {
    return switch (decision) {
      BillingExceptionReliefApprovalDecision.blocked =>
        const _ApprovalGuidanceVisuals(
          icon: Icons.lock_outline_rounded,
          iconColor: Color(0xFFB45309),
          iconBackgroundColor: Color(0xFFFEF3C7),
          backgroundColor: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFDE68A),
        ),
      BillingExceptionReliefApprovalDecision.escalate =>
        const _ApprovalGuidanceVisuals(
          icon: Icons.priority_high_rounded,
          iconColor: Color(0xFFB91C1C),
          iconBackgroundColor: Color(0xFFFEE2E2),
          backgroundColor: Color(0xFFFEF2F2),
          borderColor: Color(0xFFFECACA),
        ),
      BillingExceptionReliefApprovalDecision.approveWithControls =>
        const _ApprovalGuidanceVisuals(
          icon: Icons.admin_panel_settings_outlined,
          iconColor: Color(0xFF1D4ED8),
          iconBackgroundColor: Color(0xFFDBEAFE),
          backgroundColor: Color(0xFFF8FAFC),
          borderColor: Color(0xFFBFDBFE),
        ),
      BillingExceptionReliefApprovalDecision.approve =>
        const _ApprovalGuidanceVisuals(
          icon: Icons.task_alt_rounded,
          iconColor: Color(0xFF047857),
          iconBackgroundColor: Color(0xFFD1FAE5),
          backgroundColor: Color(0xFFF0FDF4),
          borderColor: Color(0xFFBBF7D0),
        ),
    };
  }
}

IconData _iconForAction(BillingExceptionReliefApprovalActionKind kind) {
  return switch (kind) {
    BillingExceptionReliefApprovalActionKind.resolveBlockers =>
      Icons.lock_open_outlined,
    BillingExceptionReliefApprovalActionKind.financeOwnerSignOff =>
      Icons.verified_user_outlined,
    BillingExceptionReliefApprovalActionKind.updateCashForecast =>
      Icons.insights_outlined,
    BillingExceptionReliefApprovalActionKind.notifyCollections =>
      Icons.notifications_active_outlined,
    BillingExceptionReliefApprovalActionKind.prepareRecoverySchedule =>
      Icons.event_repeat_outlined,
    BillingExceptionReliefApprovalActionKind.documentFeeWaiver =>
      Icons.description_outlined,
    BillingExceptionReliefApprovalActionKind.reviewIssuanceFreeze =>
      Icons.ac_unit_outlined,
    BillingExceptionReliefApprovalActionKind.customerNotice =>
      Icons.campaign_outlined,
  };
}
