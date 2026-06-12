import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack_preset.dart';
import 'package:kaysir/features/product/widgets/management_pack_preset_panel.dart';

void main() {
  testWidgets(
    'product management pack preset panel renders and selects preset',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1180, 920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      ProductManagementPackPreset? selectedPreset;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductManagementPackPresetPanel(
              presets: defaultProductManagementPackPresets,
              activePreset: defaultProductManagementPackPresets.first,
              onSelected: (preset) => selectedPreset = preset,
            ),
          ),
        ),
      );

      expect(find.text('Product-line presets'), findsOneWidget);
      expect(find.text('4 presets'), findsOneWidget);
      expect(find.text('Core Omni Retail'), findsOneWidget);
      expect(find.text('Counter Service Catalog'), findsOneWidget);
      expect(find.text('Digital Commerce Catalog'), findsOneWidget);
      expect(find.text('Fresh Goods Grocery'), findsAtLeastNWidgets(1));
      expect(find.text('Active'), findsOneWidget);

      await tester.tap(find.text('Digital Commerce Catalog'));
      await tester.pump();

      expect(selectedPreset?.id, 'core_digital_commerce');
    },
  );
}
