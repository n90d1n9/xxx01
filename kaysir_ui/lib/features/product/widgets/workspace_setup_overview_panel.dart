import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/product_workspace_setup_action.dart';
import '../models/product_workspace_setup_overview.dart';
import '../models/product_workspace_setup_plan.dart';
import '../models/product_workspace_setup_target.dart';
import 'workspace_setup_plan_section_details.dart';
import 'workspace_setup_plan_strip.dart';
import 'workspace_setup_readiness_visuals.dart';
import 'workspace_setup_requirement_chips.dart';
import 'workspace_preview_fixtures.dart';

/// Product workspace panel for setup targets, requirements, and route actions.
class ProductWorkspaceSetupOverviewPanel extends StatefulWidget {
  const ProductWorkspaceSetupOverviewPanel({
    super.key,
    required this.overview,
    required this.onActionSelected,
  });

  final ProductWorkspaceSetupOverview overview;
  final ValueChanged<ProductWorkspaceSetupPrompt> onActionSelected;

  @override
  State<ProductWorkspaceSetupOverviewPanel> createState() =>
      _ProductWorkspaceSetupOverviewPanelState();
}

/// Local state for the setup section currently expanded inside the overview.
class _ProductWorkspaceSetupOverviewPanelState
    extends State<ProductWorkspaceSetupOverviewPanel> {
  ProductWorkspaceSetupRequirementType? _focusedSectionType;

  @override
  Widget build(BuildContext context) {
    final overview = widget.overview;
    final focusedSection = _focusedSectionFor(overview);

    return AppContentPanel(
      title: 'Setup targets',
      subtitle: 'Pack-aware setup paths for product workflows',
      leadingIcon: Icons.rule_folder_rounded,
      trailing:
          overview.isEmpty ? null : _SetupOverviewPills(overview: overview),
      child:
          overview.isEmpty
              ? const AppEmptyState(
                title: 'No setup targets',
                message:
                    'Setup targets will appear when product modules publish them.',
                icon: Icons.rule_folder_rounded,
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (overview.plan.isNotEmpty) ...[
                    ProductWorkspaceSetupPlanStrip(
                      plan: overview.plan,
                      onSectionSelected: (section) {
                        setState(() => _focusedSectionType = section.type);
                      },
                    ),
                    if (focusedSection != null) ...[
                      const SizedBox(height: 12),
                      ProductWorkspaceSetupPlanSectionDetails(
                        section: focusedSection,
                        readiness: overview.readiness,
                        onActionPressed:
                            () => _openFocusedSection(focusedSection),
                      ),
                    ],
                    const Divider(height: 20),
                  ],
                  for (
                    var index = 0;
                    index < overview.prompts.length;
                    index += 1
                  ) ...[
                    _SetupTargetRow(
                      prompt: overview.prompts[index],
                      onSelected: widget.onActionSelected,
                    ),
                    if (index != overview.prompts.length - 1)
                      const Divider(height: 20),
                  ],
                ],
              ),
    );
  }

  ProductWorkspaceSetupPlanSection? _focusedSectionFor(
    ProductWorkspaceSetupOverview overview,
  ) {
    final focusedType = _focusedSectionType;
    if (focusedType != null) {
      for (final section in overview.plan.sections) {
        if (section.type == focusedType) return section;
      }
    }

    return overview.plan.primarySection;
  }

  void _openFocusedSection(ProductWorkspaceSetupPlanSection section) {
    final prompt = section.primaryPrompt;
    if (prompt == null) return;

    widget.onActionSelected(prompt);
  }
}

@Preview(name: 'Product workspace setup overview')
Widget workspaceSetupOverviewPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductWorkspaceSetupOverviewPanel(
          overview: previewProductWorkspaceSetupOverview,
          onActionSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Status pills that summarize setup readiness and target coverage.
class _SetupOverviewPills extends StatelessWidget {
  const _SetupOverviewPills({required this.overview});

  final ProductWorkspaceSetupOverview overview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 6,
      runSpacing: 6,
      children: [
        AppStatusPill(
          label: overview.readiness.statusLabel,
          color: productWorkspaceSetupReadinessColor(
            colorScheme,
            overview.readiness,
          ),
          icon: productWorkspaceSetupReadinessIcon(overview.readiness),
          maxWidth: 124,
        ),
        if (overview.readiness.progressLabel != overview.readiness.statusLabel)
          AppStatusPill(
            label: overview.readiness.progressLabel,
            color: colorScheme.secondary,
            icon: Icons.track_changes_rounded,
            maxWidth: 124,
          ),
        AppStatusPill(
          label: overview.readinessLabel,
          color: colorScheme.primary,
          icon: Icons.fact_check_rounded,
          maxWidth: 112,
        ),
        if (overview.hasPendingPrompts)
          AppStatusPill(
            label: overview.pendingCountLabel,
            color: colorScheme.error,
            icon: Icons.construction_rounded,
            maxWidth: 152,
          ),
        if (overview.urgentTargetCount > 0)
          AppStatusPill(
            label: overview.urgentTargetCountLabel,
            color: colorScheme.tertiary,
            icon: Icons.priority_high_rounded,
            maxWidth: 136,
          ),
        if (overview.requiredRequirementCount > 0)
          AppStatusPill(
            label: overview.requiredRequirementCountLabel,
            color: colorScheme.secondary,
            icon: Icons.checklist_rounded,
            maxWidth: 136,
          ),
        AppStatusPill(
          label: overview.targetCountLabel,
          color: colorScheme.secondary,
          icon: Icons.extension_rounded,
          maxWidth: 100,
        ),
      ],
    );
  }
}

