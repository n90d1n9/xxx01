import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/component_properties.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/models/layout_state.dart';

void main() {
  group('LayoutState export package', () {
    test('includes schema metadata summary and raw layout payload', () {
      final exportedAt = DateTime.utc(2026, 6, 3, 10, 30);
      final layout = _layoutState();

      final package = layout.toExportPackage(exportedAt: exportedAt);
      final summary = Map<String, dynamic>.from(package['summary'] as Map);
      final components = Map<String, dynamic>.from(
        summary['components'] as Map,
      );
      final layoutRules = Map<String, dynamic>.from(
        summary['layoutRules'] as Map,
      );
      final payload = Map<String, dynamic>.from(package['layout'] as Map);

      expect(package['schema'], 'kaysir.layout.export');
      expect(package['schemaVersion'], 1);
      expect(package['exportedAt'], '2026-06-03T10:30:00.000Z');
      expect(summary['name'], 'Exportable Layout');
      expect(summary['layoutMechanism'], 'tabular_columns');
      expect(components['total'], 3);
      expect(components['visible'], 2);
      expect(components['hidden'], 1);
      expect(components['locked'], 1);
      expect(components['withResponsiveOverrides'], 1);
      expect(components['responsiveOverrides'], 1);
      expect(components['withConstraints'], 1);
      expect(components['withDataBindings'], 1);
      expect(components['withEvents'], 1);
      expect(layoutRules['mechanism'], 'tabular_columns');
      expect(layoutRules['columns'], 8);
      expect(payload['name'], 'Exportable Layout');
      expect(payload['components'], isA<List>());
    });

    test('imports package JSON by using the nested layout payload', () {
      final package = _layoutState().toExportPackage(
        exportedAt: DateTime.utc(2026, 6, 3),
      );

      final imported = LayoutState.fromJson(package);

      expect(imported.name, 'Exportable Layout');
      expect(imported.config.layoutMechanism, LayoutMechanism.tabularColumns);
      expect(imported.config.tabularColumnCount, 8);
      expect(imported.components.length, 3);
      expect(
        imported.components.first.constraints.horizontalAnchor,
        ComponentAnchorMode.end,
      );
    });

    test('previews package import metadata before replacing layout', () {
      final package = _layoutState().toExportPackage(
        exportedAt: DateTime.utc(2026, 6, 3, 10, 30),
      );

      final preview = LayoutImportPreview.fromJson(package);

      expect(preview.isPackage, isTrue);
      expect(preview.formatLabel, 'Export package');
      expect(preview.schema, 'kaysir.layout.export');
      expect(preview.schemaVersion, 1);
      expect(preview.exportedAt, DateTime.utc(2026, 6, 3, 10, 30));
      expect(preview.name, 'Exportable Layout');
      expect(preview.layoutMechanism, LayoutMechanism.tabularColumns);
      expect(preview.canvasLabel, '960 x 720');
      expect(preview.componentLabel, '3 components');
      expect(preview.visibleCount, 2);
      expect(preview.lockedCount, 1);
      expect(preview.responsiveOverrideCount, 1);
      expect(preview.constrainedCount, 1);
    });

    test('previews raw layout import metadata', () {
      final rawLayout = _layoutState().toJson();

      final preview = LayoutImportPreview.fromJson(rawLayout);

      expect(preview.isPackage, isFalse);
      expect(preview.formatLabel, 'Raw layout');
      expect(preview.schema, isNull);
      expect(preview.schemaVersion, isNull);
      expect(preview.exportedAt, isNull);
      expect(preview.name, 'Exportable Layout');
      expect(preview.componentCount, 3);
    });
  });
}

LayoutState _layoutState() {
  return LayoutState.initial().copyWith(
    name: 'Exportable Layout',
    config: const LayoutConfig(
      layoutMechanism: LayoutMechanism.tabularColumns,
      tabularColumnCount: 8,
      canvasWidth: 960,
      canvasHeight: 720,
    ),
    components: [
      ComponentData.create(
        id: 'constrained',
        type: ComponentType.customButton,
        position: const Offset(120, 80),
      ).copyWith(
        constraints: const ComponentConstraints(
          horizontalAnchor: ComponentAnchorMode.end,
        ),
        responsiveProperties: const {
          'mobile': ComponentResponsiveProperties(
            position: Offset(24, 40),
            size: Size(180, 56),
          ),
        },
      ),
      ComponentData.create(
        id: 'bound',
        type: ComponentType.textLabel,
        position: const Offset(24, 24),
      ).copyWith(
        properties: const ComponentProperties(
          attributes: {'text': '{{store.name}}'},
          events: {'tap': 'layout.openStore'},
        ),
      ),
      ComponentData.create(
        id: 'hidden-locked',
        type: ComponentType.imageHolder,
        position: const Offset(300, 120),
      ).copyWith(isVisible: false, isLocked: true),
    ],
  );
}
