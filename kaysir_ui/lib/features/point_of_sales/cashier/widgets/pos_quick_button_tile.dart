import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../experiences/default_pos_touch_layout_profiles.dart';
import '../models/pos_quick_button.dart';
import '../utils/pos_quick_button_icons.dart';
import 'pos_ui.dart';

/// Touch-ready tile for a configurable POS quick button.
class POSQuickButtonTile extends StatelessWidget {
  final POSQuickButton button;
  final VoidCallback? onPressed;
  final bool pinned;
  final VoidCallback? onTogglePinned;
  final VoidCallback? onHide;
  final bool dense;

  const POSQuickButtonTile({
    super.key,
    required this.button,
    required this.onPressed,
    this.pinned = false,
    this.onTogglePinned,
    this.onHide,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final enabled = onPressed != null;
    final foreground =
        enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant;
    final borderColor =
        enabled
            ? colorScheme.primary.withValues(alpha: 0.22)
            : colorScheme.outlineVariant.withValues(alpha: 0.52);
    final backgroundColor =
        enabled
            ? colorScheme.surfaceContainerLowest
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.42);

    final tile = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(POSUiTokens.radius),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: EdgeInsets.all(dense ? 10 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    POSIconBadge(
                      icon: resolvePOSQuickButtonIcon(button.iconKey),
                      size: dense ? 30 : 34,
                      iconSize: dense ? 17 : 19,
                      backgroundColor:
                          enabled
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerHighest,
                      foregroundColor:
                          enabled
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                    ),
                    const Spacer(),
                    if (pinned)
                      Icon(
                        Icons.push_pin_outlined,
                        size: dense ? 15 : 16,
                        color: colorScheme.primary,
                      ),
                    _QuickButtonTileMenu(
                      button: button,
                      pinned: pinned,
                      onTogglePinned: onTogglePinned,
                      onHide: onHide,
                      compact: dense,
                    ),
                  ],
                ),
                const SizedBox(height: POSUiTokens.gap),
                Text(
                  button.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (!dense) ...[
                  const SizedBox(height: 3),
                  Text(
                    button.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return Tooltip(message: _tooltipMessage(enabled), child: tile);
  }

  String _tooltipMessage(bool enabled) {
    if (enabled) return '${button.label}: ${button.description}';
    return '${button.label}: handler not available for this POS surface.';
  }
}

enum _QuickButtonTileMenuAction { togglePin, hide }

class _QuickButtonTileMenu extends StatelessWidget {
  final POSQuickButton button;
  final bool pinned;
  final VoidCallback? onTogglePinned;
  final VoidCallback? onHide;
  final bool compact;

  const _QuickButtonTileMenu({
    required this.button,
    required this.pinned,
    required this.onTogglePinned,
    required this.onHide,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    if (onTogglePinned == null && onHide == null) {
      return Icon(
        _intentIcon(button.intent.kind),
        size: compact ? 15 : 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }

    return SizedBox.square(
      dimension: compact ? 28 : 30,
      child: PopupMenuButton<_QuickButtonTileMenuAction>(
        tooltip: 'Customize ${button.label}',
        padding: EdgeInsets.zero,
        iconSize: compact ? 17 : 18,
        icon: const Icon(Icons.more_horiz),
        onSelected: (action) {
          switch (action) {
            case _QuickButtonTileMenuAction.togglePin:
              onTogglePinned?.call();
            case _QuickButtonTileMenuAction.hide:
              onHide?.call();
          }
        },
        itemBuilder: (context) {
          return [
            if (onTogglePinned != null)
              PopupMenuItem(
                value: _QuickButtonTileMenuAction.togglePin,
                child: _QuickButtonMenuItem(
                  icon: Icons.push_pin_outlined,
                  label: pinned ? 'Unpin' : 'Pin first',
                ),
              ),
            if (onHide != null)
              const PopupMenuItem(
                value: _QuickButtonTileMenuAction.hide,
                child: _QuickButtonMenuItem(
                  icon: Icons.visibility_off_outlined,
                  label: 'Hide',
                ),
              ),
          ];
        },
      ),
    );
  }

  IconData _intentIcon(POSQuickButtonIntentKind kind) {
    switch (kind) {
      case POSQuickButtonIntentKind.commandAction:
        return Icons.bolt_outlined;
      case POSQuickButtonIntentKind.product:
        return Icons.inventory_2_outlined;
      case POSQuickButtonIntentKind.category:
        return Icons.grid_view_outlined;
      case POSQuickButtonIntentKind.discount:
        return Icons.discount_outlined;
      case POSQuickButtonIntentKind.modifierSet:
        return Icons.tune;
      case POSQuickButtonIntentKind.customerAction:
        return Icons.person_outline;
      case POSQuickButtonIntentKind.layoutProfile:
        return Icons.dashboard_customize_outlined;
      case POSQuickButtonIntentKind.customFlow:
        return Icons.route_outlined;
    }
  }
}

class _QuickButtonMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickButtonMenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        const SizedBox(width: POSUiTokens.gap),
        Text(label),
      ],
    );
  }
}

@Preview(name: 'POS quick button tile')
Widget posQuickButtonTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 180,
          height: 132,
          child: POSQuickButtonTile(
            button: groceryScannerTouchLayoutProfile.groups.first.buttons.first,
            onPressed: () {},
          ),
        ),
      ),
    ),
  );
}
