import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import '../models/grid_setting.dart';
import '../models/layout_health_summary.dart';
import '../models/layout_config.dart';
import '../models/layout_rule_preset.dart';
import '../models/layout_rules_conversion_preview.dart';
import '../models/layout_rules_version_name.dart';
import 'active_filter_bar.dart';
import 'color_picker.dart';
import 'filtered_empty_state.dart';
import 'grid_painter.dart';
import 'layout_health_summary_panel.dart';

/// Defines how applying Layout Rules should affect existing components.
enum LayoutRulesApplyStrategy { preserve, snapVisible, convertVisible }

/// Summarizes which visible components can be changed by a Layout Rules apply.
class LayoutRulesComponentScope {
  final int editableCount;
  final int lockedCount;
  final int hiddenCount;

  const LayoutRulesComponentScope({
    this.editableCount = 0,
    this.lockedCount = 0,
    this.hiddenCount = 0,
  });

  int get skippedCount => lockedCount + hiddenCount;
}

bool layoutRulesDraftHasChanges({
  required GridSettings initialSettings,
  required GridSettings draftSettings,
  required LayoutConfig initialConfig,
  required LayoutConfig draftConfig,
}) {
  return !_sameGridSettings(initialSettings, draftSettings) ||
      !_sameLayoutConfig(initialConfig, draftConfig);
}

bool layoutRulesDraftCanApply({
  required GridSettings initialSettings,
  required GridSettings draftSettings,
  required LayoutConfig initialConfig,
  required LayoutConfig draftConfig,
  required LayoutRulesApplyStrategy applyStrategy,
}) {
  return layoutRulesDraftHasChanges(
        initialSettings: initialSettings,
        draftSettings: draftSettings,
        initialConfig: initialConfig,
        draftConfig: draftConfig,
      ) ||
      applyStrategy != LayoutRulesApplyStrategy.preserve;
}

/// Falls back to Preserve when component geometry actions have no valid target.
LayoutRulesApplyStrategy layoutRulesEffectiveApplyStrategy({
  required LayoutRulesApplyStrategy strategy,
  required LayoutRulesComponentScope componentScope,
}) {
  if (componentScope.editableCount <= 0 &&
      strategy != LayoutRulesApplyStrategy.preserve) {
    return LayoutRulesApplyStrategy.preserve;
  }

  return strategy;
}

List<String> layoutRulesDraftChangeSummaries({
  required GridSettings initialSettings,
  required GridSettings draftSettings,
  required LayoutConfig initialConfig,
  required LayoutConfig draftConfig,
}) {
  final changes = <String>[];

  if (initialConfig.layoutMechanism != draftConfig.layoutMechanism) {
    changes.add(
      'Mechanism: ${initialConfig.layoutMechanism.label} -> ${draftConfig.layoutMechanism.label}',
    );
  }
  if (!_sameDouble(initialSettings.gridSize, draftSettings.gridSize)) {
    changes.add(
      'Cell size: ${_formatPx(initialSettings.gridSize)} -> ${_formatPx(draftSettings.gridSize)}',
    );
  }
  if (initialSettings.snapToGrid != draftSettings.snapToGrid) {
    changes.add(
      'Snap: ${_onOff(initialSettings.snapToGrid)} -> ${_onOff(draftSettings.snapToGrid)}',
    );
  }
  if (initialSettings.enabled != draftSettings.enabled) {
    changes.add(
      'Grid: ${_onOff(initialSettings.enabled)} -> ${_onOff(draftSettings.enabled)}',
    );
  }
  if (initialSettings.showSubgrid != draftSettings.showSubgrid) {
    changes.add(
      'Subgrid: ${_onOff(initialSettings.showSubgrid)} -> ${_onOff(draftSettings.showSubgrid)}',
    );
  }
  if (!_sameDouble(initialSettings.opacity, draftSettings.opacity)) {
    changes.add(
      'Opacity: ${_formatPercent(initialSettings.opacity)} -> ${_formatPercent(draftSettings.opacity)}',
    );
  }
  if (initialSettings.gridColor.toARGB32() !=
      draftSettings.gridColor.toARGB32()) {
    changes.add('Grid color changed');
  }
  if (!_sameDouble(initialConfig.canvasWidth, draftConfig.canvasWidth) ||
      !_sameDouble(initialConfig.canvasHeight, draftConfig.canvasHeight)) {
    changes.add(
      'Canvas: ${_formatSize(initialConfig.canvasWidth, initialConfig.canvasHeight)} -> ${_formatSize(draftConfig.canvasWidth, draftConfig.canvasHeight)}',
    );
  }

  _addTabularChanges(changes, initialConfig, draftConfig);
  _addAutoGridChanges(changes, initialConfig, draftConfig);

  return changes;
}

/// Returns the history label that will be created when the draft is applied.
String? layoutRulesDraftHistoryEntryName({
  required LayoutConfig config,
  required bool hasRuleChanges,
  required LayoutRulesApplyStrategy applyStrategy,
}) {
  if (!hasRuleChanges && applyStrategy == LayoutRulesApplyStrategy.preserve) {
    return null;
  }

  return layoutRulesVersionName(
    mechanism: config.layoutMechanism,
    snapVisiblePositions: applyStrategy != LayoutRulesApplyStrategy.preserve,
    snapVisibleSizes:
        applyStrategy == LayoutRulesApplyStrategy.convertVisible &&
        config.layoutMechanism != LayoutMechanism.freeform,
    resolveAutoGridConflicts:
        applyStrategy == LayoutRulesApplyStrategy.convertVisible &&
        config.layoutMechanism == LayoutMechanism.autoGrid,
    hasRuleChanges: hasRuleChanges,
  );
}

