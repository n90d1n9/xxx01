import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_component_preview.dart';
import 'website_builder_component_presets.dart';
import 'website_builder_controller.dart';
import 'website_builder_html_export_dialog.dart';
import 'website_builder_html_exporter.dart';
import 'website_builder_inspector.dart';
import 'website_builder_keyboard_shortcuts.dart';
import 'website_builder_layers_panel.dart';
import 'website_builder_palette.dart';
import 'website_builder_project_details_dialog.dart';
import 'website_builder_snapshot_import_preview.dart';
import 'website_builder_snapshot_import_mode_options.dart';
import 'website_builder_template_dialog.dart';
import 'website_builder_toolbar.dart';

class WebsiteBuilderScreen extends StatefulWidget {
  final WebsiteBuilderController? controller;

  const WebsiteBuilderScreen({super.key, this.controller});

  @override
  State<WebsiteBuilderScreen> createState() => _WebsiteBuilderScreenState();
}

class _WebsiteBuilderScreenState extends State<WebsiteBuilderScreen> {
  final _canvasDropKey = GlobalKey();
  late final WebsiteBuilderController _controller;
  late final bool _ownsController;
  String _query = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? WebsiteBuilderController();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return WebsiteBuilderKeyboardShortcuts(
          controller: _controller,
          child: Scaffold(
            appBar: AppBar(
              titleSpacing: 20,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_controller.projectName),
                  Text(
                    'Website Builder',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_note_outlined),
                  tooltip: 'Edit project details',
                  onPressed: _editProjectDetails,
                ),
                IconButton(
                  icon: const Icon(Icons.dashboard_customize_outlined),
                  tooltip: 'Open templates',
                  onPressed: _openTemplates,
                ),
                IconButton(
                  icon: const Icon(Icons.content_copy),
                  tooltip: 'Copy JSON',
                  onPressed: _copyProjectJson,
                ),
                IconButton(
                  icon: const Icon(Icons.code),
                  tooltip: 'Copy HTML',
                  onPressed: _copyProjectHtml,
                ),
                IconButton(
                  icon: const Icon(Icons.integration_instructions_outlined),
                  tooltip: 'Copy shared snapshot',
                  onPressed: _copySharedSnapshot,
                ),
                IconButton(
                  icon: const Icon(Icons.content_paste),
                  tooltip: 'Paste shared snapshot',
                  onPressed: _pasteSharedSnapshot,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: 'Clear canvas',
                  onPressed: _confirmClearCanvas,
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final workspaceWidth =
                    constraints.maxWidth < 1180 ? 1180.0 : constraints.maxWidth;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: workspaceWidth,
                    height: constraints.maxHeight,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 304,
                            child: WebsiteBuilderPalette(
                              catalog: _controller.catalog,
                              query: _query,
                              selectedCategory: _selectedCategory,
                              onQueryChanged:
                                  (query) => setState(() => _query = query),
                              onCategoryChanged: (category) {
                                setState(() => _selectedCategory = category);
                              },
                              onAddComponent: _controller.addComponent,
                              onAddComponentPreset: _addPresetComponent,
                              presetProvider: _controller.presetsFor,
                              presetMatcher: _controller.presetsMatching,
                              presetMatchChecker:
                                  _controller.kindHasPresetMatch,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                WebsiteBuilderToolbar(controller: _controller),
                                const SizedBox(height: 12),
                                Expanded(child: _buildCanvasDropTarget()),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 336,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 248,
                                  child: WebsiteBuilderLayersPanel(
                                    controller: _controller,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: WebsiteBuilderInspector(
                                    controller: _controller,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCanvasDropTarget() {
    return DragTarget<BuilderComponentKind>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        final box =
            _canvasDropKey.currentContext?.findRenderObject() as RenderBox?;
        final localOffset = box?.globalToLocal(details.offset) ?? Offset.zero;
        _controller.addComponent(
          details.data,
          position: localOffset - const Offset(24, 24),
        );
      },
      builder: (context, candidateData, rejectedData) {
        final isDragging = candidateData.isNotEmpty;
        return Stack(
          key: _canvasDropKey,
          children: [
            Positioned.fill(
              child: KyBuilderCanvasFrame(
                config: _controller.canvasConfig,
                catalog: _controller.catalog,
                components: _controller.components,
                selectedComponentId: _controller.selectedComponentId,
                onComponentSelected: _controller.selectComponent,
                componentBuilder:
                    (context, component, kind, isSelected) =>
                        WebsiteBuilderComponentPreview(
                          component: component,
                          kind: kind,
                          isSelected: isSelected,
                        ),
              ),
            ),
            if (isDragging)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.08),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _addPresetComponent(
    BuilderComponentKind kind,
    WebsiteBuilderComponentPreset preset,
  ) {
    _controller.addComponent(kind, contentPreset: preset);
    _showSnackBar('Added ${kind.label}: ${preset.label}');
  }

  Future<void> _copyProjectJson() async {
    await Clipboard.setData(ClipboardData(text: _controller.toPrettyJson()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Website JSON copied to clipboard')),
    );
  }

  Future<void> _copyProjectHtml() async {
    final options = await showDialog<WebsiteBuilderHtmlExportOptions>(
      context: context,
      builder:
          (context) => WebsiteBuilderHtmlExportDialog(
            projectName: _controller.projectName,
            canvasConfig: _controller.canvasConfig,
            components: _controller.components,
            exporter: WebsiteBuilderHtmlExporter(catalog: _controller.catalog),
          ),
    );
    if (options == null) return;

    await Clipboard.setData(
      ClipboardData(text: _controller.toHtml(options: options)),
    );
    if (!mounted) return;
    final readiness = _controller.inspectHtmlExport(options: options);
    _showSnackBar(
      'Website HTML copied (${_componentCountLabel(readiness.exportedComponentCount)})',
    );
  }

  Future<void> _copySharedSnapshot() async {
    final snapshot = _controller.toSharedSnapshot();
    await Clipboard.setData(
      ClipboardData(text: _controller.toPrettySharedSnapshotJson()),
    );
    if (!mounted) return;
    _showSnackBar(
      'Shared snapshot copied (${_componentCountLabel(snapshot.componentCount)})',
    );
  }

  Future<void> _editProjectDetails() async {
    final details = await showDialog<WebsiteBuilderProjectDetailsEdit>(
      context: context,
      builder:
          (context) => WebsiteBuilderProjectDetailsDialog(
            projectId: _controller.projectId,
            projectName: _controller.projectName,
          ),
    );
    if (details == null) return;

    final didUpdate = _controller.updateProjectDetails(
      projectId: details.projectId,
      projectName: details.projectName,
    );
    if (didUpdate) {
      _showSnackBar('Project details updated');
    }
  }

  Future<void> _openTemplates() async {
    final selection = await showDialog<WebsiteBuilderTemplateSelection>(
      context: context,
      builder:
          (context) => WebsiteBuilderTemplateDialog(
            existingComponentCount: _controller.componentCount,
          ),
    );
    if (selection == null) return;

    _controller.loadSharedSnapshot(
      selection.template.toSharedSnapshot(),
      includeUnknownComponents: false,
      mode: selection.mode,
    );
    _showSnackBar(
      'Applied template: ${selection.template.name} (${_componentCountLabel(selection.template.componentCount)})',
    );
  }

  Future<void> _confirmClearCanvas() async {
    final componentCount = _controller.componentCount;
    if (componentCount == 0) {
      _showSnackBar('Canvas is already empty');
      return;
    }

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => _ClearCanvasDialog(componentCount: componentCount),
    );
    if (shouldClear != true) return;

    _controller.clear();
    _showSnackBar(
      'Canvas cleared (${_componentCountLabel(componentCount)} removed)',
    );
  }

  Future<void> _pasteSharedSnapshot() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      _showSnackBar('Clipboard does not contain a builder snapshot');
      return;
    }

    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map) {
        _showSnackBar('Clipboard builder snapshot is not valid JSON');
        return;
      }

      final snapshot = BuilderSharedSnapshot.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      final preview = _controller.previewSharedSnapshot(snapshot);
      final options = await _confirmSharedSnapshotImport(
        preview,
        existingComponentCount: _controller.componentCount,
      );
      if (options == null) return;

      _controller.loadSharedSnapshot(
        snapshot,
        includeUnknownComponents: options.includeUnknownComponents,
        mode: options.mode,
      );
      final importedCount = preview.importedCount(
        includeUnknownComponents: options.includeUnknownComponents,
      );
      _showSnackBar(
        'Imported shared snapshot (${_componentCountLabel(importedCount)})',
      );
    } catch (_) {
      _showSnackBar('Clipboard builder snapshot is not valid JSON');
    }
  }

  Future<WebsiteBuilderSnapshotImportOptions?> _confirmSharedSnapshotImport(
    WebsiteBuilderSnapshotImportPreview preview, {
    required int existingComponentCount,
  }) async {
    return showDialog<WebsiteBuilderSnapshotImportOptions>(
      context: context,
      builder:
          (context) => _SharedSnapshotImportDialog(
            preview: preview,
            existingComponentCount: existingComponentCount,
          ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

class _ClearCanvasDialog extends StatelessWidget {
  final int componentCount;

  const _ClearCanvasDialog({required this.componentCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return KyBuilderDialog(
      title: const Text('Clear canvas'),
      maxWidth: 380,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KyBuilderMetricChip(
            icon: Icons.layers_outlined,
            value: '$componentCount',
            label: 'remove',
          ),
          const SizedBox(height: 12),
          Text(
            'This will remove ${_componentCountLabel(componentCount)} from the current canvas.',
          ),
          const SizedBox(height: 8),
          Text(
            'You can undo this from the toolbar after clearing.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.delete_sweep_outlined),
          label: const Text('Clear'),
        ),
      ],
    );
  }
}

class _SharedSnapshotImportDialog extends StatefulWidget {
  final WebsiteBuilderSnapshotImportPreview preview;
  final int existingComponentCount;

  const _SharedSnapshotImportDialog({
    required this.preview,
    required this.existingComponentCount,
  });

  @override
  State<_SharedSnapshotImportDialog> createState() =>
      _SharedSnapshotImportDialogState();
}

class _SharedSnapshotImportDialogState
    extends State<_SharedSnapshotImportDialog> {
  bool _includeUnknownComponents = true;
  WebsiteBuilderSnapshotImportMode _mode =
      WebsiteBuilderSnapshotImportMode.replace;

  @override
  Widget build(BuildContext context) {
    return KyBuilderDialog(
      title: const Text('Import shared snapshot'),
      maxWidth: 420,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 340),
        child: SingleChildScrollView(
          child: _SharedSnapshotImportPreview(
            preview: widget.preview,
            existingComponentCount: widget.existingComponentCount,
            mode: _mode,
            onModeChanged: (mode) {
              setState(() {
                _mode = mode;
              });
            },
            includeUnknownComponents: _includeUnknownComponents,
            onIncludeUnknownComponentsChanged:
                widget.preview.hasUnknownComponents
                    ? (value) {
                      setState(() {
                        _includeUnknownComponents = value;
                      });
                    }
                    : null,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed:
              () => Navigator.of(context).pop(
                WebsiteBuilderSnapshotImportOptions(
                  includeUnknownComponents: _includeUnknownComponents,
                  mode: _mode,
                ),
              ),
          icon: const Icon(Icons.file_upload_outlined),
          label: const Text('Import'),
        ),
      ],
    );
  }
}

class _SharedSnapshotImportPreview extends StatelessWidget {
  final WebsiteBuilderSnapshotImportPreview preview;
  final int existingComponentCount;
  final WebsiteBuilderSnapshotImportMode mode;
  final ValueChanged<WebsiteBuilderSnapshotImportMode> onModeChanged;
  final bool includeUnknownComponents;
  final ValueChanged<bool>? onIncludeUnknownComponentsChanged;

  const _SharedSnapshotImportPreview({
    required this.preview,
    required this.existingComponentCount,
    required this.mode,
    required this.onModeChanged,
    required this.includeUnknownComponents,
    this.onIncludeUnknownComponentsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mappedLabels = preview.mappedKindLabels;
    final unknownKindKeys = preview.unknownKindKeys;
    final options = WebsiteBuilderSnapshotImportOptions(
      includeUnknownComponents: includeUnknownComponents,
      mode: mode,
    );
    final impact = preview.impact(
      existingComponentCount: existingComponentCount,
      options: options,
    );

    return SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KyBuilderSummarySection(
            title: Text(preview.name),
            metrics: [
              KyBuilderMetricItem(
                icon: Icons.layers_outlined,
                value: '${impact.existingComponentCount}',
                label: 'existing',
              ),
              KyBuilderMetricItem(
                icon: Icons.file_download_outlined,
                value: '${impact.importedComponentCount}',
                label: 'imported',
              ),
              KyBuilderMetricItem(
                icon: Icons.task_alt,
                value: '${impact.resultComponentCount}',
                label: 'result',
              ),
              if (impact.skippedComponentCount > 0)
                KyBuilderMetricItem(
                  icon: Icons.hide_source_outlined,
                  value: '${impact.skippedComponentCount}',
                  label: 'skipped',
                ),
            ],
            spacing: 12,
            children: [
              if (impact.replacesExistingComponents)
                Text(
                  'Replace will clear ${_componentCountLabel(impact.existingComponentCount)} from the current canvas.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          KyBuilderSegmentedSelector<WebsiteBuilderSnapshotImportMode>(
            options: websiteBuilderSnapshotImportModeOptions(),
            selectedValue: mode,
            onChanged: onModeChanged,
          ),
          const SizedBox(height: 12),
          KyBuilderSummarySection(
            metrics: [
              KyBuilderMetricItem(
                icon: Icons.widgets_outlined,
                value:
                    '${preview.importedCount(includeUnknownComponents: includeUnknownComponents)}',
                label: 'import',
              ),
              KyBuilderMetricItem(
                icon: Icons.inventory_2_outlined,
                value: '${preview.componentCount}',
                label: 'total',
              ),
              KyBuilderMetricItem(
                icon: Icons.transform,
                value: '${preview.mappedCount}',
                label: 'mapped',
              ),
              KyBuilderMetricItem(
                icon:
                    preview.hasUnknownComponents
                        ? Icons.warning_amber_outlined
                        : Icons.check_circle_outline,
                value: '${preview.unknownCount}',
                label: 'unknown',
              ),
            ],
          ),
          if (mappedLabels.isNotEmpty) ...[
            const SizedBox(height: 14),
            KyBuilderDetailList(
              title: 'Mapped kinds',
              icon: Icons.transform,
              details: mappedLabels,
            ),
          ],
          if (unknownKindKeys.isNotEmpty) ...[
            const SizedBox(height: 14),
            KyBuilderDetailList(
              title: 'Unknown kinds',
              icon: Icons.warning_amber_outlined,
              details: unknownKindKeys,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: includeUnknownComponents,
              onChanged:
                  onIncludeUnknownComponentsChanged == null
                      ? null
                      : (value) =>
                          onIncludeUnknownComponentsChanged!(value ?? false),
              title: const Text('Include unknown kinds'),
            ),
          ],
        ],
      ),
    );
  }
}

String _componentCountLabel(int count) {
  return count == 1 ? '1 component' : '$count components';
}
