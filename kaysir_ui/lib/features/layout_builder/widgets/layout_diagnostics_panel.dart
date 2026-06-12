import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../provider/layout_data_binding_provider.dart';
import '../provider/layout_state_provider.dart';
import '../services/layout_clear_spot_action_service.dart';
import '../utils/layout_clear_spot_labels.dart';
import 'active_filter_bar.dart';
import 'filtered_empty_state.dart';

const Size _defaultCanvasSize = Size(
  LayoutConfig.defaultCanvasWidth,
  LayoutConfig.defaultCanvasHeight,
);
const double _minimumTouchTarget = 48;
const Set<String> _knownEventNames = {
  'onTap',
  'onLongPress',
  'onSubmit',
  'onFocus',
  'onValueChanged',
};
const Set<String> _knownEventHandlers = {
  'pos.product.add',
  'pos.pay',
  'pos.discount.open',
  'pos.order.void',
  'pos.receipt.print',
  'pos.input.clear',
  'pos.customer.select',
};

class LayoutDiagnosticsPanel extends ConsumerStatefulWidget {
  const LayoutDiagnosticsPanel({super.key});

  @override
  ConsumerState<LayoutDiagnosticsPanel> createState() =>
      _LayoutDiagnosticsPanelState();
}

class ComponentDiagnosticsCard extends ConsumerWidget {
  final String componentId;

  const ComponentDiagnosticsCard({super.key, required this.componentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SelectionDiagnosticsCard(componentIds: {componentId});
  }
}

class SelectionDiagnosticsCard extends ConsumerWidget {
  final Set<String> componentIds;

