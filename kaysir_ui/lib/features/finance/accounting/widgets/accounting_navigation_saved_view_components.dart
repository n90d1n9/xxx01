import 'package:flutter/material.dart';

import '../../../../utils/helper.dart';
import '../models/accounting_menu_saved_view.dart';
import '../models/accounting_menu_search.dart';

class AccountingNavigationSavedViews extends StatelessWidget {
  const AccountingNavigationSavedViews({
    required this.views,
    required this.query,
    required this.scope,
    required this.onSelected,
    super.key,
  });

  final List<AccountingMenuSavedView> views;
  final String query;
  final AccountingMenuSearchScope scope;
  final ValueChanged<AccountingMenuSavedView> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
                  Icons.bookmarks_rounded,
                  color: colorScheme.primary,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Text(
                  'Saved Views',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            );
            final chips = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final view in views)
                  _SavedViewChip(
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
                const SizedBox(width: 16),
                Expanded(child: chips),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SavedViewChip extends StatelessWidget {
  const _SavedViewChip({
    required this.view,
    required this.selected,
    required this.onSelected,
  });

  final AccountingMenuSavedView view;
  final bool selected;
  final ValueChanged<AccountingMenuSavedView> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final contentColor =
        selected ? colorScheme.onSecondaryContainer : colorScheme.onSurface;

    return ChoiceChip(
      key: ValueKey('accounting-saved-view-${view.id}'),
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
      selectedColor: colorScheme.secondaryContainer,
      onSelected: (_) => onSelected(view),
    );
  }
}
