import 'package:flutter/material.dart';

/// Section container for grouped branch drill-down rows and empty states.
class InventoryAnalyticsBranchDetailSection extends StatelessWidget {
  const InventoryAnalyticsBranchDetailSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    required this.emptyState,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget emptyState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (children.isEmpty)
          emptyState
        else
          Column(
            children: [
              for (var index = 0; index < children.length; index += 1) ...[
                children[index],
                if (index != children.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
      ],
    );
  }
}

/// Responsive trailing slot that adds a chevron when a branch row is actionable.
class InventoryAnalyticsBranchActionTrailing extends StatelessWidget {
  const InventoryAnalyticsBranchActionTrailing({
    super.key,
    required this.child,
    required this.enabled,
    required this.maxWidth,
  });

  final Widget child;
  final bool enabled;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: child),
          const SizedBox(width: 6),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
