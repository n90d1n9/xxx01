import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_draft_status.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_session.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_worksheet_filter.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_form_fields.dart';
import 'package:kaysir/features/inventory/widgets/inventory_separated_list.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_opname_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';
import 'package:kaysir/widgets/ui/app_icon_action_button.dart';
import 'package:kaysir/widgets/ui/app_icon_badge.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('stock opname summary renders count metrics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockOpnameSummary(
            lines: [
              _line(id: 'i1', actualQuantity: 7),
              _line(id: 'i2', systemQuantity: 8, actualQuantity: 6),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Count Lines'), findsOneWidget);
    expect(find.text('Matched'), findsOneWidget);
    expect(find.text('Variances'), findsOneWidget);
    expect(find.text('Net Change'), findsOneWidget);
  });

  test('stock opname summary metrics format count and variance state', () {
    final metrics = inventoryStockOpnameSummaryMetrics([
      _line(actualQuantity: 3),
      _line(id: 'i2', systemQuantity: 8, actualQuantity: 8),
    ]);
    final metricByTitle = {for (final metric in metrics) metric.title: metric};

    expect(metricByTitle['Count Lines']?.value, '2');
    expect(metricByTitle['Matched']?.value, '1');
    expect(metricByTitle['Variances']?.value, '1');
    expect(metricByTitle['Variances']?.helper, '2 units off');
    expect(metricByTitle['Net Change']?.value, '-2 units');
    expect(metricByTitle['Net Change']?.accentColor, Colors.red.shade700);
  });

  test('stock opname worksheet toolbar options expose labels and counts', () {
    const counts = InventoryStockOpnameWorksheetFilterCounts(
      total: 8,
      edited: 2,
      invalid: 1,
      variance: 3,
      matched: 5,
      filtered: 4,
    );

    final filterOptions = inventoryStockOpnameWorksheetFilterOptions(counts);
    final sortOptions = inventoryStockOpnameWorksheetSortOptions();

    expect(filterOptions.map((option) => option.label), [
      'All',
      'Edited',
      'Invalid',
      'Variance',
      'Matched',
    ]);
    expect(filterOptions.map((option) => option.count), [8, 2, 1, 3, 5]);
    expect(filterOptions[3].icon, Icons.warning_amber_rounded);
    expect(sortOptions.map((option) => option.label), [
      'Sheet order',
      'Product A-Z',
      'Largest variance',
      'Edited first',
      'Invalid first',
    ]);
    expect(inventoryStockOpnameWorksheetResultLabel(counts), '4 of 8 lines');
    expect(
      inventoryStockOpnameWorksheetResultLabel(
        const InventoryStockOpnameWorksheetFilterCounts(
          total: 1,
          edited: 0,
          invalid: 0,
          variance: 0,
          matched: 1,
          filtered: 1,
        ),
      ),
      '1 of 1 line',
    );
  });

  test(
    'stock opname worksheet empty state details describe row visibility',
    () {
      final filtered = inventoryStockOpnameWorksheetEmptyStateDetails(
        filter: const InventoryStockOpnameWorksheetFilterState(
          query: 'missing',
          filter: InventoryStockOpnameWorksheetFilter.variance,
        ),
        totalInventoryLines: 12,
      );
      final noStock = inventoryStockOpnameWorksheetEmptyStateDetails(
        filter: InventoryStockOpnameWorksheetFilterState.initial,
        totalInventoryLines: 0,
      );
      final emptyWarehouse = inventoryStockOpnameWorksheetEmptyStateDetails(
        filter: InventoryStockOpnameWorksheetFilterState.initial,
        totalInventoryLines: 8,
      );

      expect(filtered.title, 'No count lines match');
      expect(
        filtered.message,
        'Clear filters or search another product to review the count sheet.',
      );
      expect(filtered.icon, Icons.filter_alt_off_rounded);
      expect(noStock.title, 'No stock lines to count');
      expect(noStock.message, 'Add stock lines before starting stock opname.');
      expect(emptyWarehouse.title, 'No stock lines to count');
      expect(
        emptyWarehouse.message,
        'Choose another warehouse to continue counting.',
      );
    },
  );

  test('stock opname draft status details describe save readiness', () {
    final changed = inventoryStockOpnameDraftStatusDetails(
      const InventoryStockOpnameDraftStatus(
        changedLineCount: 1,
        invalidActualQuantityLineCount: 0,
      ),
    );
    final invalid = inventoryStockOpnameDraftStatusDetails(
      const InventoryStockOpnameDraftStatus(
        changedLineCount: 2,
        invalidActualQuantityLineCount: 1,
      ),
    );
    final clean = inventoryStockOpnameDraftStatusDetails(
      InventoryStockOpnameDraftStatus.clean,
    );

    expect(changed.title, 'Unsaved count sheet changes');
    expect(
      changed.subtitle,
      '1 edited line is ready to save as draft or complete.',
    );
    expect(changed.reviewActionLabel, 'Review first change');
    expect(changed.reviewMessage, 'Review the edited count line');
    expect(changed.badges.single.label, '1 edited line');
    expect(changed.hasInvalidDrafts, isFalse);
    expect(invalid.title, 'Fix count input before saving');
    expect(
      invalid.subtitle,
      '1 count input needs a valid whole number. 2 edited lines also need saving.',
    );
    expect(invalid.reviewActionLabel, 'Fix first input');
    expect(
      invalid.reviewMessage,
      'Review the invalid count input before saving',
    );
    expect(invalid.badges.map((badge) => badge.label), [
      '2 edited lines',
      '1 invalid input',
    ]);
    expect(invalid.hasInvalidDrafts, isTrue);
    expect(clean.title, 'No pending count sheet changes');
    expect(clean.badges, isEmpty);
  });

  testWidgets('stock opname draft status content renders badges', (
    tester,
  ) async {
    final details = inventoryStockOpnameDraftStatusDetails(
      const InventoryStockOpnameDraftStatus(
        changedLineCount: 2,
        invalidActualQuantityLineCount: 1,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return InventoryStockOpnameDraftStatusContent(
                title: details.title,
                subtitle: details.subtitle,
                accentColor: inventoryStockOpnameDraftAccentColor(
                  Theme.of(context).colorScheme,
                  details,
                ),
                badges: details.badges,
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Fix count input before saving'), findsOneWidget);
    expect(find.text('2 edited lines'), findsOneWidget);
    expect(find.text('1 invalid input'), findsOneWidget);
  });

  testWidgets('stock opname draft status actions route callbacks', (
    tester,
  ) async {
    var reviewed = false;
    var reset = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockOpnameDraftStatusActions(
            reviewActionLabel: 'Review first change',
            resetActionLabel: 'Discard edits',
            onReviewFirstIssue: () => reviewed = true,
            onReset: () => reset = true,
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(TextButton, 'Review first change'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Discard edits'));

    expect(reviewed, isTrue);
    expect(reset, isTrue);
  });

  test('stock opname batch action details describe visible row matching', () {
    final hidden = inventoryStockOpnameBatchActionDetails(
      visibleLineCount: 0,
      matchableLineCount: 2,
      hasMatchVisibleHandler: true,
    );
    final matched = inventoryStockOpnameBatchActionDetails(
      visibleLineCount: 2,
      matchableLineCount: 0,
      hasMatchVisibleHandler: true,
    );
    final single = inventoryStockOpnameBatchActionDetails(
      visibleLineCount: 2,
      matchableLineCount: 1,
      hasMatchVisibleHandler: true,
    );
    final multiple = inventoryStockOpnameBatchActionDetails(
      visibleLineCount: 4,
      matchableLineCount: 3,
      hasMatchVisibleHandler: true,
    );
    final disabled = inventoryStockOpnameBatchActionDetails(
      visibleLineCount: 4,
      matchableLineCount: 3,
      hasMatchVisibleHandler: false,
    );

    expect(hidden.isVisible, isFalse);
    expect(matched.summaryLabel, 'All visible rows matched');
    expect(matched.canMatchVisible, isFalse);
    expect(single.summaryLabel, '1 row needs matching');
    expect(single.canMatchVisible, isTrue);
    expect(multiple.summaryLabel, '3 rows need matching');
    expect(disabled.canMatchVisible, isFalse);
  });

  testWidgets('stock opname controls emit warehouse changes', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    String? selectedWarehouseId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockOpnameControls(
            warehouses: _warehouses(),
            selectedWarehouseId: 'w1',
            conductedByController: controller,
            onWarehouseChanged: (value) => selectedWarehouseId = value,
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(InventoryStockOpnameSetupFields), findsOneWidget);
    expect(find.byType(AppSelectField<String?>), findsOneWidget);
    expect(find.byType(InventoryFormTextField), findsOneWidget);
    expect(find.text('Count Setup'), findsOneWidget);

    await tester.tap(find.text('Main Warehouse'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('North Warehouse').last);
    await tester.pumpAndSettle();

    expect(selectedWarehouseId, 'w2');
  });

  testWidgets('stock opname controls render reusable validation messages', (
    tester,
  ) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: InventoryStockOpnameControls(
              warehouses: _warehouses(),
              conductedByController: controller,
              warehouseValidator: inventoryStockOpnameWarehouseFieldError,
              conductedByValidator: inventoryStockOpnameCounterFieldError,
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    expect(
      find.text('Select a warehouse before saving the count.'),
      findsOneWidget,
    );
    expect(find.text('Enter who conducted the stock opname.'), findsOneWidget);
  });

  testWidgets('stock opname setup fields adapt compact and wide layouts', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = TextEditingController();
    addTearDown(controller.dispose);

    Future<void> pumpFields(double width) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: InventoryStockOpnameSetupFields(
                  warehouses: _warehouses(),
                  selectedWarehouseId: 'w1',
                  conductedByController: controller,
                ),
              ),
            ),
          ),
        ),
      );
    }

    await pumpFields(640);

    expect(
      find.byKey(const ValueKey('stock-opname-setup-fields-compact')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('stock-opname-setup-fields-wide')),
      findsNothing,
    );

    await pumpFields(820);

    expect(
      find.byKey(const ValueKey('stock-opname-setup-fields-wide')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('stock-opname-setup-fields-compact')),
      findsNothing,
    );
  });

  testWidgets('stock opname panel renders editable lines and actions', (
    tester,
  ) async {
    var actualValue = '';
    var notesValue = '';
    var matched = false;
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockOpnamePanel(
            lines: [_line(actualQuantity: 3)],
            totalInventoryLines: 1,
            onActualQuantityChanged: (_, value) => actualValue = value,
            onNotesChanged: (_, value) => notesValue = value,
            onMatchSystem: (_) => matched = true,
            onComplete: () => completed = true,
          ),
        ),
      ),
    );

    expect(
      find.byType(InventorySeparatedList<InventoryStockOpnameLine>),
      findsOneWidget,
    );
    expect(find.byType(InventoryStockOpnameLineTile), findsOneWidget);
    expect(find.byType(InventoryStockOpnameWorksheetLineList), findsOneWidget);
    expect(find.byType(InventoryStockOpnameActions), findsOneWidget);
    expect(find.byType(InventoryStockOpnameActionLayout), findsOneWidget);
    expect(find.byType(InventoryStockOpnameVariancePill), findsOneWidget);
    expect(find.byType(InventoryStockOpnameLineIdentity), findsOneWidget);
    expect(find.byType(InventoryStockOpnameLineLayout), findsOneWidget);
    expect(find.byType(InventoryStockOpnameLineNotesField), findsOneWidget);
    expect(find.byType(InventoryStockOpnameCountStepper), findsOneWidget);
    expect(find.byType(InventoryTileSurface), findsOneWidget);
    expect(find.byType(InventoryIntegerFormField), findsOneWidget);
    expect(find.byType(InventoryFormTextField), findsNWidgets(2));
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('-2 units'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-actual-i1')),
      '7',
    );
    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-notes-i1')),
      'Shelf recount',
    );
    await tester.tap(find.byTooltip('Match system count for Laptop'));
    await tester.tap(find.widgetWithText(FilledButton, 'Complete count'));

    expect(actualValue, '7');
    expect(notesValue, 'Shelf recount');
    expect(matched, isTrue);
    expect(completed, isTrue);
  });

  testWidgets('stock opname panel emits visible match batch action', (
    tester,
  ) async {
    List<InventoryStockOpnameLine> matchedLines = const [];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockOpnamePanel(
            lines: [_line(actualQuantity: 3), _line(id: 'i2')],
            totalInventoryLines: 2,
            onMatchVisibleLines: (lines) => matchedLines = lines,
          ),
        ),
      ),
    );

    expect(find.byType(InventoryStockOpnameBatchActions), findsOneWidget);
    expect(find.text('1 row needs matching'), findsOneWidget);
    expect(
      find.widgetWithText(OutlinedButton, 'Match visible'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Match visible'));
    await tester.pump();

    expect(matchedLines.map((line) => line.id), ['i1', 'i2']);
  });

  testWidgets('stock opname panel disables matched visible batch action', (
    tester,
  ) async {
    var matchedVisible = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockOpnamePanel(
            lines: [_line(), _line(id: 'i2')],
            totalInventoryLines: 2,
            onMatchVisibleLines: (_) => matchedVisible = true,
          ),
        ),
      ),
    );

    final matchButton = find.widgetWithText(OutlinedButton, 'Match visible');
    expect(find.text('All visible rows matched'), findsOneWidget);
    expect(matchButton, findsOneWidget);
    expect(tester.widget<OutlinedButton>(matchButton).onPressed, isNull);

    await tester.tap(matchButton);
    await tester.pump();

    expect(matchedVisible, isFalse);
  });

  testWidgets('stock opname actions emit footer callbacks', (tester) async {
    var reset = false;
    var saved = false;
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockOpnameActions(
            onReset: () => reset = true,
            onSaveDraft: () => saved = true,
            onComplete: () => completed = true,
          ),
        ),
      ),
    );

    expect(find.byType(InventoryStockOpnameActionLayout), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Reset count'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Save draft'));
    await tester.tap(find.widgetWithText(FilledButton, 'Complete count'));

    expect(reset, isTrue);
    expect(saved, isTrue);
    expect(completed, isTrue);
  });

  testWidgets('stock opname action layout adapts compact and wide footers', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<void> pumpLayout(double width) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: InventoryStockOpnameActionLayout(
                  actions: const [
                    Text('Reset action'),
                    Text('Draft action'),
                    Text('Complete action'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    await pumpLayout(480);

    expect(
      find.descendant(
        of: find.byType(InventoryStockOpnameActionLayout),
        matching: find.byType(Column),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(InventoryStockOpnameActionLayout),
        matching: find.byType(Row),
      ),
      findsNothing,
    );

    await pumpLayout(700);

    expect(
      find.descendant(
        of: find.byType(InventoryStockOpnameActionLayout),
        matching: find.byType(Row),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(InventoryStockOpnameActionLayout),
        matching: find.byType(Column),
      ),
      findsNothing,
    );
  });

  testWidgets('stock opname count stepper nudges actual quantity', (
    tester,
  ) async {
    final controller = TextEditingController(text: '5');
    addTearDown(controller.dispose);

    final changes = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: InventoryStockOpnameCountStepper(
              fieldKey: const ValueKey('stock-opname-stepper-field'),
              controller: controller,
              value: 5,
              productName: 'Laptop',
              onChanged: changes.add,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Increase count for Laptop'));
    await tester.pump();

    expect(controller.text, '6');
    expect(changes.last, '6');

    await tester.tap(find.byTooltip('Decrease count for Laptop'));
    await tester.tap(find.byTooltip('Decrease count for Laptop'));
    await tester.pump();

    expect(controller.text, '4');
    expect(changes.last, '4');
  });

  testWidgets('stock opname line match action disables matched rows', (
    tester,
  ) async {
    var matched = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockOpnameLineTile(
            line: _line(),
            onMatchSystem: () => matched = true,
          ),
        ),
      ),
    );

    final actionFinder = find.byWidgetPredicate(
      (widget) =>
          widget is AppIconActionButton &&
          widget.tooltip == 'Already matches system count for Laptop',
    );

    expect(
      find.byTooltip('Already matches system count for Laptop'),
      findsOneWidget,
    );
    expect(actionFinder, findsOneWidget);
    expect(tester.widget<AppIconActionButton>(actionFinder).onPressed, isNull);

    await tester.tap(find.byTooltip('Already matches system count for Laptop'));
    await tester.pump();

    expect(matched, isFalse);
  });

  testWidgets(
    'stock opname line layout switches compact and wide composition',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Future<void> pumpLayout(double width) {
        return tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: InventoryStockOpnameLineLayout(
                    identity: const Text('Identity slot'),
                    actualField: const Text('Actual slot'),
                    notesField: const Text('Notes slot'),
                    variance: const Text('Variance slot'),
                    action: const Text('Action slot'),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      await pumpLayout(700);

      expect(
        find.descendant(
          of: find.byType(InventoryStockOpnameLineLayout),
          matching: find.byType(Column),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(InventoryStockOpnameLineLayout),
          matching: find.byType(Wrap),
        ),
        findsOneWidget,
      );

      await pumpLayout(1000);

      expect(
        find.descendant(
          of: find.byType(InventoryStockOpnameLineLayout),
          matching: find.byType(Row),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(InventoryStockOpnameLineLayout),
          matching: find.byType(Wrap),
        ),
        findsNothing,
      );
    },
  );

  testWidgets('stock opname line tile applies discrepancy row tone', (
    tester,
  ) async {
    final line = _line(actualQuantity: 3);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: InventoryStockOpnameLineTile(line: line)),
      ),
    );

    final context = tester.element(find.byType(InventoryStockOpnameLineTile));
    final tone = inventoryStockOpnameLineTone(context, line);
    final surfaceDecorationFinder = find.descendant(
      of: find.byType(InventoryTileSurface),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == tone.backgroundColor,
      ),
    );

    expect(surfaceDecorationFinder, findsOneWidget);

    final decoratedBox = tester.widget<DecoratedBox>(surfaceDecorationFinder);
    final decoration = decoratedBox.decoration as BoxDecoration;
    final shape = decoration.border as Border;

    expect(decoration.color, tone.backgroundColor);
    expect(shape.top.color, tone.borderColor);

    final badge = tester.widget<AppIconBadge>(find.byType(AppIconBadge));
    expect(badge.backgroundColor, tone.iconBackgroundColor);
    expect(badge.foregroundColor, tone.accentColor);
  });

  testWidgets('stock opname line identity renders toned product context', (
    tester,
  ) async {
    final line = _line(actualQuantity: 7);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: InventoryStockOpnameLineIdentity(line: line)),
      ),
    );

    final context = tester.element(
      find.byType(InventoryStockOpnameLineIdentity),
    );
    final tone = inventoryStockOpnameLineTone(context, line);
    final badge = tester.widget<AppIconBadge>(find.byType(AppIconBadge));

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('LT-001 | System 5 units'), findsOneWidget);
    expect(badge.backgroundColor, tone.iconBackgroundColor);
    expect(badge.foregroundColor, tone.accentColor);
  });

  testWidgets('stock opname line notes field emits note changes', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Initial recount');
    addTearDown(controller.dispose);
    var note = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockOpnameLineNotesField(
            controller: controller,
            lineId: 'i1',
            onChanged: (value) => note = value,
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('stock-opname-notes-i1')), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-notes-i1')),
      'Second shelf recount',
    );

    expect(controller.text, 'Second shelf recount');
    expect(note, 'Second shelf recount');
  });

  test('stock opname line input controllers sync model values', () {
    final controllers = InventoryStockOpnameLineInputControllers.fromLine(
      _line(actualQuantity: 7, notes: 'Shelf recount'),
    );
    addTearDown(controllers.dispose);

    expect(controllers.actualQuantityController.text, '7');
    expect(controllers.notesController.text, 'Shelf recount');

    controllers.syncActualQuantityFromLine(_line(actualQuantity: 5));
    controllers.syncNotesFromLine(_line(notes: 'External recount note'));

    expect(controllers.actualQuantityController.text, '5');
    expect(controllers.notesController.text, 'External recount note');
  });

  testWidgets('stock opname variance pill labels matched and variance lines', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              InventoryStockOpnameVariancePill(line: _line()),
              InventoryStockOpnameVariancePill(
                line: _line(id: 'i2', actualQuantity: 7),
              ),
              InventoryStockOpnameVariancePill(
                line: _line(id: 'i3', actualQuantity: 3),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Matched'), findsOneWidget);
    expect(find.text('+2 units'), findsOneWidget);
    expect(find.text('-2 units'), findsOneWidget);
  });

  testWidgets('stock opname panel renders draft status banner actions', (
    tester,
  ) async {
    var reviewed = false;
    var reset = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockOpnamePanel(
            lines: [_line(actualQuantity: 3)],
            totalInventoryLines: 1,
            draftStatus: const InventoryStockOpnameDraftStatus(
              changedLineCount: 2,
              invalidActualQuantityLineCount: 1,
            ),
            onReviewDraftIssue: () => reviewed = true,
            onReset: () => reset = true,
          ),
        ),
      ),
    );

    expect(find.byType(InventoryStockOpnameDraftStatusBanner), findsOneWidget);
    expect(find.text('Fix count input before saving'), findsOneWidget);
    expect(find.text('2 edited lines'), findsOneWidget);
    expect(find.text('1 invalid input'), findsOneWidget);

    final banner = find.byType(InventoryStockOpnameDraftStatusBanner);
    await tester.tap(find.widgetWithText(TextButton, 'Fix first input'));
    await tester.tap(
      find.descendant(
        of: banner,
        matching: find.widgetWithText(OutlinedButton, 'Discard edits'),
      ),
    );

    expect(reviewed, isTrue);
    expect(reset, isTrue);
  });

  testWidgets('stock opname panel renders worksheet review toolbar', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final searchController = TextEditingController();
    addTearDown(searchController.dispose);

    var query = '';
    var filter = InventoryStockOpnameWorksheetFilter.all;
    var sort = InventoryStockOpnameWorksheetSort.sheetOrder;
    var reset = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InventoryStockOpnamePanel(
              lines: [_line(actualQuantity: 7), _line(id: 'i2')],
              allLines: [_line(actualQuantity: 7), _line(id: 'i2')],
              totalInventoryLines: 2,
              countSheetSearchController: searchController,
              worksheetFilter: const InventoryStockOpnameWorksheetFilterState(
                query: 'lap',
                filter: InventoryStockOpnameWorksheetFilter.all,
              ),
              worksheetFilterCounts:
                  const InventoryStockOpnameWorksheetFilterCounts(
                    total: 2,
                    edited: 1,
                    invalid: 0,
                    variance: 1,
                    matched: 1,
                    filtered: 1,
                  ),
              onWorksheetSearchChanged: (value) => query = value,
              onWorksheetFilterChanged: (value) => filter = value,
              onWorksheetSortChanged: (value) => sort = value,
              onWorksheetFiltersReset: () => reset = true,
            ),
          ),
        ),
      ),
    );

    final toolbar = find.byType(InventoryStockOpnameWorksheetToolbar);
    expect(toolbar, findsOneWidget);
    expect(
      find.byType(InventoryStockOpnameWorksheetReviewHeader),
      findsOneWidget,
    );
    expect(
      find.byType(InventoryStockOpnameWorksheetFilterChips),
      findsOneWidget,
    );
    expect(find.byType(InventoryStockOpnameWorksheetSortField), findsOneWidget);
    expect(
      find.byType(InventoryStockOpnameWorksheetToolbarMeta),
      findsOneWidget,
    );
    expect(find.text('1 of 2 lines'), findsOneWidget);
    expect(
      find.descendant(of: toolbar, matching: find.text('Edited')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: toolbar, matching: find.text('Invalid')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: toolbar, matching: find.text('Variance')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: toolbar, matching: find.text('Matched')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: toolbar, matching: find.text('Sort rows')),
      findsOneWidget,
    );

    await tester.enterText(
      find.descendant(of: toolbar, matching: find.byType(TextField)),
      'cable',
    );
    await tester.tap(
      find.descendant(of: toolbar, matching: find.text('Variance')),
    );
    await tester.tap(
      find.descendant(
        of: toolbar,
        matching: find.byType(
          AppSelectField<InventoryStockOpnameWorksheetSort>,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Largest variance').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Clear'));

    expect(query, 'cable');
    expect(filter, InventoryStockOpnameWorksheetFilter.variance);
    expect(sort, InventoryStockOpnameWorksheetSort.varianceMagnitude);
    expect(reset, isTrue);
  });

  testWidgets('stock opname panel explains filtered empty worksheet', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final searchController = TextEditingController(text: 'missing');
    addTearDown(searchController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InventoryStockOpnamePanel(
              lines: const [],
              allLines: [_line(id: 'i1'), _line(id: 'i2')],
              totalInventoryLines: 2,
              countSheetSearchController: searchController,
              worksheetFilter: const InventoryStockOpnameWorksheetFilterState(
                query: 'missing',
                filter: InventoryStockOpnameWorksheetFilter.variance,
              ),
              worksheetFilterCounts:
                  const InventoryStockOpnameWorksheetFilterCounts(
                    total: 2,
                    edited: 0,
                    invalid: 0,
                    variance: 0,
                    matched: 2,
                    filtered: 0,
                  ),
              onWorksheetSearchChanged: (_) {},
              onWorksheetFilterChanged: (_) {},
              onWorksheetSortChanged: (_) {},
              onWorksheetFiltersReset: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(InventoryStockOpnameWorksheetToolbar), findsOneWidget);
    expect(find.text('No count lines match'), findsOneWidget);
    expect(find.text('0 of 2 lines'), findsOneWidget);
  });

  testWidgets(
    'stock opname line tile syncs visible inputs from model updates',
    (tester) async {
      Future<void> pumpLine(InventoryStockOpnameLine line) {
        return tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 1000,
                child: InventoryStockOpnameLineTile(line: line),
              ),
            ),
          ),
        );
      }

      await pumpLine(_line(actualQuantity: 7, notes: 'Shelf recount'));

      expect(
        _editableTextValue(tester, const ValueKey('stock-opname-actual-i1')),
        '7',
      );
      expect(
        _editableTextValue(tester, const ValueKey('stock-opname-notes-i1')),
        'Shelf recount',
      );

      await pumpLine(_line(actualQuantity: 5));
      await tester.pump();

      expect(
        _editableTextValue(tester, const ValueKey('stock-opname-actual-i1')),
        '5',
      );
      expect(
        _editableTextValue(tester, const ValueKey('stock-opname-notes-i1')),
        isEmpty,
      );

      await tester.enterText(
        find.byKey(const ValueKey('stock-opname-actual-i1')),
        '',
      );
      await pumpLine(_line(actualQuantity: 5, notes: 'External recount note'));
      await tester.pump();

      expect(
        _editableTextValue(tester, const ValueKey('stock-opname-actual-i1')),
        isEmpty,
      );
      expect(
        _editableTextValue(tester, const ValueKey('stock-opname-notes-i1')),
        'External recount note',
      );
    },
  );

  testWidgets('stock opname panel shows empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InventoryStockOpnamePanel(lines: [], totalInventoryLines: 0),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(
      find.byType(InventoryStockOpnameWorksheetEmptyState),
      findsOneWidget,
    );
    expect(find.text('No stock lines to count'), findsOneWidget);
  });
}

String _editableTextValue(WidgetTester tester, Key fieldKey) {
  final finder = find.descendant(
    of: find.byKey(fieldKey),
    matching: find.byType(EditableText),
  );
  expect(finder, findsOneWidget);
  return tester.widget<EditableText>(finder).controller.text;
}

List<Warehouse> _warehouses() {
  return [
    Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
    Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
  ];
}

InventoryStockOpnameLine _line({
  String id = 'i1',
  int systemQuantity = 5,
  int actualQuantity = 5,
  String notes = '',
}) {
  return InventoryStockOpnameLine(
    id: id,
    inventoryItemId: id,
    productId: 'p1',
    productName: 'Laptop',
    skuLabel: 'LT-001',
    systemQuantity: systemQuantity,
    actualQuantity: actualQuantity,
    notes: notes,
  );
}
