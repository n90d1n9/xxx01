import 'package:flutter/material.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_component_properties.dart';
import 'website_builder_controller.dart';

class WebsiteBuilderLayersPanel extends StatefulWidget {
  final WebsiteBuilderController controller;

  const WebsiteBuilderLayersPanel({super.key, required this.controller});

  @override
  State<WebsiteBuilderLayersPanel> createState() =>
      _WebsiteBuilderLayersPanelState();
}

class _WebsiteBuilderLayersPanelState extends State<WebsiteBuilderLayersPanel> {
  var _filter = _LayerFilter.all;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final selectedId = controller.selectedComponentId;
    final selectedComponent = controller.selectedComponent;
    final canReorderSelected =
        selectedComponent != null && !selectedComponent.isLocked;
    final contentIssueCount = controller.contentIssueCount;
    final contentIssuesById = {
      for (final component in controller.components)
        component.id: websiteBuilderContentIssuesFor(component),
    };
    final allLayers = [...controller.components]
      ..sort((a, b) => b.zIndex.compareTo(a.zIndex));
    final layers = [
      for (final component in allLayers)
        if (_filter.matches(
          component,
          contentIssuesById[component.id] ?? const [],
        ))
          component,
    ];
    final layerSubtitle =
        _filter == _LayerFilter.all
            ? _layersSubtitle(
              componentCount: controller.componentCount,
              contentIssueCount: contentIssueCount,
            )
            : '${_layersSubtitle(componentCount: controller.componentCount, contentIssueCount: contentIssueCount)} | ${_filter.label}: ${layers.length}';

    return KyBuilderSurface(
      title: 'Layers',
      subtitle: layerSubtitle,
      scrollable: true,
      actions: [
        PopupMenuButton<_ContentIssueAction>(
          key: const ValueKey('website-builder-layers-content-issues-menu'),
          tooltip: 'Content issues',
          enabled:
              controller.hasContentIssueComponents ||
              controller.hasFixableContentIssues,
          icon: const Icon(Icons.manage_search_outlined),
          onSelected: (action) {
            switch (action) {
              case _ContentIssueAction.previous:
                controller.selectPreviousComponentWithContentIssues();
              case _ContentIssueAction.next:
                controller.selectNextComponentWithContentIssues();
              case _ContentIssueAction.fixAll:
                controller.applyAllContentIssueFixes();
            }
          },
          itemBuilder:
              (context) => [
                for (final action in _ContentIssueAction.values)
                  PopupMenuItem<_ContentIssueAction>(
                    key: ValueKey(
                      'website-builder-layers-content-action-${action.name}',
                    ),
                    value: action,
                    enabled: action.isEnabled(controller),
                    child: Row(
                      children: [
                        Icon(action.icon, size: 18),
                        const SizedBox(width: 8),
                        Text(action.label),
                      ],
                    ),
                  ),
              ],
        ),
        PopupMenuButton<_LayerFilter>(
          key: const ValueKey('website-builder-layers-filter-menu'),
          tooltip: 'Filter layers',
          icon: Icon(_filter.icon),
          onSelected: (filter) => setState(() => _filter = filter),
          itemBuilder:
              (context) => [
                for (final filter in _LayerFilter.values)
                  CheckedPopupMenuItem<_LayerFilter>(
                    key: ValueKey(
                      'website-builder-layers-filter-${filter.name}',
                    ),
                    value: filter,
                    checked: filter == _filter,
                    child: Text(filter.label),
                  ),
              ],
        ),
        IconButton(
          tooltip: 'Send backward',
          onPressed:
              canReorderSelected ? controller.sendSelectedBackward : null,
          icon: const Icon(Icons.vertical_align_bottom_outlined),
        ),
        IconButton(
          tooltip: 'Bring forward',
          onPressed:
              canReorderSelected ? controller.bringSelectedForward : null,
          icon: const Icon(Icons.vertical_align_top_outlined),
        ),
      ],
      child:
          allLayers.isEmpty
              ? const _LayerEmptyState(
                icon: Icons.layers_outlined,
                title: 'No layers yet',
              )
              : layers.isEmpty
              ? _LayerEmptyState(
                icon: _filter.icon,
                title: 'No matching layers',
              )
              : ListView.separated(
                itemCount: layers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final component = layers[index];
                  final kind = controller.catalog.byKey(component.kindKey);
                  final contentIssues = websiteBuilderContentIssuesFor(
                    component,
                  );
                  return _LayerTile(
                    key: ValueKey('website-builder-layer-${component.id}'),
                    component: component,
                    kind: kind,
                    contentIssues: contentIssues,
                    selected: selectedId == component.id,
                    onTap: () => controller.selectComponent(component.id),
                    onToggleVisibility:
                        () =>
                            controller.toggleComponentVisibility(component.id),
                    onToggleLock:
                        () => controller.toggleComponentLock(component.id),
                  );
                },
              ),
    );
  }
}

