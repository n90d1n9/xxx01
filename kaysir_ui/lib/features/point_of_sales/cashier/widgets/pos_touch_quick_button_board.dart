import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../experiences/default_pos_touch_layout_profiles.dart';
import '../experiences/pos_experience_manifest.dart';
import '../models/pos_quick_button.dart';
import '../models/pos_quick_button_customization.dart';
import '../models/pos_touch_layout_profile.dart';
import '../states/pos_layout_provider.dart';
import '../utils/pos_quick_button_actions.dart';
import '../utils/pos_touch_quick_button_metrics.dart';
import 'pos_quick_button_tile.dart';
import 'pos_ui.dart';

/// Responsive quick-button board for the active POS touch layout profile.
class POSTouchQuickButtonBoard extends StatelessWidget {
  final POSTouchLayoutProfile profile;
  final POSQuickButtonSurface surface;
  final POSExperienceFormFactor formFactor;
  final POSLayoutPreference layoutPreference;
  final POSQuickButtonActionHandlers actionHandlers;
  final POSQuickButtonCustomization customization;
  final POSTouchLayoutDensity? touchDensity;
  final ValueChanged<String>? onTogglePinned;
  final ValueChanged<String>? onHide;
  final bool dense;

  const POSTouchQuickButtonBoard({
    super.key,
    required this.profile,
    required this.surface,
    required this.formFactor,
    required this.layoutPreference,
    this.actionHandlers = const POSQuickButtonActionHandlers(),
    this.customization = POSQuickButtonCustomization.empty,
    this.touchDensity,
    this.onTogglePinned,
    this.onHide,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final groups = profile.groupsForSurface(surface);
    if (groups.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in groups) ...[
          _QuickButtonGroupSection(
            profile: profile,
            group: group,
            formFactor: formFactor,
            layoutPreference: layoutPreference,
            actionHandlers: actionHandlers,
            customization: customization,
            touchDensity: touchDensity ?? profile.density,
            onTogglePinned: onTogglePinned,
            onHide: onHide,
            dense: dense,
          ),
          if (group != groups.last) const SizedBox(height: POSUiTokens.gap),
        ],
      ],
    );
  }
}

class _QuickButtonGroupSection extends StatelessWidget {
  final POSTouchLayoutProfile profile;
  final POSQuickButtonGroup group;
  final POSExperienceFormFactor formFactor;
  final POSLayoutPreference layoutPreference;
  final POSQuickButtonActionHandlers actionHandlers;
  final POSQuickButtonCustomization customization;
  final POSTouchLayoutDensity touchDensity;
  final ValueChanged<String>? onTogglePinned;
  final ValueChanged<String>? onHide;
  final bool dense;

  const _QuickButtonGroupSection({
    required this.profile,
    required this.group,
    required this.formFactor,
    required this.layoutPreference,
    required this.actionHandlers,
    required this.customization,
    required this.touchDensity,
    required this.onTogglePinned,
    required this.onHide,
    required this.dense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableButtons = group.visibleButtonsFor(
      profile.contextFor(
        surface: group.surface,
        formFactor: formFactor,
        layoutPreference: layoutPreference,
      ),
    );
    final buttons = customization.applyTo(availableButtons);
    if (buttons.isEmpty) return const SizedBox.shrink();
    final metrics = resolvePOSTouchQuickButtonMetrics(
      density: touchDensity,
      compactChrome: dense,
      minTileExtent: profile.minTileExtent,
    );

    return POSSurface(
      padding: EdgeInsets.all(metrics.sectionPadding),
      color: theme.colorScheme.surfaceContainerLowest,
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.72),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _QuickButtonGroupHeader(
            profile: profile,
            group: group,
            count: buttons.length,
            density: metrics.density,
            dense: dense,
          ),
          const SizedBox(height: POSUiTokens.gap),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = _resolveColumns(
                width: constraints.maxWidth,
                metrics: metrics,
                maxColumns: profile.maxGridColumns,
              );

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: metrics.spacing,
                  mainAxisSpacing: metrics.spacing,
                  mainAxisExtent: metrics.mainAxisExtent,
                ),
                itemCount: buttons.length,
                itemBuilder: (context, index) {
                  final button = buttons[index];
                  return POSQuickButtonTile(
                    button: button,
                    dense: dense,
                    pinned: customization.isPinned(button.id),
                    onTogglePinned:
                        onTogglePinned == null
                            ? null
                            : () => onTogglePinned!(button.id),
                    onHide: onHide == null ? null : () => onHide!(button.id),
                    onPressed: actionHandlers.resolve(button),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  int _resolveColumns({
    required double width,
    required POSTouchQuickButtonMetrics metrics,
    required int maxColumns,
  }) {
    return metrics.columnsFor(width: width, maxColumns: maxColumns);
  }
}

class _QuickButtonGroupHeader extends StatelessWidget {
  final POSTouchLayoutProfile profile;
  final POSQuickButtonGroup group;
  final int count;
  final POSTouchLayoutDensity density;
  final bool dense;

  const _QuickButtonGroupHeader({
    required this.profile,
    required this.group,
    required this.count,
    required this.density,
    required this.dense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        POSIconBadge(
          icon: Icons.touch_app_outlined,
          size: dense ? 28 : 32,
          iconSize: dense ? 16 : 18,
        ),
        const SizedBox(width: POSUiTokens.gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (!dense)
                Text(
                  '${profile.catalogEmphasis.label} | ${density.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        POSMetricPill(
          label: '$count',
          value: count == 1 ? 'button' : 'buttons',
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          foregroundColor: theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

@Preview(name: 'POS touch quick button board')
Widget posTouchQuickButtonBoardPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: POSTouchQuickButtonBoard(
          profile: groceryScannerTouchLayoutProfile,
          surface: POSQuickButtonSurface.primaryGrid,
          formFactor: POSExperienceFormFactor.tablet,
          layoutPreference: POSLayoutPreference.counter,
          actionHandlers: POSQuickButtonActionHandlers(
            onCategorySelected: (_) {},
            onCustomFlow: (_) {},
            onDiscountSelected: (_) {},
          ),
          customization: const POSQuickButtonCustomization(
            pinnedButtonIds: ['grocery_weigh_item'],
          ),
        ),
      ),
    ),
  );
}
