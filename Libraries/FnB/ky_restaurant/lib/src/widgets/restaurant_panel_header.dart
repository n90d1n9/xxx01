import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import 'restaurant_signal_chip.dart';
import 'restaurant_status_styles.dart';

/// Displays a panel title area with optional lead icon, badges, and actions.
class RestaurantPanelHeader extends StatelessWidget {
  const RestaurantPanelHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.badges = const [],
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget> badges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      container: true,
      header: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            _PanelHeaderLeading(child: leading!),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: badges),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

/// Displays a compact header metric with optional status-aware styling.
class RestaurantPanelHeaderBadge extends StatelessWidget {
  const RestaurantPanelHeaderBadge({
    super.key,
    required this.label,
    this.icon,
    this.status,
    this.tooltip,
  });

  final String label;
  final IconData? icon;
  final RestaurantServiceStatus? status;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final content = status == null
        ? _NeutralPanelHeaderBadge(
            label: label,
            icon: icon,
            foreground: colors.onSurfaceVariant,
            background: colors.surfaceContainerHighest.withValues(alpha: .48),
          )
        : RestaurantStatusPill(
            status: status!,
            label: label,
            icon: icon,
            compact: true,
          );

    if (tooltip == null) return content;
    return Tooltip(message: tooltip!, child: content);
  }
}

class _NeutralPanelHeaderBadge extends StatelessWidget {
  const _NeutralPanelHeaderBadge({
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return RestaurantSignalChip(
      label: label,
      icon: icon,
      foregroundColor: foreground,
      backgroundColor: background,
      iconSize: 14,
    );
  }
}

class _PanelHeaderLeading extends StatelessWidget {
  const _PanelHeaderLeading({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: .56),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: IconTheme.merge(
          data: IconThemeData(color: colors.primary, size: 20),
          child: child,
        ),
      ),
    );
  }
}
