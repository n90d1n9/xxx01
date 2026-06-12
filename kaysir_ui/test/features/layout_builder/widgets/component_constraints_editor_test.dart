import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/widgets/component_constraints_editor.dart';

void main() {
  testWidgets('renders component constraint controls', (tester) async {
    final component = ComponentData.create(
      id: 'button-1',
      type: ComponentType.customButton,
      position: const Offset(20, 20),
      size: const Size(180, 56),
    ).copyWith(
      constraints: const ComponentConstraints(
        horizontalAnchor: ComponentAnchorMode.center,
        verticalAnchor: ComponentAnchorMode.start,
        maintainAspectRatio: true,
        minWidth: 120,
        minHeight: 48,
        maxWidth: 320,
        maxHeight: 120,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ComponentConstraintsEditor(
                component: component,
                config: const LayoutConfig(),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Constraints'), findsOneWidget);
    expect(find.text('Horizontal'), findsOneWidget);
    expect(find.text('Vertical'), findsOneWidget);
    expect(find.text('Lock aspect ratio'), findsOneWidget);
    expect(find.text('Min W'), findsOneWidget);
    expect(find.text('Min H'), findsOneWidget);
    expect(find.text('Max W'), findsOneWidget);
    expect(find.text('Max H'), findsOneWidget);
    expect(find.text('Clear max'), findsOneWidget);
    expect(find.byIcon(Icons.align_horizontal_center), findsOneWidget);
    expect(find.byIcon(Icons.vertical_align_top), findsOneWidget);
  });
}
