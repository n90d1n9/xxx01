import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/core/features/feature_routes.dart';

import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_icon_action_button.dart';
import '../../../widgets/ui/app_info_row.dart';
import '../../../widgets/ui/app_search_field.dart';
import '../../../widgets/ui/app_status_pill.dart';
import 'route_search_index.dart';
import 'route_shell_metadata.dart';

/// Opens the workspace route search palette.
Future<void> showRouteSearchDialog(
  BuildContext context, {
  required List<FeatureRoutes> features,
}) {
  final entries = buildRouteSearchEntries(features);

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return RouteSearchDialog(
        entries: entries,
        onSelected: (entry) {
          Navigator.of(dialogContext).pop();
          _goToRoute(context, entry.path);
        },
      );
    },
  );
}

/// Search palette for navigating registered workspace routes.
class RouteSearchDialog extends StatefulWidget {
  const RouteSearchDialog({
    super.key,
    required this.entries,
    required this.onSelected,
  });

  final List<RouteSearchEntry> entries;
  final ValueChanged<RouteSearchEntry> onSelected;

  @override
  State<RouteSearchDialog> createState() => _RouteSearchDialogState();
}

class _RouteSearchDialogState extends State<RouteSearchDialog> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final ScrollController _resultScrollController;
  late List<RouteSearchEntry> _visibleEntries;
  late int _highlightedIndex;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode(onKeyEvent: _handleSearchKeyEvent);
    _resultScrollController = ScrollController();
    _visibleEntries = widget.entries;
    _highlightedIndex = _initialHighlightFor(_visibleEntries);
  }

  @override
  void didUpdateWidget(covariant RouteSearchDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      _visibleEntries = filterRouteSearchEntries(
        widget.entries,
        _searchController.text,
      );
      _highlightedIndex = _clampedHighlight(_highlightedIndex, _visibleEntries);
      _scrollHighlightedEntryIntoView();
    }
  }

  @override
  void dispose() {
    _resultScrollController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Find workspace route',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  AppStatusPill(
                    key: const ValueKey('route-search-count-pill'),
                    label: _routeSearchCountLabel(
                      totalCount: widget.entries.length,
                      visibleCount: _visibleEntries.length,
                      isFiltering: _searchController.text.trim().isNotEmpty,
                    ),
                    color: colorScheme.primary,
                    icon: Icons.route_rounded,
                    maxWidth: 120,
                  ),
                  const SizedBox(width: 8),
                  AppIconActionButton(
                    icon: Icons.close_rounded,
                    tooltip: 'Close search',
                    variant: AppIconActionButtonVariant.ghost,
                    onPressed: _closeSearch,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppSearchField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: 'Search route, module, or path',
                autofocus: true,
                onChanged: _filterEntries,
                onSubmitted: (_) => _submitHighlightedEntry(),
                trailing:
                    _searchController.text.isEmpty
                        ? null
                        : IconButton(
                          tooltip: 'Clear search',
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close_rounded),
                        ),
              ),
            ),
            const SizedBox(height: 14),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child:
                    _visibleEntries.isEmpty
                        ? const _RouteSearchEmptyState()
                        : _RouteSearchResultList(
                          controller: _resultScrollController,
                          entries: _visibleEntries,
                          highlightedIndex: _highlightedIndex,
                          onSelected: widget.onSelected,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterEntries(String query) {
    setState(() {
      _visibleEntries = filterRouteSearchEntries(widget.entries, query);
      _highlightedIndex = _initialHighlightFor(_visibleEntries);
    });
    _scrollHighlightedEntryIntoView();
  }

  void _clearSearch() {
    _searchController.clear();
    _filterEntries('');
  }

  KeyEventResult _handleSearchKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _handleEscape();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _moveHighlight(1);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _moveHighlight(-1);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.home) {
      _jumpHighlight(toEnd: false);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.end) {
      _jumpHighlight(toEnd: true);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _submitHighlightedEntry();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _moveHighlight(int delta) {
    if (_visibleEntries.isEmpty) return;
    setState(() {
      if (_highlightedIndex < 0) {
        _highlightedIndex = delta > 0 ? 0 : _visibleEntries.length - 1;
        return;
      }

      _highlightedIndex = _wrappedHighlightIndex(
        current: _highlightedIndex,
        delta: delta,
        count: _visibleEntries.length,
      );
    });
    _scrollHighlightedEntryIntoView();
  }

  void _jumpHighlight({required bool toEnd}) {
    if (_visibleEntries.isEmpty) return;
    setState(() {
      _highlightedIndex = toEnd ? _visibleEntries.length - 1 : 0;
    });
    _scrollHighlightedEntryIntoView();
  }

  void _submitHighlightedEntry() {
    if (_highlightedIndex < 0 || _highlightedIndex >= _visibleEntries.length) {
      return;
    }

    widget.onSelected(_visibleEntries[_highlightedIndex]);
  }

  void _handleEscape() {
    if (_searchController.text.trim().isNotEmpty) {
      _clearSearch();
      return;
    }

    _closeSearch();
  }

  void _closeSearch() {
    final navigator = Navigator.maybeOf(context);
    if (navigator == null || !navigator.canPop()) return;
    navigator.pop();
  }

  void _scrollHighlightedEntryIntoView() {
    if (_highlightedIndex < 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_resultScrollController.hasClients) return;

      final position = _resultScrollController.position;
      final targetOffset = _routeSearchResultOffsetForIndex(
        _highlightedIndex,
      ).clamp(position.minScrollExtent, position.maxScrollExtent);
      _resultScrollController.jumpTo(targetOffset);
    });
  }
}

