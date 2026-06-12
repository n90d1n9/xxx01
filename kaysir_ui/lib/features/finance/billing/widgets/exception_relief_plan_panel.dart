import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_exception_event.dart';
import '../models/exception_relief_plan.dart';
import '../utils/billing_formatters.dart';
import '../utils/billing_policy_presets.dart';
import '../utils/exception_relief_planner.dart';

/// Presents a configured billing exception relief plan and its blockers.
class BillingExceptionReliefPlanPanel extends StatelessWidget {
  final BillingExceptionReliefPlan plan;

  const BillingExceptionReliefPlanPanel({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final visuals = _ReliefVisuals.fromPlan(plan);

    return Container(
      key: ValueKey('billing-exception-relief-plan-${plan.kind.name}'),
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
                        Text(
                          '${plan.kind.label} relief plan',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        _ReliefStatusPill(
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
              _ReliefMetricChip(
                icon: Icons.receipt_long_outlined,
                label: 'Invoices',
                value: '${plan.affectedInvoiceCount}',
              ),
              _ReliefMetricChip(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Exposure',
                value: formatBillingCurrency(plan.openAmount),
              ),
              _ReliefMetricChip(
                icon: Icons.event_repeat_outlined,
                label: 'Window',
                value: '${plan.reliefDurationDays}d',
              ),
            ],
          ),
          if (plan.actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Column(
              children: [
                for (final action in plan.actions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ReliefActionTile(action: action),
                  ),
              ],
            ),
          ],
          if (plan.blockerIssues.isNotEmpty) ...[
            const SizedBox(height: 4),
            _ReliefIssueList(issues: plan.blockerIssues),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Exception relief plan panel')
Widget billingExceptionReliefPlanPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SizedBox(
          width: 660,
          child: BillingExceptionReliefPlanPanel(
            plan: planBillingExceptionRelief(
              config: constructionBillingPolicyConfig(),
              kind: BillingExceptionEventKind.forceMajeure,
              affectedInvoiceCount: 12,
              openAmount: 42600,
              reliefDurationDays: 21,
              evidenceCaptured: true,
            ),
          ),
        ),
      ),
    ),
  );
}

class _ReliefActionTile extends StatelessWidget {
  final BillingExceptionReliefAction action;

  const _ReliefActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final color =
        action.isBlocked
            ? const Color(0xFFB45309)
            : action.isGovernance && !action.completed
            ? const Color(0xFF7C3AED)
            : const Color(0xFF047857);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.16)),
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
                    _ReliefStatusPill(
                      label: action.statusLabel,
                      color: color,
                      compact: true,
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
                if (action.isBlocked) ...[
                  const SizedBox(height: 4),
                  Text(
                    action.capabilitySummaryLabel,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
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

class _ReliefIssueList extends StatelessWidget {
  final List<BillingExceptionReliefIssue> issues;

  const _ReliefIssueList({required this.issues});

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
          for (final issue in issues)
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
                      issue.message,
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

class _ReliefMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReliefMetricChip({
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

class _ReliefStatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool compact;

  const _ReliefStatusPill({
    required this.label,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ReliefVisuals {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _ReliefVisuals({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  factory _ReliefVisuals.fromPlan(BillingExceptionReliefPlan plan) {
    if (plan.needsCapability || plan.needsContext) {
      return const _ReliefVisuals(
        icon: Icons.lock_clock_outlined,
        iconColor: Color(0xFFB45309),
        iconBackgroundColor: Color(0xFFFEF3C7),
        backgroundColor: Color(0xFFFFFBEB),
        borderColor: Color(0xFFFDE68A),
      );
    }
    if (plan.needsGovernance) {
      return const _ReliefVisuals(
        icon: Icons.verified_user_outlined,
        iconColor: Color(0xFF7C3AED),
        iconBackgroundColor: Color(0xFFF3E8FF),
        backgroundColor: Color(0xFFFAF5FF),
        borderColor: Color(0xFFE9D5FF),
      );
    }

    return const _ReliefVisuals(
      icon: Icons.health_and_safety_outlined,
      iconColor: Color(0xFF047857),
      iconBackgroundColor: Color(0xFFD1FAE5),
      backgroundColor: Color(0xFFF0FDF4),
      borderColor: Color(0xFFBBF7D0),
    );
  }
}

IconData _iconForAction(BillingExceptionReliefActionKind kind) {
  return switch (kind) {
    BillingExceptionReliefActionKind.pauseDueDates =>
      Icons.pause_circle_outline_rounded,
    BillingExceptionReliefActionKind.suspendDunning =>
      Icons.notifications_paused_outlined,
    BillingExceptionReliefActionKind.waiveLateFees =>
      Icons.money_off_csred_outlined,
    BillingExceptionReliefActionKind.reschedulePayments =>
      Icons.event_repeat_outlined,
    BillingExceptionReliefActionKind.freezeIssuance => Icons.ac_unit_outlined,
    BillingExceptionReliefActionKind.captureEvidence =>
      Icons.attach_file_outlined,
    BillingExceptionReliefActionKind.requestApproval =>
      Icons.verified_user_outlined,
  };
}