/// Responsive row for one setup target prompt.
class _SetupTargetRow extends StatelessWidget {
  const _SetupTargetRow({required this.prompt, required this.onSelected});

  final ProductWorkspaceSetupPrompt prompt;
  final ValueChanged<ProductWorkspaceSetupPrompt> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = _availabilityColor(colorScheme, prompt);

    return LayoutBuilder(
      builder: (context, constraints) {
        final action = AppActionButton(
          label: prompt.actionLabel,
          icon:
              prompt.isInactive
                  ? Icons.swap_horiz_rounded
                  : Icons.arrow_forward_rounded,
          variant: AppActionButtonVariant.secondary,
          compact: true,
          onPressed: () => onSelected(prompt),
        );
        final content = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(_availabilityIcon(prompt), color: accent, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        prompt.target.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      AppStatusPill(
                        label: prompt.statusLabel,
                        color: accent,
                        showDot: true,
                        maxWidth: 118,
                      ),
                      AppStatusPill(
                        label: _actionSourceLabel(prompt),
                        color: colorScheme.primary,
                        icon: _actionSourceIcon(prompt),
                        maxWidth: 136,
                      ),
                      AppStatusPill(
                        label: prompt.target.priorityLabel,
                        color: _priorityColor(colorScheme, prompt),
                        icon: Icons.flag_rounded,
                        maxWidth: 136,
                      ),
                      AppStatusPill(
                        label: prompt.target.estimatedEffortLabel,
                        color: colorScheme.secondary,
                        icon: Icons.timer_rounded,
                        maxWidth: 92,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prompt.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (prompt.target.hasRequirements) ...[
                    const SizedBox(height: 8),
                    ProductWorkspaceSetupRequirementChips(
                      requirements: prompt.target.requirements,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );

        if (constraints.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              content,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: action),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: content),
            const SizedBox(width: 12),
            action,
          ],
        );
      },
    );
  }
}

Color _availabilityColor(
  ColorScheme colorScheme,
  ProductWorkspaceSetupPrompt prompt,
) {
  if (prompt.isInactive) return colorScheme.error;
  if (prompt.isCustom) return colorScheme.tertiary;

  return colorScheme.primary;
}

Color _priorityColor(
  ColorScheme colorScheme,
  ProductWorkspaceSetupPrompt prompt,
) {
  return switch (prompt.target.priority) {
    ProductWorkspaceSetupPriority.critical => colorScheme.error,
    ProductWorkspaceSetupPriority.high => colorScheme.tertiary,
    ProductWorkspaceSetupPriority.medium => colorScheme.primary,
    ProductWorkspaceSetupPriority.low => colorScheme.secondary,
  };
}

IconData _availabilityIcon(ProductWorkspaceSetupPrompt prompt) {
  if (prompt.isInactive) return Icons.construction_rounded;
  if (prompt.isCustom) return Icons.extension_rounded;

  return Icons.task_alt_rounded;
}

String _actionSourceLabel(ProductWorkspaceSetupPrompt prompt) {
  if (prompt.isInactive) return 'Pack switch';
  if (prompt.isCustom) return 'Custom path';
  if (prompt.usesRecommendation) return 'Recommended';

  return 'Fallback path';
}

IconData _actionSourceIcon(ProductWorkspaceSetupPrompt prompt) {
  if (prompt.isInactive) return Icons.swap_horiz_rounded;
  if (prompt.isCustom) return Icons.tune_rounded;
  if (prompt.usesRecommendation) return Icons.auto_awesome_rounded;

  return Icons.alt_route_rounded;
}
