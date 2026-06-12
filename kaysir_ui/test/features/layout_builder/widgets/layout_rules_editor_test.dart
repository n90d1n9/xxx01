import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/models/layout_health_summary.dart';
import 'package:kaysir/features/layout_builder/models/layout_rules_conversion_preview.dart';
import 'package:kaysir/features/layout_builder/widgets/layout_rules_editor.dart';

void main() {
  test('summarizes layout rule draft changes', () {
    final changes = layoutRulesDraftChangeSummaries(
      initialSettings: const GridSettings(),
      draftSettings: const GridSettings(gridSize: 24, snapToGrid: false),
      initialConfig: const LayoutConfig(),
      draftConfig: const LayoutConfig(
        layoutMechanism: LayoutMechanism.tabularColumns,
        tabularColumnGap: 24,
        tabularRowHeight: 72,
      ),
    );

    expect(
      changes,
      containsAll([
        'Mechanism: Grid -> Tabular Columns',
        'Cell size: 20px -> 24px',
        'Snap: on -> off',
        'Column gap: 12px -> 24px',
        'Row height: 64px -> 72px',
      ]),
    );
  });

  test('names draft history entries by apply strategy', () {
    expect(
      layoutRulesDraftHistoryEntryName(
        config: const LayoutConfig(),
        hasRuleChanges: false,
        applyStrategy: LayoutRulesApplyStrategy.preserve,
      ),
      isNull,
    );
    expect(
      layoutRulesDraftHistoryEntryName(
        config: const LayoutConfig(
          layoutMechanism: LayoutMechanism.tabularColumns,
        ),
        hasRuleChanges: true,
        applyStrategy: LayoutRulesApplyStrategy.preserve,
      ),
      'Layout rules: Update rules',
    );
    expect(
      layoutRulesDraftHistoryEntryName(
        config: const LayoutConfig(layoutMechanism: LayoutMechanism.grid),
        hasRuleChanges: false,
        applyStrategy: LayoutRulesApplyStrategy.snapVisible,
      ),
      'Layout rules: Snap visible',
    );
    expect(
      layoutRulesDraftHistoryEntryName(
        config: const LayoutConfig(layoutMechanism: LayoutMechanism.autoGrid),
        hasRuleChanges: true,
        applyStrategy: LayoutRulesApplyStrategy.convertVisible,
      ),
      'Layout rules: Convert to Auto Grid',
    );
  });

  test('normalizes geometry apply strategies without editable components', () {
    expect(
      layoutRulesEffectiveApplyStrategy(
        strategy: LayoutRulesApplyStrategy.convertVisible,
        componentScope: const LayoutRulesComponentScope(),
      ),
      LayoutRulesApplyStrategy.preserve,
    );
    expect(
      layoutRulesEffectiveApplyStrategy(
        strategy: LayoutRulesApplyStrategy.snapVisible,
        componentScope: const LayoutRulesComponentScope(editableCount: 2),
      ),
      LayoutRulesApplyStrategy.snapVisible,
    );
  });

  test('summarizes layout rule conversion dry run', () {
    final preview = layoutRulesConversionPreviewFor(
      components: [
        ComponentData.create(
          id: 'moving',
          type: ComponentType.customButton,
          position: const Offset(13, 27),
          size: const Size(121, 83),
        ),
        ComponentData.create(
          id: 'stable',
          type: ComponentType.customButton,
          position: const Offset(40, 40),
          size: const Size(120, 80),
        ),
        ComponentData.create(
          id: 'locked',
          type: ComponentType.customButton,
          position: const Offset(9, 9),
          size: const Size(111, 81),
        ).copyWith(isLocked: true),
        ComponentData.create(
          id: 'hidden',
          type: ComponentType.customButton,
          position: const Offset(7, 7),
          size: const Size(107, 87),
        ).copyWith(isVisible: false),
      ],
      gridSettings: const GridSettings(gridSize: 20),
      config: const LayoutConfig(layoutMechanism: LayoutMechanism.grid),
      snapPositions: true,
      snapSizes: true,
    );

    expect(preview.editableCount, 2);
    expect(preview.moveCount, 1);
    expect(preview.resizeCount, 1);
    expect(preview.moveComponentIds, ['moving']);
    expect(preview.resizeComponentIds, ['moving']);
    expect(preview.autoGridConflictComponentIds, isEmpty);
    expect(preview.changedCount, 1);
    expect(preview.unchangedCount, 1);
  });

  testWidgets('switches to tabular rules and updates column presets', (
    tester,
  ) async {
    var latestConfig = const LayoutConfig();

    await _pumpEditor(
      tester,
      onConfigChanged: (config) => latestConfig = config,
    );

    expect(find.text('Grid rules'), findsOneWidget);

    await tester.tap(find.text('Columns').first);
    await tester.pump();

    expect(latestConfig.layoutMechanism, LayoutMechanism.tabularColumns);
    expect(find.text('Tabular column rules'), findsOneWidget);
    expect(find.text('Rules will update'), findsOneWidget);
    expect(find.text('Mechanism: Grid -> Tabular Columns'), findsOneWidget);
    expect(find.text('History: Layout rules: Update rules'), findsOneWidget);
    expect(find.text('12 columns'), findsOneWidget);

    await tester.ensureVisible(find.text('16 cols'));
    await tester.pump();
    await tester.tap(find.text('16 cols'));
    await tester.pump();

    expect(latestConfig.tabularColumnCount, 16);
    expect(find.text('16 columns'), findsOneWidget);
    expect(find.text('Columns: 12 -> 16'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filters layout rule presets by mechanism', (tester) async {
    var latestConfig = const LayoutConfig();

    await _pumpEditor(
      tester,
      onConfigChanged: (config) => latestConfig = config,
    );

    expect(find.text('Responsive Columns'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Auto Grid'));
    await tester.pump();

    expect(find.text('Auto Cards'), findsOneWidget);
    expect(find.text('Auto Dense'), findsOneWidget);
    expect(find.text('Responsive Columns'), findsNothing);

    await tester.tap(find.text('Auto Cards'));
    await tester.pump();

    expect(latestConfig.layoutMechanism, LayoutMechanism.autoGrid);
    expect(latestConfig.autoGridColumnCount, 4);
    expect(find.text('Mechanism: Grid -> Auto Grid'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('searches layout rule presets and clears filters', (
    tester,
  ) async {
    await _pumpEditor(tester);

    final searchField = find.byKey(const ValueKey('layout-rule-preset-search'));

    await tester.enterText(searchField, 'dense');
    await tester.pump();

    expect(find.text('Dense Grid'), findsOneWidget);
    expect(find.text('Auto Dense'), findsOneWidget);
    expect(find.text('Precision Grid'), findsNothing);
    expect(find.text('Search: dense'), findsOneWidget);
    expect(find.text('2 of 7 presets'), findsOneWidget);

    await tester.enterText(searchField, 'missing');
    await tester.pump();

    expect(find.text('No presets found'), findsOneWidget);
    expect(find.text('0 of 7 presets'), findsOneWidget);

    await tester.tap(find.text('Clear filters').last);
    await tester.pump();

    expect(find.text('Responsive Columns'), findsOneWidget);
    expect(find.text('No presets found'), findsNothing);
    expect(find.text('7 of 7 presets'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows Auto Grid controls and updates auto column presets', (
    tester,
  ) async {
    var latestConfig = const LayoutConfig(
      layoutMechanism: LayoutMechanism.autoGrid,
    );

    await _pumpEditor(
      tester,
      initialConfig: latestConfig,
      onConfigChanged: (config) => latestConfig = config,
    );

    expect(find.text('Auto Grid rules'), findsOneWidget);
    expect(find.text('4 columns'), findsOneWidget);

    await tester.ensureVisible(find.text('6 cols'));
    await tester.pump();
    await tester.tap(find.text('6 cols'));
    await tester.pump();

    expect(latestConfig.autoGridColumnCount, 6);
    expect(find.text('6 columns'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows layout health summary issue chips', (tester) async {
    var latestStrategy = LayoutRulesApplyStrategy.preserve;
    var latestConfig = const LayoutConfig();
    var didReposition = false;
    var didSelectOffCanvas = false;
    var didSelectLeftTop = false;
    var didSelectPosition = false;
    var didSelectSize = false;
    var didSelectConflicts = false;

    Future<void> tapVisible(String label) async {
      await tester.ensureVisible(find.text(label));
      await tester.pump();
      await tester.tap(find.text(label));
      await tester.pump();
    }

    await _pumpEditor(
      tester,
      componentScope: const LayoutRulesComponentScope(
        editableCount: 4,
        lockedCount: 1,
        hiddenCount: 2,
      ),
      healthSummary: const LayoutHealthSummary(
        visibleComponentCount: 5,
        editableComponentCount: 4,
        lockedComponentCount: 1,
        hiddenComponentCount: 2,
        offCanvasCount: 1,
        repositionOffCanvasCount: 1,
        repositionableOffCanvasCount: 1,
        offRulePositionCount: 3,
        offRuleSizeCount: 2,
        autoGridConflictCount: 1,
        offCanvasComponentIds: ['outside'],
        repositionOffCanvasComponentIds: ['outside'],
        offRulePositionComponentIds: ['outside', 'position-only'],
        offRuleSizeComponentIds: ['size-only'],
        autoGridConflictComponentIds: ['conflict'],
        expandedCanvasSize: Size(1280, 820),
        repositionOffset: Offset(24, 12),
      ),
      onConfigChanged: (config) => latestConfig = config,
      onApplyStrategyChanged: (strategy) => latestStrategy = strategy,
      onRepositionInsideCanvas: () => didReposition = true,
      onSelectOffCanvas: () => didSelectOffCanvas = true,
      onSelectRepositionOffCanvas: () => didSelectLeftTop = true,
      onSelectOffRulePositions: () => didSelectPosition = true,
      onSelectOffRuleSizes: () => didSelectSize = true,
      onSelectAutoGridConflicts: () => didSelectConflicts = true,
    );

    expect(find.text('Layout health'), findsOneWidget);
    expect(find.text('7 issues detected'), findsOneWidget);
    expect(
      find.text(
        '4 editable components - 1 locked component - 2 hidden components',
      ),
      findsOneWidget,
    );
    expect(find.text('1 off canvas'), findsOneWidget);
    expect(find.text('1 left/top outside'), findsOneWidget);
    expect(find.text('3 off position rules'), findsOneWidget);
    expect(find.text('2 off size rules'), findsOneWidget);
    expect(find.text('1 Auto Grid conflict detected'), findsOneWidget);
    expect(find.text('Select Position'), findsOneWidget);
    expect(find.text('Select Size'), findsOneWidget);
    expect(find.text('Select Conflicts'), findsOneWidget);
    expect(find.text('Select Left/Top'), findsOneWidget);
    expect(find.text('Select Overflow'), findsNothing);
    expect(find.text('Select Off Canvas'), findsOneWidget);
    expect(find.text('Reposition +24px, +12px'), findsOneWidget);

    await tapVisible('Select Position');
    await tapVisible('Select Size');
    await tapVisible('Select Conflicts');
    await tapVisible('Select Left/Top');
    await tapVisible('Select Off Canvas');

    expect(didSelectPosition, isTrue);
    expect(didSelectSize, isTrue);
    expect(didSelectConflicts, isTrue);
    expect(didSelectLeftTop, isTrue);
    expect(didSelectOffCanvas, isTrue);

    await tapVisible('Reposition +24px, +12px');

    expect(didReposition, isTrue);

    await tapVisible('Expand Canvas to 1280 x 820');

    expect(latestConfig.canvasSize, const Size(1280, 820));

    await tapVisible('Use Snap');

    expect(latestStrategy, LayoutRulesApplyStrategy.snapVisible);
    expect(find.text('Positions will snap'), findsOneWidget);
    expect(find.text('Snap selected'), findsOneWidget);
    expect(find.text('Use Convert'), findsOneWidget);

    await tapVisible('Use Convert');

    expect(latestStrategy, LayoutRulesApplyStrategy.convertVisible);
    expect(find.text('Components will convert'), findsOneWidget);
    expect(find.text('Use Snap'), findsOneWidget);
    expect(find.text('Convert selected'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows healthy layout status', (tester) async {
    await _pumpEditor(
      tester,
      healthSummary: const LayoutHealthSummary(
        visibleComponentCount: 1,
        editableComponentCount: 1,
        lockedComponentCount: 0,
        hiddenComponentCount: 0,
        offCanvasCount: 0,
        offRulePositionCount: 0,
        offRuleSizeCount: 0,
        autoGridConflictCount: 0,
      ),
    );

    expect(find.text('Layout health'), findsOneWidget);
    expect(find.text('Healthy layout'), findsOneWidget);
    expect(find.text('1 editable component'), findsOneWidget);
    expect(find.text('No layout issues'), findsOneWidget);
    expect(find.textContaining('Expand Canvas'), findsNothing);
    expect(find.text('Use Snap'), findsNothing);
    expect(find.text('Use Convert'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('falls back to preserve mode when no components are editable', (
    tester,
  ) async {
    var latestStrategy = LayoutRulesApplyStrategy.preserve;

    await _pumpEditor(
      tester,
      componentScope: const LayoutRulesComponentScope(
        editableCount: 0,
        lockedCount: 2,
        hiddenCount: 1,
      ),
      initialApplyStrategy: LayoutRulesApplyStrategy.convertVisible,
      onApplyStrategyChanged: (strategy) => latestStrategy = strategy,
    );

    expect(find.text('No pending changes'), findsOneWidget);
    expect(find.text('Components will convert'), findsNothing);
    expect(
      find.text('Keep existing component positions and sizes.'),
      findsOneWidget,
    );
    expect(
      find.text('No editable components to snap or convert.'),
      findsOneWidget,
    );
    expect(find.text('2 locked skipped'), findsOneWidget);
    expect(find.text('1 hidden skipped'), findsOneWidget);
    expect(find.text('0 editable'), findsNothing);

    await tester.tap(find.text('Convert'));
    await tester.pump();

    expect(latestStrategy, LayoutRulesApplyStrategy.preserve);
    expect(find.text('No pending changes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changes apply strategy for visible components', (tester) async {
    var latestStrategy = LayoutRulesApplyStrategy.preserve;

    await _pumpEditor(
      tester,
      visibleComponentCount: 3,
      componentScope: const LayoutRulesComponentScope(
        editableCount: 3,
        lockedCount: 1,
        hiddenCount: 2,
      ),
      conversionPreview: const LayoutRulesConversionPreview(
        editableCount: 3,
        moveCount: 2,
        resizeCount: 1,
        changedCount: 2,
        unchangedCount: 1,
      ),
      onApplyStrategyChanged: (strategy) => latestStrategy = strategy,
    );

    expect(find.text('Apply mode'), findsOneWidget);
    expect(find.text('No pending changes'), findsOneWidget);
    expect(find.textContaining('History: Layout rules'), findsNothing);
    expect(
      find.text('Keep existing component positions and sizes.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Convert'));
    await tester.pump();

    expect(latestStrategy, LayoutRulesApplyStrategy.convertVisible);
    expect(find.text('Components will convert'), findsOneWidget);
    expect(find.text('History: Layout rules: Convert to Grid'), findsOneWidget);
    expect(
      find.text('Snap positions and sizes for 3 editable components.'),
      findsOneWidget,
    );
    expect(find.text('3 editable'), findsOneWidget);
    expect(find.text('1 locked skipped'), findsOneWidget);
    expect(find.text('2 hidden skipped'), findsOneWidget);
    expect(find.text('2 will move'), findsOneWidget);
    expect(find.text('1 will resize'), findsOneWidget);
    expect(find.text('1 unchanged'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpEditor(
  WidgetTester tester, {
  LayoutConfig initialConfig = const LayoutConfig(),
  GridSettings initialSettings = const GridSettings(),
  int visibleComponentCount = 0,
  LayoutRulesComponentScope? componentScope,
  LayoutRulesConversionPreview? conversionPreview,
  LayoutHealthSummary? healthSummary,
  LayoutRulesApplyStrategy initialApplyStrategy =
      LayoutRulesApplyStrategy.preserve,
  ValueChanged<LayoutConfig>? onConfigChanged,
  ValueChanged<LayoutRulesApplyStrategy>? onApplyStrategyChanged,
  VoidCallback? onRepositionInsideCanvas,
  VoidCallback? onSelectOffCanvas,
  VoidCallback? onSelectExpandableOffCanvas,
  VoidCallback? onSelectRepositionOffCanvas,
  VoidCallback? onSelectOffRulePositions,
  VoidCallback? onSelectOffRuleSizes,
  VoidCallback? onSelectAutoGridConflicts,
}) async {
  tester.view.physicalSize = const Size(640, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 460,
            height: 820,
            child: _LayoutRulesEditorHarness(
              initialConfig: initialConfig,
              initialSettings: initialSettings,
              visibleComponentCount: visibleComponentCount,
              componentScope: componentScope,
              conversionPreview: conversionPreview,
              healthSummary: healthSummary,
              initialApplyStrategy: initialApplyStrategy,
              onConfigChanged: onConfigChanged,
              onApplyStrategyChanged: onApplyStrategyChanged,
              onRepositionInsideCanvas: onRepositionInsideCanvas,
              onSelectOffCanvas: onSelectOffCanvas,
              onSelectExpandableOffCanvas: onSelectExpandableOffCanvas,
              onSelectRepositionOffCanvas: onSelectRepositionOffCanvas,
              onSelectOffRulePositions: onSelectOffRulePositions,
              onSelectOffRuleSizes: onSelectOffRuleSizes,
              onSelectAutoGridConflicts: onSelectAutoGridConflicts,
            ),
          ),
        ),
      ),
    ),
  );
}

class _LayoutRulesEditorHarness extends StatefulWidget {
  final LayoutConfig initialConfig;
  final GridSettings initialSettings;
  final int visibleComponentCount;
  final LayoutRulesComponentScope? componentScope;
  final LayoutRulesConversionPreview? conversionPreview;
  final LayoutHealthSummary? healthSummary;
  final LayoutRulesApplyStrategy initialApplyStrategy;
  final ValueChanged<LayoutConfig>? onConfigChanged;
  final ValueChanged<LayoutRulesApplyStrategy>? onApplyStrategyChanged;
  final VoidCallback? onRepositionInsideCanvas;
  final VoidCallback? onSelectOffCanvas;
  final VoidCallback? onSelectExpandableOffCanvas;
  final VoidCallback? onSelectRepositionOffCanvas;
  final VoidCallback? onSelectOffRulePositions;
  final VoidCallback? onSelectOffRuleSizes;
  final VoidCallback? onSelectAutoGridConflicts;

  const _LayoutRulesEditorHarness({
    required this.initialConfig,
    required this.initialSettings,
    required this.visibleComponentCount,
    this.componentScope,
    this.conversionPreview,
    this.healthSummary,
    required this.initialApplyStrategy,
    this.onConfigChanged,
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
  State<_LayoutRulesEditorHarness> createState() =>
      _LayoutRulesEditorHarnessState();
}

class _LayoutRulesEditorHarnessState extends State<_LayoutRulesEditorHarness> {
  late GridSettings _settings;
  late LayoutConfig _config;
  var _applyStrategy = LayoutRulesApplyStrategy.preserve;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
    _config = widget.initialConfig;
    _applyStrategy = widget.initialApplyStrategy;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutRulesDraftEditor(
      settings: _settings,
      config: _config,
      baselineSettings: widget.initialSettings,
      baselineConfig: widget.initialConfig,
      visibleComponentCount: widget.visibleComponentCount,
      componentScope: widget.componentScope,
      conversionPreview: widget.conversionPreview,
      healthSummary: widget.healthSummary,
      applyStrategy: _applyStrategy,
      onSettingsChanged: (settings) {
        setState(() => _settings = settings);
      },
      onConfigChanged: (config) {
        setState(() => _config = config);
        widget.onConfigChanged?.call(config);
      },
      onPresetSelected: (preset) {
        setState(() {
          _settings = preset.applyToGridSettings(_settings);
          _config = preset.applyToConfig(_config);
        });
        widget.onConfigChanged?.call(_config);
      },
      onApplyStrategyChanged: (strategy) {
        setState(() => _applyStrategy = strategy);
        widget.onApplyStrategyChanged?.call(strategy);
      },
      onRepositionInsideCanvas: widget.onRepositionInsideCanvas,
      onSelectOffCanvas: widget.onSelectOffCanvas,
      onSelectExpandableOffCanvas: widget.onSelectExpandableOffCanvas,
      onSelectRepositionOffCanvas: widget.onSelectRepositionOffCanvas,
      onSelectOffRulePositions: widget.onSelectOffRulePositions,
      onSelectOffRuleSizes: widget.onSelectOffRuleSizes,
      onSelectAutoGridConflicts: widget.onSelectAutoGridConflicts,
    );
  }
}
