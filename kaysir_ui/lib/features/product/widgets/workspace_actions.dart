import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/product_workspace_action_group.dart';
import '../models/product_workspace_action_summary.dart';
import '../models/product_workspace_shortcut.dart';
import 'workspace_preview_fixtures.dart';
import 'workspace_shortcut_visuals.dart';

/// Responsive launchpad for grouped product workspace shortcuts.
class ProductWorkspaceActions extends StatelessWidget {
  const ProductWorkspaceActions({
    super.key,
    required this.onShortcutSelected,
    this.onSetupFocusSelected,
    this.shortcuts = const [],
    this.groups,
    this.title = 'Workspace shortcuts',
    this.subtitle = 'Jump into product catalog and stock operations',
    this.emptyTitle = 'No workspace shortcuts',
    this.emptyMessage =
        'Shortcut actions will appear when product workflows are enabled.',
    this.iconBuilder = defaultProductWorkspaceShortcutIcon,
    this.colorBuilder = defaultProductWorkspaceShortcutColor,
  });

  final List<ProductWorkspaceShortcut> shortcuts;
  final List<ProductWorkspaceActionGroup>? groups;
  final ValueChanged<ProductWorkspaceShortcut> onShortcutSelected;
  final ValueChanged<ProductWorkspaceActionSetupFocus>? onSetupFocusSelected;
  final String title;
  final String subtitle;
  final String emptyTitle;
  final String? emptyMessage;
  final ProductWorkspaceShortcutIconBuilder iconBuilder;
  final ProductWorkspaceShortcutColorBuilder colorBuilder;

  @override
  Widget build(BuildContext context) {
    final visibleGroups = groups
        ?.where((group) => group.hasShortcuts)
        .toList(growable: false);
    final actionSummary =
        visibleGroups == null
            ? ProductWorkspaceActionSummary.fromShortcuts(shortcuts)
            : ProductWorkspaceActionSummary.fromGroups(visibleGroups);
    final hasActions = actionSummary.hasActions;

    return AppContentPanel(
      title: title,
      subtitle: subtitle,
      leadingIcon: Icons.route_rounded,
      trailing:
          hasActions
              ? _WorkspaceActionSummaryPills(
                summary: actionSummary,
                onSetupFocusSelected: onSetupFocusSelected,
              )
              : null,
      child:
          !hasActions
              ? AppEmptyState(
                title: emptyTitle,
                message: emptyMessage,
                icon: Icons.route_rounded,
              )
              : LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      constraints.maxWidth < 760
                          ? 1
                          : constraints.maxWidth < 1080
                          ? 2
                          : 4;

                  if (visibleGroups != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (
                          var index = 0;
                          index < visibleGroups.length;
                          index += 1
                        ) ...[
                          _WorkspaceActionGroupSection(
                            group: visibleGroups[index],
                            columns: columns,
                            iconBuilder: iconBuilder,
                            colorBuilder: colorBuilder,
                            onShortcutSelected: onShortcutSelected,
                          ),
                          if (index != visibleGroups.length - 1)
                            const SizedBox(height: 16),
                        ],
                      ],
                    );
                  }

                  return _WorkspaceActionGrid(
                    shortcuts: shortcuts,
                    columns: columns,
                    iconBuilder: iconBuilder,
                    colorBuilder: colorBuilder,
                    onShortcutSelected: onShortcutSelected,
                  );
                },
              ),
    );
  }
}

@Preview(name: 'Product workspace actions')
Widget workspaceActionsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductWorkspaceActions(
          groups: previewProductWorkspaceActionGroups,
          onShortcutSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Status pills summarizing workspace action readiness and setup focus.
class _WorkspaceActionSummaryPills extends StatelessWidget {
  const _WorkspaceActionSummaryPills({
    required this.summary,
    required this.onSetupFocusSelected,
  });

  final ProductWorkspaceActionSummary summary;
  final ValueChanged<ProductWorkspaceActionSetupFocus>? onSetupFocusSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final readinessColor = _readinessColor(colorScheme, summary.availability);
    final setupFocus = summary.setupFocus;

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 6,
      runSpacing: 6,
      children: [
        AppStatusPill(
          label: summary.readyActionLabel,
          color: readinessColor,
          tooltip: summary.readinessTooltip,
          showDot: true,
          maxWidth: 118,
        ),
        if (summary.hasGroups)
          AppStatusPill(
            label: summary.groupCountLabel,
            color: colorScheme.primary,
            maxWidth: 92,
          ),
        if (summary.hasGatedActions)
          AppStatusPill(
            label: summary.setupActionLabel,
            color: colorScheme.tertiary,
            maxWidth: 92,
          ),
        if (setupFocus != null)
          _WorkspaceSetupFocusPill(
            focus: setupFocus,
            onSelected: onSetupFocusSelected,
          ),
      ],
    );
  }
}

/// Selectable setup reminder for the most important gated workspace action.
class _WorkspaceSetupFocusPill extends StatelessWidget {
  const _WorkspaceSetupFocusPill({
    required this.focus,
    required this.onSelected,
  });