/// Edits layout mechanisms, grid rules, presets, and component apply behavior.
class LayoutRulesDraftEditor extends StatelessWidget {
  final GridSettings settings;
  final LayoutConfig config;
  final GridSettings? baselineSettings;
  final LayoutConfig? baselineConfig;
  final int visibleComponentCount;
  final LayoutRulesComponentScope? componentScope;
  final LayoutRulesConversionPreview? conversionPreview;
  final LayoutHealthSummary? healthSummary;
  final LayoutRulesApplyStrategy applyStrategy;
  final ValueChanged<GridSettings> onSettingsChanged;
  final ValueChanged<LayoutConfig> onConfigChanged;
  final ValueChanged<LayoutRulePreset> onPresetSelected;
  final ValueChanged<LayoutRulesApplyStrategy>? onApplyStrategyChanged;
  final VoidCallback? onRepositionInsideCanvas;
  final VoidCallback? onSelectOffCanvas;
  final VoidCallback? onSelectExpandableOffCanvas;
  final VoidCallback? onSelectRepositionOffCanvas;
  final VoidCallback? onSelectOffRulePositions;
  final VoidCallback? onSelectOffRuleSizes;
  final VoidCallback? onSelectAutoGridConflicts;

  const LayoutRulesDraftEditor({
    super.key,
    required this.settings,
    required this.config,
    this.baselineSettings,
    this.baselineConfig,
    this.visibleComponentCount = 0,
    this.componentScope,
    this.conversionPreview,
    this.healthSummary,
    this.applyStrategy = LayoutRulesApplyStrategy.preserve,
    required this.onSettingsChanged,
    required this.onConfigChanged,
    required this.onPresetSelected,
    this.onApplyStrategyChanged,
    this.onRepositionInsideCanvas,
    this.onSelectOffCanvas,
    this.onSelectExpandableOffCanvas,
    this.onSelectRepositionOffCanvas,
    this.onSelectOffRulePositions,
    this.onSelectOffRuleSizes,
    this.onSelectAutoGridConflicts,
  });

  @override
  Widget build(BuildContext context) {
    final scope =
        componentScope ??
        LayoutRulesComponentScope(editableCount: visibleComponentCount);
    final effectiveApplyStrategy = layoutRulesEffectiveApplyStrategy(
      strategy: applyStrategy,
      componentScope: scope,
    );
    final hasRuleChanges =
        baselineSettings == null || baselineConfig == null
            ? true
            : layoutRulesDraftHasChanges(
              initialSettings: baselineSettings!,
              draftSettings: settings,
              initialConfig: baselineConfig!,
              draftConfig: config,
            );
    final changeSummaries =
        baselineSettings == null || baselineConfig == null
            ? const <String>[]
            : layoutRulesDraftChangeSummaries(
              initialSettings: baselineSettings!,
              draftSettings: settings,
              initialConfig: baselineConfig!,
              draftConfig: config,
            );
    final historyEntryName = layoutRulesDraftHistoryEntryName(
      config: config,
      hasRuleChanges: hasRuleChanges,
      applyStrategy: effectiveApplyStrategy,
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RulesPreview(settings: settings, config: config),
          const SizedBox(height: 10),
          _RulesSummary(settings: settings, config: config),
          if (healthSummary != null) ...[
            const SizedBox(height: 12),
            LayoutHealthSummaryPanel(
              summary: healthSummary!,
              snapSelected:
                  effectiveApplyStrategy ==
                  LayoutRulesApplyStrategy.snapVisible,
              convertSelected:
                  effectiveApplyStrategy ==
                  LayoutRulesApplyStrategy.convertVisible,
              onUseSnap:
                  onApplyStrategyChanged == null
                      ? null
                      : () => onApplyStrategyChanged!(
                        LayoutRulesApplyStrategy.snapVisible,
                      ),
              onUseConvert:
                  onApplyStrategyChanged == null
                      ? null
                      : () => onApplyStrategyChanged!(
                        LayoutRulesApplyStrategy.convertVisible,
                      ),
              onCanvasSizeSelected:
                  (canvasSize) =>
                      onConfigChanged(config.copyWith(canvasSize: canvasSize)),
              onRepositionInsideCanvas: onRepositionInsideCanvas,
              onSelectOffCanvas: onSelectOffCanvas,
              onSelectExpandableOffCanvas: onSelectExpandableOffCanvas,
              onSelectRepositionOffCanvas: onSelectRepositionOffCanvas,
              onSelectOffRulePositions: onSelectOffRulePositions,
              onSelectOffRuleSizes: onSelectOffRuleSizes,
              onSelectAutoGridConflicts: onSelectAutoGridConflicts,
            ),
          ],
          const SizedBox(height: 12),
          _DraftImpactSummary(
            hasRuleChanges: hasRuleChanges,
            strategy: effectiveApplyStrategy,
            componentScope: scope,
            changeSummaries: changeSummaries,
            historyEntryName: historyEntryName,
          ),
          const SizedBox(height: 12),
          _PresetPicker(
            selectedPresetId: selectedLayoutRulePresetId(config, settings),
            onSelected: onPresetSelected,
          ),
          const SizedBox(height: 14),
          _MechanismSelector(
            mechanism: config.layoutMechanism,
            onChanged:
                (mechanism) => onConfigChanged(
                  config.copyWith(layoutMechanism: mechanism),
                ),
          ),
          const SizedBox(height: 12),
          _ApplyStrategySelector(
            strategy: effectiveApplyStrategy,
            componentScope: scope,
            conversionPreview: conversionPreview,
            onChanged: onApplyStrategyChanged,
          ),
          const SizedBox(height: 12),
          _RuleSwitches(
            settings: settings,
            config: config,
            onChanged: onSettingsChanged,
          ),
          const SizedBox(height: 8),
          _RuleSlider(
            label: _spacingLabelFor(config.layoutMechanism),
            value: settings.gridSize,
            min: 8,
            max: 80,
            divisions: 18,
            valueLabel: '${settings.gridSize.round()}px',
            onChanged:
                (value) =>
                    onSettingsChanged(settings.copyWith(gridSize: value)),
          ),
          _RuleSlider(
            label: 'Opacity',
            value: settings.opacity,
            min: 0.05,
            max: 0.8,
            divisions: 15,
            valueLabel: '${(settings.opacity * 100).round()}%',
            onChanged:
                (value) => onSettingsChanged(settings.copyWith(opacity: value)),
          ),
          const SizedBox(height: 8),
          ColorPicker(
            label: 'Color',
            color: settings.gridColor,
            onColorChanged:
                (color) =>
                    onSettingsChanged(settings.copyWith(gridColor: color)),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          _ModeRuleControls(
            settings: settings,
            config: config,
            onConfigChanged: onConfigChanged,
          ),
        ],
      ),
    );
  }
}

