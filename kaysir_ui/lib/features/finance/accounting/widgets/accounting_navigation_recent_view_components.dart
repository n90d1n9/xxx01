import 'package:flutter/material.dart';

import '../../../../utils/helper.dart';
import '../models/accounting_menu_search.dart';
import '../models/accounting_workspace_recent_view.dart';

class AccountingNavigationRecentViews extends StatelessWidget {
  const AccountingNavigationRecentViews({
    required this.views,
    required this.query,
    required this.scope,
    required this.onSelected,
    required this.onClear,
    super.key,
  });

  final List<AccountingWorkspaceRecentView> views;
  final String query;
  final AccountingMenuSearchScope scope;
  final ValueChanged<AccountingWorkspaceRecentView> onSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final title = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history_rounded,
                  color: colorScheme.primary,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Views',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  key: const ValueKey('accounting-recent-views-clear'),
                  tooltip: 'Clear recent views',
                  visualDensity: VisualDensity.compact,
                  onPressed: onClear,
                  icon: const Icon(Icons.clear_all_rounded, size: 19),
                ),
              ],
            );
            final chips = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final view in views)
                  _RecentViewChip(
                    view: view,
                    selected: view.isSelected(query: query, scope: scope),
                    onSelected: onSelected,
                  ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 10), chips],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(width: 12),
                Expanded(child: chips),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RecentViewChip extends StatelessWidget {
  const _RecentViewChip({
    required this.view,
    required this.selected,
    required this.onSelected,
  });

  final AccountingWorkspaceRecentView view;
  final bool selected;
  final ValueChanged<AccountingWorkspaceRecentView> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final contentColor =
        selected ? colorScheme.onTertiaryContainer : colorScheme.onSurface;

    return ChoiceChip(
      key: ValueKey('accounting-recent-view-${view.id}'),
      selected: selected,
      showCheckmark: false,
      avatar: Icon(getIconData(view.icon), size: 17, color: contentColor),
      label: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 180),
        child: Text(
          view.label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: contentColor,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ),
      tooltip: view.path,
      selectedColor: colorScheme.tertiaryContainer,
      onSelected: (_) => onSelected(view),
    );
  }
}
