import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_content_preset_dialog.dart';
import 'website_builder_content_preset_manager_dialog.dart';
import 'website_builder_component_presets.dart';
import 'website_builder_component_properties.dart';
import 'website_builder_content_preset_library.dart';
import 'website_builder_controller.dart';
import 'website_builder_preset_source_badge.dart';

class WebsiteBuilderInspector extends StatelessWidget {
  final WebsiteBuilderController controller;

  const WebsiteBuilderInspector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final component = controller.selectedComponent;
    final kind = controller.selectedComponentKind;

    return KyBuilderSurface(
      title: 'Inspector',
      subtitle: component == null ? 'No selection' : kind?.category,
      scrollable: true,
      child:
          component == null
              ? const KyBuilderEmptyState(
                icon: Icons.touch_app_outlined,
                title: 'Select a component',
                message: 'Choose a canvas item to inspect placement and rules.',
              )
              : _SelectedComponentInspector(
                controller: controller,
                component: component,
                kind: kind,
              ),
    );
  }
}

class _SelectedComponentInspector extends StatelessWidget {
  final WebsiteBuilderController controller;
  final BuilderComponentGeometry component;
  final BuilderComponentKind? kind;

  const _SelectedComponentInspector({
    required this.controller,
    required this.component,
    required this.kind,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertySpecs = websiteBuilderPropertySpecsFor(component.kindKey);
    final contentPresets = controller.presetsFor(component.kindKey);
    final customContentPresets = controller.customContentPresetsFor(
      component.kindKey,
    );
    final contentIssues = websiteBuilderContentIssuesFor(component);

    return ListView(
      key: const ValueKey('website-builder-inspector-scroll'),
      children: [
        Text(
          kind?.label ?? component.kindKey,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(kind?.description ?? component.kindKey),
        const SizedBox(height: 18),
        if (propertySpecs.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Content',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey(
                  'website-builder-inspector-save-content-preset',
                ),
                tooltip: 'Save content preset',
                onPressed:
                    component.isLocked
                        ? null
                        : () => _saveContentPreset(context),
                icon: const Icon(Icons.bookmark_add_outlined),
              ),
              IconButton(
                key: const ValueKey(
                  'website-builder-inspector-manage-content-presets',
                ),
                tooltip: 'Manage content presets',
                onPressed:
                    () => _manageContentPresets(context, customContentPresets),
                icon: const Icon(Icons.bookmarks_outlined),
              ),
              if (contentPresets.isNotEmpty) ...[
                _ContentPresetMenu(
                  controller: controller,
                  presets: contentPresets,
                  enabled: !component.isLocked,
                ),
                const SizedBox(width: 4),
              ],
              TextButton.icon(
                key: const ValueKey('website-builder-inspector-reset-content'),
                onPressed:
                    component.isLocked ||
                            websiteBuilderComponentContentMatchesDefaults(
                              component,
                            )
                        ? null
                        : controller.resetSelectedComponentProperties,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ComponentPropertyEditor(
            controller: controller,
            component: component,
            specs: propertySpecs,
            enabled: !component.isLocked,
          ),
          if (contentIssues.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ContentIssueList(
              controller: controller,
              component: component,
              issues: contentIssues,
              enabled: !component.isLocked,
            ),
          ],
          const SizedBox(height: 18),
        ],
        _InspectorMetricGrid(component: component),
        const SizedBox(height: 18),
        Text(
          'State',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        _InspectorStateControls(controller: controller, component: component),
        const SizedBox(height: 18),
        Text(
          'Placement',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        _NudgeControls(controller: controller, enabled: !component.isLocked),
        const SizedBox(height: 18),
        Text(
          'Size',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        _SizeControls(
          controller: controller,
          component: component,
          enabled: !component.isLocked,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    component.isLocked ? null : controller.duplicateSelected,
                icon: const Icon(Icons.copy),
                label: const Text('Duplicate'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed:
                    component.isLocked ? null : controller.removeSelected,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveContentPreset(BuildContext context) async {
    final presetName = await showDialog<String>(
      context: context,
      builder:
          (context) => WebsiteBuilderContentPresetDialog(
            initialName:
                websiteBuilderPrimaryPropertyValue(component) ??
                (kind?.label ?? component.kindKey),
          ),
    );
    if (presetName == null || presetName.trim().isEmpty) return;
    controller.saveComponentContentPreset(component.id, label: presetName);
  }

  Future<void> _manageContentPresets(
    BuildContext context,
    List<WebsiteBuilderComponentPreset> customContentPresets,
  ) async {
    final action = await showDialog<WebsiteBuilderContentPresetManagerAction>(
      context: context,
      builder:
          (context) => WebsiteBuilderContentPresetManagerDialog(
            kindLabel: kind?.label ?? component.kindKey,
            presets: customContentPresets,
          ),
    );
    if (action == null) return;
    if (!context.mounted) return;

    switch (action.type) {
      case WebsiteBuilderContentPresetManagerActionType.export:
        final library = controller.customContentPresetLibraryFor(
          component.kindKey,
          kindLabel: kind?.label ?? component.kindKey,
        );
        await Clipboard.setData(ClipboardData(text: library.toPrettyJson()));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Content presets copied (${_contentPresetCountLabel(library.presetCount)})',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      case WebsiteBuilderContentPresetManagerActionType.import:
        await _importContentPresetLibraryFromClipboard(context);
        return;
      case WebsiteBuilderContentPresetManagerActionType.update:
        controller.updateCustomContentPresetFromComponent(
          action.presetId,
          component.id,
        );
        return;
      case WebsiteBuilderContentPresetManagerActionType.delete:
        controller.deleteCustomContentPreset(action.presetId);
        return;
      case WebsiteBuilderContentPresetManagerActionType.rename:
        if (!context.mounted) return;
        final presetName = await showDialog<String>(
          context: context,
          builder:
              (context) => WebsiteBuilderContentPresetDialog(
                initialName: action.presetLabel,
                title: 'Rename content preset',
                actionLabel: 'Rename',
                actionIcon: Icons.edit_outlined,
              ),
        );
        if (presetName == null || presetName.trim().isEmpty) return;
        controller.renameCustomContentPreset(action.presetId, presetName);
        return;
    }
  }

  Future<void> _importContentPresetLibraryFromClipboard(
    BuildContext context,
  ) async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipboardData?.text?.trim();
    if (text == null || text.isEmpty) {
      if (!context.mounted) return;
      _showContentPresetSnackBar(
        context,
        'Clipboard does not contain content preset JSON',
      );
      return;
    }

    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map) {
        if (!context.mounted) return;
        _showContentPresetSnackBar(
          context,
          'Clipboard does not contain content preset JSON',
        );
        return;
      }

      final json = Map<String, dynamic>.from(decoded);
      if (json['schema'] != WebsiteBuilderContentPresetLibrary.schemaId) {
        if (!context.mounted) return;
        _showContentPresetSnackBar(
          context,
          'Clipboard does not contain content preset JSON',
        );
        return;
      }

      final library = WebsiteBuilderContentPresetLibrary.fromJson(json);
      final preview = controller.previewCustomContentPresetLibrary(
        library,
        kindKey: component.kindKey,
      );
      if (!context.mounted) return;
      final shouldImport = await showDialog<bool>(
        context: context,
        builder:
            (context) => _ContentPresetLibraryImportDialog(
              library: library,
              preview: preview,
              targetKindLabel: kind?.label ?? component.kindKey,
            ),
      );
      if (shouldImport != true) return;
      if (!context.mounted) return;

      final result = controller.importCustomContentPresetLibrary(
        library,
        kindKey: component.kindKey,
      );
      if (!context.mounted) return;

      if (!result.didChange) {
        _showContentPresetSnackBar(context, 'No content presets imported');
        return;
      }

      _showContentPresetSnackBar(
        context,
        'Content presets imported (${_contentPresetCountLabel(result.importedCount)})',
      );
    } catch (_) {
      if (!context.mounted) return;
      _showContentPresetSnackBar(
        context,
        'Clipboard content preset JSON is not valid',
      );
    }
  }
}

class _ContentPresetLibraryImportDialog extends StatelessWidget {
  final WebsiteBuilderContentPresetLibrary library;
  final WebsiteBuilderContentPresetLibraryImportResult preview;
  final String targetKindLabel;

  const _ContentPresetLibraryImportDialog({
    required this.library,
    required this.preview,
    required this.targetKindLabel,
  });

  @override
  Widget build(BuildContext context) {
    final libraryLabel =
        library.kindLabel.trim().isEmpty
            ? preview.libraryKindKey
            : library.kindLabel.trim();
    final canImport = !preview.kindMismatch && preview.didChange;
    final summaryIssues = [
      if (preview.kindMismatch)
        KyBuilderIssueItem(
          severity: KyBuilderIssueSeverity.warning,
          message:
              'This preset library is for $libraryLabel, not $targetKindLabel.',
        )
      else if (!preview.didChange)
        const KyBuilderIssueItem(
          severity: KyBuilderIssueSeverity.info,
          message: 'No importable changes found.',
        ),
    ];

    return KyBuilderDialog(
      title: const Text('Import content presets'),
      maxWidth: 420,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          KyBuilderSummarySection(
            subtitle: Text(libraryLabel),
            metrics:
                preview.kindMismatch
                    ? const []
                    : [
                      KyBuilderMetricItem(
                        icon: Icons.add_circle_outline,
                        value: '${preview.addedCount}',
                        label: 'new',
                      ),
                      KyBuilderMetricItem(
                        icon: Icons.sync_outlined,
                        value: '${preview.updatedCount}',
                        label: 'updated',
                      ),
                      KyBuilderMetricItem(
                        icon: Icons.block,
                        value: '${preview.skippedCount}',
                        label: 'skipped',
                      ),
                    ],
            issues: summaryIssues,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const ValueKey('website-builder-content-preset-import-confirm'),
          onPressed: canImport ? () => Navigator.of(context).pop(true) : null,
          icon: const Icon(Icons.content_paste_go_outlined),
          label: const Text('Import'),
        ),
      ],
    );
  }
}

String _contentPresetCountLabel(int count) {
  return count == 1 ? '1 preset' : '$count presets';
}

void _showContentPresetSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}

class _ComponentPropertyEditor extends StatelessWidget {
  final WebsiteBuilderController controller;
  final BuilderComponentGeometry component;
  final List<WebsiteBuilderComponentPropertySpec> specs;
  final bool enabled;

  const _ComponentPropertyEditor({
    required this.controller,
    required this.component,
    required this.specs,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < specs.length; index += 1) ...[
          _ComponentPropertyField(
            controller: controller,
            component: component,
            spec: specs[index],
            enabled: enabled,
          ),
          if (index < specs.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ComponentPropertyField extends StatefulWidget {
  final WebsiteBuilderController controller;
  final BuilderComponentGeometry component;
  final WebsiteBuilderComponentPropertySpec spec;
  final bool enabled;

  const _ComponentPropertyField({
    required this.controller,
    required this.component,
    required this.spec,
    required this.enabled,
  });

  @override
  State<_ComponentPropertyField> createState() =>
      _ComponentPropertyFieldState();
}

class _ComponentPropertyFieldState extends State<_ComponentPropertyField> {
  late final TextEditingController _textController;
  late String _externalValue;

  @override
  void initState() {
    super.initState();
    _externalValue = _valueFromWidget(widget);
    _textController = TextEditingController(text: _externalValue);
  }

  @override
  void didUpdateWidget(covariant _ComponentPropertyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextExternalValue = _valueFromWidget(widget);
    if (nextExternalValue != _externalValue) {
      _externalValue = nextExternalValue;
      if (_textController.text != nextExternalValue) {
        _textController.text = nextExternalValue;
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(
        'website-builder-property-${widget.component.id}-${widget.spec.key}',
      ),
      controller: _textController,
      enabled: widget.enabled,
      maxLines: widget.spec.maxLines,
      keyboardType:
          widget.spec.maxLines > 1
              ? TextInputType.multiline
              : TextInputType.text,
      textInputAction:
          widget.spec.maxLines > 1
              ? TextInputAction.newline
              : TextInputAction.next,
      decoration: InputDecoration(
        labelText: widget.spec.label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (value) {
        _externalValue = value;
        widget.controller.updateComponentProperty(
          widget.component.id,
          widget.spec.key,
          value,
        );
      },
    );
  }

  static String _valueFromWidget(_ComponentPropertyField widget) {
    return widget.component.properties[widget.spec.key] ??
        widget.spec.defaultValue;
  }
}

class _ContentPresetMenu extends StatelessWidget {
  final WebsiteBuilderController controller;
  final List<WebsiteBuilderComponentPreset> presets;
  final bool enabled;

  const _ContentPresetMenu({
    required this.controller,
    required this.presets,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return PopupMenuButton<WebsiteBuilderComponentPreset>(
      key: const ValueKey('website-builder-inspector-presets'),
      enabled: enabled,
      tooltip: 'Apply content preset',
      icon: const Icon(Icons.tune_outlined),
      onSelected: controller.applySelectedComponentPreset,
      itemBuilder:
          (context) => [
            for (final preset in presets)
              PopupMenuItem(
                key: ValueKey('website-builder-inspector-preset-${preset.id}'),
                value: preset,
                child: SizedBox(
                  width: 244,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        preset.label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              preset.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          WebsiteBuilderPresetSourceBadge(
                            preset: preset,
                            dense: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
    );
  }
}

class _ContentIssueList extends StatelessWidget {
  final WebsiteBuilderController controller;
  final BuilderComponentGeometry component;
  final List<WebsiteBuilderComponentContentIssue> issues;
  final bool enabled;

  const _ContentIssueList({
    required this.controller,
    required this.component,
    required this.issues,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canFixAll = enabled && issues.any((issue) => issue.hasFix);
    return KyBuilderPanel(
      key: const ValueKey('website-builder-content-issues'),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.fact_check_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Content health',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton.filledTonal(
                key: const ValueKey('website-builder-content-fix-all'),
                onPressed:
                    canFixAll
                        ? () => controller.applyContentIssueFixes(component.id)
                        : null,
                icon: const Icon(Icons.auto_fix_high, size: 18),
                tooltip: 'Fix all content issues',
              ),
            ],
          ),
          const SizedBox(height: 8),
          KyBuilderIssueList(
            issues: [
              for (final issue in issues)
                KyBuilderIssueItem(
                  severity: _builderIssueSeverity(issue.severity),
                  message: issue.message,
                  action:
                      issue.hasFix
                          ? KyBuilderIssueAction(
                            key: ValueKey(
                              'website-builder-content-fix-${issue.key}',
                            ),
                            label: issue.fixLabel,
                            onPressed:
                                enabled
                                    ? () => controller.applyContentIssueFix(
                                      component.id,
                                      issue,
                                    )
                                    : null,
                          )
                          : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

KyBuilderIssueSeverity _builderIssueSeverity(
  WebsiteBuilderComponentContentIssueSeverity severity,
) {
  return switch (severity) {
    WebsiteBuilderComponentContentIssueSeverity.info =>
      KyBuilderIssueSeverity.info,
    WebsiteBuilderComponentContentIssueSeverity.warning =>
      KyBuilderIssueSeverity.warning,
  };
}

class _InspectorStateControls extends StatelessWidget {
  final WebsiteBuilderController controller;
  final BuilderComponentGeometry component;

  const _InspectorStateControls({
    required this.controller,
    required this.component,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InspectorStateSwitch(
          key: const ValueKey('website-builder-inspector-visible-control'),
          icon:
              component.isVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
          iconColor: component.isVisible ? colorScheme.primary : null,
          title: 'Visible',
          subtitle:
              component.isVisible ? 'Shown on canvas' : 'Hidden from canvas',
          value: component.isVisible,
          onChanged: (_) => controller.toggleComponentVisibility(component.id),
        ),
        const SizedBox(height: 6),
        _InspectorStateSwitch(
          key: const ValueKey('website-builder-inspector-lock-control'),
          icon:
              component.isLocked
                  ? Icons.lock_outline
                  : Icons.lock_open_outlined,
          iconColor: component.isLocked ? colorScheme.primary : null,
          title: 'Locked',
          subtitle: component.isLocked ? 'Locked from editing' : 'Editable',
          value: component.isLocked,
          onChanged: (_) => controller.toggleComponentLock(component.id),
        ),
      ],
    );
  }
}

class _InspectorStateSwitch extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _InspectorStateSwitch({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, color: iconColor ?? colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _InspectorMetricGrid extends StatelessWidget {
  final BuilderComponentGeometry component;

  const _InspectorMetricGrid({required this.component});

  @override
  Widget build(BuildContext context) {
    return KyBuilderMetricStrip(
      metrics: [
        KyBuilderMetricItem(
          icon: Icons.near_me_outlined,
          value: '${component.position.dx.round()}',
          label: 'x',
        ),
        KyBuilderMetricItem(
          icon: Icons.south_east,
          value: '${component.position.dy.round()}',
          label: 'y',
        ),
        KyBuilderMetricItem(
          icon: Icons.width_normal,
          value: '${component.size.width.round()}',
          label: 'w',
        ),
        KyBuilderMetricItem(
          icon: Icons.height,
          value: '${component.size.height.round()}',
          label: 'h',
        ),
      ],
    );
  }
}

class _NudgeControls extends StatelessWidget {
  final WebsiteBuilderController controller;
  final bool enabled;

  const _NudgeControls({required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    const step = 20.0;
    return Center(
      child: SizedBox(
        width: 156,
        child: Column(
          children: [
            IconButton.filledTonal(
              onPressed:
                  enabled
                      ? () => controller.nudgeSelected(const Offset(0, -step))
                      : null,
              icon: const Icon(Icons.keyboard_arrow_up),
              tooltip: 'Move up',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  onPressed:
                      enabled
                          ? () =>
                              controller.nudgeSelected(const Offset(-step, 0))
                          : null,
                  icon: const Icon(Icons.keyboard_arrow_left),
                  tooltip: 'Move left',
                ),
                IconButton.filledTonal(
                  onPressed:
                      enabled
                          ? () =>
                              controller.nudgeSelected(const Offset(step, 0))
                          : null,
                  icon: const Icon(Icons.keyboard_arrow_right),
                  tooltip: 'Move right',
                ),
              ],
            ),
            IconButton.filledTonal(
              onPressed:
                  enabled
                      ? () => controller.nudgeSelected(const Offset(0, step))
                      : null,
              icon: const Icon(Icons.keyboard_arrow_down),
              tooltip: 'Move down',
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeControls extends StatelessWidget {
  final WebsiteBuilderController controller;
  final BuilderComponentGeometry component;
  final bool enabled;

  const _SizeControls({
    required this.controller,
    required this.component,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    const step = 20.0;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                enabled
                    ? () => controller.resizeComponent(
                      component.id,
                      Size(
                        component.size.width - step,
                        component.size.height - step,
                      ),
                    )
                    : null,
            icon: const Icon(Icons.remove),
            label: const Text('Smaller'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                enabled
                    ? () => controller.resizeComponent(
                      component.id,
                      Size(
                        component.size.width + step,
                        component.size.height + step,
                      ),
                    )
                    : null,
            icon: const Icon(Icons.add),
            label: const Text('Larger'),
          ),
        ),
      ],
    );
  }
}
