import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/widgets/component_builtin_config_editor.dart';

void main() {
  testWidgets('routes every component type to its built-in config panel', (
    tester,
  ) async {
    final cases = <({ComponentType type, String expectedText})>[
      (type: ComponentType.buttonGrid, expectedText: 'Product grid'),
      (type: ComponentType.cartPanel, expectedText: 'Cart panel'),
      (type: ComponentType.customButton, expectedText: 'Text appearance'),
      (type: ComponentType.textLabel, expectedText: 'Text appearance'),
      (type: ComponentType.imageHolder, expectedText: 'Image source'),
      (type: ComponentType.numpad, expectedText: 'Numpad controls'),
      (type: ComponentType.functionPanel, expectedText: 'Function panel'),
      (type: ComponentType.separator, expectedText: 'Dashed line'),
    ];

    for (final testCase in cases) {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 360,
                  child: ComponentBuiltInConfigEditor(
                    component: ComponentData.create(
                      id: 'built-in-${testCase.type.name}',
                      type: testCase.type,
                      position: Offset.zero,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.text(testCase.expectedText),
        findsOneWidget,
        reason:
            '${testCase.type.name} should route to ${testCase.expectedText}',
      );
    }
  });
}
