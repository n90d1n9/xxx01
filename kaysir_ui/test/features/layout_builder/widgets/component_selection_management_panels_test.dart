import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_selection_management_panels.dart';

void main() {
  testWidgets('renders selection summary and layer overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                ComponentSelectionSummaryCard(
                  components: _selectionComponents(),
                ),
                ComponentSelectionLayersList(
                  components: _selectionComponents(),
                  maxVisibleCount: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('20, 20 - 380x196'), findsOneWidget);
    expect(find.text('3 layers'), findsOneWidget);
    expect(find.text('1 locked'), findsOneWidget);
    expect(find.text('1 hidden'), findsOneWidget);
    expect(find.text('Selected layers'), findsOneWidget);
    expect(find.text('Action Button'), findsOneWidget);
    expect(find.text('+2 more'), findsOneWidget);
  });

  testWidgets('runs group lock and visibility bulk actions', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(layoutStateProvider.notifier);
    notifier.addComponents([
      ComponentData.create(
        id: 'bulk-first',
        type: ComponentType.customButton,
        position: const Offset(20, 20),
        size: const Size(160, 56),
      ),
      ComponentData.create(
        id: 'bulk-second',
        type: ComponentType.textLabel,
        position: const Offset(220, 20),
        size: const Size(180, 48),
      ),
    ]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(layoutStateProvider);
                return ComponentSelectionBulkActionsEditor(
                  components: state.selectedComponents,
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Bulk actions'), findsOneWidget);
    expect(find.text('Group'), findsOneWidget);
    expect(find.text('Lock all'), findsOneWidget);
    expect(find.text('Hide all'), findsOneWidget);

    await tester.tap(find.text('Group'));
    await tester.pump();

    final groupedComponents = container.read(layoutStateProvider).components;
    final groupIds =
        groupedComponents
            .map((component) => component.properties.parentId)
            .whereType<String>()
            .toSet();
    expect(groupIds.length, 1);
    expect(find.text('Ungroup'), findsOneWidget);

    await tester.tap(find.text('Lock all'));
    await tester.pump();

    expect(
      container
          .read(layoutStateProvider)
          .components
          .every((component) => component.isLocked),
      isTrue,
    );
    expect(find.text('Unlock all'), findsOneWidget);

    await tester.tap(find.text('Hide all'));
    await tester.pump();

    expect(
      container
          .read(layoutStateProvider)
          .components
          .every((component) => !component.isVisible),
      isTrue,
    );
    expect(find.text('Show all'), findsOneWidget);
  });
}

List<ComponentData> _selectionComponents() {
  return [
    ComponentData.create(
      id: 'summary-first',
      type: ComponentType.customButton,
      position: const Offset(20, 20),
      size: const Size(160, 56),
    ),
    ComponentData.create(
      id: 'summary-second',
      type: ComponentType.textLabel,
      position: const Offset(220, 20),
      size: const Size(180, 48),
    ).copyWith(isLocked: true),
    ComponentData.create(
      id: 'summary-third',
      type: ComponentType.imageHolder,
      position: const Offset(20, 96),
      size: const Size(180, 120),
    ).copyWith(isVisible: false),
  ];
}
