import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/product_workspace_setup_plan.dart';
import '../models/product_workspace_setup_readiness.dart';
import 'workspace_preview_fixtures.dart';
import 'workspace_setup_readiness_visuals.dart';
import 'workspace_setup_requirement_visuals.dart';

/// Detailed requirement view for the selected product workspace setup area.
class ProductWorkspaceSetupPlanSectionDetails extends StatelessWidget {
  const ProductWorkspaceSetupPlanSectionDetails({
    super.key,
    required this.section,
    required this.onActionPressed,
    this.readiness,
  });

  final ProductWorkspaceSetupPlanSection section;
  final VoidCallback onActionPressed;
  final ProductWorkspaceSetupReadiness? readiness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = productWorkspaceSetupRequirementColor(
      colorScheme,
      section.type,
    );
    final effectiveReadiness =
        readiness ?? ProductWorkspaceSetupReadiness.empty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.05),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final heading = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      productWorkspaceSetupRequirementIcon(section.type),
                      color: accent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${section.title} details',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            section.detailLabel,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final action = AppActionButton(
                  label: section.primaryActionLabel,
                  icon: Icons.arrow_forward_rounded,
                  variant: AppActionButtonVariant.secondary,
                  compact: true,
                  onPressed: onActionPressed,
                );

                if (constraints.maxWidth < 700) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      heading,
                      const SizedBox(height: 10),
                      Align(alignment: Alignment.centerLeft, child: action),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: heading),
                    const SizedBox(width: 12),
                    action,
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (
                  var index = 0;
                  index < section.targetGroups.length;
                  index += 1
                ) ...[
                  _SetupPlanTargetGroupBlock(
                    group: section.targetGroups[index],
                    readiness: _readinessForPlanRequirements(
                      effectiveReadiness,
                      section.targetGroups[index].requirements,
                    ),
                    accent: accent,
                  ),
                  if (index != section.targetGroups.length - 1) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Product workspace setup details')
Widget workspaceSetupPlanSectionDetailsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductWorkspaceSetupPlanSectionDetails(
          section: previewProductWorkspaceSetupOverview.plan.primarySection!,
          readiness: previewProductWorkspaceSetupOverview.readiness,
          onActionPressed: () {},
        ),
      ),
    ),
  );
}

/// Requirement group for one setup target inside the selected setup area.
class _SetupPlanTargetGroupBlock extends StatelessWidget {
  const _SetupPlanTargetGroupBlock({
    required this.group,
    required this.readiness,
    required this.accent,
  });

  final ProductWorkspaceSetupPlanTargetGroup group;
  final ProductWorkspaceSetupReadiness readiness;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              group.targetTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            AppStatusPill(
              label: group.statusLabel,
              color: accent,
              showDot: true,
              maxWidth: 118,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            AppStatusPill(
              label: group.requirementCountLabel,
              color: colorScheme.secondary,
              icon: Icons.checklist_rounded,
              maxWidth: 122,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            if (readiness.isNotEmpty)
              AppStatusPill(
                label: readiness.statusLabel,
                color: productWorkspaceSetupReadinessColor(
                  colorScheme,
                  readiness,
                ),
                icon: productWorkspaceSetupReadinessIcon(readiness),
                maxWidth: 118,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            if (readiness.isNotEmpty &&
                readiness.progressLabel != readiness.statusLabel)
              AppStatusPill(
                label: readiness.progressLabel,
                color: colorScheme.secondary,
                icon: Icons.track_changes_rounded,
                maxWidth: 112,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (
              var index = 0;
              index < group.requirements.length;
              index += 1
            ) ...[
              _SetupPlanRequirementRow(
                requirement: group.requirements[index],
                evaluation: readiness.evaluationForRequirement(
                  targetId: group.requirements[index].targetId,
                  requirementId: group.requirements[index].requirement.id,
                ),
                accent: accent,
              ),
              if (index != group.requirements.length - 1)
                const SizedBox(height: 8),
            ],
          ],
        ),
      ],
    );
  }
}

/// Requirement row with readiness state and target context.
class _SetupPlanRequirementRow extends StatelessWidget {
  const _SetupPlanRequirementRow({
    required this.requirement,
    required this.evaluation,
    required this.accent,
  });

  final ProductWorkspaceSetupPlanRequirement requirement;
  final ProductWorkspaceSetupRequirementEvaluation? evaluation;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor =
        evaluation == null
            ? accent
            : productWorkspaceSetupRequirementStatusColor(
              colorScheme,
              evaluation!.status,
            );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          evaluation == null
              ? Icons.check_circle_outline_rounded
              : productWorkspaceSetupRequirementStatusIcon(evaluation!.status),
          color: statusColor,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                requirement.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                requirement.targetTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (evaluation != null) ...[
                const SizedBox(height: 2),
                Text(
                  evaluation!.reason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        AppStatusPill(
          label: evaluation?.statusLabel ?? requirement.typeLabel,
          color: statusColor,
          maxWidth: 104,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ],
    );
  }
}

ProductWorkspaceSetupReadiness _readinessForPlanRequirements(
  ProductWorkspaceSetupReadiness readiness,
  List<ProductWorkspaceSetupPlanRequirement> requirements,
) {
  if (readiness.isEmpty) return ProductWorkspaceSetupReadiness.empty;

  return ProductWorkspaceSetupReadiness.fromEvaluations([
    for (final requirement in requirements)
      if (readiness.evaluationForRequirement(
            targetId: requirement.targetId,
            requirementId: requirement.requirement.id,
          )
          case final evaluation?)
        evaluation,
  ]);
}
