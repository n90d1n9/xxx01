import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/provider/review_state.dart';
import 'package:kaysir/features/layout_builder/widgets/component_selection_responsive_override_editor.dart';

void main() {
  testWidgets('creates and clears selected mobile responsive overrides', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(layoutStateProvider.notifier);
    notifier.addComponents([
      ComponentData.create(
        id: 'responsive-selection-first',
        type: ComponentType.customButton,
        position: const Offset(20, 20),
        size: const Size(160, 56),
      ).copyWith(
        responsiveProperties: const {
          'mobile': ComponentResponsiveProperties(
            position: Offset(12, 20),
            size: Size(180, 72),
            isVisible: true,
          ),
        },
      ),
      ComponentData.create(
        id: 'responsive-selection-second',
        type: ComponentType.customButton,
        position: const Offset(220, 20),
        size: const Size(160, 56),
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
                return SingleChildScrollView(
                  child: SizedBox(
                    width: 320,
                    child: ComponentSelectionResponsiveOverrideEditor(
                      components: state.selectedComponents,
                      previewState: ResponsivePreviewState.mobile,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Responsive overrides'), findsOneWidget);
    expect(find.text('Mobile'), findsOneWidget);
    expect(find.text('1 current'), findsOneWidget);
    expect(find.text('1 with overrides'), findsOneWidget);
    expect(find.text('Use as base'), findsOneWidget);

    await tester.tap(find.text('Copy base'));
    await tester.pump();

    final copiedState = container.read(layoutStateProvider);
    expect(
      copiedState
          .componentsById['responsive-selection-first']
          ?.responsiveProperties
          .containsKey('mobile'),
      isTrue,
    );
    expect(
      copiedState
          .componentsById['responsive-selection-second']
          ?.responsiveProperties['mobile']
          ?.position,
      const Offset(220, 20),
    );
    expect(find.text('2 current'), findsOneWidget);

    await tester.tap(find.text('Reset device'));
    await tester.pump();

    final clearedState = container.read(layoutStateProvider);
    expect(
      clearedState
          .componentsById['responsive-selection-first']
          ?.responsiveProperties
          .containsKey('mobile'),
      isFalse,
    );
    expect(
      clearedState
          .componentsById['responsive-selection-second']
          ?.responsiveProperties
          .containsKey('mobile'),
      isFalse,
    );
  });
}
