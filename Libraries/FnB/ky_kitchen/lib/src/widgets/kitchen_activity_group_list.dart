import 'package:flutter/material.dart';

import '../models/kitchen_activity_group.dart';

/// Shows compact ticket or station groups for recent kitchen activity.
class KitchenActivityGroupList extends StatefulWidget {
  const KitchenActivityGroupList({
    super.key,
    required this.grouping,
    this.initialScope = KitchenActivityGroupScope.ticket,
    this.limit = 3,
    this.onGroupSelected,
  }) : assert(limit > 0, 'limit must be greater than zero.');

  final KitchenActivityGrouping grouping;
  final KitchenActivityGroupScope initialScope;
  final int limit;
  final ValueChanged<KitchenActivityGroup>? onGroupSelected;

  @override
  State<KitchenActivityGroupList> createState() =>
      _KitchenActivityGroupListState();
}

/// Manages the active grouping lens for kitchen activity groups.
class _KitchenActivityGroupListState extends State<KitchenActivityGroupList> {
  late KitchenActivityGroupScope _scope = widget.initialScope;

  @override
  void didUpdateWidget(covariant KitchenActivityGroupList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialScope != widget.initialScope) {
      _scope = widget.initialScope;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.grouping.isEmpty) return const SizedBox.shrink();

    final groups = widget.grouping.groupsBy(_scope, limit: widget.limit);
    if (groups.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _KitchenActivityGroupHeader(
          selectedScope: _scope,
          onScopeChanged: (scope) => setState(() => _scope = scope),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final group in groups)
              _KitchenActivityGroupPill(
                group: group,
                onPressed: widget.onGroupSelected == null
                    ? null
                    : () => widget.onGroupSelected!(group),
              ),
          ],
        ),
      ],
    );
  }
}

/// Header and scope selector for kitchen activity groups.
class _KitchenActivityGroupHeader extends StatelessWidget {
  const _KitchenActivityGroupHeader({
    required this.selectedScope,
    required this.onScopeChanged,
  });

  final KitchenActivityGroupScope selectedScope;
  final ValueChanged<KitchenActivityGroupScope> onScopeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Activity groups',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        SegmentedButton<KitchenActivityGroupScope>(
          selected: {selectedScope},
          showSelectedIcon: false,
          segments: [
            for (final scope in KitchenActivityGroupScope.values)
              ButtonSegment(value: scope, label: Text(scope.label)),
          ],
          onSelectionChanged: (selection) => onScopeChanged(selection.single),
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            textStyle: WidgetStatePropertyAll(
              theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact pill for one kitchen activity group.
class _KitchenActivityGroupPill extends StatelessWidget {
  const _KitchenActivityGroupPill({
    required this.group,
    required this.onPressed,
  });

  final KitchenActivityGroup group;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final issueColor = group.hasIssues ? colors.error : colors.primary;

    return Tooltip(
      message: group.subtitle ?? group.label,
      child: Material(
        color: colors.surface.withValues(alpha: .72),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colors.outlineVariant.withValues(alpha: .48)),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_groupIcon(group.scope), size: 16, color: issueColor),
                const SizedBox(width: 7),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      group.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      group.hasIssues
                          ? '${group.actionCountLabel} - ${group.issueCountLabel}'
                          : group.actionCountLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _groupIcon(KitchenActivityGroupScope scope) {
  return switch (scope) {
    KitchenActivityGroupScope.ticket => Icons.receipt_long_outlined,
    KitchenActivityGroupScope.station => Icons.restaurant_menu_outlined,
  };
}
