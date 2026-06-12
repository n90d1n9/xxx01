import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/provider/review_state.dart';
import 'package:kaysir/features/layout_builder/widgets/component_responsive_override_editor.dart';

void main() {
  testWidgets('creates and edits a mobile responsive override', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(layoutStateProvider.notifier)
        .addComponent(
          ComponentData.create(
            id: 'responsive-button',
            type: ComponentType.customButton,
            position: const Offset(20, 24),
            size: const Size(160, 56),
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(layoutStateProvider);
                  return ComponentResponsiveOverrideEditor(
                    component: state.selectedComponent!,
                    previewState: ResponsivePreviewState.mobile,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Mobile override'), findsOneWidget);
    expect(find.text('Create from base'), findsOneWidget);
    expect(find.text('Visible on this device'), findsOneWidget);

    await tester.tap(find.text('Create from base'));
    await tester.pump();

    var override =
        container
            .read(layoutStateProvider)
            .components
            .single
            .responsiveProperties['mobile'];

    expect(override?.position, const Offset(20, 20));
    expect(override?.size, const Size(160, 80));
    expect(override?.isVisible, isTrue);

    await tester.enterText(find.byType(TextFormField).first, '84');
    await tester.pump();

    override =
        container
            .read(layoutStateProvider)
            .components
            .single
            .responsiveProperties['mobile'];

    expect(override?.position?.dx, 84);
    expect(override?.position?.dy, 20);
    expect(find.text('Refresh from base'), findsOneWidget);
  });
}