@Preview(name: 'Route search dialog')
Widget routeSearchDialogPreview() {
  final entries = buildRouteSearchEntries([
    FeatureRoutes(
      title: 'Dashboard',
      subtitle: 'Workspace dashboards',
      icon: 'dashboard',
      path: '/dashboard',
      child: const SizedBox.shrink(),
    ),
    FeatureRoutes(
      title: 'Inventory',
      subtitle: 'Stock movements',
      icon: 'inventory',
      path: '/inventory',
      child: const SizedBox.shrink(),
      items: [
        FeatureRoutes(
          title: 'Movement History',
          subtitle: 'Inventory timeline',
          icon: 'timeline',
          path: '/inventory/movements',
          child: const SizedBox.shrink(),
        ),
      ],
    ),
  ]);

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: RouteSearchDialog(entries: entries, onSelected: (_) {}),
      ),
    ),
  );
}

class _RouteSearchResultList extends StatelessWidget {
  const _RouteSearchResultList({
    required this.controller,
    required this.entries,
    required this.highlightedIndex,
    required this.onSelected,
  });

  final ScrollController controller;
  final List<RouteSearchEntry> entries;
  final int highlightedIndex;
  final ValueChanged<RouteSearchEntry> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const ValueKey('route-search-results'),
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final colorScheme = Theme.of(context).colorScheme;
        final isHighlighted = index == highlightedIndex;

        return SizedBox(
          height: _routeSearchResultHeight,
          child: Semantics(
            key: ValueKey('route-search-result-semantics-${entry.path}'),
            button: true,
            selected: isHighlighted,
            label: _resultSemanticLabel(entry),
            child: ExcludeSemantics(
              child: AppInfoRow(
                key: ValueKey('route-search-result-${entry.path}'),
                contained: true,
                icon: routeShellIconData(entry.route),
                iconStyle: AppInfoRowIconStyle.badge,
                iconBackgroundColor: colorScheme.primaryContainer,
                iconForegroundColor: colorScheme.onPrimaryContainer,
                backgroundColor:
                    isHighlighted
                        ? colorScheme.primaryContainer.withValues(alpha: 0.45)
                        : null,
                borderColor:
                    isHighlighted
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                title: entry.displayTitle,
                subtitle: entry.subtitle,
                titleMaxLines: 1,
                subtitleMaxLines: 2,
                trailing: Icon(
                  isHighlighted
                      ? Icons.keyboard_return_rounded
                      : Icons.arrow_forward_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                onTap: () => onSelected(entry),
              ),
            ),
          ),
        );
      },
    );
  }
}

const _routeSearchResultHeight = 80.0;
const _routeSearchResultGap = 8.0;
const _routeSearchResultListPadding = 16.0;

int _initialHighlightFor(List<RouteSearchEntry> entries) {
  return entries.isEmpty ? -1 : 0;
}

int _clampedHighlight(int current, List<RouteSearchEntry> entries) {
  if (entries.isEmpty) return -1;
  if (current < 0) return 0;
  return current.clamp(0, entries.length - 1);
}

int _wrappedHighlightIndex({
  required int current,
  required int delta,
  required int count,
}) {
  if (count <= 0) return -1;
  return (current + delta) % count;
}

String _resultSemanticLabel(RouteSearchEntry entry) {
  return '${entry.displayTitle}, ${entry.subtitle}';
}

double _routeSearchResultOffsetForIndex(int index) {
  return _routeSearchResultListPadding +
      (index * (_routeSearchResultHeight + _routeSearchResultGap));
}

String _routeSearchCountLabel({
  required int totalCount,
  required int visibleCount,
  required bool isFiltering,
}) {
  return isFiltering
      ? _pluralizedCount(visibleCount, 'match', plural: 'matches')
      : _pluralizedCount(totalCount, 'route');
}

String _pluralizedCount(int count, String noun, {String? plural}) {
  return '$count ${count == 1 ? noun : plural ?? '${noun}s'}';
}

class _RouteSearchEmptyState extends StatelessWidget {
  const _RouteSearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      title: 'No matching routes',
      message: 'Try a different route, module, or path.',
      icon: Icons.search_off_rounded,
    );
  }
}

void _goToRoute(BuildContext context, String path) {
  if (path.trim().isEmpty || routeShellCurrentLocation(context) == path) {
    return;
  }

  try {
    context.go(path);
  } catch (_) {
    // Preview and widget tests may render the shell outside a GoRouter tree.
  }
}