  const SelectionDiagnosticsCard({super.key, required this.componentIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (componentIds.isEmpty) return const SizedBox.shrink();

    final layoutState = ref.watch(layoutStateProvider);
    final bindings = ref
        .watch(layoutDataBindingProvider)
        .maybeWhen(
          data: (values) => values,
          orElse: LayoutDataBindingValues.fallback,
        );
    final diagnostics =
        _buildLayoutDiagnostics(
              layoutState.components,
              bindings: bindings,
              canvasSize: layoutState.config.canvasSize,
              layoutConfig: layoutState.config,
            )
            .where(
              (diagnostic) =>
                  diagnostic.targetComponentIds.any(componentIds.contains),
            )
            .toList();
    final selectedIds =
        layoutState.selectedComponentIds.isNotEmpty
            ? layoutState.selectedComponentIds
            : {
              if (layoutState.selectedComponentId != null)
                layoutState.selectedComponentId!,
            };
    final isCurrentSelectionCard =
        selectedIds.isNotEmpty &&
        selectedIds.length == componentIds.length &&
        selectedIds.containsAll(componentIds);
    final clearSpotAction = LayoutClearSpotActionState.fromSelection(
      hasSelection: isCurrentSelectionCard,
      preview:
          ref
              .read(layoutStateProvider.notifier)
              .selectedConflictResolutionPreview(),
    );

    if (diagnostics.isEmpty && !clearSpotAction.isAvailable) {
      return const SizedBox.shrink();
    }

    final affectedComponentIds = <String>{
      for (final diagnostic in diagnostics) ...diagnostic.targetComponentIds,
    };
    final colorScheme = Theme.of(context).colorScheme;
    final warningCount =
        diagnostics
            .where((item) => item.severity == _DiagnosticSeverity.warning)
            .length;
    final noteCount = diagnostics.length - warningCount;
    final fixCount =
        diagnostics
            .where(
              (diagnostic) =>
                  diagnostic.quickFix != null &&
                  diagnostic.targetComponentIds.isNotEmpty,
            )
            .length;
    final shouldShowSelectAffected =
        affectedComponentIds.isNotEmpty &&
        (affectedComponentIds.length != componentIds.length ||
            !componentIds.containsAll(affectedComponentIds));

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
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
                  Icon(
                    warningCount > 0
                        ? Icons.report_problem_outlined
                        : Icons.info_outline,
                    size: 18,
                    color:
                        warningCount > 0
                            ? colorScheme.error
                            : colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _componentDiagnosticsSummaryLabel(
                        warnings: warningCount,
                        notes: noteCount,
                        hasClearSpotAction: clearSpotAction.isAvailable,
                      ),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (clearSpotAction.isAvailable)
                    Tooltip(
                      message:
                          'Move selected components to ${clearSpotAction.sentenceTargetLabel}',
                      child: OutlinedButton.icon(
                        key: const ValueKey(
                          'layout-diagnostics-move-clear-spot',
                        ),
                        icon: const Icon(Icons.near_me_outlined, size: 16),
                        label: Text(
                          clearSpotAction.menuActionLabel(prefix: 'Move to'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: () => _moveSelectedToClearSpot(context, ref),
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                  if (shouldShowSelectAffected)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.select_all, size: 16),
                      label: Text(
                        'Select affected (${affectedComponentIds.length})',
                      ),
                      onPressed:
                          () => ref
                              .read(layoutStateProvider.notifier)
                              .selectComponents(affectedComponentIds),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  if (fixCount > 1)
                    TextButton.icon(
                      icon: const Icon(Icons.auto_fix_high_outlined, size: 16),
                      label: Text('Fix $fixCount'),
                      onPressed:
                          () => _applyDiagnosticQuickFixes(ref, diagnostics),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.content_copy_outlined, size: 16),
                    label: const Text('Copy'),
                    onPressed:
                        () => _copyDiagnosticsReportFromContext(
                          context,
                          diagnostics,
                          warningCount,
                        ),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final diagnostic in diagnostics)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _ComponentDiagnosticRow(diagnostic: diagnostic),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LayoutDiagnosticsPanelState
    extends ConsumerState<LayoutDiagnosticsPanel> {
  late final TextEditingController _searchController;
  var _query = '';
  var _filter = _DiagnosticFilter.all;

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
    final layoutState = ref.watch(layoutStateProvider);
    final bindings = ref
        .watch(layoutDataBindingProvider)
        .maybeWhen(
          data: (values) => values,
          orElse: LayoutDataBindingValues.fallback,
        );
    final diagnostics = _buildLayoutDiagnostics(
      layoutState.components,
      bindings: bindings,
      canvasSize: layoutState.config.canvasSize,
      layoutConfig: layoutState.config,
    );
    final filteredDiagnostics =
        diagnostics.where(_matchesFilter).where(_matchesQuery).toList();
    final shownTargetIds = <String>{
      for (final diagnostic in filteredDiagnostics)
        ...diagnostic.targetComponentIds,
    };
    final warnings =
        diagnostics
            .where((item) => item.severity == _DiagnosticSeverity.warning)
            .length;
    final notes = diagnostics.length - warnings;
    final shownFixes =
        filteredDiagnostics
            .where(
              (item) =>
                  item.quickFix != null && item.targetComponentIds.isNotEmpty,
            )
            .length;
    final hasQuery = _query.isNotEmpty;
    final hasActiveFilter = _filter != _DiagnosticFilter.all;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Diagnostics', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _DiagnosticsSummary(
          componentCount: layoutState.components.length,
          issueCount: diagnostics.length,
          warningCount: warnings,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          enabled: diagnostics.isNotEmpty,
          decoration: InputDecoration(
            hintText: 'Search issues',
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                _query.isEmpty
                    ? null
                    : IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Clear search',
                      onPressed: _clearDiagnosticSearch,
                    ),
            isDense: true,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _DiagnosticFilterChip(
              label: 'All ${diagnostics.length}',
              selected: _filter == _DiagnosticFilter.all,
              onSelected: () => setState(() => _filter = _DiagnosticFilter.all),
            ),
            _DiagnosticFilterChip(
              label: 'Warnings $warnings',
              selected: _filter == _DiagnosticFilter.warnings,
              onSelected:
                  () => setState(() => _filter = _DiagnosticFilter.warnings),
            ),
            _DiagnosticFilterChip(
              label: 'Notes $notes',
              selected: _filter == _DiagnosticFilter.info,
              onSelected:
                  () => setState(() => _filter = _DiagnosticFilter.info),
            ),
          ],
        ),
        if (hasQuery || hasActiveFilter) ...[
          const SizedBox(height: 10),
          ActiveFilterBar(
            tokens: [
              if (hasQuery)
                ActiveFilterToken(
                  icon: Icons.search,
                  label: 'Search "$_query"',
                  clearTooltip: 'Clear search filter',
                  onClear: _clearDiagnosticSearch,
                ),
              if (hasActiveFilter)
                ActiveFilterToken(
                  icon: _diagnosticFilterIcon(_filter),
                  label: 'Filter ${_diagnosticFilterLabel(_filter)}',
                  clearTooltip: 'Clear severity filter',
                  onClear:
                      () => setState(() => _filter = _DiagnosticFilter.all),
                ),
            ],
            onClearAll: _clearDiagnosticFilters,
          ),
        ],
        if (filteredDiagnostics.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (shownTargetIds.isNotEmpty)
                OutlinedButton.icon(
                  icon: const Icon(Icons.select_all),
                  label: Text('Select shown (${shownTargetIds.length})'),
                  onPressed:
                      () => ref
                          .read(layoutStateProvider.notifier)
                          .selectComponents(shownTargetIds),
                ),
              if (shownFixes > 0)
                FilledButton.icon(
                  icon: const Icon(Icons.auto_fix_high_outlined),
                  label: Text('Fix shown ($shownFixes)'),
                  onPressed: () => _applyQuickFixes(filteredDiagnostics),
                ),
              OutlinedButton.icon(
                icon: const Icon(Icons.content_copy_outlined),
                label: const Text('Copy report'),
                onPressed:
                    () => _copyDiagnosticsReport(
                      diagnostics: diagnostics,
                      shownDiagnostics: filteredDiagnostics,
                      warningCount: warnings,
                    ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        if (diagnostics.isEmpty)
          const _EmptyDiagnostics()
        else if (filteredDiagnostics.isEmpty)
          FilteredEmptyState(
            title: 'No matching issues',
            onAction:
                hasQuery || hasActiveFilter ? _clearDiagnosticFilters : null,
          )
        else
          for (final diagnostic in filteredDiagnostics)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DiagnosticTile(diagnostic: diagnostic),
            ),
      ],
    );
  }

  bool _matchesFilter(_LayoutDiagnostic diagnostic) {
    switch (_filter) {
      case _DiagnosticFilter.all:
        return true;
      case _DiagnosticFilter.warnings:
        return diagnostic.severity == _DiagnosticSeverity.warning;
      case _DiagnosticFilter.info:
        return diagnostic.severity == _DiagnosticSeverity.info;
    }
  }

  bool _matchesQuery(_LayoutDiagnostic diagnostic) {
    final normalizedQuery = _query.toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    return diagnostic.title.toLowerCase().contains(normalizedQuery) ||
        diagnostic.message.toLowerCase().contains(normalizedQuery);
  }

  void _applyQuickFixes(List<_LayoutDiagnostic> diagnostics) {
    _applyDiagnosticQuickFixes(ref, diagnostics);
  }

  void _clearDiagnosticSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _clearDiagnosticFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _filter = _DiagnosticFilter.all;
    });
  }

  Future<void> _copyDiagnosticsReport({
    required List<_LayoutDiagnostic> diagnostics,
    required List<_LayoutDiagnostic> shownDiagnostics,
    required int warningCount,
  }) async {
    final report = _formatDiagnosticsReport(
      diagnostics: diagnostics,
      shownDiagnostics: shownDiagnostics,
      warningCount: warningCount,
    );

    await Clipboard.setData(ClipboardData(text: report));
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Diagnostics report copied')));
  }
}

int layoutDiagnosticIssueCount(
  List<ComponentData> components, {
  LayoutDataBindingValues? bindings,
  LayoutConfig layoutConfig = const LayoutConfig(),
}) {
  return _buildLayoutDiagnostics(
    components,
    bindings: bindings,
    layoutConfig: layoutConfig,
  ).length;
}

Map<String, LayoutComponentDiagnosticSummary>
layoutDiagnosticSummariesByComponent(
  List<ComponentData> components, {
  LayoutDataBindingValues? bindings,
  LayoutConfig layoutConfig = const LayoutConfig(),
}) {
  final summaries = <String, _MutableLayoutComponentDiagnosticSummary>{};

  for (final diagnostic in _buildLayoutDiagnostics(
    components,
    bindings: bindings,
    layoutConfig: layoutConfig,
  )) {
    for (final componentId in diagnostic.targetComponentIds) {
      summaries
          .putIfAbsent(
            componentId,
            _MutableLayoutComponentDiagnosticSummary.new,
          )
          .add(diagnostic);
    }
  }

  return summaries.map((key, value) => MapEntry(key, value.toSummary()));
}

class LayoutComponentDiagnosticSummary {
  final int warningCount;
  final int noteCount;
  final List<String> warningTitles;
  final List<String> noteTitles;