  final ProductWorkspaceActionSetupFocus focus;
  final ValueChanged<ProductWorkspaceActionSetupFocus>? onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pill = AppStatusPill(
      label: focus.label,
      color: colorScheme.error,
      icon: Icons.construction_rounded,
      tooltip: focus.tooltip,
      maxWidth: 168,
    );

    if (onSelected == null) return pill;

    return Semantics(
      button: true,
      label: focus.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => onSelected!(focus),
        child: pill,
      ),
    );
  }
}

/// Section for one logical workspace action group.
class _WorkspaceActionGroupSection extends StatelessWidget {
  const _WorkspaceActionGroupSection({
    required this.group,
    required this.columns,
    required this.iconBuilder,
    required this.colorBuilder,
    required this.onShortcutSelected,
  });

  final ProductWorkspaceActionGroup group;
  final int columns;
  final ProductWorkspaceShortcutIconBuilder iconBuilder;
  final ProductWorkspaceShortcutColorBuilder colorBuilder;
  final ValueChanged<ProductWorkspaceShortcut> onShortcutSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final readinessColor = _readinessColor(colorScheme, group.availability);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                group.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 8),
            AppStatusPill(
              label: group.readinessLabel,
              color: readinessColor,
              tooltip: group.availabilityLabel,
              showDot: true,
              maxWidth: 116,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            AppStatusPill(
              label: group.actionCountLabel,
              color: colorScheme.primary,
              maxWidth: 92,
            ),
            if (group.hasDisabledShortcuts) ...[
              AppStatusPill(
                label: group.disabledCountLabel,
                color: colorScheme.tertiary,
                maxWidth: 86,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          group.subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _WorkspaceActionGrid(
          shortcuts: group.shortcuts,
          columns: columns,
          iconBuilder: iconBuilder,
          colorBuilder: colorBuilder,
          onShortcutSelected: onShortcutSelected,
        ),
      ],
    );
  }
}

Color _readinessColor(
  ColorScheme colorScheme,
  ProductWorkspaceActionGroupAvailability availability,
) {
  return switch (availability) {
    ProductWorkspaceActionGroupAvailability.ready => colorScheme.secondary,
    ProductWorkspaceActionGroupAvailability.partial => colorScheme.tertiary,
    ProductWorkspaceActionGroupAvailability.gated => colorScheme.error,
  };
}

/// Responsive grid for product workspace shortcut cards.
class _WorkspaceActionGrid extends StatelessWidget {
  const _WorkspaceActionGrid({
    required this.shortcuts,
    required this.columns,
    required this.iconBuilder,
    required this.colorBuilder,
    required this.onShortcutSelected,
  });

  final List<ProductWorkspaceShortcut> shortcuts;
  final int columns;
  final ProductWorkspaceShortcutIconBuilder iconBuilder;
  final ProductWorkspaceShortcutColorBuilder colorBuilder;
  final ValueChanged<ProductWorkspaceShortcut> onShortcutSelected;

  @override
  Widget build(BuildContext context) {
    final cards = [
      for (final shortcut in shortcuts)
        _WorkspaceActionCard(
          title: shortcut.title,
          subtitle: shortcut.subtitle,
          icon: iconBuilder(shortcut),
          accentColor: colorBuilder(context, shortcut),
          status: shortcut.status,
          isEnabled: shortcut.isEnabled,
          disabledReason: shortcut.disabledReason,
          onPressed: () => onShortcutSelected(shortcut),
        ),
    ];

    if (columns == 1) {
      return Column(
        children: [
          for (var index = 0; index < cards.length; index += 1) ...[
            cards[index],
            if (index != cards.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var start = 0; start < cards.length; start += columns) ...[
          _WorkspaceActionRow(
            cards: cards.skip(start).take(columns).toList(),
            columns: columns,
          ),
          if (start + columns < cards.length) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Fixed-column row used by the workspace shortcut grid.
class _WorkspaceActionRow extends StatelessWidget {
  const _WorkspaceActionRow({required this.cards, required this.columns});

  final List<_WorkspaceActionCard> cards;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < columns; index += 1) ...[
          Expanded(
            child:
                index < cards.length ? cards[index] : const SizedBox.shrink(),
          ),
          if (index != columns - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

/// Clickable shortcut card with disabled-state context.
class _WorkspaceActionCard extends StatelessWidget {
  const _WorkspaceActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.status,
    required this.isEnabled,
    this.disabledReason,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String status;
  final bool isEnabled;
  final String? disabledReason;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveAccentColor =
        isEnabled ? accentColor : colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            isEnabled
                ? colorScheme.surface
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.46),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isEnabled ? onPressed : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: effectiveAccentColor.withValues(alpha: 0.12),
                      border: Border.all(
                        color: effectiveAccentColor.withValues(alpha: 0.22),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        isEnabled ? icon : Icons.lock_rounded,
                        color: effectiveAccentColor,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  AppStatusPill(
                    label: status,
                    color: effectiveAccentColor,
                    maxWidth: 130,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!isEnabled && disabledReason != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        disabledReason!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
