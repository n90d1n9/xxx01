import 'package:flutter/material.dart';

import 'restaurant_panel_header.dart';

export 'restaurant_mini_stat.dart';
export 'restaurant_panel_header.dart';

class RestaurantPanel extends StatelessWidget {
  const RestaurantPanel({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
    this.trailing,
    this.headerBadges = const [],
    this.padding = const EdgeInsets.all(18),
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget> headerBadges;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .7)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: .05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantPanelHeader(
              title: title,
              subtitle: subtitle,
              leading: leading,
              trailing: trailing,
              badges: headerBadges,
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