  const LayoutComponentDiagnosticSummary({
    required this.warningCount,
    required this.noteCount,
    this.warningTitles = const <String>[],
    this.noteTitles = const <String>[],
  });

  int get totalCount => warningCount + noteCount;

  bool get hasIssues => totalCount > 0;

  bool get hasWarnings => warningCount > 0;

  List<String> get diagnosticTitles => [...warningTitles, ...noteTitles];
}

class _MutableLayoutComponentDiagnosticSummary {
  var warningCount = 0;
  var noteCount = 0;
  final warningTitles = <String>[];
  final noteTitles = <String>[];

  void add(_LayoutDiagnostic diagnostic) {
    switch (diagnostic.severity) {
      case _DiagnosticSeverity.warning:
        warningCount += 1;
        warningTitles.add(diagnostic.title);
        break;
      case _DiagnosticSeverity.info:
        noteCount += 1;
        noteTitles.add(diagnostic.title);
        break;
    }
  }

  LayoutComponentDiagnosticSummary toSummary() {
    return LayoutComponentDiagnosticSummary(
      warningCount: warningCount,
      noteCount: noteCount,
      warningTitles: List.unmodifiable(warningTitles),
      noteTitles: List.unmodifiable(noteTitles),
    );
  }
}

String _formatDiagnosticsReport({
  required List<_LayoutDiagnostic> diagnostics,
  required List<_LayoutDiagnostic> shownDiagnostics,
  required int warningCount,
}) {
  final buffer =
      StringBuffer()
        ..writeln('Layout diagnostics report')
        ..writeln('Total issues: ${diagnostics.length}')
        ..writeln('Warnings: $warningCount')
        ..writeln('Notes: ${diagnostics.length - warningCount}');

  if (shownDiagnostics.length != diagnostics.length) {
    buffer.writeln('Shown issues: ${shownDiagnostics.length}');
  }

  buffer.writeln('');

  for (var index = 0; index < shownDiagnostics.length; index++) {
    final diagnostic = shownDiagnostics[index];
    buffer.writeln(
      '${index + 1}. [${_diagnosticSeverityLabel(diagnostic.severity)}] ${diagnostic.title}',
    );
    buffer.writeln('   ${diagnostic.message}');

    if (diagnostic.targetComponentIds.isNotEmpty) {
      buffer.writeln(
        '   Components: ${diagnostic.targetComponentIds.join(', ')}',
      );
    }

    final quickFix = diagnostic.quickFix;
    if (quickFix != null) {
      buffer.writeln('   Quick fix: ${_diagnosticQuickFixLabel(quickFix)}');
    }
  }

  return buffer.toString().trimRight();
}

Future<void> _copyDiagnosticsReportFromContext(
  BuildContext context,
  List<_LayoutDiagnostic> diagnostics,
  int warningCount,
) async {
  final report = _formatDiagnosticsReport(
    diagnostics: diagnostics,
    shownDiagnostics: diagnostics,
    warningCount: warningCount,
  );

  await Clipboard.setData(ClipboardData(text: report));
  if (!context.mounted) return;

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Diagnostics report copied')));
}

List<_LayoutDiagnostic> _buildLayoutDiagnostics(
  List<ComponentData> components, {
  Size canvasSize = _defaultCanvasSize,
  LayoutConfig layoutConfig = const LayoutConfig(),
  LayoutDataBindingValues? bindings,
}) {
  final diagnostics = <_LayoutDiagnostic>[];
  final bindingValues = bindings ?? LayoutDataBindingValues.fallback();

  if (components.isEmpty) return diagnostics;

  for (final component in components) {
    final name = _componentName(component);
    final bounds = _componentBounds(component);

    if (!component.isVisible) {
      diagnostics.add(
        _LayoutDiagnostic(
          severity: _DiagnosticSeverity.info,
          icon: Icons.visibility_off_outlined,
          title: '$name is hidden',
          message: 'Hidden components will not appear in the cashier layout.',
          componentId: component.id,
          quickFix: _DiagnosticQuickFix.showComponent,
        ),
      );
    }

    if (component.isLocked) {
      diagnostics.add(
        _LayoutDiagnostic(
          severity: _DiagnosticSeverity.info,
          icon: Icons.lock_outline,
          title: '$name is locked',
          message: 'Unlock it before moving or resizing from the canvas.',
          componentId: component.id,
          quickFix: _DiagnosticQuickFix.unlockComponent,
        ),
      );
    }

    if (!_isInsideCanvas(bounds, canvasSize)) {
      diagnostics.add(
        _LayoutDiagnostic(
          severity: _DiagnosticSeverity.warning,
          icon: Icons.crop_free,
          title: '$name is outside the canvas',
          message:
              'Bounds ${bounds.left.round()}, ${bounds.top.round()} - ${bounds.width.round()}x${bounds.height.round()} exceed ${canvasSize.width.round()}x${canvasSize.height.round()}.',
          componentId: component.id,
          quickFix: _DiagnosticQuickFix.moveInsideCanvas,
        ),
      );
    }

    if (_needsMinimumTouchTarget(component, bounds)) {
      diagnostics.add(
        _LayoutDiagnostic(
          severity: _DiagnosticSeverity.warning,
          icon: Icons.touch_app_outlined,
          title: '$name is hard to tap',
          message:
              'Interactive cashier controls should be at least ${_minimumTouchTarget.round()}x${_minimumTouchTarget.round()} for touch use.',
          componentId: component.id,
          quickFix: _DiagnosticQuickFix.enlargeTouchTarget,
        ),
      );
    }

    if (_hasGenericActionLabel(component)) {
      diagnostics.add(
        _LayoutDiagnostic(
          severity: _DiagnosticSeverity.info,
          icon: Icons.badge_outlined,
          title: '$name uses a generic label',
          message:
              'Give action buttons a specific label so cashier workflows are easier to scan.',
          componentId: component.id,
        ),
      );
    }

    diagnostics.addAll(_bindingDiagnostics(component, bindingValues));
    diagnostics.addAll(_eventDiagnostics(component));
  }

  final visibleComponents =
      components.where((component) => component.isVisible).toList();
  diagnostics.addAll(_autoGridRuleDiagnostics(visibleComponents, layoutConfig));
  diagnostics.addAll(
    _autoGridCellConflictDiagnostics(visibleComponents, layoutConfig),
  );

  for (var i = 0; i < visibleComponents.length; i++) {
    final current = visibleComponents[i];
    final currentBounds = _componentBounds(current);

    for (var j = i + 1; j < visibleComponents.length; j++) {
      final compared = visibleComponents[j];
      final comparedBounds = _componentBounds(compared);

      if (_areInSameGroup(current, compared)) continue;
      if (!currentBounds.overlaps(comparedBounds)) continue;

      diagnostics.add(
        _LayoutDiagnostic(
          severity: _DiagnosticSeverity.warning,
          icon: Icons.warning_amber_outlined,
          title:
              '${_componentName(current)} overlaps ${_componentName(compared)}',
          message: 'Move or resize one of these visible components.',
          componentId: current.id,
          componentIds: {current.id, compared.id},
        ),
      );
    }
  }

  final names = <String, List<ComponentData>>{};
  for (final component in components) {
    final name = _componentName(component).toLowerCase();
    names.putIfAbsent(name, () => []).add(component);
  }

  for (final entry in names.entries) {
    if (entry.value.length < 2) continue;

    diagnostics.add(
      _LayoutDiagnostic(
        severity: _DiagnosticSeverity.warning,
        icon: Icons.label_outline,
        title: 'Duplicate layer name',
        message:
            '${entry.value.length} components use "${_componentName(entry.value.first)}". Rename one for easier maintenance.',
        componentId: entry.value.first.id,
        componentIds: entry.value.map((component) => component.id).toSet(),
        quickFix: _DiagnosticQuickFix.makeLayerNamesUnique,
      ),
    );
  }

  diagnostics.sort((a, b) => b.severity.index.compareTo(a.severity.index));
  return diagnostics;
}

class _LayoutDiagnostic {
  final _DiagnosticSeverity severity;
  final IconData icon;
  final String title;
  final String message;
  final String? componentId;
  final Set<String> componentIds;
  final _DiagnosticQuickFix? quickFix;
  final String? attributeKey;
  final String? bindingKey;
  final String? eventName;

