import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_policy_capability.dart';
import '../models/billing_policy_config.dart';
import '../utils/billing_policy_presets.dart';

/// Displays configurable billing policy capabilities grouped by concern.
class BillingPolicyCapabilityMatrix extends StatelessWidget {
  final List<BillingPolicyCapability> capabilities;
  final BillingPolicyConfig config;
  final void Function(BillingPolicyCapabilityId capabilityId, bool enabled)?
  onCapabilityChanged;

  const BillingPolicyCapabilityMatrix({
    super.key,
    required this.capabilities,
    required this.config,
    this.onCapabilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final groups = {
      for (final group in BillingPolicyCapabilityGroup.values)
        group: capabilities
            .where((capability) => capability.group == group)
            .toList(growable: false),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in groups.entries)
          if (entry.value.isNotEmpty) ...[
            _CapabilityGroupHeader(group: entry.key),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final capability in entry.value)
                  _CapabilityTile(
                    capability: capability,
                    enabled: config.isEnabled(capability.id),
                    onChanged:
                        onCapabilityChanged == null
                            ? null
                            : (enabled) =>
                                onCapabilityChanged!(capability.id, enabled),
                  ),
              ],
            ),
            const SizedBox(height: 14),
          ],
      ],
    );
  }
}

@Preview(name: 'Billing policy capability matrix')
Widget billingPolicyCapabilityMatrixPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: BillingPolicyCapabilityMatrix(
          capabilities: standardBillingPolicyCapabilities(),
          config: constructionBillingPolicyConfig(),
        ),
      ),
    ),
  );
}

class _CapabilityGroupHeader extends StatelessWidget {
  final BillingPolicyCapabilityGroup group;

  const _CapabilityGroupHeader({required this.group});

  @override
  Widget build(BuildContext context) {
    return Text(
      group.label,
      style: const TextStyle(
        color: Color(0xFF475569),
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _CapabilityTile extends StatelessWidget {
  final BillingPolicyCapability capability;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  const _CapabilityTile({
    required this.capability,
    required this.enabled,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final accent = enabled ? const Color(0xFF047857) : const Color(0xFF64748B);

    return Container(
      key: ValueKey('billing-policy-capability-${capability.id.name}'),
      width: 260,
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: enabled ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                enabled ? Icons.check_circle_outline : Icons.block_outlined,
                color: accent,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  capability.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Switch.adaptive(
                key: ValueKey(
                  'billing-policy-capability-toggle-${capability.id.name}',
                ),
                value: enabled,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            capability.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
