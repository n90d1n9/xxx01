import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/accounting_menu_search.dart';

/// A compact preset that applies a query and scope to accounting search.
class AccountingNavigationSearchSuggestion {
  const AccountingNavigationSearchSuggestion({
    required this.label,
    required this.query,
    required this.scope,
    required this.icon,
    required this.tooltip,
  });

  final String label;
  final String query;
  final AccountingMenuSearchScope scope;
  final IconData icon;
  final String tooltip;
}

/// Search, scope, and quick-filter controls for the accounting workspace.
class AccountingNavigationSearchPanel extends StatelessWidget {
  const AccountingNavigationSearchPanel({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.onSubmitted,
    required this.scope,
    required this.onScopeChanged,
    required this.resultCount,
    required this.hasQuery,
    this.suggestions = const [],
    this.onSuggestionSelected,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<String>? onSubmitted;
  final AccountingMenuSearchScope scope;
  final ValueChanged<AccountingMenuSearchScope> onScopeChanged;
  final int resultCount;
  final bool hasQuery;
  final List<AccountingNavigationSearchSuggestion> suggestions;
  final ValueChanged<AccountingNavigationSearchSuggestion>?
  onSuggestionSelected;

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
            final compact = constraints.maxWidth < 860;
            final scopeControl = SegmentedButton<AccountingMenuSearchScope>(
              showSelectedIcon: false,
              segments: [
                for (final item in AccountingMenuSearchScope.values)
                  ButtonSegment<AccountingMenuSearchScope>(
                    value: item,
                    label: Text(item.label),
                    icon: Icon(_scopeIcon(item), size: 17),
                  ),
              ],
              selected: {scope},
              onSelectionChanged: (selection) {
                final selected = selection.firstOrNull;
                if (selected != null) {
                  onScopeChanged(selected);
                }
              },
            );
            final searchField = TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search accounting',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon:
                    hasQuery
                        ? IconButton(
                          tooltip: 'Clear search',
                          onPressed: onClear,
                          icon: const Icon(Icons.close_rounded),
                        )
                        : null,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            );
            final resultBadge = _SearchResultBadge(
              label:
                  hasQuery
                      ? '$resultCount match${resultCount == 1 ? '' : 'es'}'
                      : '$resultCount destinations',
            );
            final suggestionStrip =
                suggestions.isEmpty
                    ? null
                    : _SearchSuggestionStrip(
                      suggestions: suggestions,
                      onSelected: onSuggestionSelected,
                    );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchField,
                  const SizedBox(height: 10),
                  scopeControl,
                  const SizedBox(height: 10),
                  resultBadge,
                  if (suggestionStrip != null) ...[
                    const SizedBox(height: 10),
                    suggestionStrip,
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: searchField),
                const SizedBox(width: 12),
                scopeControl,
                const SizedBox(width: 12),
                resultBadge,
                if (suggestionStrip != null) ...[
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: suggestionStrip,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

@Preview(name: 'Accounting search panel')
Widget accountingNavigationSearchPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AccountingNavigationSearchPanel(
          controller: TextEditingController(),
          onChanged: (_) {},
          onClear: () {},
          scope: AccountingMenuSearchScope.all,
          onScopeChanged: (_) {},
          resultCount: 32,
          hasQuery: false,
          suggestions: const [
            AccountingNavigationSearchSuggestion(
              label: 'Management',
              query: 'management',
              scope: AccountingMenuSearchScope.shortcuts,
              icon: Icons.speed_rounded,
              tooltip: 'Show management measure focus shortcuts',
            ),
            AccountingNavigationSearchSuggestion(
              label: 'Release',
              query: 'release',
              scope: AccountingMenuSearchScope.shortcuts,
              icon: Icons.verified_user_rounded,
              tooltip: 'Show report release focus shortcuts',
            ),
          ],
        ),
      ),
    ),
  );
}

IconData _scopeIcon(AccountingMenuSearchScope scope) {
  switch (scope) {
    case AccountingMenuSearchScope.all:
      return Icons.apps_rounded;
    case AccountingMenuSearchScope.screens:
      return Icons.web_asset_rounded;
    case AccountingMenuSearchScope.shortcuts:
      return Icons.shortcut_rounded;
  }
}

/// Displays suggested searches as small chips below the main search controls.
class _SearchSuggestionStrip extends StatelessWidget {
  const _SearchSuggestionStrip({
    required this.suggestions,
    required this.onSelected,
  });

  final List<AccountingNavigationSearchSuggestion> suggestions;
  final ValueChanged<AccountingNavigationSearchSuggestion>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text(
            'Suggested',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          for (final suggestion in suggestions) ...[
            ActionChip(
              key: ValueKey('accounting-search-suggestion-${suggestion.label}'),
              avatar: Icon(suggestion.icon, size: 16),
              label: Text(suggestion.label, overflow: TextOverflow.ellipsis),
              tooltip: suggestion.tooltip,
              onPressed:
                  onSelected == null ? null : () => onSelected!(suggestion),
            ),
            if (suggestion != suggestions.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class AccountingNavigationEmptyState extends StatelessWidget {
  const AccountingNavigationEmptyState({required this.query, super.key});

  final String query;

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
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.search_off_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No accounting matches for "$query"',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultBadge extends StatelessWidget {
  const _SearchResultBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
