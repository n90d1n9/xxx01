import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_surface.dart';
import '../models/product_module_contribution_registry_diagnostic_detail.dart';

/// Numbered remediation checklist for product module registry diagnostics.
class ProductModuleContributionRegistryNextActionList extends StatelessWidget {
  const ProductModuleContributionRegistryNextActionList({
    super.key,
    required this.actions,
    required this.accentColor,
  });

  final List<ProductModuleContributionRegistryDiagnosticAction> actions;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return AppSurface(
      padding: const EdgeInsets.all(12),
      backgroundColor: Color.alphaBlend(
        accentColor.withValues(alpha: 0.07),
        colorScheme.surface,
      ),
      borderColor: accentColor.withValues(alpha: 0.22),
      child: Column(
        children: [
          for (var index = 0; index < actions.length; index += 1)
            _DiagnosticNextActionTile(
              action: actions[index],
              index: index,
              accentColor: accentColor,
              showDivider: index != actions.length - 1,
            ),
        ],
      ),
    );
  }
}

@Preview(name: 'Product module registry next action list')
Widget productModuleContributionRegistryNextActionListPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ProductModuleContributionRegistryNextActionList(
            accentColor: Colors.amber.shade800,
            actions: const [
              ProductModuleContributionRegistryDiagnosticAction(
                title: 'Choose the owning module',
                description:
                    'Keep the shared hook on the module that should own this '
                    'behavior.',
              ),
              ProductModuleContributionRegistryDiagnosticAction(
                title: 'Rename duplicate hooks',
                description:
                    'Give the remaining hooks unique ids scoped to their '
                    'module or workflow.',
              ),
              ProductModuleContributionRegistryDiagnosticAction(
                title: 'Retest the active pack',
                description:
                    'Refresh the management pack and confirm registry '
                    'diagnostics are clear.',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Single remediation action row shown in the registry action list.
class _DiagnosticNextActionTile extends StatelessWidget {
  const _DiagnosticNextActionTile({
    required this.action,
    required this.index,
    required this.accentColor,
    required this.showDivider,
  });

  final ProductModuleContributionRegistryDiagnosticAction action;
  final int index;
  final Color accentColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.13),
                border: Border.all(color: accentColor.withValues(alpha: 0.42)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    action.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      height: 1.28,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 10),
          Divider(color: colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
