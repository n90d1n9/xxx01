import 'package:flutter/material.dart';

import '../../../../core/features/feature_routes.dart';
import '../../services/admin_route_icon_resolver.dart';
import '../../states/sidebar_provider.dart';

class SidebarMenuTile extends StatelessWidget {
  const SidebarMenuTile({
    super.key,
    required this.item,
    required this.displayMode,
    required this.isSelected,
    required this.isExpanded,
    required this.depth,
    required this.expandedPadding,
    required this.accentColor,
    required this.enableTooltip,
    required this.onTap,
  });

  final FeatureRoutes item;
  final SidebarMode displayMode;
  final bool isSelected;
  final bool isExpanded;
  final int depth;
  final EdgeInsetsGeometry expandedPadding;
  final Color accentColor;
  final bool enableTooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCompact = displayMode == SidebarMode.compact;
    final itemPadding =
        isCompact
            ? EdgeInsets.only(
              top: 10,
              bottom: 10,
              right: 8,
              left: depth > 0 ? 16 : 8,
            )
            : expandedPadding.add(EdgeInsets.only(left: depth * 16.0));

    Widget content =
        isCompact
            ? _CompactMenuContent(
              item: item,
              isSelected: isSelected,
              isExpanded: isExpanded,
              accentColor: accentColor,
            )
            : _ExpandedMenuContent(
              item: item,
              isSelected: isSelected,
              isExpanded: isExpanded,
              accentColor: accentColor,
            );

    if (isCompact && enableTooltip) {
      content = Tooltip(
        message: item.title ?? item.name ?? '',
        waitDuration: const Duration(milliseconds: 450),
        showDuration: const Duration(seconds: 2),
        child: content,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: accentColor.withValues(alpha: 0.1),
        highlightColor: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: itemPadding,
          decoration: BoxDecoration(
            color: _backgroundColor(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor(context)),
          ),
          child: content,
        ),
      ),
    );
  }

  Color _backgroundColor(BuildContext context) {
    if (!isSelected || displayMode != SidebarMode.expanded) {
      return Colors.transparent;
    }

    return Theme.of(
      context,
    ).colorScheme.primaryContainer.withValues(alpha: 0.5);
  }

  Color _borderColor(BuildContext context) {
    if (!isSelected || displayMode != SidebarMode.expanded) {
      return Colors.transparent;
    }

    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.24);
  }
}

class _CompactMenuContent extends StatelessWidget {
  const _CompactMenuContent({
    required this.item,
    required this.isSelected,
    required this.isExpanded,
    required this.accentColor,
  });

  final FeatureRoutes item;
  final bool isSelected;
  final bool isExpanded;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasChildren = item.items.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.72)
                : colorScheme.surfaceContainerLow.withValues(alpha: 0.0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isSelected
                  ? accentColor.withValues(alpha: 0.35)
                  : Colors.transparent,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _RouteIcon(
            item: item,
            color:
                isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
            size: hasChildren ? 23 : 20,
          ),
          if (hasChildren)
            Positioned(
              right: 2,
              bottom: 2,
              child: _ChildIndicator(
                color:
                    isExpanded
                        ? accentColor
                        : colorScheme.outline.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExpandedMenuContent extends StatelessWidget {
  const _ExpandedMenuContent({
    required this.item,
    required this.isSelected,
    required this.isExpanded,
    required this.accentColor,
  });

  final FeatureRoutes item;
  final bool isSelected;
  final bool isExpanded;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasChildren = item.items.isNotEmpty;

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? accentColor.withValues(alpha: 0.12)
                    : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _RouteIcon(
            item: item,
            color: isSelected ? accentColor : colorScheme.onSurfaceVariant,
            size: 19,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title ?? item.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? accentColor : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              if (item.subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  item.subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hasChildren)
          AnimatedRotation(
            turns: isExpanded ? 0.25 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
      ],
    );
  }
}

class _RouteIcon extends StatelessWidget {
  const _RouteIcon({
    required this.item,
    required this.color,
    required this.size,
  });

  final FeatureRoutes item;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return item.iconWidget ??
        Icon(resolveAdminRouteIcon(item), color: color, size: size);
  }
}

class _ChildIndicator extends StatelessWidget {
  const _ChildIndicator({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
