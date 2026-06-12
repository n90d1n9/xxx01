import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/canvas_viewport_provider.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/editor_command_palette.dart';

void main() {
  testWidgets('Editor command palette shows removable active filters', (
    tester,
  ) async {
    final container = _container(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder:
                  (context, ref, _) => TextButton(
                    onPressed: () => showEditorCommandPalette(context, ref),
                    child: const Text('Open palette'),
                  ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open palette'));
    await tester.pumpAndSettle();

    await tester.enterText(_commandSearchField(), 'zoom');
    await tester.pumpAndSettle();
    await tester.tap(_choiceChipStartingWith('Command '));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Available only'));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsOneWidget);
    expect(find.text('Search "zoom"'), findsOneWidget);
    expect(find.text('Group Command'), findsOneWidget);
    expect(find.byTooltip('Clear availability filter'), findsOneWidget);
    expect(find.text('Clear all'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear command search filter'));
    await tester.pumpAndSettle();

    expect(find.text('Search "zoom"'), findsNothing);
    expect(find.text('Group Command'), findsOneWidget);
    expect(find.byTooltip('Clear availability filter'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear command group filter'));
    await tester.pumpAndSettle();

    expect(find.text('Group Command'), findsNothing);
    expect(find.byTooltip('Clear availability filter'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear availability filter'));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsNothing);
    expect(find.byTooltip('Clear availability filter'), findsNothing);

    await tester.enterText(_commandSearchField(), 'zoom');
    await tester.pumpAndSettle();
    await tester.tap(_choiceChipStartingWith('Command '));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Available only'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsNothing);
    expect(find.text('Search "zoom"'), findsNothing);
    expect(find.text('Group Command'), findsNothing);
    expect(find.byTooltip('Clear availability filter'), findsNothing);

    await tester.enterText(_commandSearchField(), 'definitely-no-command');
    await tester.pumpAndSettle();

    expect(find.text('No commands found'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    expect(find.text('No commands found'), findsNothing);
    expect(find.text('Active filters'), findsNothing);
    expect(find.text('Save layout'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Editor command palette exposes shared builder snapshot export', (
    tester,
  ) async {
    final container = _container(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder:
                  (context, ref, _) => TextButton(
                    onPressed: () => showEditorCommandPalette(context, ref),
                    child: const Text('Open palette'),
                  ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open palette'));
    await tester.pumpAndSettle();
    await tester.enterText(_commandSearchField(), 'shared snapshot');
    await tester.pumpAndSettle();

    expect(find.text('Copy shared builder snapshot'), findsOneWidget);
    expect(find.textContaining('File - 0 components'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Editor command palette fits canvas to content with feedback', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    _configureGrid(notifier);
    notifier.addComponent(
      _component('content', position: const Offset(500, 300)),
    );

    await _pumpPaletteLauncher(tester, container);
    await tester.tap(find.text('Open palette'));
    await tester.pumpAndSettle();
    await tester.enterText(_commandSearchField(), 'fit canvas to content');
    await tester.pumpAndSettle();

    expect(find.text('Fit canvas to content'), findsOneWidget);

    await tester.tap(find.text('Fit canvas to content'));
    await tester.pumpAndSettle();

    expect(
      container.read(layoutStateProvider).config.canvasSize,
      const Size(564, 364),
    );
    expect(find.text('Fit canvas to content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Editor command palette applies zoom preset with feedback', (
    tester,
  ) async {
    final container = _container(tester);

    await _pumpPaletteLauncher(tester, container);
    await tester.tap(find.text('Open palette'));
    await tester.pumpAndSettle();
    await tester.enterText(_commandSearchField(), 'set zoom to 125');
    await tester.pumpAndSettle();

    expect(find.text('Set zoom to 125%'), findsOneWidget);

    await tester.tap(find.text('Set zoom to 125%'));
    await tester.pumpAndSettle();

    expect(container.read(canvasViewportProvider).zoom, closeTo(1.25, 0.001));
    expect(find.text('Zoom set to 125%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Editor command palette explains clear spot without selection', (
    tester,
  ) async {
    final container = _container(tester);

    await _pumpPaletteLauncher(tester, container);
    await tester.tap(find.text('Open palette'));
    await tester.pumpAndSettle();
    await tester.enterText(_commandSearchField(), 'clear spot');
    await tester.pumpAndSettle();

    final commandTile = _commandTile('Move selection to clear spot');

    expect(commandTile, findsOneWidget);
    expect(find.text('Layout - Select a component first'), findsOneWidget);
    expect(tester.widget<ListTile>(commandTile).enabled, isFalse);

    await tester.tap(find.widgetWithText(FilterChip, 'Available only'));
    await tester.pumpAndSettle();

    expect(commandTile, findsNothing);
    expect(find.text('No available commands found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Editor command palette explains clear spot without a destination',
    (tester) async {
      final container = _container(tester);
      final notifier = container.read(layoutStateProvider.notifier);
      _configureGrid(notifier);
      notifier.addComponent(_component('solo', position: const Offset(20, 20)));
      notifier.selectComponent('solo');

      await _pumpPaletteLauncher(tester, container);
      await tester.tap(find.text('Open palette'));
      await tester.pumpAndSettle();
      await tester.enterText(_commandSearchField(), 'clear spot');
      await tester.pumpAndSettle();

      final commandTile = _commandTile('Move selection to clear spot');

      expect(commandTile, findsOneWidget);
      expect(find.text('Layout - No clear spot available'), findsOneWidget);
      expect(tester.widget<ListTile>(commandTile).enabled, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Editor command palette moves selection inside canvas', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    _configureGrid(notifier);
    notifier.addComponent(
      _component('outside', position: const Offset(260, 20)),
    );
    notifier.selectComponent('outside');

    await _pumpPaletteLauncher(tester, container);
    await tester.tap(find.text('Open palette'));
    await tester.pumpAndSettle();
    await tester.enterText(_commandSearchField(), 'inside canvas');
    await tester.pumpAndSettle();

    expect(find.text('Keep selection inside canvas'), findsOneWidget);

    await tester.tap(find.text('Keep selection inside canvas'));
    await tester.pumpAndSettle();

    expect(
      container.read(layoutStateProvider).componentsById['outside']?.position,
      const Offset(200, 20),
    );
    expect(find.text('Moved selection inside canvas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Editor command palette fits selection into canvas', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    _configureGrid(notifier);
    notifier.addComponent(
      _component(
        'wide',
        position: const Offset(-20, 20),
        size: const Size(320, 80),
      ),
    );
    notifier.selectComponent('wide');

    await _pumpPaletteLauncher(tester, container);
    await tester.tap(find.text('Open palette'));
    await tester.pumpAndSettle();
    await tester.enterText(_commandSearchField(), 'fit selection into canvas');
    await tester.pumpAndSettle();

    expect(find.text('Fit selection into canvas'), findsOneWidget);

    await tester.tap(find.text('Fit selection into canvas'));
    await tester.pumpAndSettle();

    final fitted = container.read(layoutStateProvider).componentsById['wide'];

    expect(fitted?.position, const Offset(20, 100));
    expect(fitted?.size, const Size(200, 40));
    expect(find.text('Fit selection into canvas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Editor command palette moves selection to canvas origin', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    _configureGrid(notifier);
    notifier.addComponent(_component('offset', position: const Offset(60, 40)));
    notifier.selectComponent('offset');

    await _pumpPaletteLauncher(tester, container);
    await tester.tap(find.text('Open palette'));
    await tester.pumpAndSettle();
    await tester.enterText(_commandSearchField(), 'canvas origin');
    await tester.pumpAndSettle();

    expect(find.text('Move selection to canvas origin'), findsOneWidget);

    await tester.tap(find.text('Move selection to canvas origin'));
    await tester.pumpAndSettle();

    expect(
      container.read(layoutStateProvider).componentsById['offset']?.position,
      Offset.zero,
    );
    expect(find.text('Moved selection to canvas origin'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Editor command palette aligns selection with feedback', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    _configureGrid(notifier);
    notifier.updateGridSettings(
      const GridSettings(gridSize: 20, snapToGrid: false),
    );
    notifier.addComponents([
      _component('left', position: const Offset(60, 20)),
      _component('right', position: const Offset(100, 80)),
    ]);
    notifier.selectComponents({'left', 'right'});

    await _pumpPaletteLauncher(tester, container);
    await tester.tap(find.text('Open palette'));
    await tester.pumpAndSettle();
    await tester.enterText(_commandSearchField(), 'align left');
    await tester.pumpAndSettle();

    expect(find.text('Align left'), findsOneWidget);

    await tester.tap(find.text('Align left'));
    await tester.pumpAndSettle();

    final components = container.read(layoutStateProvider).componentsById;

    expect(components['left']?.position, const Offset(60, 20));
    expect(components['right']?.position, const Offset(60, 80));
    expect(find.text('Aligned selection left'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Editor command palette stacks selection with feedback', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    _configureGrid(notifier);
    notifier.addComponents([
      _component('first', position: const Offset(60, 40)),
      _component('second', position: const Offset(20, 20)),
    ]);
    notifier.selectComponents({'first', 'second'});

    await _pumpPaletteLauncher(tester, container);
    await tester.tap(find.text('Open palette'));
    await tester.pumpAndSettle();
    await tester.enterText(_commandSearchField(), 'stack selection as row');
    await tester.pumpAndSettle();

    expect(find.text('Stack selection as row'), findsOneWidget);

    await tester.tap(find.text('Stack selection as row'));
    await tester.pumpAndSettle();

    final components = container.read(layoutStateProvider).componentsById;

    expect(components['first']?.position, const Offset(80, 20));
    expect(components['second']?.position, const Offset(20, 20));
    expect(find.text('Stacked selection horizontally'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Editor command palette snaps visible components with feedback', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    _configureGrid(notifier);
    notifier.updateGridSettings(
      const GridSettings(gridSize: 20, snapToGrid: false),
    );
    notifier.addComponents([
      _component('visible', position: const Offset(20, 20)),
      _component('hidden', position: const Offset(40, 40), isVisible: false),
    ]);
    notifier.updateComponentPosition('visible', const Offset(13, 27));

    await _pumpPaletteLauncher(tester, container);
    await tester.tap(find.text('Open palette'));
    await tester.pumpAndSettle();
    await tester.enterText(_commandSearchField(), 'snap visible components');
    await tester.pumpAndSettle();

    expect(
      find.text('Snap visible components to layout rules'),
      findsOneWidget,
    );

    await tester.tap(find.text('Snap visible components to layout rules'));
    await tester.pumpAndSettle();

    final components = container.read(layoutStateProvider).componentsById;

    expect(components['visible']?.position, const Offset(20, 20));
    expect(components['hidden']?.position, const Offset(40, 40));
    expect(
      find.text('Snapped visible components to layout rules'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Editor command palette moves selection to free Auto Grid cells',
    (tester) async {
      final container = _container(tester);
      final notifier = container.read(layoutStateProvider.notifier);
      _configureAutoGrid(notifier);
      notifier.addComponents([
        _component(
          'blocker',
          position: Offset.zero,
          size: const Size(100, 100),
        ),
        _component('moving', position: Offset.zero, size: const Size(100, 100)),
      ]);
      notifier.selectComponent('moving');

      await _pumpPaletteLauncher(tester, container);
      await tester.tap(find.text('Open palette'));
      await tester.pumpAndSettle();
      await tester.enterText(_commandSearchField(), 'free auto grid cells');
      await tester.pumpAndSettle();

      expect(
        find.text('Move selection to free Auto Grid cells'),
        findsOneWidget,
      );

      await tester.tap(find.text('Move selection to free Auto Grid cells'));
      await tester.pumpAndSettle();

      expect(
        container.read(layoutStateProvider).componentsById['moving']?.position,
        const Offset(110, 0),
      );
      expect(
        find.text('Moved selection to free Auto Grid cells'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Editor command palette moves selection to a clear spot', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    _configureGrid(notifier);
    notifier.addComponents([
      _component('blocker', position: const Offset(20, 20)),
      _component('dragged', position: const Offset(20, 20)),
    ]);
    notifier.selectComponent('dragged');

    await _pumpPaletteLauncher(tester, container);
    await tester.tap(find.text('Open palette'));
    await tester.pumpAndSettle();
    await tester.enterText(_commandSearchField(), 'clear spot');
    await tester.pumpAndSettle();

    expect(
      find.text('Move selection to clear spot (Grid c4 r2)'),
      findsOneWidget,
    );
    expect(find.textContaining('Clear spot: Grid'), findsOneWidget);

    await tester.tap(find.text('Move selection to clear spot (Grid c4 r2)'));
    await tester.pumpAndSettle();

    expect(
      container.read(layoutStateProvider).componentsById['dragged']?.position,
      const Offset(60, 20),
    );
    expect(
      find.text('Moved selection to clear spot at Grid c4 r2'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpPaletteLauncher(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder:
                (context, ref, _) => TextButton(
                  onPressed: () => showEditorCommandPalette(context, ref),
                  child: const Text('Open palette'),
                ),
          ),
        ),
      ),
    ),
  );
}

Finder _commandSearchField() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is TextField && widget.decoration?.hintText == 'Search commands',
  );
}

Finder _choiceChipStartingWith(String labelPrefix) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is ChoiceChip &&
        widget.label is Text &&
        ((widget.label as Text).data?.startsWith(labelPrefix) ?? false),
  );
}

Finder _commandTile(String title) {
  return find.ancestor(of: find.text(title), matching: find.byType(ListTile));
}

void _configureGrid(LayoutStateNotifier notifier) {
  notifier.updateLayoutConfig(
    const LayoutConfig(
      canvasWidth: 240,
      canvasHeight: 240,
      minComponentWidth: 20,
      minComponentHeight: 20,
      layoutMechanism: LayoutMechanism.grid,
    ),
  );
  notifier.updateGridSettings(const GridSettings(gridSize: 20));
}

void _configureAutoGrid(LayoutStateNotifier notifier) {
  notifier.updateLayoutConfig(
    const LayoutConfig(
      canvasWidth: 430,
      canvasHeight: 430,
      minComponentWidth: 20,
      minComponentHeight: 20,
      layoutMechanism: LayoutMechanism.autoGrid,
      autoGridColumnCount: 4,
      autoGridGap: 10,
      autoGridRowHeight: 100,
    ),
  );
}

ProviderContainer _container(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 760);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}

ComponentData _component(
  String id, {
  required Offset position,
  Size size = const Size(40, 40),
  bool isVisible = true,
}) {
  return ComponentData.create(
    id: id,
    type: ComponentType.customButton,
    position: position,
    size: size,
  ).copyWith(isVisible: isVisible);
}
