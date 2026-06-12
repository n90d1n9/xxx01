import 'package:flutter/material.dart';

import '../models/order_workspace_breadcrumb.dart';

class OrderWorkspaceBreadcrumbs extends StatelessWidget {
  final List<OrderWorkspaceBreadcrumb> items;
  final ValueChanged<String>? onOpenLocation;

  const OrderWorkspaceBreadcrumbs({
    super.key,
    required this.items,
    this.onOpenLocation,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedItems = items
        .where((item) => item.label.trim().isNotEmpty)
        .toList(growable: false);
    if (normalizedItems.isEmpty) return const SizedBox.shrink();

    return Wrap(
      key: const ValueKey('order_workspace_breadcrumbs'),
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        for (var index = 0; index < normalizedItems.length; index++) ...[
          _BreadcrumbLabel(
            item: normalizedItems[index],
            isLast: index == normalizedItems.length - 1,
            onOpenLocation: onOpenLocation,
          ),
          if (index < normalizedItems.length - 1) const _BreadcrumbSeparator(),
        ],
      ],
    );
  }
}

class _BreadcrumbLabel extends StatelessWidget {
  final OrderWorkspaceBreadcrumb item;
  final bool isLast;
  final ValueChanged<String>? onOpenLocation;

  const _BreadcrumbLabel({
    required this.item,
    required this.isLast,
    required this.onOpenLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final handler = onOpenLocation;
    final canOpen = handler != null && item.canOpen;
    final textStyle = theme.textTheme.labelMedium?.copyWith(
      color:
          isLast || canOpen
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w800,
      decoration: canOpen ? TextDecoration.underline : TextDecoration.none,
      decorationColor: theme.colorScheme.primary,
    );
    final label = Text(
      item.label.trim(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );

    if (!canOpen) {
      return KeyedSubtree(
        key: ValueKey('order_workspace_breadcrumb_${item.id}'),
        child: label,
      );
    }

    return Tooltip(
      message: 'Open ${item.label.trim()}',
      child: Semantics(
        button: true,
        label: item.label.trim(),
        child: InkWell(
          key: ValueKey('order_workspace_breadcrumb_${item.id}'),
          borderRadius: BorderRadius.circular(6),
          onTap: () => handler(item.location),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: label,
          ),
        ),
      ),
    );
  }
}

class _BreadcrumbSeparator extends StatelessWidget {
  const _BreadcrumbSeparator();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right,
      size: 16,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}
