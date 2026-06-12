import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_impact_estimate.dart';

class DashboardActionImpactPreview extends StatelessWidget {
  final DashboardActionImpactEstimate impact;

  const DashboardActionImpactPreview({super.key, required this.impact});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_outlined,
                color: HrisColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Impact preview',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: impact.timeframe,
                color: HrisColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            impact.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ImpactValue(
                  label: impact.currentLabel,
                  value: impact.currentValue,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_rounded,
                color: HrisColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ImpactValue(
                  label: impact.targetLabel,
                  value: impact.targetValue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            impact.description,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

class _ImpactValue extends StatelessWidget {
  final String label;
  final String value;

  const _ImpactValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
