import 'package:flutter/material.dart';

import '../../../widgets/ui/app_icon_action_button.dart';
import '../../../widgets/ui/app_search_field.dart';
import '../models/admin_route_search_entry.dart';
import '../services/admin_route_search_index.dart';
import 'admin_dialog_surface.dart';
import 'admin_route_search_result_tile.dart';

Future<AdminRouteSearchEntry?> showAdminRouteSearch(
  BuildContext context, {
  required List<AdminRouteSearchEntry> entries,
}) {
  return showDialog<AdminRouteSearchEntry>(
    context: context,
    builder: (context) => AdminRouteSearchPanel(entries: entries),
  );
}

class AdminRouteSearchPanel extends StatefulWidget {
  const AdminRouteSearchPanel({
    super.key,
    required this.entries,
    this.initialQuery = '',
    this.onSelected,
  });

  final List<AdminRouteSearchEntry> entries;
  final String initialQuery;
  final ValueChanged<AdminRouteSearchEntry>? onSelected;

  @override
  State<AdminRouteSearchPanel> createState() => _AdminRouteSearchPanelState();
}

class _AdminRouteSearchPanelState extends State<AdminRouteSearchPanel> {
  late final TextEditingController _controller;
  late String _query;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _controller = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = filterAdminRouteSearchEntries(widget.entries, _query);

    return AdminDialogSurface(
      maxWidth: 680,
      maxHeight: 620,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RouteSearchField(
            controller: _controller,
            hasQuery: _query.trim().isNotEmpty,
            onChanged: _setQuery,
            onClear: () => _setQuery(''),
            onClose: () => Navigator.of(context).maybePop(),
            onSubmitted: _selectTopResult,
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Flexible(
            child: _RouteSearchResults(
              entries: results,
              hasQuery: _query.trim().isNotEmpty,
              onSelected: _selectEntry,
            ),
          ),
        ],
      ),
    );
  }

  void _setQuery(String value) {
    if (_controller.text != value) {
      _controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }

    setState(() => _query = value);
  }

  void _selectEntry(AdminRouteSearchEntry entry) {
    final onSelected = widget.onSelected;
    if (onSelected != null) {
      onSelected(entry);
      return;
    }

    Navigator.of(context).pop(entry);
  }

  void _selectTopResult() {
    final results = filterAdminRouteSearchEntries(
      widget.entries,
      _controller.text,
    );
    if (results.isEmpty) return;

    _selectEntry(results.first);
  }
}

class _RouteSearchField extends StatelessWidget {
  const _RouteSearchField({
    required this.controller,
    required this.hasQuery,
    required this.onChanged,
    required this.onClear,
    required this.onClose,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onClose;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: AppSearchField(
        width: double.infinity,
        controller: controller,
        hintText: 'Search pages',
        autofocus: true,
        onChanged: onChanged,
        onSubmitted: (_) => onSubmitted?.call(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasQuery)
              AppIconActionButton(
                icon: Icons.clear,
                tooltip: 'Clear search',
                size: 36,
                iconSize: 18,
                onPressed: onClear,
              ),
            AppIconActionButton(
              icon: Icons.close,
              tooltip: 'Close search',
              size: 36,
              iconSize: 18,
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteSearchResults extends StatelessWidget {
  const _RouteSearchResults({
    required this.entries,
    required this.hasQuery,
    required this.onSelected,
  });

  final List<AdminRouteSearchEntry> entries;
  final bool hasQuery;
  final ValueChanged<AdminRouteSearchEntry> onSelected;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _SearchEmptyState(hasQuery: hasQuery);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: true,
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        return AdminRouteSearchResultTile(
          entry: entries[index],
          highlighted: index == 0,
          onTap: () => onSelected(entries[index]),
        );
      },
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 260,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasQuery ? Icons.search_off_outlined : Icons.manage_search,
              size: 36,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              hasQuery ? 'No pages found' : 'No pages available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
