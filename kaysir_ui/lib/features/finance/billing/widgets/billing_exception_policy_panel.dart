import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_exception_event.dart';
import '../utils/billing_policy_presets.dart';

/// Presents exception-event billing policies and their configured effects.
class BillingExceptionPolicyPanel extends StatelessWidget {
  final List<BillingExceptionEventPolicy> policies;

  const BillingExceptionPolicyPanel({super.key, required this.policies});

  @override
  Widget build(BuildContext context) {
    if (policies.isEmpty) {
      return const _EmptyExceptionPolicy();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final policy in policies)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ExceptionPolicyTile(policy: policy),
          ),
      ],
    );
  }
}

@Preview(name: 'Billing exception policy panel')
Widget billingExceptionPolicyPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: BillingExceptionPolicyPanel(
          policies: agnosticBillingPolicyConfig().exceptionPolicies,
        ),
      ),
    ),
  );
}

class _ExceptionPolicyTile extends StatelessWidget {
  final BillingExceptionEventPolicy policy;

  const _ExceptionPolicyTile({required this.policy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.gpp_maybe_outlined,
                color: Color(0xFFB45309),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  policy.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            policy.description,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final effect in policy.effects)
                _ExceptionEffectChip(label: effect.label),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExceptionEffectChip extends StatelessWidget {
  final String label;

  const _ExceptionEffectChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 26),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF92400E),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _EmptyExceptionPolicy extends StatelessWidget {
  const _EmptyExceptionPolicy();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Text(
        'No exception-event policies are enabled for this billing profile.',
        style: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
