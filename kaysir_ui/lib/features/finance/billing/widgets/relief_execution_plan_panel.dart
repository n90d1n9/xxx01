import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_exception_event.dart';
import '../models/relief_execution_plan.dart';
import '../utils/billing_policy_presets.dart';
import '../utils/exception_relief_planner.dart';
import '../utils/relief_application_packet_builder.dart';
import '../utils/relief_approval_guidance_resolver.dart';
import '../utils/relief_execution_plan_builder.dart';
import '../utils/relief_impact_analyzer.dart';

/// Presents the ordered handoff for applying exception relief safely.
class BillingExceptionReliefExecutionPlanPanel extends StatelessWidget {
  final BillingExceptionReliefExecutionPlan plan;

  const BillingExceptionReliefExecutionPlanPanel({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _ExecutionVisuals.fromPlan(plan);

    return Container(
      key: const ValueKey('billing-exception-relief-execution-plan'),
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
                          'Execution handoff',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        _ExecutionStatusPill(
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
              _ExecutionMetricChip(
                icon: Icons.alt_route_outlined,
                label: 'Phases',
                value: '${plan.phaseCount}',
              ),
              _ExecutionMetricChip(
                icon: Icons.playlist_add_check_circle_outlined,
                label: 'Required steps',
                value: '${plan.requiredStepCount}',
              ),
              _ExecutionMetricChip(
                icon: Icons.lock_outline_rounded,
                label: 'Blocked',
                value: '${plan.blockedStepCount}',
              ),
            ],
          ),
          if (plan.hasBlockers) ...[
            const SizedBox(height: 12),
            _ExecutionBlockerList(blockers: plan.blockers),
          ],
          if (plan.hasSteps) ...[
            const SizedBox(height: 12),
            _ExecutionPhaseGrid(plan: plan),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Relief execution plan panel')
Widget billingExceptionReliefExecutionPlanPanelPreview() {
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

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SizedBox(
          width: 760,
          child: BillingExceptionReliefExecutionPlanPanel(
            plan: buildBillingExceptionReliefExecutionPlan(guidance: guidance),
          ),
        ),
      ),
    ),
  );
}

class _ExecutionPhaseGrid extends StatelessWidget {
  final BillingExceptionReliefExecutionPlan plan;

  const _ExecutionPhaseGrid({required this.plan});

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
            for (final phase in plan.phases)
              SizedBox(
                width: cardWidth,
                child: _ExecutionPhaseCard(
                  phase: phase,
                  steps: plan.stepsForPhase(phase),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ExecutionPhaseCard extends StatelessWidget {
  final BillingExceptionReliefExecutionPhase phase;
  final List<BillingExceptionReliefExecutionStep> steps;

  const _ExecutionPhaseCard({required this.phase, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _iconForPhase(phase),
                color: const Color(0xFF1D4ED8),
                size: 17,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  phase.label,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _ExecutionStatusPill(
                label: '${steps.length}',
                color: const Color(0xFF64748B),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final step in steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ExecutionStepTile(step: step),
            ),
        ],
      ),
    );
  }
}

class _ExecutionStepTile extends StatelessWidget {
  final BillingExceptionReliefExecutionStep step;

  const _ExecutionStepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    final color =
        step.isBlocked
            ? const Color(0xFFB45309)
            : step.isRequired
            ? const Color(0xFF1D4ED8)
            : const Color(0xFF64748B);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_iconForStep(step), color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    step.label,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  _ExecutionStatusPill(label: step.statusLabel, color: color),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                step.ownerRole,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                step.description,
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
    );
  }
}

class _ExecutionBlockerList extends StatelessWidget {
  final List<String> blockers;

  const _ExecutionBlockerList({required this.blockers});

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

class _ExecutionMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ExecutionMetricChip({
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

class _ExecutionStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _ExecutionStatusPill({required this.label, required this.color});

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

class _ExecutionVisuals {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _ExecutionVisuals({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  factory _ExecutionVisuals.fromPlan(BillingExceptionReliefExecutionPlan plan) {
    return switch (plan.status) {
      BillingExceptionReliefExecutionStatus.blocked => const _ExecutionVisuals(
        icon: Icons.lock_outline_rounded,
        iconColor: Color(0xFFB45309),
        iconBackgroundColor: Color(0xFFFEF3C7),
        backgroundColor: Color(0xFFFFFBEB),
        borderColor: Color(0xFFFDE68A),
      ),
      BillingExceptionReliefExecutionStatus.escalationRequired =>
        const _ExecutionVisuals(
          icon: Icons.priority_high_rounded,
          iconColor: Color(0xFFB91C1C),
          iconBackgroundColor: Color(0xFFFEE2E2),
          backgroundColor: Color(0xFFFEF2F2),
          borderColor: Color(0xFFFECACA),
        ),
      BillingExceptionReliefExecutionStatus.controlsRequired =>
        const _ExecutionVisuals(
          icon: Icons.account_tree_outlined,
          iconColor: Color(0xFF1D4ED8),
          iconBackgroundColor: Color(0xFFDBEAFE),
          backgroundColor: Color(0xFFF8FAFC),
          borderColor: Color(0xFFBFDBFE),
        ),
      BillingExceptionReliefExecutionStatus.ready => const _ExecutionVisuals(
        icon: Icons.task_alt_rounded,
        iconColor: Color(0xFF047857),
        iconBackgroundColor: Color(0xFFD1FAE5),
        backgroundColor: Color(0xFFF0FDF4),
        borderColor: Color(0xFFBBF7D0),
      ),
    };
  }
}

IconData _iconForPhase(BillingExceptionReliefExecutionPhase phase) {
  return switch (phase) {
    BillingExceptionReliefExecutionPhase.unblock => Icons.lock_open_outlined,
    BillingExceptionReliefExecutionPhase.approval =>
      Icons.verified_user_outlined,
    BillingExceptionReliefExecutionPhase.forecast => Icons.insights_outlined,
    BillingExceptionReliefExecutionPhase.collections =>
      Icons.notifications_active_outlined,
    BillingExceptionReliefExecutionPhase.recovery =>
      Icons.event_repeat_outlined,
    BillingExceptionReliefExecutionPhase.customer => Icons.campaign_outlined,
    BillingExceptionReliefExecutionPhase.application =>
      Icons.playlist_add_check_circle_outlined,
  };
}

IconData _iconForStep(BillingExceptionReliefExecutionStep step) {
  if (step.isBlocked) return Icons.lock_outline_rounded;
  return step.isRequired
      ? Icons.check_circle_outline_rounded
      : Icons.radio_button_unchecked_rounded;
}
