import 'package:flutter/material.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_snapshot_import_preview.dart';
import 'website_builder_snapshot_import_mode_options.dart';
import 'website_builder_template_preview.dart';
import 'website_builder_templates.dart';

class WebsiteBuilderTemplateSelection {
  final WebsiteBuilderTemplate template;
  final WebsiteBuilderSnapshotImportMode mode;

  const WebsiteBuilderTemplateSelection({
    required this.template,
    required this.mode,
  });
}

enum _TemplateSortMode { recommended, name, mostBlocks }

extension _TemplateSortModeLabel on _TemplateSortMode {
  String get label {
    return switch (this) {
      _TemplateSortMode.recommended => 'Recommended',
      _TemplateSortMode.name => 'Name A-Z',
      _TemplateSortMode.mostBlocks => 'Most blocks',
    };
  }

  String get keySuffix {
    return switch (this) {
      _TemplateSortMode.recommended => 'recommended',
      _TemplateSortMode.name => 'name',
      _TemplateSortMode.mostBlocks => 'blocks',
    };
  }
}

class WebsiteBuilderTemplateDialog extends StatefulWidget {
  final List<WebsiteBuilderTemplate> templates;
  final int existingComponentCount;

  const WebsiteBuilderTemplateDialog({
    super.key,
    this.templates = websiteBuilderTemplates,
    required this.existingComponentCount,
  });

  @override
  State<WebsiteBuilderTemplateDialog> createState() =>
      _WebsiteBuilderTemplateDialogState();
}

