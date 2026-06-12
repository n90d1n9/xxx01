import 'package:flutter/material.dart';

import '../experiences/pos_data_trait.dart';
import '../experiences/pos_experience_manifest.dart';
import 'pos_ui.dart';

class POSExperienceManifestSummary extends StatelessWidget {
  final POSExperienceManifest manifest;

  const POSExperienceManifestSummary({super.key, required this.manifest});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: POSUiTokens.gap,
          runSpacing: POSUiTokens.gap,
          children: [
            _ManifestMetric(label: 'Product line', value: manifest.productLine),
            _ManifestMetric(label: 'Archetype', value: manifest.archetypeLabel),
            _ManifestMetric(
              label: 'Release',
              value: manifest.releaseStage.label,
            ),
          ],
        ),
        const SizedBox(height: POSUiTokens.gapLarge),
        _ManifestChipGroup(
          title: 'Form factors',
          values:
              manifest.supportedFormFactors
                  .map((formFactor) => formFactor.label)
                  .toList(),
        ),
        if (manifest.traits.isNotEmpty) ...[
          const SizedBox(height: POSUiTokens.gap),
          _ManifestChipGroup(title: 'Traits', values: manifest.traits),
        ],
        if (manifest.dataTraits.isNotEmpty) ...[
          const SizedBox(height: POSUiTokens.gap),
          _ManifestChipGroup(
            title: 'Data',
            values: POSDataTraits.labelsFor(manifest.dataTraits),
          ),
        ],
      ],
    );
  }
}

class _ManifestMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ManifestMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 148,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManifestChipGroup extends StatelessWidget {
  final String title;
  final List<String> values;

  const _ManifestChipGroup({required this.title, required this.values});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: POSUiTokens.gap,
          runSpacing: POSUiTokens.gap,
          children:
              values
                  .map(
                    (value) => Chip(
                      label: Text(value),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
