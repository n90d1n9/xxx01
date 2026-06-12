import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_module_contribution_activation_summary.dart';

class ProductModuleContributionActivationStrip extends StatelessWidget {
  const ProductModuleContributionActivationStrip({
    super.key,
    required this.summaries,
  });

  final List<ProductModuleContributionActivationSummary> summaries;

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Module diagnostics',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            for (var index = 0; index < summaries.length; index += 1)
              _ModuleActivationLine(
                summary: summaries[index],
                showDivider: index != summaries.length - 1,
              ),
          ],
        ),
      ],
    );
  }
}

class _ModuleActivationLine extends StatelessWidget {
  const _ModuleActivationLine({
    required this.summary,
    required this.showDivider,
  });

  final ProductModuleContributionActivationSummary summary;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent =
        summary.isActive ? Colors.teal.shade700 : colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final titleBlock = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  summary.isActive
                      ? Icons.extension_rounded
                      : Icons.extension_off_rounded,
                  size: 19,
                  color: accent,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              summary.isActive
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${summary.reasonLabel} | ${summary.mixLabel}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
            final status = AppStatusPill(
              label: summary.statusLabel,
              color: accent,
              showDot: true,
              maxWidth: 104,
            );

            if (constraints.maxWidth < 620) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleBlock,
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      status,
                      AppStatusPill(
                        label: summary.hookCountLabel,
                        color: colorScheme.primary,
                        maxWidth: 104,
                      ),
                    ],
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: titleBlock),
                const SizedBox(width: 14),
                AppStatusPill(
                  label: summary.hookCountLabel,
                  color: colorScheme.primary,
                  maxWidth: 104,
                ),
                const SizedBox(width: 8),
                status,
              ],
            );
          },
        ),
        if (showDivider) ...[
          const SizedBox(height: 12),
          Divider(color: colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
