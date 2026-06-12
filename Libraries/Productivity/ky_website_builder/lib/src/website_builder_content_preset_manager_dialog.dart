import 'package:flutter/material.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_component_presets.dart';

enum WebsiteBuilderContentPresetManagerActionType {
  export,
  import,
  update,
  rename,
  delete,
}

class WebsiteBuilderContentPresetManagerAction {
  final WebsiteBuilderContentPresetManagerActionType type;
  final String presetId;
  final String presetLabel;

  const WebsiteBuilderContentPresetManagerAction._({
    required this.type,
    required this.presetId,
    required this.presetLabel,
  });

  const WebsiteBuilderContentPresetManagerAction.rename({
    required String presetId,
    required String presetLabel,
  }) : this._(
         type: WebsiteBuilderContentPresetManagerActionType.rename,
         presetId: presetId,
         presetLabel: presetLabel,
       );

  const WebsiteBuilderContentPresetManagerAction.update({
    required String presetId,
    required String presetLabel,
  }) : this._(
         type: WebsiteBuilderContentPresetManagerActionType.update,
         presetId: presetId,
         presetLabel: presetLabel,
       );

  const WebsiteBuilderContentPresetManagerAction.export()
    : this._(
        type: WebsiteBuilderContentPresetManagerActionType.export,
        presetId: '',
        presetLabel: '',
      );

  const WebsiteBuilderContentPresetManagerAction.import()
    : this._(
        type: WebsiteBuilderContentPresetManagerActionType.import,
        presetId: '',
        presetLabel: '',
      );

  const WebsiteBuilderContentPresetManagerAction.delete({
    required String presetId,
    required String presetLabel,
  }) : this._(
         type: WebsiteBuilderContentPresetManagerActionType.delete,
         presetId: presetId,
         presetLabel: presetLabel,
       );
}

enum _ContentPresetSortMode { recentlySaved, name, fieldCoverage }

extension _ContentPresetSortModeLabel on _ContentPresetSortMode {
  String get label {
    return switch (this) {
      _ContentPresetSortMode.recentlySaved => 'Recently saved',
      _ContentPresetSortMode.name => 'Name A-Z',
      _ContentPresetSortMode.fieldCoverage => 'Most fields',
    };
  }

  String get keySuffix {
    return switch (this) {
      _ContentPresetSortMode.recentlySaved => 'recent',
      _ContentPresetSortMode.name => 'name',
      _ContentPresetSortMode.fieldCoverage => 'fields',
    };
  }
}

class WebsiteBuilderContentPresetManagerDialog extends StatefulWidget {
  final String kindLabel;
  final List<WebsiteBuilderComponentPreset> presets;

  const WebsiteBuilderContentPresetManagerDialog({
    super.key,
    required this.kindLabel,
    required this.presets,
  });

  @override
  State<WebsiteBuilderContentPresetManagerDialog> createState() =>
      _WebsiteBuilderContentPresetManagerDialogState();
}