class _LayerEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;

  const _LayerEmptyState({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

enum _LayerFilter { all, visible, hidden, locked, issues }

enum _ContentIssueAction { previous, next, fixAll }

extension _ContentIssueActionDetails on _ContentIssueAction {
  String get label {
    return switch (this) {
      _ContentIssueAction.previous => 'Previous issue',
      _ContentIssueAction.next => 'Next issue',
      _ContentIssueAction.fixAll => 'Fix all issues',
    };
  }

  IconData get icon {
    return switch (this) {
      _ContentIssueAction.previous => Icons.navigate_before,
      _ContentIssueAction.next => Icons.navigate_next,
      _ContentIssueAction.fixAll => Icons.auto_fix_high,
    };
  }

  bool isEnabled(WebsiteBuilderController controller) {
    return switch (this) {
      _ContentIssueAction.previous ||
      _ContentIssueAction.next => controller.hasContentIssueComponents,
      _ContentIssueAction.fixAll => controller.hasFixableContentIssues,
    };
  }
}

extension _LayerFilterDetails on _LayerFilter {
  String get label {
    return switch (this) {
      _LayerFilter.all => 'All',
      _LayerFilter.visible => 'Visible',
      _LayerFilter.hidden => 'Hidden',
      _LayerFilter.locked => 'Locked',
      _LayerFilter.issues => 'Has issues',
    };
  }

  IconData get icon {
    return switch (this) {
      _LayerFilter.all => Icons.filter_list,
      _LayerFilter.visible => Icons.visibility_outlined,
      _LayerFilter.hidden => Icons.visibility_off_outlined,
      _LayerFilter.locked => Icons.lock_outline,
      _LayerFilter.issues => Icons.warning_amber_outlined,
    };
  }

  bool matches(
    BuilderComponentGeometry component,
    List<WebsiteBuilderComponentContentIssue> issues,
  ) {
    return switch (this) {
      _LayerFilter.all => true,
      _LayerFilter.visible => component.isVisible,
      _LayerFilter.hidden => !component.isVisible,
      _LayerFilter.locked => component.isLocked,
      _LayerFilter.issues => issues.isNotEmpty,
    };
  }
}

String _layersSubtitle({
  required int componentCount,
  required int contentIssueCount,
}) {
  if (contentIssueCount == 0) return '$componentCount on canvas';
  return '$componentCount on canvas | ${_issueCountLabel(contentIssueCount)}';
}

String _issueCountLabel(int count) {
  return count == 1 ? '1 issue' : '$count issues';
}

class _LayerTile extends StatelessWidget {
  final BuilderComponentGeometry component;
  final BuilderComponentKind? kind;
  final List<WebsiteBuilderComponentContentIssue> contentIssues;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onToggleVisibility;
  final VoidCallback onToggleLock;

  const _LayerTile({
    super.key,
    required this.component,
    required this.kind,
    required this.contentIssues,
    required this.selected,
    required this.onTap,
    required this.onToggleVisibility,
    required this.onToggleLock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = selected ? colorScheme.primary : colorScheme.outlineVariant;
    final foreground =
        component.isVisible
            ? colorScheme.onSurface
            : colorScheme.onSurfaceVariant.withValues(alpha: 0.72);

    return Material(
      color:
          selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.42)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.36),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            border: Border.all(color: accent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 34,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(color: accent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${component.zIndex}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color:
                            selected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      kind?.label ?? component.kindKey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            component.id,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (contentIssues.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _LayerHealthBadge(
                            componentId: component.id,
                            issues: contentIssues,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _LayerIconButton(
                key: ValueKey(
                  'website-builder-layer-visibility-${component.id}',
                ),
                tooltip: component.isVisible ? 'Hide layer' : 'Show layer',
                icon:
                    component.isVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                selected: component.isVisible,
                onPressed: onToggleVisibility,
              ),
              const SizedBox(width: 4),
              _LayerIconButton(
                key: ValueKey('website-builder-layer-lock-${component.id}'),
                tooltip: component.isLocked ? 'Unlock layer' : 'Lock layer',
                icon:
                    component.isLocked
                        ? Icons.lock_outline
                        : Icons.lock_open_outlined,
                selected: component.isLocked,
                onPressed: onToggleLock,
              ),
              const SizedBox(width: 4),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 18,
                color: selected ? colorScheme.primary : colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows issue count and severity for a layer row.
class _LayerHealthBadge extends StatelessWidget {
  final String componentId;
  final List<WebsiteBuilderComponentContentIssue> issues;

  const _LayerHealthBadge({required this.componentId, required this.issues});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final warningCount = issues.where((issue) => issue.isWarning).length;
    final isWarning = warningCount > 0;
    final color = isWarning ? colorScheme.error : colorScheme.primary;
    final count = issues.length;
    final countLabel = '$count';
    final issueLabel = count == 1 ? '1 issue' : '$count issues';
    final tooltip =
        isWarning
            ? '$issueLabel, $warningCount warning${warningCount == 1 ? '' : 's'}'
            : issueLabel;

    return KyBuilderBadge(
      key: ValueKey('website-builder-layer-health-$componentId'),
      label: countLabel,
      icon: isWarning ? Icons.warning_amber_outlined : Icons.info_outline,
      tooltip: tooltip,
      backgroundColor: color.withValues(alpha: 0.10),
      borderColor: color.withValues(alpha: 0.42),
      foregroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      iconGap: 3,
    );
  }
}

class _LayerIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  const _LayerIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
    );
  }
}
