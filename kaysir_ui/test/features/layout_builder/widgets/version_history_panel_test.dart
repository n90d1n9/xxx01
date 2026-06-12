import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/version_history_panel.dart';

void main() {
  testWidgets('VersionHistoryPanel renders layout snapshot metadata', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    notifier.updateLayoutRules(
      gridSettings: const GridSettings(gridSize: 32, snapToGrid: false),
      config: const LayoutConfig(
        gridSize: 32,
        canvasWidth: 700,
        canvasHeight: 500,
        snapToGrid: false,
        layoutMechanism: LayoutMechanism.tabularColumns,
        tabularColumnCount: 8,
        tabularColumnGap: 18,
      ),
      versionName: 'Rules checkpoint',
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: VersionHistoryPanel())),
      ),
    );

    expect(find.text('Rules checkpoint'), findsOneWidget);
    expect(find.textContaining('Tabular Columns'), findsWidgets);
    expect(find.textContaining('700 x 500'), findsWidgets);
    expect(find.text('8 columns - 18px gap'), findsOneWidget);
    expect(find.text('Mode Tabular Columns'), findsOneWidget);
    expect(find.text('Canvas 700 x 500'), findsOneWidget);
    expect(find.text('8 cols'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('VersionHistoryPanel restores a tapped layout snapshot', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    notifier.updateLayoutRules(
      gridSettings: const GridSettings(gridSize: 28),
      config: const LayoutConfig(
        gridSize: 28,
        canvasWidth: 720,
        canvasHeight: 520,
        layoutMechanism: LayoutMechanism.tabularColumns,
        tabularColumnCount: 9,
      ),
      versionName: 'Tabular checkpoint',
    );
    notifier.updateLayoutRules(
      gridSettings: const GridSettings(gridSize: 20),
      config: const LayoutConfig(
        canvasWidth: 900,
        canvasHeight: 620,
        layoutMechanism: LayoutMechanism.autoGrid,
        autoGridColumnCount: 6,
      ),
      versionName: 'Auto checkpoint',
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: VersionHistoryPanel())),
      ),
    );

    await tester.tap(find.text('Tabular checkpoint'));
    await tester.pump();

    final restored = container.read(layoutStateProvider);
    expect(restored.config.layoutMechanism, LayoutMechanism.tabularColumns);
    expect(restored.config.canvasSize, const Size(720, 520));
    expect(restored.config.tabularColumnCount, 9);
    expect(find.textContaining('current 2 - Tabular Columns'), findsOneWidget);
  });

  testWidgets('VersionHistoryPanel previews and restores from action menu', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    notifier.updateLayoutRules(
      gridSettings: const GridSettings(gridSize: 28),
      config: const LayoutConfig(
        gridSize: 28,
        canvasWidth: 720,
        canvasHeight: 520,
        layoutMechanism: LayoutMechanism.tabularColumns,
        tabularColumnCount: 9,
      ),
      versionName: 'Tabular checkpoint',
    );
    notifier.updateLayoutRules(
      gridSettings: const GridSettings(gridSize: 20),
      config: const LayoutConfig(
        canvasWidth: 900,
        canvasHeight: 620,
        layoutMechanism: LayoutMechanism.autoGrid,
        autoGridColumnCount: 6,
      ),
      versionName: 'Auto checkpoint',
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: VersionHistoryPanel())),
      ),
    );

    await tester.tap(find.byTooltip('Snapshot actions').at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    expect(find.text('Snapshot preview'), findsOneWidget);
    expect(find.text('Tabular checkpoint'), findsWidgets);
    expect(find.text('Mode'), findsOneWidget);
    expect(find.text('Tabular Columns'), findsWidgets);

    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();

    final restored = container.read(layoutStateProvider);
    expect(restored.config.layoutMechanism, LayoutMechanism.tabularColumns);
    expect(restored.config.canvasSize, const Size(720, 520));
  });

  testWidgets('VersionHistoryPanel compares snapshot against current layout', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    notifier.updateLayoutRules(
      gridSettings: const GridSettings(gridSize: 28),
      config: const LayoutConfig(
        gridSize: 28,
        canvasWidth: 720,
        canvasHeight: 520,
        layoutMechanism: LayoutMechanism.tabularColumns,
        tabularColumnCount: 9,
      ),
      versionName: 'Tabular checkpoint',
    );
    notifier.updateLayoutRules(
      gridSettings: const GridSettings(gridSize: 20),
      config: const LayoutConfig(
        canvasWidth: 900,
        canvasHeight: 620,
        layoutMechanism: LayoutMechanism.autoGrid,
        autoGridColumnCount: 6,
      ),
      versionName: 'Auto checkpoint',
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: VersionHistoryPanel())),
      ),
    );

    await tester.tap(find.byTooltip('Snapshot actions').at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compare current'));
    await tester.pumpAndSettle();

    expect(find.text('Compare with current'), findsOneWidget);
    expect(find.text('Restore impact'), findsOneWidget);
    expect(find.text('Tabular checkpoint'), findsWidgets);
    expect(find.text('Auto checkpoint'), findsWidgets);
    expect(find.text('Mode Tabular Columns'), findsWidgets);
    expect(find.text('Canvas 720 x 520'), findsWidgets);

    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();

    final restored = container.read(layoutStateProvider);
    expect(restored.config.layoutMechanism, LayoutMechanism.tabularColumns);
    expect(restored.config.canvasSize, const Size(720, 520));
  });
}

ProviderContainer _container(WidgetTester tester) {
  tester.view.physicalSize = const Size(420, 760);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}
