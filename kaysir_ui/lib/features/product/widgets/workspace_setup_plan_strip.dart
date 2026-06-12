import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/product_workspace_setup_plan.dart';
import 'workspace_preview_fixtures.dart';
import 'workspace_setup_requirement_visuals.dart';

/// Compact strip that groups setup requirements by operational area.
class ProductWorkspaceSetupPlanStrip extends StatelessWidget {
  const ProductWorkspaceSetupPlanStrip({
    super.key,
    required this.plan,
    this.onSectionSelected,
  });

  final ProductWorkspaceSetupPlan plan;
  final ValueChanged<ProductWorkspaceSetupPlanSection>? onSectionSelected;

  @override
  Widget build(BuildContext context) {
    if (plan.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppStatusPill(
              label: plan.summaryLabel,
              color: colorScheme.primary,
              icon: Icons.checklist_rounded,
              maxWidth: 220,
            ),
            AppStatusPill(
              label: plan.sectionCountLabel,
              color: colorScheme.secondary,
              icon: Icons.view_module_rounded,
              maxWidth: 104,
            ),
            AppStatusPill(
              label: plan.estimatedEffortLabel,
              color: colorScheme.tertiary,
              icon: Icons.timer_rounded,
              maxWidth: 104,
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final columnCount =
                constraints.maxWidth >= 820
                    ? 4
                    : constraints.maxWidth >= 560
                    ? 2
                    : 1;
            const gap = 8.0;
            final width =
                (constraints.maxWidth - (gap * (columnCount - 1))) /
                columnCount;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final section in plan.sections)
                  SizedBox(
                    width: width,
                    child: _SetupPlanSectionTile(
                      section: section,
                      onSelected: onSectionSelected,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

@Preview(name: 'Product workspace setup plan')
Widget workspaceSetupPlanStripPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductWorkspaceSetupPlanStrip(
          plan: previewProductWorkspaceSetupOverview.plan,
          onSectionSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Selectable setup area tile shown inside the setup plan strip.
class _SetupPlanSectionTile extends StatelessWidget {
  const _SetupPlanSectionTile({
    required this.section,
    required this.onSelected,
  });

  final ProductWorkspaceSetupPlanSection section;
  final ValueChanged<ProductWorkspaceSetupPlanSection>? onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = productWorkspaceSetupRequirementColor(
      colorScheme,
      section.type,
    );
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
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
                  productWorkspaceSetupRequirementIcon(section.type),
                  color: accent,
                  size: 18,
                ),
                const Spacer(),
                AppStatusPill(
                  label: section.requirementCountLabel,
                  color: accent,
                  maxWidth: 112,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              section.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              section.targetCountLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            AppStatusPill(
              label: section.primaryActionLabel,
              color: accent,
              icon:
                  onSelected == null
                      ? Icons.info_outline_rounded
                      : Icons.arrow_forward_rounded,
              maxWidth: 176,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ],
        ),
      ),
    );

    if (onSelected == null) return content;

    return Semantics(
      button: true,
      label: section.primaryActionLabel,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onSelected!(section),
        child: content,
      ),
    );
  }
}
