import 'package:flutter/material.dart';

import '../models/kitchen_handoff_verification.dart';

/// Receives verification changes for one handoff checklist step.
typedef KitchenHandoffVerificationStepChanged =
    void Function(String stepId, bool verified);

/// Displays actionable verification steps before a ready ticket is served.
class KitchenHandoffVerificationChecklist extends StatelessWidget {
  const KitchenHandoffVerificationChecklist({
    super.key,
    required this.plan,
    this.onStepChanged,
  });

  final KitchenHandoffVerificationPlan plan;
  final KitchenHandoffVerificationStepChanged? onStepChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .72),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .48)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  plan.isComplete
                      ? Icons.verified_outlined
                      : Icons.fact_check_outlined,
                  size: 18,
                  color: plan.isComplete ? colors.primary : colors.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Handoff checks',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  plan.progressLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (plan.steps.isEmpty)
              Text(
                plan.statusLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              for (final entry in plan.steps.asMap().entries) ...[
                _HandoffVerificationStepRow(
                  step: entry.value,
                  verified: plan.isVerified(entry.value.id),
                  verificationRecord: plan.recordFor(entry.value.id),
                  onChanged: onStepChanged,
                ),
                if (entry.key != plan.steps.length - 1)
                  Divider(
                    height: 14,
                    color: colors.outlineVariant.withValues(alpha: .5),
                  ),
              ],
          ],
        ),
      ),
    );
  }
}

/// One checkbox row for a handoff verification step.
class _HandoffVerificationStepRow extends StatelessWidget {
  const _HandoffVerificationStepRow({
    required this.step,
    required this.verified,
    required this.verificationRecord,
    required this.onChanged,
  });

  final KitchenHandoffVerificationStep step;
  final bool verified;
  final KitchenHandoffVerificationRecord? verificationRecord;
  final KitchenHandoffVerificationStepChanged? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: Checkbox(
            value: verified,
            onChanged: onChanged == null
                ? null
                : (value) => onChanged!(step.id, value ?? false),
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                step.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (verified && verificationRecord != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 13,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        verificationRecord!.auditLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