class _DraftImpactSummary extends StatelessWidget {
  final bool hasRuleChanges;
  final LayoutRulesApplyStrategy strategy;
  final LayoutRulesComponentScope componentScope;
  final List<String> changeSummaries;
  final String? historyEntryName;

  const _DraftImpactSummary({
    required this.hasRuleChanges,
    required this.strategy,
    required this.componentScope,
    required this.changeSummaries,
    required this.historyEntryName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = _draftImpactTitle(
      hasRuleChanges: hasRuleChanges,
      strategy: strategy,
    );
    final description = _draftImpactDescription(
      hasRuleChanges: hasRuleChanges,
      strategy: strategy,
      visibleComponentCount: componentScope.editableCount,
    );
    final color = _draftImpactColor(
      colorScheme: colorScheme,
      hasRuleChanges: hasRuleChanges,
      strategy: strategy,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _draftImpactIcon(
                hasRuleChanges: hasRuleChanges,
                strategy: strategy,
              ),
              size: 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (historyEntryName != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.history,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'History: $historyEntryName',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (changeSummaries.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final summary in changeSummaries)
                          _RuleChangeChip(label: summary),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleChangeChip extends StatelessWidget {
  final String label;

  const _RuleChangeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _RulesPreview extends StatelessWidget {
  final GridSettings settings;
  final LayoutConfig config;

  const _RulesPreview({required this.settings, required this.config});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: SizedBox(
          height: 96,
          child: CustomPaint(
            painter:
                settings.enabled
                    ? switch (config.layoutMechanism) {
                      LayoutMechanism.tabularColumns => TabularGridPainter(
                        columnCount: config.tabularColumnCount,
                        columnGap: config.tabularColumnGap,
                        rowHeight: config.tabularRowHeight,
                        color: settings.gridColor.withValues(
                          alpha: settings.opacity,
                        ),
                      ),
                      LayoutMechanism.autoGrid => AutoGridPainter(
                        columnCount: config.autoGridColumnCount,
                        gap: config.autoGridGap,
                        rowHeight: config.autoGridRowHeight,
                        color: settings.gridColor.withValues(
                          alpha: settings.opacity,
                        ),
                      ),
                      LayoutMechanism.freeform ||
                      LayoutMechanism.grid => GridPainter(
                        cellSize: Size.square(
                          settings.gridSize.clamp(8, 80).toDouble(),
                        ),
                        color: settings.gridColor.withValues(
                          alpha: settings.opacity,
                        ),
                        showSubgrid:
                            config.layoutMechanism == LayoutMechanism.grid &&
                            settings.showSubgrid,
                      ),
                    }
                    : null,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _RulesSummary extends StatelessWidget {
  final GridSettings settings;
  final LayoutConfig config;

  const _RulesSummary({required this.settings, required this.config});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetricChip(
          icon: _mechanismIcon(config.layoutMechanism),
          label: config.layoutMechanism.label,
        ),
        _MetricChip(
          icon: Icons.aspect_ratio,
          label:
              '${config.canvasWidth.round()} x ${config.canvasHeight.round()}',
        ),
        _MetricChip(
          icon: settings.snapToGrid ? Icons.grid_goldenratio : Icons.open_with,
          label: settings.snapToGrid ? 'Snap on' : 'Snap off',
        ),
        _MetricChip(
          icon: settings.enabled ? Icons.grid_on : Icons.grid_off,
          label: settings.enabled ? 'Grid on' : 'Grid off',
        ),
      ],
    );
  }
}

enum _PresetFilter { all, freeform, grid, tabularColumns, autoGrid }

class _PresetPicker extends StatefulWidget {
  final String? selectedPresetId;
  final ValueChanged<LayoutRulePreset> onSelected;

  const _PresetPicker({
    required this.selectedPresetId,
    required this.onSelected,
  });

  @override
  State<_PresetPicker> createState() => _PresetPickerState();
}

class _PresetPickerState extends State<_PresetPicker> {
  late final TextEditingController _searchController;
  var _filter = _PresetFilter.all;
  var _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final filteredPresets = layoutRulePresets
        .where((preset) => _filter.matches(preset.layoutMechanism))
        .where((preset) => _matchesPresetQuery(preset, normalizedQuery))
        .toList(growable: false);
    final filterTokens = _activeFilterTokens();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(icon: Icons.tune, label: 'Presets'),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey('layout-rule-preset-search'),
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search presets',
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon:
                _query.isEmpty
                    ? null
                    : IconButton(
                      tooltip: 'Clear preset search',
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _clearSearch,
                    ),
            isDense: true,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final filter in _PresetFilter.values)
              FilterChip(
                avatar: Icon(filter.icon, size: 16),
                label: Text(filter.label),
                selected: _filter == filter,
                onSelected: (_) => setState(() => _filter = filter),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
        const SizedBox(height: 8),
        ActiveFilterBar(
          title: 'Preset filters',
          tokens: filterTokens,
          clearAllLabel: 'Clear filters',
          onClearAll: _clearFilters,
        ),
        if (filterTokens.isNotEmpty) const SizedBox(height: 8),
        _PresetListSummary(
          visibleCount: filteredPresets.length,
          totalCount: layoutRulePresets.length,
        ),
        const SizedBox(height: 8),
        filteredPresets.isEmpty
            ? FilteredEmptyState(
              title: 'No presets found',
              onAction: _clearFilters,
            )
            : Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final preset in filteredPresets)
                  Tooltip(
                    message: preset.description,
                    child: FilterChip(
                      avatar: Icon(
                        _mechanismIcon(preset.layoutMechanism),
                        size: 16,
                      ),
                      label: Text(preset.label),
                      selected: widget.selectedPresetId == preset.id,
                      onSelected: (_) => widget.onSelected(preset),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
      ],
    );
  }

  List<ActiveFilterToken> _activeFilterTokens() {
    return [
      if (_filter != _PresetFilter.all)
        ActiveFilterToken(
          icon: _filter.icon,
          label: _filter.label,
          clearTooltip: 'Clear preset mechanism filter',
          onClear: () => setState(() => _filter = _PresetFilter.all),
        ),
      if (_query.trim().isNotEmpty)
        ActiveFilterToken(
          icon: Icons.search,
          label: 'Search: ${_query.trim()}',
          clearTooltip: 'Clear preset search',
          onClear: _clearSearch,
        ),
    ];
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _filter = _PresetFilter.all;
      _query = '';
    });
  }
}

class _PresetListSummary extends StatelessWidget {
  final int visibleCount;
  final int totalCount;

  const _PresetListSummary({
    required this.visibleCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.rule_folder_outlined, size: 16, color: colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$visibleCount of $totalCount presets',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

bool _matchesPresetQuery(LayoutRulePreset preset, String query) {
  if (query.isEmpty) return true;

  return [
    preset.label,
    preset.description,
    preset.layoutMechanism.label,
    preset.id,
  ].any((value) => value.toLowerCase().contains(query));
}

extension _PresetFilterX on _PresetFilter {
  String get label {
    switch (this) {
      case _PresetFilter.all:
        return 'All';
      case _PresetFilter.freeform:
        return 'Freeform';
      case _PresetFilter.grid:
        return 'Grid';
      case _PresetFilter.tabularColumns:
        return 'Tabular';
      case _PresetFilter.autoGrid:
        return 'Auto Grid';
    }
  }

  IconData get icon {
    switch (this) {
      case _PresetFilter.all:
        return Icons.dashboard_customize_outlined;
      case _PresetFilter.freeform:
        return _mechanismIcon(LayoutMechanism.freeform);
      case _PresetFilter.grid:
        return _mechanismIcon(LayoutMechanism.grid);
      case _PresetFilter.tabularColumns:
        return _mechanismIcon(LayoutMechanism.tabularColumns);
      case _PresetFilter.autoGrid:
        return _mechanismIcon(LayoutMechanism.autoGrid);
    }
  }

  bool matches(LayoutMechanism mechanism) {
    switch (this) {
      case _PresetFilter.all:
        return true;
      case _PresetFilter.freeform:
        return mechanism == LayoutMechanism.freeform;
      case _PresetFilter.grid:
        return mechanism == LayoutMechanism.grid;
      case _PresetFilter.tabularColumns:
        return mechanism == LayoutMechanism.tabularColumns;
      case _PresetFilter.autoGrid:
        return mechanism == LayoutMechanism.autoGrid;
    }
  }
}

class _MechanismSelector extends StatelessWidget {
  final LayoutMechanism mechanism;
  final ValueChanged<LayoutMechanism> onChanged;

  const _MechanismSelector({required this.mechanism, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(icon: Icons.account_tree_outlined, label: 'Mechanism'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: KyBuilderSegmentedSelector<LayoutMechanism>(
            options: const [
              KyBuilderSegmentOption(
                value: LayoutMechanism.freeform,
                icon: Icons.open_with,
                label: 'Free',
                tooltip: 'Freeform',
              ),
              KyBuilderSegmentOption(
                value: LayoutMechanism.grid,
                icon: Icons.grid_4x4,
                label: 'Grid',
                tooltip: 'Grid',
              ),
              KyBuilderSegmentOption(
                value: LayoutMechanism.tabularColumns,
                icon: Icons.view_column_outlined,
                label: 'Columns',
                tooltip: 'Tabular Columns',
              ),
              KyBuilderSegmentOption(
                value: LayoutMechanism.autoGrid,
                icon: Icons.dashboard_customize_outlined,
                label: 'Auto',
                tooltip: 'Auto Grid',
              ),
            ],
            selectedValue: mechanism,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

/// Selects how Layout Rules apply to existing editable components.
class _ApplyStrategySelector extends StatelessWidget {
  final LayoutRulesApplyStrategy strategy;
  final LayoutRulesComponentScope componentScope;
  final LayoutRulesConversionPreview? conversionPreview;
  final ValueChanged<LayoutRulesApplyStrategy>? onChanged;

  const _ApplyStrategySelector({
    required this.strategy,
    required this.componentScope,
    required this.conversionPreview,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasEditableComponents = componentScope.editableCount > 0;
    final canAdjustComponents = hasEditableComponents && onChanged != null;
    final description = _strategyDescription(
      strategy,
      componentScope.editableCount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(icon: Icons.rule_folder_outlined, label: 'Apply mode'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: KyBuilderSegmentedSelector<LayoutRulesApplyStrategy>(
            options: [
              const KyBuilderSegmentOption(
                value: LayoutRulesApplyStrategy.preserve,
                icon: Icons.near_me_disabled_outlined,
                label: 'Preserve',
                tooltip: 'Preserve component positions and sizes',
              ),
              KyBuilderSegmentOption(
                value: LayoutRulesApplyStrategy.snapVisible,
                icon: Icons.grid_goldenratio,
                label: 'Snap',
                tooltip: 'Snap visible component positions',
                enabled: canAdjustComponents,
              ),
              KyBuilderSegmentOption(
                value: LayoutRulesApplyStrategy.convertVisible,
                icon: Icons.auto_fix_high_outlined,
                label: 'Convert',
                tooltip: 'Snap visible component positions and sizes',
                enabled: canAdjustComponents,
              ),
            ],
            selectedValue: strategy,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 8),
        _ApplyStrategySummary(
          icon: _strategyIcon(strategy),
          description: description,
        ),
        if (!hasEditableComponents) ...[
          const SizedBox(height: 8),
          _NoEditableComponentsNotice(scope: componentScope),
        ],
        if (strategy != LayoutRulesApplyStrategy.preserve) ...[
          const SizedBox(height: 8),
          _ConversionScopePreview(scope: componentScope),
          if (conversionPreview != null) ...[
            const SizedBox(height: 8),
            _ConversionDryRunReport(preview: conversionPreview!),
          ],
        ],
      ],
    );
  }
}

/// Explains why component geometry apply modes are unavailable.
class _NoEditableComponentsNotice extends StatelessWidget {
  final LayoutRulesComponentScope scope;

  const _NoEditableComponentsNotice({required this.scope});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.block, size: 18, color: colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No editable components to snap or convert.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (scope.skippedCount > 0) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (scope.lockedCount > 0)
                    _MetricChip(
                      icon: Icons.lock_outline,
                      label: '${scope.lockedCount} locked skipped',
                    ),
                  if (scope.hiddenCount > 0)
                    _MetricChip(
                      icon: Icons.visibility_off_outlined,
                      label: '${scope.hiddenCount} hidden skipped',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lists component counts that will or will not be changed by conversion.
class _ConversionScopePreview extends StatelessWidget {
  final LayoutRulesComponentScope scope;

  const _ConversionScopePreview({required this.scope});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetricChip(
          icon: Icons.edit_outlined,
          label: '${scope.editableCount} editable',
        ),
        if (scope.lockedCount > 0)
          _MetricChip(
            icon: Icons.lock_outline,
            label: '${scope.lockedCount} locked skipped',
          ),
        if (scope.hiddenCount > 0)
          _MetricChip(
            icon: Icons.visibility_off_outlined,
            label: '${scope.hiddenCount} hidden skipped',
          ),
      ],
    );
  }
}

/// Summarizes expected geometry changes before applying Layout Rules.
class _ConversionDryRunReport extends StatelessWidget {
  final LayoutRulesConversionPreview preview;

  const _ConversionDryRunReport({required this.preview});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (!preview.hasGeometryChanges)
          const _MetricChip(
            icon: Icons.check_circle_outline,
            label: 'No geometry changes',
          ),
        if (preview.moveCount > 0)
          _MetricChip(
            icon: Icons.route_outlined,
            label: '${preview.moveCount} will move',
          ),
        if (preview.resizeCount > 0)
          _MetricChip(
            icon: Icons.aspect_ratio,
            label: '${preview.resizeCount} will resize',
          ),
        if (preview.unchangedCount > 0)
          _MetricChip(
            icon: Icons.check_outlined,
            label: '${preview.unchangedCount} unchanged',
          ),
        if (preview.autoGridConflictCount > 0)
          _MetricChip(
            icon: Icons.warning_amber_outlined,
            label: '${preview.autoGridConflictCount} Auto Grid conflicts',
          ),
      ],
    );
  }
}

/// Displays the selected Layout Rules apply mode in plain language.
class _ApplyStrategySummary extends StatelessWidget {
  final IconData icon;
  final String description;

  const _ApplyStrategySummary({required this.icon, required this.description});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleSwitches extends StatelessWidget {
  final GridSettings settings;
  final LayoutConfig config;
  final ValueChanged<GridSettings> onChanged;

  const _RuleSwitches({
    required this.settings,
    required this.config,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canShowSubgrid =
        settings.enabled && config.layoutMechanism == LayoutMechanism.grid;

    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Show grid'),
          value: settings.enabled,
          onChanged: (value) => onChanged(settings.copyWith(enabled: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Snap to rules'),
          value: settings.snapToGrid,
          onChanged:
              (value) => onChanged(
                settings.copyWith(
                  snapToGrid: value,
                  enabled: value ? true : settings.enabled,
                ),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Show subgrid'),
          value: settings.showSubgrid,
          onChanged:
              canShowSubgrid
                  ? (value) => onChanged(settings.copyWith(showSubgrid: value))
                  : null,
        ),
      ],
    );
  }
}

class _ModeRuleControls extends StatelessWidget {
  final GridSettings settings;
  final LayoutConfig config;
  final ValueChanged<LayoutConfig> onConfigChanged;

  const _ModeRuleControls({
    required this.settings,
    required this.config,
    required this.onConfigChanged,
  });

  @override
  Widget build(BuildContext context) {
    return switch (config.layoutMechanism) {
      LayoutMechanism.freeform => _FreeformRuleControls(
        settings: settings,
        config: config,
      ),
      LayoutMechanism.grid => _GridRuleControls(
        settings: settings,
        config: config,
      ),
      LayoutMechanism.tabularColumns => _TabularRuleControls(
        config: config,
        onConfigChanged: onConfigChanged,
      ),
      LayoutMechanism.autoGrid => _AutoGridRuleControls(
        config: config,
        onConfigChanged: onConfigChanged,
      ),
    };
  }
}

class _FreeformRuleControls extends StatelessWidget {
  final GridSettings settings;
  final LayoutConfig config;

  const _FreeformRuleControls({required this.settings, required this.config});

  @override
  Widget build(BuildContext context) {
    return _RuleMetricPanel(
      icon: Icons.open_with,
      title: 'Freeform rules',
      metrics: [
        _RuleMetric(
          icon: Icons.straighten,
          label: '${settings.gridSize.round()}px reference',
        ),
        _RuleMetric(
          icon: settings.snapToGrid ? Icons.grid_goldenratio : Icons.open_with,
          label: settings.snapToGrid ? 'Grid snap' : 'Free placement',
        ),
        _RuleMetric(
          icon: Icons.aspect_ratio,
          label:
              '${config.canvasWidth.round()} x ${config.canvasHeight.round()} canvas',
        ),
      ],
    );
  }
}

class _GridRuleControls extends StatelessWidget {
  final GridSettings settings;
  final LayoutConfig config;

  const _GridRuleControls({required this.settings, required this.config});

  @override
  Widget build(BuildContext context) {
    final cellSize = settings.gridSize.clamp(1, double.infinity).toDouble();
    final columns = (config.canvasWidth / cellSize).floor().clamp(1, 999);
    final rows = (config.canvasHeight / cellSize).floor().clamp(1, 999);

    return _RuleMetricPanel(
      icon: Icons.grid_4x4,
      title: 'Grid rules',
      metrics: [
        _RuleMetric(
          icon: Icons.crop_square,
          label: '${settings.gridSize.round()}px cells',
        ),
        _RuleMetric(
          icon: Icons.view_module_outlined,
          label: '$columns columns',
        ),
        _RuleMetric(icon: Icons.table_rows_outlined, label: '$rows rows'),
        _RuleMetric(
          icon: settings.showSubgrid ? Icons.grid_on : Icons.grid_off,
          label: settings.showSubgrid ? 'Subgrid on' : 'Subgrid off',
        ),
      ],
    );
  }
}

class _TabularRuleControls extends StatelessWidget {
  final LayoutConfig config;
  final ValueChanged<LayoutConfig> onConfigChanged;

  const _TabularRuleControls({
    required this.config,
    required this.onConfigChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RuleMetricPanel(
          icon: Icons.view_column_outlined,
          title: 'Tabular column rules',
          metrics: [
            _RuleMetric(
              icon: Icons.view_column_outlined,
              label: '${config.tabularColumnCount} columns',
            ),
            _RuleMetric(
              icon: Icons.width_normal,
              label: '${config.tabularColumnWidth.round()}px width',
            ),
            _RuleMetric(
              icon: Icons.space_bar,
              label: '${config.tabularColumnGap.round()}px gap',
            ),
            _RuleMetric(
              icon: Icons.table_rows_outlined,
              label: '${config.tabularRowHeight.round()}px rows',
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ColumnPresetChips(
          label: 'Column presets',
          values: const [4, 8, 12, 16],
          selectedValue: config.tabularColumnCount,
          onSelected:
              (value) =>
                  onConfigChanged(config.copyWith(tabularColumnCount: value)),
        ),
        const SizedBox(height: 8),
        _RuleSlider(
          label: 'Columns',
          value: config.tabularColumnCount.toDouble(),
          min: 2,
          max: 24,
          divisions: 22,
          valueLabel: '${config.tabularColumnCount}',
          onChanged:
              (value) => onConfigChanged(
                config.copyWith(tabularColumnCount: value.round()),
              ),
        ),
        _RuleSlider(
          label: 'Gap',
          value: config.tabularColumnGap,
          min: 0,
          max: 48,
          divisions: 24,
          valueLabel: '${config.tabularColumnGap.round()}px',
          onChanged:
              (value) =>
                  onConfigChanged(config.copyWith(tabularColumnGap: value)),
        ),
        _RuleSlider(
          label: 'Row height',
          value: config.tabularRowHeight,
          min: 24,
          max: 160,
          divisions: 17,
          valueLabel: '${config.tabularRowHeight.round()}px',
          onChanged:
              (value) =>
                  onConfigChanged(config.copyWith(tabularRowHeight: value)),
        ),
      ],
    );
  }
}

class _AutoGridRuleControls extends StatelessWidget {
  final LayoutConfig config;
  final ValueChanged<LayoutConfig> onConfigChanged;

  const _AutoGridRuleControls({
    required this.config,
    required this.onConfigChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RuleMetricPanel(
          icon: Icons.dashboard_customize_outlined,
          title: 'Auto Grid rules',
          metrics: [
            _RuleMetric(
              icon: Icons.view_column_outlined,
              label: '${config.autoGridColumnCount} columns',
            ),
            _RuleMetric(
              icon: Icons.width_normal,
              label: '${config.autoGridColumnWidth.round()}px width',
            ),
            _RuleMetric(
              icon: Icons.space_bar,
              label: '${config.autoGridGap.round()}px gap',
            ),
            _RuleMetric(
              icon: Icons.table_rows_outlined,
              label: '${config.autoGridRowHeight.round()}px rows',
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ColumnPresetChips(
          label: 'Column presets',
          values: const [2, 3, 4, 6, 8, 12],
          selectedValue: config.autoGridColumnCount,
          onSelected:
              (value) =>
                  onConfigChanged(config.copyWith(autoGridColumnCount: value)),
        ),
        const SizedBox(height: 8),
        _RuleSlider(
          label: 'Columns',
          value: config.autoGridColumnCount.toDouble(),
          min: 1,
          max: 12,
          divisions: 11,
          valueLabel: '${config.autoGridColumnCount}',
          onChanged:
              (value) => onConfigChanged(
                config.copyWith(autoGridColumnCount: value.round()),
              ),
        ),
        _RuleSlider(
          label: 'Gap',
          value: config.autoGridGap,
          min: 0,
          max: 48,
          divisions: 24,
          valueLabel: '${config.autoGridGap.round()}px',
          onChanged:
              (value) => onConfigChanged(config.copyWith(autoGridGap: value)),
        ),
        _RuleSlider(
          label: 'Row height',
          value: config.autoGridRowHeight,
          min: 48,
          max: 260,
          divisions: 53,
          valueLabel: '${config.autoGridRowHeight.round()}px',
          onChanged:
              (value) =>
                  onConfigChanged(config.copyWith(autoGridRowHeight: value)),
        ),
      ],
    );
  }
}

class _ColumnPresetChips extends StatelessWidget {
  final String label;
  final List<int> values;
  final int selectedValue;
  final ValueChanged<int> onSelected;

  const _ColumnPresetChips({
    required this.label,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final value in values)
              FilterChip(
                label: Text('$value cols'),
                selected: selectedValue == value,
                onSelected: (_) => onSelected(value),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
      ],
    );
  }
}

class _RuleMetricPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_RuleMetric> metrics;

  const _RuleMetricPanel({
    required this.icon,
    required this.title,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final metric in metrics)
                  _MetricChip(icon: metric.icon, label: metric.label),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleMetric {
  final IconData icon;
  final String label;

  const _RuleMetric({required this.icon, required this.label});
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}

class _RuleSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  const _RuleSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            label: valueLabel,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 56,
          child: Text(
            valueLabel,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}

String _spacingLabelFor(LayoutMechanism mechanism) {
  switch (mechanism) {
    case LayoutMechanism.freeform:
      return 'Reference';
    case LayoutMechanism.grid:
      return 'Cell size';
    case LayoutMechanism.tabularColumns:
      return 'Guide';
    case LayoutMechanism.autoGrid:
      return 'Guide';
  }
}

IconData _mechanismIcon(LayoutMechanism mechanism) {
  switch (mechanism) {
    case LayoutMechanism.freeform:
      return Icons.open_with;
    case LayoutMechanism.grid:
      return Icons.grid_4x4;
    case LayoutMechanism.tabularColumns:
      return Icons.view_column_outlined;
    case LayoutMechanism.autoGrid:
      return Icons.dashboard_customize_outlined;
  }
}

IconData _strategyIcon(LayoutRulesApplyStrategy strategy) {
  switch (strategy) {
    case LayoutRulesApplyStrategy.preserve:
      return Icons.near_me_disabled_outlined;
    case LayoutRulesApplyStrategy.snapVisible:
      return Icons.grid_goldenratio;
    case LayoutRulesApplyStrategy.convertVisible:
      return Icons.auto_fix_high_outlined;
  }
}

String _strategyDescription(
  LayoutRulesApplyStrategy strategy,
  int visibleComponentCount,
) {
  if (visibleComponentCount == 0 &&
      strategy != LayoutRulesApplyStrategy.preserve) {
    return 'No editable components to update.';
  }

  final componentLabel =
      visibleComponentCount == 1
          ? '1 editable component'
          : '$visibleComponentCount editable components';

  switch (strategy) {
    case LayoutRulesApplyStrategy.preserve:
      return 'Keep existing component positions and sizes.';
    case LayoutRulesApplyStrategy.snapVisible:
      return 'Snap positions for $componentLabel.';
    case LayoutRulesApplyStrategy.convertVisible:
      return 'Snap positions and sizes for $componentLabel.';
  }
}

IconData _draftImpactIcon({
  required bool hasRuleChanges,
  required LayoutRulesApplyStrategy strategy,
}) {
  if (!hasRuleChanges && strategy == LayoutRulesApplyStrategy.preserve) {
    return Icons.check_circle_outline;
  }

  return switch (strategy) {
    LayoutRulesApplyStrategy.preserve => Icons.rule_folder_outlined,
    LayoutRulesApplyStrategy.snapVisible => Icons.grid_goldenratio,
    LayoutRulesApplyStrategy.convertVisible => Icons.auto_fix_high_outlined,
  };
}

String _draftImpactTitle({
  required bool hasRuleChanges,
  required LayoutRulesApplyStrategy strategy,
}) {
  if (!hasRuleChanges && strategy == LayoutRulesApplyStrategy.preserve) {
    return 'No pending changes';
  }

  return switch (strategy) {
    LayoutRulesApplyStrategy.preserve => 'Rules will update',
    LayoutRulesApplyStrategy.snapVisible => 'Positions will snap',
    LayoutRulesApplyStrategy.convertVisible => 'Components will convert',
  };
}

String _draftImpactDescription({
  required bool hasRuleChanges,
  required LayoutRulesApplyStrategy strategy,
  required int visibleComponentCount,
}) {
  if (!hasRuleChanges && strategy == LayoutRulesApplyStrategy.preserve) {
    return 'Change a rule or choose an apply mode to enable Apply.';
  }

  final rulePrefix = hasRuleChanges ? 'Rules update' : 'Rules stay unchanged';
  final componentLabel =
      visibleComponentCount == 1
          ? '1 editable component'
          : '$visibleComponentCount editable components';

  return switch (strategy) {
    LayoutRulesApplyStrategy.preserve =>
      '$rulePrefix; components keep their current positions and sizes.',
    LayoutRulesApplyStrategy.snapVisible =>
      '$rulePrefix; positions snap for $componentLabel.',
    LayoutRulesApplyStrategy.convertVisible =>
      '$rulePrefix; positions and sizes conform for $componentLabel.',
  };
}

Color _draftImpactColor({
  required ColorScheme colorScheme,
  required bool hasRuleChanges,
  required LayoutRulesApplyStrategy strategy,
}) {
  if (!hasRuleChanges && strategy == LayoutRulesApplyStrategy.preserve) {
    return colorScheme.outline;
  }

  return switch (strategy) {
    LayoutRulesApplyStrategy.preserve => colorScheme.primary,
    LayoutRulesApplyStrategy.snapVisible => colorScheme.tertiary,
    LayoutRulesApplyStrategy.convertVisible => colorScheme.primary,
  };
}

void _addTabularChanges(
  List<String> changes,
  LayoutConfig initialConfig,
  LayoutConfig draftConfig,
) {
  final isRelevant =
      initialConfig.layoutMechanism == LayoutMechanism.tabularColumns ||
      draftConfig.layoutMechanism == LayoutMechanism.tabularColumns;
  if (!isRelevant) return;

  if (initialConfig.tabularColumnCount != draftConfig.tabularColumnCount) {
    changes.add(
      'Columns: ${initialConfig.tabularColumnCount} -> ${draftConfig.tabularColumnCount}',
    );
  }
  if (!_sameDouble(
    initialConfig.tabularColumnGap,
    draftConfig.tabularColumnGap,
  )) {
    changes.add(
      'Column gap: ${_formatPx(initialConfig.tabularColumnGap)} -> ${_formatPx(draftConfig.tabularColumnGap)}',
    );
  }
  if (!_sameDouble(
    initialConfig.tabularRowHeight,
    draftConfig.tabularRowHeight,
  )) {
    changes.add(
      'Row height: ${_formatPx(initialConfig.tabularRowHeight)} -> ${_formatPx(draftConfig.tabularRowHeight)}',
    );
  }
}

void _addAutoGridChanges(
  List<String> changes,
  LayoutConfig initialConfig,
  LayoutConfig draftConfig,
) {
  final isRelevant =
      initialConfig.layoutMechanism == LayoutMechanism.autoGrid ||
      draftConfig.layoutMechanism == LayoutMechanism.autoGrid;
  if (!isRelevant) return;

  if (initialConfig.autoGridColumnCount != draftConfig.autoGridColumnCount) {
    changes.add(
      'Auto columns: ${initialConfig.autoGridColumnCount} -> ${draftConfig.autoGridColumnCount}',
    );
  }
  if (!_sameDouble(initialConfig.autoGridGap, draftConfig.autoGridGap)) {
    changes.add(
      'Auto gap: ${_formatPx(initialConfig.autoGridGap)} -> ${_formatPx(draftConfig.autoGridGap)}',
    );
  }
  if (!_sameDouble(
    initialConfig.autoGridRowHeight,
    draftConfig.autoGridRowHeight,
  )) {
    changes.add(
      'Auto row height: ${_formatPx(initialConfig.autoGridRowHeight)} -> ${_formatPx(draftConfig.autoGridRowHeight)}',
    );
  }
}

String _formatPx(double value) => '${value.round()}px';

String _formatPercent(double value) => '${(value * 100).round()}%';

String _formatSize(double width, double height) {
  return '${width.round()} x ${height.round()}';
}

String _onOff(bool value) => value ? 'on' : 'off';

bool _sameGridSettings(GridSettings left, GridSettings right) {
  return _sameDouble(left.gridSize, right.gridSize) &&
      _sameDouble(left.opacity, right.opacity) &&
      left.enabled == right.enabled &&
      left.snapToGrid == right.snapToGrid &&
      left.gridColor.toARGB32() == right.gridColor.toARGB32() &&
      left.showSubgrid == right.showSubgrid;
}

bool _sameLayoutConfig(LayoutConfig left, LayoutConfig right) {
  return _sameDouble(left.gridSize, right.gridSize) &&
      _sameDouble(left.canvasWidth, right.canvasWidth) &&
      _sameDouble(left.canvasHeight, right.canvasHeight) &&
      _sameDouble(left.minComponentWidth, right.minComponentWidth) &&
      _sameDouble(left.minComponentHeight, right.minComponentHeight) &&
      left.snapToGrid == right.snapToGrid &&
      left.showGrid == right.showGrid &&
      left.layoutMechanism == right.layoutMechanism &&
      left.tabularColumnCount == right.tabularColumnCount &&
      _sameDouble(left.tabularColumnGap, right.tabularColumnGap) &&
      _sameDouble(left.tabularRowHeight, right.tabularRowHeight) &&
      left.autoGridColumnCount == right.autoGridColumnCount &&
      _sameDouble(left.autoGridGap, right.autoGridGap) &&
      _sameDouble(left.autoGridRowHeight, right.autoGridRowHeight);
}

bool _sameDouble(double left, double right) {
  return (left - right).abs() < 0.01;
}

@Preview(name: 'Layout Rules draft editor')
Widget layoutRulesDraftEditorPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 460,
          height: 820,
          child: _LayoutRulesDraftEditorPreviewHarness(),
        ),
      ),
    ),
  );
}

/// Provides mutable sample state for the Layout Rules editor widget preview.
class _LayoutRulesDraftEditorPreviewHarness extends StatefulWidget {
  const _LayoutRulesDraftEditorPreviewHarness();

  @override
  State<_LayoutRulesDraftEditorPreviewHarness> createState() =>
      _LayoutRulesDraftEditorPreviewHarnessState();
}

/// Holds interactive draft values while previewing the Layout Rules editor.
class _LayoutRulesDraftEditorPreviewHarnessState
    extends State<_LayoutRulesDraftEditorPreviewHarness> {
  static const _baselineSettings = GridSettings();
  static const _baselineConfig = LayoutConfig();
  static const _conversionPreview = LayoutRulesConversionPreview(
    editableCount: 6,
    moveCount: 4,
    resizeCount: 2,
    changedCount: 5,
    unchangedCount: 1,
    autoGridConflictCount: 1,
  );
  static const _healthSummary = LayoutHealthSummary(
    visibleComponentCount: 7,
    editableComponentCount: 6,
    lockedComponentCount: 1,
    hiddenComponentCount: 2,
    offCanvasCount: 2,
    expandableOffCanvasCount: 1,
    repositionOffCanvasCount: 1,
    repositionableOffCanvasCount: 1,
    offRulePositionCount: 4,
    offRuleSizeCount: 2,
    autoGridConflictCount: 1,
    offCanvasComponentIds: ['left-top', 'right-bottom'],
    expandableOffCanvasComponentIds: ['right-bottom'],
    repositionOffCanvasComponentIds: ['left-top'],
    offRulePositionComponentIds: ['left-top', 'right-bottom'],
    offRuleSizeComponentIds: ['left-top'],
    autoGridConflictComponentIds: ['right-bottom'],
    expandedCanvasSize: Size(1320, 900),
    repositionOffset: Offset(24, 12),
  );

  var _settings = const GridSettings(gridSize: 24, opacity: 0.32);
  var _config = const LayoutConfig(
    layoutMechanism: LayoutMechanism.autoGrid,
    autoGridColumnCount: 4,
    autoGridGap: 16,
    autoGridRowHeight: 140,
  );
  var _applyStrategy = LayoutRulesApplyStrategy.convertVisible;

  @override
  Widget build(BuildContext context) {
    return LayoutRulesDraftEditor(
      settings: _settings,
      config: _config,
      baselineSettings: _baselineSettings,
      baselineConfig: _baselineConfig,
      componentScope: const LayoutRulesComponentScope(
        editableCount: 6,
        lockedCount: 1,
        hiddenCount: 2,
      ),
      conversionPreview: _conversionPreview,
      healthSummary: _healthSummary,
      applyStrategy: _applyStrategy,
      onSettingsChanged: (settings) => setState(() => _settings = settings),
      onConfigChanged: (config) => setState(() => _config = config),
      onPresetSelected:
          (preset) => setState(() {
            _settings = preset.applyToGridSettings(_settings);
            _config = preset.applyToConfig(_config);
          }),
      onApplyStrategyChanged:
          (strategy) => setState(() => _applyStrategy = strategy),
      onRepositionInsideCanvas: () {},
      onSelectOffCanvas: () {},
      onSelectExpandableOffCanvas: () {},
      onSelectRepositionOffCanvas: () {},
      onSelectOffRulePositions: () {},
      onSelectOffRuleSizes: () {},
      onSelectAutoGridConflicts: () {},
    );
  }
}