class _WebsiteBuilderContentPresetManagerDialogState
    extends State<WebsiteBuilderContentPresetManagerDialog> {
  String _query = '';
  _ContentPresetSortMode _sortMode = _ContentPresetSortMode.recentlySaved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredPresets = _filteredContentPresets(widget.presets, _query);
    final sortedPresets = _sortedContentPresets(filteredPresets, _sortMode);

    return KyBuilderDialog(
      title: const Text('Manage content presets'),
      maxWidth: 460,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.kindLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (widget.presets.isNotEmpty) ...[
            KyBuilderLibraryToolbar<_ContentPresetSortMode>(
              searchFieldKey: const ValueKey(
                'website-builder-content-preset-manager-search',
              ),
              searchClearKey: const ValueKey(
                'website-builder-content-preset-manager-search-clear',
              ),
              countKey: const ValueKey(
                'website-builder-content-preset-manager-count',
              ),
              sortMenuKey: const ValueKey(
                'website-builder-content-preset-manager-sort',
              ),
              sortOptionKeyPrefix: 'website-builder-content-preset-sort',
              searchQuery: _query,
              searchHint: 'Search presets',
              visibleCount: filteredPresets.length,
              totalCount: widget.presets.length,
              itemLabel: 'preset',
              itemPluralLabel: 'presets',
              selectedSortValue: _sortMode,
              sortOptions: [
                for (final mode in _ContentPresetSortMode.values)
                  KyBuilderSortOption<_ContentPresetSortMode>(
                    value: mode,
                    label: mode.label,
                    keySuffix: mode.keySuffix,
                  ),
              ],
              onSearchQueryChanged: (value) => setState(() => _query = value),
              onSortChanged: (sortMode) => setState(() => _sortMode = sortMode),
            ),
            const SizedBox(height: 12),
          ],
          if (widget.presets.isEmpty)
            const KyBuilderEmptyState(
              icon: Icons.bookmark_add_outlined,
              title: 'No saved content presets yet.',
              message: 'Paste JSON or save the selected content as a preset.',
            )
          else if (filteredPresets.isEmpty)
            const KyBuilderEmptyState(
              icon: Icons.manage_search_outlined,
              title: 'No matching content presets.',
              message: 'Try a different name, field, or saved value.',
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (
                      var index = 0;
                      index < sortedPresets.length;
                      index += 1
                    ) ...[
                      _ContentPresetManagerRow(preset: sortedPresets[index]),
                      if (index < sortedPresets.length - 1)
                        const SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton.icon(
          key: const ValueKey('website-builder-content-preset-import'),
          onPressed:
              () => Navigator.of(
                context,
              ).pop(const WebsiteBuilderContentPresetManagerAction.import()),
          icon: const Icon(Icons.content_paste_go_outlined),
          label: const Text('Paste JSON'),
        ),
        TextButton.icon(
          key: const ValueKey('website-builder-content-preset-export'),
          onPressed:
              widget.presets.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(
                    const WebsiteBuilderContentPresetManagerAction.export(),
                  ),
          icon: const Icon(Icons.ios_share_outlined),
          label: const Text('Copy JSON'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

List<WebsiteBuilderComponentPreset> _filteredContentPresets(
  List<WebsiteBuilderComponentPreset> presets,
  String query,
) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return presets;
  }

  return [
    for (final preset in presets)
      if (_contentPresetMatchesQuery(preset, normalizedQuery)) preset,
  ];
}

List<WebsiteBuilderComponentPreset> _sortedContentPresets(
  List<WebsiteBuilderComponentPreset> presets,
  _ContentPresetSortMode sortMode,
) {
  final sortedPresets = [...presets];

  switch (sortMode) {
    case _ContentPresetSortMode.recentlySaved:
      return sortedPresets.reversed.toList();
    case _ContentPresetSortMode.name:
      sortedPresets.sort(_comparePresetLabels);
      return sortedPresets;
    case _ContentPresetSortMode.fieldCoverage:
      sortedPresets.sort((left, right) {
        final fieldComparison = right.properties.length.compareTo(
          left.properties.length,
        );
        if (fieldComparison != 0) {
          return fieldComparison;
        }
        return _comparePresetLabels(left, right);
      });
      return sortedPresets;
  }
}

int _comparePresetLabels(
  WebsiteBuilderComponentPreset left,
  WebsiteBuilderComponentPreset right,
) {
  final labelComparison = left.label.toLowerCase().compareTo(
    right.label.toLowerCase(),
  );
  if (labelComparison != 0) {
    return labelComparison;
  }
  return left.id.compareTo(right.id);
}

bool _contentPresetMatchesQuery(
  WebsiteBuilderComponentPreset preset,
  String normalizedQuery,
) {
  if (_matchesPresetText(preset.id, normalizedQuery) ||
      _matchesPresetText(preset.kindKey, normalizedQuery) ||
      _matchesPresetText(preset.label, normalizedQuery) ||
      _matchesPresetText(preset.description, normalizedQuery)) {
    return true;
  }

  return preset.properties.entries.any(
    (entry) =>
        _matchesPresetText(entry.key, normalizedQuery) ||
        _matchesPresetText(entry.value, normalizedQuery),
  );
}

bool _matchesPresetText(String value, String normalizedQuery) {
  return value.toLowerCase().contains(normalizedQuery);
}

class _ContentPresetManagerRow extends StatelessWidget {
  final WebsiteBuilderComponentPreset preset;

  const _ContentPresetManagerRow({required this.preset});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return KyBuilderLibraryTile(
      key: ValueKey('website-builder-content-preset-row-${preset.id}'),
      dense: true,
      leading: const Icon(Icons.bookmark_outline),
      title: Text(
        preset.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        '${preset.properties.length} fields',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Wrap(
        spacing: 2,
        children: [
          IconButton(
            key: ValueKey('website-builder-content-preset-update-${preset.id}'),
            tooltip: 'Update preset from selection',
            onPressed:
                () => Navigator.of(context).pop(
                  WebsiteBuilderContentPresetManagerAction.update(
                    presetId: preset.id,
                    presetLabel: preset.label,
                  ),
                ),
            icon: const Icon(Icons.published_with_changes_outlined),
          ),
          IconButton(
            key: ValueKey('website-builder-content-preset-rename-${preset.id}'),
            tooltip: 'Rename preset',
            onPressed:
                () => Navigator.of(context).pop(
                  WebsiteBuilderContentPresetManagerAction.rename(
                    presetId: preset.id,
                    presetLabel: preset.label,
                  ),
                ),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            key: ValueKey('website-builder-content-preset-delete-${preset.id}'),
            tooltip: 'Delete preset',
            onPressed:
                () => Navigator.of(context).pop(
                  WebsiteBuilderContentPresetManagerAction.delete(
                    presetId: preset.id,
                    presetLabel: preset.label,
                  ),
                ),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