class _WebsiteBuilderTemplateDialogState
    extends State<WebsiteBuilderTemplateDialog> {
  String _query = '';
  String _selectedCategory = 'All';
  _TemplateSortMode _sortMode = _TemplateSortMode.recommended;
  WebsiteBuilderTemplate? _selectedTemplate;
  WebsiteBuilderSnapshotImportMode _mode =
      WebsiteBuilderSnapshotImportMode.replace;

  @override
  void initState() {
    super.initState();
    if (widget.templates.isNotEmpty) {
      _selectedTemplate = widget.templates.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final library = WebsiteBuilderTemplateLibrary(widget.templates);
    final categories = ['All', ...library.categories];
    final templates = library.search(
      query: _query,
      category: _selectedCategory == 'All' ? null : _selectedCategory,
    );
    final sortedTemplates = _sortedTemplates(templates, _sortMode);
    final selectedTemplate = _visibleSelectedTemplate(sortedTemplates);
    return KyBuilderDialog(
      title: const Text('Templates'),
      width: 720,
      height: 520,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KyBuilderSegmentedSelector<WebsiteBuilderSnapshotImportMode>(
            options: websiteBuilderSnapshotImportModeOptions(),
            selectedValue: _mode,
            onChanged: (mode) => setState(() => _mode = mode),
          ),
          if (_mode == WebsiteBuilderSnapshotImportMode.replace &&
              widget.existingComponentCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Replace will clear ${_componentCountLabel(widget.existingComponentCount)} from the current canvas.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 320,
                  child: _TemplateBrowser(
                    categories: categories,
                    selectedCategory: _selectedCategory,
                    query: _query,
                    templates: sortedTemplates,
                    totalTemplateCount: widget.templates.length,
                    sortMode: _sortMode,
                    selectedTemplate: selectedTemplate,
                    onQueryChanged: (query) => setState(() => _query = query),
                    onCategoryChanged:
                        (category) =>
                            setState(() => _selectedCategory = category),
                    onSortChanged:
                        (sortMode) => setState(() => _sortMode = sortMode),
                    onTemplateSelected:
                        (template) =>
                            setState(() => _selectedTemplate = template),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child:
                      selectedTemplate == null
                          ? const _EmptyTemplateSelection()
                          : _TemplateDetails(template: selectedTemplate),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed:
              selectedTemplate == null
                  ? null
                  : () => Navigator.of(context).pop(
                    WebsiteBuilderTemplateSelection(
                      template: selectedTemplate,
                      mode: _mode,
                    ),
                  ),
          icon: const Icon(Icons.dashboard_customize_outlined),
          label: const Text('Apply'),
        ),
      ],
    );
  }

  WebsiteBuilderTemplate? _visibleSelectedTemplate(
    List<WebsiteBuilderTemplate> templates,
  ) {
    if (templates.isEmpty) return null;
    final selectedId = _selectedTemplate?.id;
    for (final template in templates) {
      if (template.id == selectedId) return template;
    }
    return templates.first;
  }
}

class _TemplateBrowser extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final String query;
  final List<WebsiteBuilderTemplate> templates;
  final int totalTemplateCount;
  final _TemplateSortMode sortMode;
  final WebsiteBuilderTemplate? selectedTemplate;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<_TemplateSortMode> onSortChanged;
  final ValueChanged<WebsiteBuilderTemplate> onTemplateSelected;

  const _TemplateBrowser({
    required this.categories,
    required this.selectedCategory,
    required this.query,
    required this.templates,
    required this.totalTemplateCount,
    required this.sortMode,
    required this.selectedTemplate,
    required this.onQueryChanged,
    required this.onCategoryChanged,
    required this.onSortChanged,
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KyBuilderLibraryToolbar<_TemplateSortMode>(
          searchFieldKey: const ValueKey('website-builder-template-search'),
          searchClearKey: const ValueKey(
            'website-builder-template-search-clear',
          ),
          countKey: const ValueKey('website-builder-template-count'),
          sortMenuKey: const ValueKey('website-builder-template-sort'),
          sortOptionKeyPrefix: 'website-builder-template-sort',
          searchQuery: query,
          searchHint: 'Search templates',
          visibleCount: templates.length,
          totalCount: totalTemplateCount,
          itemLabel: 'template',
          itemPluralLabel: 'templates',
          selectedSortValue: sortMode,
          sortOptions: [
            for (final mode in _TemplateSortMode.values)
              KyBuilderSortOption<_TemplateSortMode>(
                value: mode,
                label: mode.label,
                keySuffix: mode.keySuffix,
              ),
          ],
          onSearchQueryChanged: onQueryChanged,
          onSortChanged: onSortChanged,
        ),
        const SizedBox(height: 10),
        KyBuilderFilterChipBar<String>(
          optionKeyPrefix: 'website-builder-template-category',
          options: categories,
          selectedValue: selectedCategory,
          labelBuilder: (category) => category,
          onChanged: onCategoryChanged,
          wrap: true,
        ),
        const SizedBox(height: 10),
        Expanded(
          child:
              templates.isEmpty
                  ? const _NoTemplateMatches()
                  : ListView.separated(
                    itemCount: templates.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      return _TemplateTile(
                        template: template,
                        selected: template.id == selectedTemplate?.id,
                        onTap: () => onTemplateSelected(template),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final WebsiteBuilderTemplate template;
  final bool selected;
  final VoidCallback onTap;

  const _TemplateTile({
    required this.template,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return KyBuilderLibraryTile(
      key: ValueKey('website-builder-template-tile-${template.id}'),
      selected: selected,
      title: Text(
        template.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        template.category,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _NoTemplateMatches extends StatelessWidget {
  const _NoTemplateMatches();

  @override
  Widget build(BuildContext context) {
    return const KyBuilderEmptyState(
      icon: Icons.manage_search_outlined,
      title: 'No templates match the current filters.',
      message: 'Try a different search term or category.',
    );
  }
}

class _EmptyTemplateSelection extends StatelessWidget {
  const _EmptyTemplateSelection();

  @override
  Widget build(BuildContext context) {
    return const KyBuilderPanel(
      backgroundAlpha: 0.34,
      child: KyBuilderEmptyState(
        icon: Icons.dashboard_customize_outlined,
        title: 'Select a template to inspect it.',
        message: 'Choose a template from the browser to preview its layout.',
      ),
    );
  }
}

class _TemplateDetails extends StatelessWidget {
  final WebsiteBuilderTemplate template;

  const _TemplateDetails({required this.template});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = template.canvasConfig;
    return KyBuilderPanel(
      backgroundAlpha: 0.34,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            template.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            template.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          KyBuilderMetricStrip(
            metrics: [
              KyBuilderMetricItem(
                icon: Icons.widgets_outlined,
                value: '${template.componentCount}',
                label: 'blocks',
              ),
              KyBuilderMetricItem(
                icon: Icons.crop_free,
                value:
                    '${config.canvasWidth.round()} x ${config.canvasHeight.round()}',
                label: 'canvas',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: WebsiteBuilderTemplatePreview(template: template),
          ),
          const SizedBox(height: 16),
          Text(
            'Components',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: template.components.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final component = template.components[index];
                return Row(
                  children: [
                    Icon(
                      Icons.drag_indicator,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        component.kindKey,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${component.size.width.round()} x ${component.size.height.round()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _componentCountLabel(int count) {
  return count == 1 ? '1 component' : '$count components';
}

List<WebsiteBuilderTemplate> _sortedTemplates(
  List<WebsiteBuilderTemplate> templates,
  _TemplateSortMode sortMode,
) {
  final sortedTemplates = [...templates];

  switch (sortMode) {
    case _TemplateSortMode.recommended:
      return sortedTemplates;
    case _TemplateSortMode.name:
      sortedTemplates.sort(_compareTemplateNames);
      return sortedTemplates;
    case _TemplateSortMode.mostBlocks:
      sortedTemplates.sort((left, right) {
        final blockComparison = right.componentCount.compareTo(
          left.componentCount,
        );
        if (blockComparison != 0) {
          return blockComparison;
        }
        return _compareTemplateNames(left, right);
      });
      return sortedTemplates;
  }
}

int _compareTemplateNames(
  WebsiteBuilderTemplate left,
  WebsiteBuilderTemplate right,
) {
  final nameComparison = left.name.toLowerCase().compareTo(
    right.name.toLowerCase(),
  );
  if (nameComparison != 0) {
    return nameComparison;
  }
  return left.id.compareTo(right.id);
}
