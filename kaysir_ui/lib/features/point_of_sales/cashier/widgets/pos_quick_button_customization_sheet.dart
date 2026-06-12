import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../experiences/default_pos_touch_layout_profiles.dart';
import '../models/pos_quick_button.dart';
import '../models/pos_quick_button_customization.dart';
import '../models/pos_quick_button_customization_view.dart';
import '../models/pos_touch_layout_profile.dart';
import '../utils/pos_quick_button_icons.dart';
import 'pos_touch_density_selector.dart';
import 'pos_ui.dart';

/// Review and recovery sheet for POS quick-button customization.
class POSQuickButtonCustomizationSheet extends StatelessWidget {
  final POSQuickButtonCustomizationView view;
  final POSTouchLayoutDensity profileDensity;
  final POSTouchLayoutDensity selectedDensity;
  final ValueChanged<String> onTogglePinned;
  final ValueChanged<String> onToggleHidden;
  final ValueChanged<POSTouchLayoutDensity?> onDensityChanged;
  final ValueChanged<String> onMovePinnedUp;
  final ValueChanged<String> onMovePinnedDown;
  final VoidCallback? onReset;

  const POSQuickButtonCustomizationSheet({
    super.key,
    required this.view,
    required this.profileDensity,
    required this.selectedDensity,
    required this.onTogglePinned,
    required this.onToggleHidden,
    required this.onDensityChanged,
    required this.onMovePinnedUp,
    required this.onMovePinnedDown,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const POSIconBadge(icon: Icons.tune),
                const SizedBox(width: POSUiTokens.gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick buttons',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${view.pinnedCount} pinned | ${view.hiddenCount} hidden',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            POSTouchDensitySelector(
              profileDensity: profileDensity,
              selectedDensity: selectedDensity,
              onDensityChanged: onDensityChanged,
            ),
            const SizedBox(height: POSUiTokens.gap),
            _CustomizationSection(
              title: 'Pinned first',
              emptyMessage: 'No pinned shortcuts yet.',
              buttons: view.pinnedButtons,
              actionIcon: Icons.push_pin,
              actionLabel: 'Unpin',
              onAction: onTogglePinned,
              onMoveUp: onMovePinnedUp,
              onMoveDown: onMovePinnedDown,
            ),
            const SizedBox(height: POSUiTokens.gap),
            _CustomizationSection(
              title: 'Hidden',
              emptyMessage: 'No hidden shortcuts.',
              buttons: view.hiddenButtons,
              actionIcon: Icons.visibility_outlined,
              actionLabel: 'Show',
              onAction: onToggleHidden,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomizationSection extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final List<POSQuickButton> buttons;
  final IconData actionIcon;
  final String actionLabel;
  final ValueChanged<String> onAction;
  final ValueChanged<String>? onMoveUp;
  final ValueChanged<String>? onMoveDown;

  const _CustomizationSection({
    required this.title,
    required this.emptyMessage,
    required this.buttons,
    required this.actionIcon,
    required this.actionLabel,
    required this.onAction,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return POSSurface(
      padding: const EdgeInsets.all(10),
      color: theme.colorScheme.surfaceContainerLowest,
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.72),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: POSUiTokens.gap),
          if (buttons.isEmpty)
            Text(
              emptyMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            for (var index = 0; index < buttons.length; index += 1)
              _CustomizationButtonRow(
                button: buttons[index],
                actionIcon: actionIcon,
                actionLabel: actionLabel,
                onAction: () => onAction(buttons[index].id),
                onMoveUp:
                    index == 0 || onMoveUp == null
                        ? null
                        : () => onMoveUp!(buttons[index].id),
                onMoveDown:
                    index == buttons.length - 1 || onMoveDown == null
                        ? null
                        : () => onMoveDown!(buttons[index].id),
              ),
        ],
      ),
    );
  }
}

class _CustomizationButtonRow extends StatelessWidget {
  final POSQuickButton button;
  final IconData actionIcon;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const _CustomizationButtonRow({
    required this.button,
    required this.actionIcon,
    required this.actionLabel,
    required this.onAction,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: POSIconBadge(
        icon: resolvePOSQuickButtonIcon(button.iconKey),
        size: 30,
        iconSize: 17,
      ),
      title: Text(
        button.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        button.intent.kind.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onMoveUp != null)
            IconButton(
              tooltip: 'Move ${button.label} up',
              onPressed: onMoveUp,
              icon: const Icon(Icons.keyboard_arrow_up),
              visualDensity: VisualDensity.compact,
            ),
          if (onMoveDown != null)
            IconButton(
              tooltip: 'Move ${button.label} down',
              onPressed: onMoveDown,
              icon: const Icon(Icons.keyboard_arrow_down),
              visualDensity: VisualDensity.compact,
            ),
          TextButton.icon(
            onPressed: onAction,
            icon: Icon(actionIcon),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'POS quick button customization sheet')
Widget posQuickButtonCustomizationSheetPreview() {
  final buttons =
      coreCounterTouchLayoutProfile.groups
          .expand((group) => group.buttons)
          .toList();

  return MaterialApp(
    home: Scaffold(
      body: POSQuickButtonCustomizationSheet(
        view: POSQuickButtonCustomizationView.fromButtons(
          buttons: buttons,
          customization: const POSQuickButtonCustomization(
            pinnedButtonIds: ['core_category_top_sellers'],
            hiddenButtonIds: ['core_category_services'],
            densityOverride: POSTouchLayoutDensity.spacious,
          ),
        ),
        profileDensity: coreCounterTouchLayoutProfile.density,
        selectedDensity: POSTouchLayoutDensity.spacious,
        onTogglePinned: (_) {},
        onToggleHidden: (_) {},
        onDensityChanged: (_) {},
        onMovePinnedUp: (_) {},
        onMovePinnedDown: (_) {},
        onReset: () {},
      ),
    ),
  );
}
