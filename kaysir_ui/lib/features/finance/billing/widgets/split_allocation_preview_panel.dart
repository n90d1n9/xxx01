import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_tenant_preferences.dart';
import '../models/split_allocation_plan.dart';
import '../utils/billing_formatters.dart';
import '../utils/billing_policy_presets.dart';
import '../utils/split_allocation_planner.dart';

/// Presents a policy-evaluated split billing allocation preview.
class BillingSplitAllocationPreviewPanel extends StatelessWidget {
  final BillingSplitAllocationPlan plan;
  final BillingTenantPreferences preferences;

  const BillingSplitAllocationPreviewPanel({
    super.key,
    required this.plan,
    this.preferences = const BillingTenantPreferences(),
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _SplitAllocationVisuals.fromPlan(plan);

    return Container(
      key: const ValueKey('billing-split-allocation-preview'),
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
                          'Split allocation',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        _SplitStatusPill(
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
          if (plan.lines.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final line in plan.lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AllocationLineTile(
                  line: line,
                  preferences: preferences,
                ),
              ),
          ],
          if (plan.blockerIssues.isNotEmpty) ...[
            const SizedBox(height: 10),
            _SplitIssueSummary(issues: plan.blockerIssues),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Split allocation preview panel')
Widget billingSplitAllocationPreviewPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SizedBox(
          width: 620,
          child: BillingSplitAllocationPreviewPanel(
            plan: planBillingSplitAllocation(
              config: constructionBillingPolicyConfig(),
              totalAmount: 1200,
              recipients: const [
                BillingSplitAllocationRecipient(
                  id: 'primary',
                  label: 'Primary payer',
                  share: 0.5,
                ),
                BillingSplitAllocationRecipient(
                  id: 'co-payer',
                  label: 'Co-payer',
                  share: 0.3,
                ),
                BillingSplitAllocationRecipient(
                  id: 'sponsor',
                  label: 'Sponsor',
                  share: 0.2,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _AllocationLineTile extends StatelessWidget {
  final BillingSplitAllocationLine line;
  final BillingTenantPreferences preferences;

  const _AllocationLineTile({required this.line, required this.preferences});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              line.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            line.shareLabel,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatBillingCurrency(line.amount, preferences: preferences),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitIssueSummary extends StatelessWidget {
  final List<BillingSplitAllocationIssue> issues;

  const _SplitIssueSummary({required this.issues});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final issue in issues)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFB45309),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    issue.message,
                    style: const TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SplitStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _SplitStatusPill({required this.label, required this.color});

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

class _SplitAllocationVisuals {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _SplitAllocationVisuals({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  factory _SplitAllocationVisuals.fromPlan(BillingSplitAllocationPlan plan) {
    if (!plan.isConfigured || plan.hasBlockers) {
      return const _SplitAllocationVisuals(
        icon: Icons.call_split_outlined,
        iconColor: Color(0xFFB45309),
        iconBackgroundColor: Color(0xFFFEF3C7),
        backgroundColor: Color(0xFFFFFBEB),
        borderColor: Color(0xFFFDE68A),
      );
    }

    return const _SplitAllocationVisuals(
      icon: Icons.account_tree_outlined,
      iconColor: Color(0xFF7C3AED),
      iconBackgroundColor: Color(0xFFF3E8FF),
      backgroundColor: Color(0xFFFAF5FF),
      borderColor: Color(0xFFE9D5FF),
    );
  }
}