  const _LayoutDiagnostic({
    required this.severity,
    required this.icon,
    required this.title,
    required this.message,
    this.componentId,
    this.componentIds = const <String>{},
    this.quickFix,
    this.attributeKey,
    this.bindingKey,
    this.eventName,
  });

  Set<String> get targetComponentIds => {
    if (componentId != null) componentId!,
    ...componentIds,
  };
}

class _DiagnosticsSummary extends StatelessWidget {
  final int componentCount;
  final int issueCount;
  final int warningCount;

  const _DiagnosticsSummary({
    required this.componentCount,
    required this.issueCount,
    required this.warningCount,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$componentCount components'),
            const SizedBox(height: 4),
            Text('$issueCount notes - $warningCount warnings'),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _DiagnosticFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _DiagnosticTile extends ConsumerWidget {
  final _LayoutDiagnostic diagnostic;

  const _DiagnosticTile({required this.diagnostic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _severityColor(context, diagnostic.severity);
    final quickFix = diagnostic.quickFix;
    final targetIds = diagnostic.targetComponentIds;
    final shouldShowSelectAction = targetIds.length > 1;
    final shouldShowQuickFix =
        quickFix != null && diagnostic.targetComponentIds.isNotEmpty;

    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap:
            targetIds.isEmpty
                ? null
                : () => _selectDiagnosticTargets(ref, diagnostic),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(diagnostic.icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diagnostic.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      diagnostic.message,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (shouldShowSelectAction || shouldShowQuickFix) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (shouldShowSelectAction)
                            TextButton.icon(
                              icon: const Icon(Icons.select_all, size: 18),
                              label: Text('Select ${targetIds.length}'),
                              onPressed:
                                  () =>
                                      _selectDiagnosticTargets(ref, diagnostic),
                            ),
                          if (quickFix != null && shouldShowQuickFix)
                            TextButton.icon(
                              icon: Icon(_quickFixIcon(quickFix), size: 18),
                              label: Text(_quickFixLabel(quickFix)),
                              onPressed: () => _applyQuickFix(ref, diagnostic),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _severityColor(BuildContext context, _DiagnosticSeverity severity) {
    return _diagnosticSeverityColor(context, severity);
  }

  IconData _quickFixIcon(_DiagnosticQuickFix quickFix) {
    return _diagnosticQuickFixIcon(quickFix);
  }

  String _quickFixLabel(_DiagnosticQuickFix quickFix) {
    return _diagnosticQuickFixLabel(quickFix);
  }

  void _applyQuickFix(WidgetRef ref, _LayoutDiagnostic diagnostic) {
    _applyDiagnosticQuickFix(ref, diagnostic);
  }

  void _selectDiagnosticTargets(WidgetRef ref, _LayoutDiagnostic diagnostic) {
    ref
        .read(layoutStateProvider.notifier)
        .selectComponents(diagnostic.targetComponentIds);
  }
}

class _ComponentDiagnosticRow extends ConsumerWidget {
  final _LayoutDiagnostic diagnostic;

  const _ComponentDiagnosticRow({required this.diagnostic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _diagnosticSeverityColor(context, diagnostic.severity);
    final quickFix = diagnostic.quickFix;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(diagnostic.icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diagnostic.title,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                diagnostic.message,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (quickFix != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: Icon(_diagnosticQuickFixIcon(quickFix), size: 16),
                    label: Text(_diagnosticQuickFixLabel(quickFix)),
                    onPressed: () => _applyDiagnosticQuickFix(ref, diagnostic),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyDiagnostics extends StatelessWidget {
  const _EmptyDiagnostics();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.task_alt),
            SizedBox(height: 8),
            Text('No layout issues found'),
          ],
        ),
      ),
    );
  }
}

enum _DiagnosticFilter { all, warnings, info }

enum _DiagnosticSeverity { info, warning }

IconData _diagnosticFilterIcon(_DiagnosticFilter filter) {
  switch (filter) {
    case _DiagnosticFilter.all:
      return Icons.rule_folder_outlined;
    case _DiagnosticFilter.warnings:
      return Icons.report_problem_outlined;
    case _DiagnosticFilter.info:
      return Icons.info_outline;
  }
}

String _diagnosticFilterLabel(_DiagnosticFilter filter) {
  switch (filter) {
    case _DiagnosticFilter.all:
      return 'All';
    case _DiagnosticFilter.warnings:
      return 'Warnings';
    case _DiagnosticFilter.info:
      return 'Notes';
  }
}

String _diagnosticSeverityLabel(_DiagnosticSeverity severity) {
  switch (severity) {
    case _DiagnosticSeverity.warning:
      return 'WARNING';
    case _DiagnosticSeverity.info:
      return 'NOTE';
  }
}

Color _diagnosticSeverityColor(
  BuildContext context,
  _DiagnosticSeverity severity,
) {
  switch (severity) {
    case _DiagnosticSeverity.warning:
      return Colors.orange.shade700;
    case _DiagnosticSeverity.info:
      return Theme.of(context).colorScheme.primary;
  }
}

String _componentDiagnosticsSummaryLabel({
  required int warnings,
  required int notes,
  bool hasClearSpotAction = false,
}) {
  final parts = <String>[];

  if (warnings > 0) {
    parts.add('$warnings ${warnings == 1 ? 'warning' : 'warnings'}');
  }

  if (notes > 0) {
    parts.add('$notes ${notes == 1 ? 'note' : 'notes'}');
  }

  if (parts.isEmpty) {
    return hasClearSpotAction ? 'Layout rule action available' : 'No issues';
  }

  return 'Diagnostics: ${parts.join(', ')}';
}

void _moveSelectedToClearSpot(BuildContext context, WidgetRef ref) {
  layoutClearSpotActionService.moveSelectionToClearSpot(context, ref);
}

enum _DiagnosticQuickFix {
  showComponent,
  unlockComponent,
  moveInsideCanvas,
  snapToLayoutRules,
  arrangeIntoAutoGrid,
  enlargeTouchTarget,
  removeUnknownBinding,
  removeEvent,
  addDefaultTapEvent,
  namespaceEventHandler,
  makeLayerNamesUnique,
}

IconData _diagnosticQuickFixIcon(_DiagnosticQuickFix quickFix) {
  switch (quickFix) {
    case _DiagnosticQuickFix.showComponent:
      return Icons.visibility_outlined;
    case _DiagnosticQuickFix.unlockComponent:
      return Icons.lock_open_outlined;
    case _DiagnosticQuickFix.moveInsideCanvas:
      return Icons.move_down_outlined;
    case _DiagnosticQuickFix.snapToLayoutRules:
      return Icons.grid_on_outlined;
    case _DiagnosticQuickFix.arrangeIntoAutoGrid:
      return Icons.auto_fix_high_outlined;
    case _DiagnosticQuickFix.enlargeTouchTarget:
      return Icons.open_in_full_outlined;
    case _DiagnosticQuickFix.removeUnknownBinding:
      return Icons.cleaning_services_outlined;
    case _DiagnosticQuickFix.removeEvent:
      return Icons.delete_outline;
    case _DiagnosticQuickFix.addDefaultTapEvent:
      return Icons.bolt_outlined;
    case _DiagnosticQuickFix.namespaceEventHandler:
      return Icons.auto_fix_high_outlined;
    case _DiagnosticQuickFix.makeLayerNamesUnique:
      return Icons.drive_file_rename_outline;
  }
}

int _diagnosticQuickFixPriority(_DiagnosticQuickFix? quickFix) {
  switch (quickFix) {
    case _DiagnosticQuickFix.unlockComponent:
      return 0;
    case _DiagnosticQuickFix.showComponent:
      return 1;
    case _DiagnosticQuickFix.moveInsideCanvas:
    case _DiagnosticQuickFix.snapToLayoutRules:
    case _DiagnosticQuickFix.arrangeIntoAutoGrid:
    case _DiagnosticQuickFix.enlargeTouchTarget:
    case _DiagnosticQuickFix.removeUnknownBinding:
    case _DiagnosticQuickFix.removeEvent:
    case _DiagnosticQuickFix.addDefaultTapEvent:
    case _DiagnosticQuickFix.namespaceEventHandler:
    case _DiagnosticQuickFix.makeLayerNamesUnique:
      return 2;
    case null:
      return 3;
  }
}

String _diagnosticQuickFixLabel(_DiagnosticQuickFix quickFix) {
  switch (quickFix) {
    case _DiagnosticQuickFix.showComponent:
      return 'Show';
    case _DiagnosticQuickFix.unlockComponent:
      return 'Unlock';
    case _DiagnosticQuickFix.moveInsideCanvas:
      return 'Move inside';
    case _DiagnosticQuickFix.snapToLayoutRules:
      return 'Snap to rules';
    case _DiagnosticQuickFix.arrangeIntoAutoGrid:
      return 'Free cells';
    case _DiagnosticQuickFix.enlargeTouchTarget:
      return 'Enlarge';
    case _DiagnosticQuickFix.removeUnknownBinding:
      return 'Clean token';
    case _DiagnosticQuickFix.removeEvent:
      return 'Remove event';
    case _DiagnosticQuickFix.addDefaultTapEvent:
      return 'Add tap event';
    case _DiagnosticQuickFix.namespaceEventHandler:
      return 'Namespace handler';
    case _DiagnosticQuickFix.makeLayerNamesUnique:
      return 'Make names unique';
  }
}

void _applyDiagnosticQuickFix(WidgetRef ref, _LayoutDiagnostic diagnostic) {
  final quickFix = diagnostic.quickFix;
  final targetIds = diagnostic.targetComponentIds;
  if (targetIds.isEmpty || quickFix == null) return;

  final canvasSize = ref.read(
    layoutStateProvider.select((state) => state.config.canvasSize),
  );
  final notifier = ref.read(layoutStateProvider.notifier);
  notifier.selectComponents(targetIds);
  final componentId = diagnostic.componentId ?? targetIds.first;

  switch (quickFix) {
    case _DiagnosticQuickFix.showComponent:
      notifier.setComponentsVisibility(targetIds, true);
      break;
    case _DiagnosticQuickFix.unlockComponent:
      notifier.setComponentsLock(targetIds, false);
      break;
    case _DiagnosticQuickFix.moveInsideCanvas:
      if (targetIds.length == 1) {
        notifier.moveComponentInsideCanvas(componentId, canvasSize);
      } else {
        notifier.moveSelectedInsideCanvas(canvasSize: canvasSize);
      }
      break;
    case _DiagnosticQuickFix.snapToLayoutRules:
      notifier.snapSelectedToGrid();
      notifier.snapSelectedSizeToGrid();
      break;
    case _DiagnosticQuickFix.arrangeIntoAutoGrid:
      notifier.moveSelectedToFreeAutoGridCells();
      break;
    case _DiagnosticQuickFix.enlargeTouchTarget:
      _enlargeTouchTarget(ref, componentId);
      break;
    case _DiagnosticQuickFix.removeUnknownBinding:
      _removeUnknownBinding(ref, diagnostic);
      break;
    case _DiagnosticQuickFix.removeEvent:
      _removeEvent(ref, diagnostic);
      break;
    case _DiagnosticQuickFix.addDefaultTapEvent:
      _addDefaultTapEvent(ref, componentId);
      break;
    case _DiagnosticQuickFix.namespaceEventHandler:
      _namespaceEventHandler(ref, diagnostic);
      break;
    case _DiagnosticQuickFix.makeLayerNamesUnique:
      _makeLayerNamesUnique(ref, diagnostic);
      break;
  }
}

void _applyDiagnosticQuickFixes(
  WidgetRef ref,
  Iterable<_LayoutDiagnostic> diagnostics,
) {
  final orderedDiagnostics = [...diagnostics]..sort(
    (a, b) => _diagnosticQuickFixPriority(
      a.quickFix,
    ).compareTo(_diagnosticQuickFixPriority(b.quickFix)),
  );

  for (final diagnostic in orderedDiagnostics) {
    final quickFix = diagnostic.quickFix;
    if (quickFix == null || diagnostic.targetComponentIds.isEmpty) continue;
    _applyDiagnosticQuickFix(ref, diagnostic);
  }
}

void _makeLayerNamesUnique(WidgetRef ref, _LayoutDiagnostic diagnostic) {
  final targetIds = diagnostic.targetComponentIds;
  if (targetIds.length < 2) return;

  final layoutState = ref.read(layoutStateProvider);
  final targetComponents =
      layoutState.components
          .where((component) => targetIds.contains(component.id))
          .toList();
  if (targetComponents.length < 2) return;

  final existingNames =
      layoutState.components
          .where((component) => !targetIds.contains(component.id))
          .map((component) => _componentName(component).toLowerCase())
          .toSet();
  final namesById = <String, String>{};
  final baseName = _componentName(targetComponents.first);
  var suffix = 1;

  for (var index = 0; index < targetComponents.length; index++) {
    final component = targetComponents[index];
    var candidate = baseName;

    if (index > 0 || existingNames.contains(candidate.toLowerCase())) {
      do {
        suffix += 1;
        candidate = '$baseName $suffix';
      } while (existingNames.contains(candidate.toLowerCase()));
    }

    existingNames.add(candidate.toLowerCase());
    namesById[component.id] = candidate;
  }

  ref.read(layoutStateProvider.notifier).renameComponents(namesById);
}

void _removeUnknownBinding(WidgetRef ref, _LayoutDiagnostic diagnostic) {
  final componentId = diagnostic.componentId;
  final attributeKey = diagnostic.attributeKey;
  final bindingKey = diagnostic.bindingKey;
  if (componentId == null || attributeKey == null || bindingKey == null) {
    return;
  }

  final component = ref.read(layoutStateProvider).componentsById[componentId];
  if (component == null) return;

  final currentValue = component.properties.attributes[attributeKey];
  if (currentValue is! String) return;

  final cleanedValue =
      currentValue
          .replaceAllMapped(_bindingTokenRegex, (match) {
            return match.group(1) == bindingKey ? '' : match.group(0) ?? '';
          })
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .trim();
  final nextValue =
      cleanedValue.isEmpty
          ? _fallbackAttributeValue(component, attributeKey)
          : cleanedValue;
  final attributes = Map<String, dynamic>.from(component.properties.attributes)
    ..[attributeKey] = nextValue;

  ref
      .read(layoutStateProvider.notifier)
      .updateComponentProperties(
        componentId,
        component.properties.copyWith(attributes: attributes),
      );
}

void _removeEvent(WidgetRef ref, _LayoutDiagnostic diagnostic) {
  final componentId = diagnostic.componentId;
  final eventName = diagnostic.eventName;
  if (componentId == null || eventName == null) return;

  final component = ref.read(layoutStateProvider).componentsById[componentId];
  if (component == null) return;

  final events = Map<String, String>.from(component.properties.events)
    ..remove(eventName);

  ref
      .read(layoutStateProvider.notifier)
      .updateComponentProperties(
        componentId,
        component.properties.copyWith(events: events),
      );
}

void _addDefaultTapEvent(WidgetRef ref, String componentId) {
  final component = ref.read(layoutStateProvider).componentsById[componentId];
  if (component == null) return;

  final events = Map<String, String>.from(component.properties.events);
  events['onTap'] = _defaultTapHandler(component);

  ref
      .read(layoutStateProvider.notifier)
      .updateComponentProperties(
        componentId,
        component.properties.copyWith(events: events),
      );
}

void _namespaceEventHandler(WidgetRef ref, _LayoutDiagnostic diagnostic) {
  final componentId = diagnostic.componentId;
  final eventName = diagnostic.eventName;
  if (componentId == null || eventName == null) return;

  final component = ref.read(layoutStateProvider).componentsById[componentId];
  if (component == null) return;

  final handler = component.properties.events[eventName]?.trim();
  if (handler == null || handler.isEmpty) return;

  final events = Map<String, String>.from(component.properties.events)
    ..[eventName] = 'custom.${_handlerSlug(handler)}';

  ref
      .read(layoutStateProvider.notifier)
      .updateComponentProperties(
        componentId,
        component.properties.copyWith(events: events),
      );
}

void _enlargeTouchTarget(WidgetRef ref, String componentId) {
  final component = ref.read(layoutStateProvider).componentsById[componentId];
  if (component == null) return;

  ref
      .read(layoutStateProvider.notifier)
      .updateComponentSize(
        componentId,
        Size(
          math.max(component.size.width, _minimumTouchTarget),
          math.max(component.size.height, _minimumTouchTarget),
        ),
      );
}

Rect _componentBounds(ComponentData component) {
  return Rect.fromLTWH(
    component.position.dx,
    component.position.dy,
    component.size.width,
    component.size.height,
  );
}

bool _isInsideCanvas(Rect bounds, Size canvasSize) {
  return bounds.left >= 0 &&
      bounds.top >= 0 &&
      bounds.right <= canvasSize.width &&
      bounds.bottom <= canvasSize.height;
}

bool _needsMinimumTouchTarget(ComponentData component, Rect bounds) {
  if (!component.isVisible || !_isTouchTargetComponent(component)) return false;

  return bounds.width < _minimumTouchTarget ||
      bounds.height < _minimumTouchTarget;
}

List<_LayoutDiagnostic> _autoGridRuleDiagnostics(
  List<ComponentData> visibleComponents,
  LayoutConfig config,
) {
  if (config.layoutMechanism != LayoutMechanism.autoGrid) {
    return const <_LayoutDiagnostic>[];
  }

  final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
  final rowTrackHeight =
      math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
  if (trackWidth <= 0 || rowTrackHeight <= 0) {
    return const <_LayoutDiagnostic>[];
  }

  final diagnostics = <_LayoutDiagnostic>[];
  for (final component in visibleComponents) {
    if (component.isLocked) continue;

    final snappedPosition = _snapAutoGridPosition(component.position, config);
    final snappedSize = _snapAutoGridSize(component.size, config);
    final needsPositionSnap =
        (snappedPosition - component.position).distance >= 0.01;
    final needsSizeSnap =
        (snappedSize.width - component.size.width).abs() >= 0.01 ||
        (snappedSize.height - component.size.height).abs() >= 0.01;

    if (!needsPositionSnap && !needsSizeSnap) continue;

    final mismatch =
        needsPositionSnap && needsSizeSnap
            ? 'position and size'
            : needsPositionSnap
            ? 'position'
            : 'size';

    diagnostics.add(
      _LayoutDiagnostic(
        severity: _DiagnosticSeverity.info,
        icon: Icons.grid_on_outlined,
        title: '${_componentName(component)} is off Auto Grid rules',
        message:
            'Its $mismatch does not match Auto Grid tracks. Snap it so packing, spans, and keyboard moves stay predictable.',
        componentId: component.id,
        quickFix: _DiagnosticQuickFix.snapToLayoutRules,
      ),
    );
  }

  return diagnostics;
}

List<_LayoutDiagnostic> _autoGridCellConflictDiagnostics(
  List<ComponentData> visibleComponents,
  LayoutConfig config,
) {
  if (config.layoutMechanism != LayoutMechanism.autoGrid) {
    return const <_LayoutDiagnostic>[];
  }

  final placements =
      visibleComponents
          .where((component) => !component.isLocked)
          .map((component) => _autoGridCellPlacementFor(component, config))
          .whereType<_AutoGridCellPlacement>()
          .toList();
  if (placements.length < 2) return const <_LayoutDiagnostic>[];

  final diagnostics = <_LayoutDiagnostic>[];
  for (var index = 0; index < placements.length; index++) {
    final current = placements[index];

    for (
      var compareIndex = index + 1;
      compareIndex < placements.length;
      compareIndex++
    ) {
      final compared = placements[compareIndex];
      if (_areInSameGroup(current.component, compared.component)) continue;
      if (!current.cells.overlaps(compared.cells)) continue;

      diagnostics.add(
        _LayoutDiagnostic(
          severity: _DiagnosticSeverity.warning,
          icon: Icons.dashboard_customize_outlined,
          title:
              '${_componentName(current.component)} shares Auto Grid cells with ${_componentName(compared.component)}',
          message:
              'Their Auto Grid spans overlap. Move the pair to free Auto Grid cells to clear the conflict.',
          componentId: current.component.id,
          componentIds: {current.component.id, compared.component.id},
          quickFix: _DiagnosticQuickFix.arrangeIntoAutoGrid,
        ),
      );
    }
  }

  return diagnostics;
}

class _AutoGridCellPlacement {
  final ComponentData component;
  final Rect cells;

  const _AutoGridCellPlacement({required this.component, required this.cells});
}

_AutoGridCellPlacement? _autoGridCellPlacementFor(
  ComponentData component,
  LayoutConfig config,
) {
  final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
  final rowTrackHeight =
      math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
  if (trackWidth <= 0 || rowTrackHeight <= 0) return null;

  final column =
      (component.position.dx / trackWidth)
          .round()
          .clamp(0, config.autoGridColumnCount - 1)
          .toInt();
  final row = math.max(0, (component.position.dy / rowTrackHeight).round());
  final columnSpan =
      ((component.size.width + config.autoGridGap) / trackWidth)
          .round()
          .clamp(1, config.autoGridColumnCount)
          .toInt();
  final rowSpan = math.max(
    1,
    ((component.size.height + config.autoGridGap) / rowTrackHeight).round(),
  );

  return _AutoGridCellPlacement(
    component: component,
    cells: Rect.fromLTRB(
      column.toDouble(),
      row.toDouble(),
      math.min(config.autoGridColumnCount, column + columnSpan).toDouble(),
      (row + rowSpan).toDouble(),
    ),
  );
}

Offset _snapAutoGridPosition(Offset position, LayoutConfig config) {
  final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
  final column =
      trackWidth <= 0
          ? 0
          : (position.dx / trackWidth)
              .round()
              .clamp(0, config.autoGridColumnCount - 1)
              .toInt();
  final rowTrackHeight =
      math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
  final row = rowTrackHeight <= 0 ? 0 : (position.dy / rowTrackHeight).round();

  return Offset(column * trackWidth, row * rowTrackHeight);
}

Size _snapAutoGridSize(Size size, LayoutConfig config) {
  final constrained = Size(
    size.width.clamp(config.minComponentWidth, double.infinity).toDouble(),
    size.height.clamp(config.minComponentHeight, double.infinity).toDouble(),
  );
  final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
  if (trackWidth <= 0) return constrained;

  final columnSpan =
      ((constrained.width + config.autoGridGap) / trackWidth)
          .round()
          .clamp(1, config.autoGridColumnCount)
          .toInt();
  final rowTrackHeight =
      math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
  final rowSpan = math.max(
    1,
    ((constrained.height + config.autoGridGap) / rowTrackHeight).round(),
  );

  return Size(
    columnSpan * config.autoGridColumnWidth +
        math.max(0, columnSpan - 1) * config.autoGridGap,
    rowSpan * math.max(24.0, config.autoGridRowHeight) +
        math.max(0, rowSpan - 1) * config.autoGridGap,
  );
}

bool _isTouchTargetComponent(ComponentData component) {
  return component.type == ComponentType.customButton;
}

bool _hasGenericActionLabel(ComponentData component) {
  if (component.type != ComponentType.customButton) return false;

  final attributes = component.properties.attributes;
  final label = attributes['label'] ?? attributes['text'];

  return label is! String ||
      label.trim().isEmpty ||
      label.trim().toLowerCase() == component.type.label.toLowerCase();
}

List<_LayoutDiagnostic> _bindingDiagnostics(
  ComponentData component,
  LayoutDataBindingValues bindings,
) {
  final diagnostics = <_LayoutDiagnostic>[];
  final seenTokens = <String>{};

  for (final entry in component.properties.attributes.entries) {
    final value = entry.value;
    if (value is! String || !value.contains('{{')) continue;

    for (final match in _bindingTokenRegex.allMatches(value)) {
      final key = match.group(1);
      if (key == null || bindings.hasBinding(key)) continue;
      if (!seenTokens.add('${entry.key}:$key')) continue;

      diagnostics.add(
        _LayoutDiagnostic(
          severity: _DiagnosticSeverity.warning,
          icon: Icons.data_object_outlined,
          title: '${_componentName(component)} has an unknown binding',
          message:
              '${_attributeLabel(entry.key)} uses ${match.group(0)}, but that field is not available in demo_profile.json.',
          componentId: component.id,
          quickFix: _DiagnosticQuickFix.removeUnknownBinding,
          attributeKey: entry.key,
          bindingKey: key,
        ),
      );
    }
  }

  return diagnostics;
}

List<_LayoutDiagnostic> _eventDiagnostics(ComponentData component) {
  final diagnostics = <_LayoutDiagnostic>[];
  final events = component.properties.events;
  final name = _componentName(component);

  if (_expectsTapEvent(component) && !events.containsKey('onTap')) {
    diagnostics.add(
      _LayoutDiagnostic(
        severity: _DiagnosticSeverity.info,
        icon: Icons.bolt_outlined,
        title: '$name has no tap event',
        message:
            'Add tap metadata so this action button has a documented POS behavior.',
        componentId: component.id,
        quickFix: _DiagnosticQuickFix.addDefaultTapEvent,
      ),
    );
  }

  for (final entry in events.entries) {
    final eventName = entry.key.trim();
    final handler = entry.value.trim();

    if (eventName.isEmpty || handler.isEmpty) {
      diagnostics.add(
        _LayoutDiagnostic(
          severity: _DiagnosticSeverity.warning,
          icon: Icons.bolt_outlined,
          title: '$name has an incomplete event',
          message:
              'Events need both a name and handler. Empty entries are ignored by runtime integrations.',
          componentId: component.id,
          quickFix: _DiagnosticQuickFix.removeEvent,
          eventName: entry.key,
        ),
      );
      continue;
    }

    if (!_knownEventNames.contains(eventName)) {
      diagnostics.add(
        _LayoutDiagnostic(
          severity: _DiagnosticSeverity.info,
          icon: Icons.help_outline,
          title: '$name uses a custom event',
          message:
              '$eventName is not one of the common editor events. Keep it if a custom runtime listens for it.',
          componentId: component.id,
          eventName: entry.key,
        ),
      );
    }

    if (!_isRecognizedHandler(handler)) {
      diagnostics.add(
        _LayoutDiagnostic(
          severity: _DiagnosticSeverity.info,
          icon: Icons.rule_folder_outlined,
          title: '$name uses a custom handler',
          message:
              '$handler is not a known POS handler or namespaced custom handler. Use a namespace such as custom.$handler.',
          componentId: component.id,
          quickFix:
              handler.contains('.')
                  ? null
                  : _DiagnosticQuickFix.namespaceEventHandler,
          eventName: entry.key,
        ),
      );
    }
  }

  return diagnostics;
}

String _attributeLabel(String key) {
  switch (key) {
    case 'label':
      return 'Label';
    case 'text':
      return 'Text';
    case 'name':
      return 'Layer name';
    default:
      return key;
  }
}

String _fallbackAttributeValue(ComponentData component, String attributeKey) {
  switch (attributeKey) {
    case 'label':
      return component.type == ComponentType.customButton
          ? 'Action'
          : component.type.label;
    case 'text':
      return 'Label';
    case 'name':
      return component.type.label;
    default:
      return '';
  }
}

final _bindingTokenRegex = RegExp(r'\{\{\s*([\w\.\-]+)\s*\}\}');

bool _expectsTapEvent(ComponentData component) {
  return component.type == ComponentType.customButton;
}

String _defaultTapHandler(ComponentData component) {
  final label =
      component.properties.attributes['label']?.toString().trim().toLowerCase();

  if (label == 'pay' || label == 'checkout') return 'pos.pay';
  if (label == 'void' || label == 'cancel') return 'pos.order.void';
  if (label == 'discount') return 'pos.discount.open';
  if (label == 'print') return 'pos.receipt.print';
  if (label == 'clear') return 'pos.input.clear';

  return 'pos.product.add';
}

bool _isRecognizedHandler(String handler) {
  return _knownEventHandlers.contains(handler) ||
      handler.startsWith('custom.') ||
      handler.startsWith('navigate.') ||
      handler.startsWith('dialog.');
}

String _handlerSlug(String handler) {
  final slug = handler
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '.')
      .replaceAll(RegExp(r'\.+'), '.')
      .replaceAll(RegExp(r'^\.|\.$'), '');

  return slug.isEmpty ? 'handler' : slug;
}

bool _areInSameGroup(ComponentData first, ComponentData second) {
  final firstParent = first.properties.parentId;
  if (firstParent == null) return false;

  return firstParent == second.properties.parentId;
}

String _componentName(ComponentData component) {
  final attributes = component.properties.attributes;
  final customName =
      attributes['name'] ?? attributes['label'] ?? attributes['text'];

  if (customName is String && customName.trim().isNotEmpty) {
    return customName.trim();
  }

  return component.type.label;
}
