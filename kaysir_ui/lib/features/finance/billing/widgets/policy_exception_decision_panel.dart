import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_exception_event.dart';
import '../models/policy_exception_plan.dart';
import '../utils/billing_policy_presets.dart';
import '../utils/policy_exception_planner.dart';

/// Presents an evaluated exception policy decision for operators.
class BillingPolicyExceptionDecisionPanel extends StatelessWidget {
  final BillingPolicyExceptionPlan plan;

  const BillingPolicyExceptionDecisionPanel({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final visuals = _PolicyDecisionVisuals.fromPlan(plan);

    return Container(
      key: ValueKey('billing-policy-exception-plan-${plan.kind.name}'),
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
                          plan.kind.label,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        _DecisionStatusPill(
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
          if (plan.effectDecisions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final decision in plan.effectDecisions)
                  _EffectDecisionChip(decision: decision),
              ],
            ),
          ],
          if (plan.requiresApproval || plan.requiresEvidence) ...[
            const SizedBox(height: 12),
            _GovernanceLine(plan: plan),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Policy exception decision panel')
Widget billingPolicyExceptionDecisionPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SizedBox(
          width: 620,
          child: BillingPolicyExceptionDecisionPanel(
            plan: planBillingPolicyException(
              config: constructionBillingPolicyConfig(),
              kind: BillingExceptionEventKind.forceMajeure,
            ),
          ),
        ),
      ),
    ),
  );
}

class _EffectDecisionChip extends StatelessWidget {
  final BillingPolicyExceptionEffectDecision decision;

  const _EffectDecisionChip({required this.decision});

  @override
  Widget build(BuildContext context) {
    final color =
        decision.isAllowed ? const Color(0xFF047857) : const Color(0xFFB45309);
    final icon =
        decision.isAllowed
            ? Icons.check_circle_outline_rounded
            : Icons.lock_outline_rounded;

    return Tooltip(
      message: decision.summaryLabel,
      child: Container(
        key: ValueKey('billing-policy-effect-${decision.effect.name}'),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              decision.effect.label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GovernanceLine extends StatelessWidget {
  final BillingPolicyExceptionPlan plan;

  const _GovernanceLine({required this.plan});

  @override
  Widget build(BuildContext context) {
    final labels = [
      if (plan.requiresApproval) 'approval',
      if (plan.requiresEvidence) 'evidence',
    ];

    return Row(
      children: [
        const Icon(
          Icons.verified_user_outlined,
          color: Color(0xFF475569),
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Requires ${labels.join(' and ')} before relief is applied.',
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _DecisionStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _DecisionStatusPill({required this.label, required this.color});

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

class _PolicyDecisionVisuals {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _PolicyDecisionVisuals({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  factory _PolicyDecisionVisuals.fromPlan(BillingPolicyExceptionPlan plan) {
    if (!plan.isConfigured) {
      return const _PolicyDecisionVisuals(
        icon: Icons.help_outline_rounded,
        iconColor: Color(0xFF64748B),
        iconBackgroundColor: Color(0xFFE2E8F0),
        backgroundColor: Color(0xFFF8FAFC),
        borderColor: Color(0xFFE2E8F0),
      );
    }
    if (!plan.isActionable) {
      return const _PolicyDecisionVisuals(
        icon: Icons.lock_outline_rounded,
        iconColor: Color(0xFFB45309),
        iconBackgroundColor: Color(0xFFFEF3C7),
        backgroundColor: Color(0xFFFFFBEB),
        borderColor: Color(0xFFFDE68A),
      );
    }

    return const _PolicyDecisionVisuals(
      icon: Icons.task_alt_rounded,
      iconColor: Color(0xFF047857),
      iconBackgroundColor: Color(0xFFD1FAE5),
      backgroundColor: Color(0xFFF0FDF4),
      borderColor: Color(0xFFBBF7D0),
    );
  }
}
