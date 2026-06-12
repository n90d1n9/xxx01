import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:kaysir/features/layout_builder/adapters/shared_builder_adapter.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/models/layout_state.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

void main() {
  test('maps layout config to shared canvas config and back', () {
    const config = LayoutConfig(
      gridSize: 16,
      canvasWidth: 1440,
      canvasHeight: 900,
      layoutMechanism: LayoutMechanism.tabularColumns,
      tabularColumnCount: 16,
      tabularColumnGap: 8,
      tabularRowHeight: 72,
    );

    final sharedConfig = config.toSharedBuilderCanvasConfig();
    final restored = sharedConfig.toLayoutConfig();

    expect(sharedConfig.layoutMechanism, BuilderLayoutMechanism.tabularColumns);
    expect(sharedConfig.tabularColumnCount, 16);
    expect(restored.layoutMechanism, LayoutMechanism.tabularColumns);
    expect(restored.canvasWidth, 1440);
  });

  test('maps component geometry, constraints, and responsive overrides', () {
    final component = ComponentData.create(
      id: 'cart',
      type: ComponentType.cartPanel,
      position: const Offset(40, 80),
    ).copyWith(
      constraints: const ComponentConstraints(
        horizontalAnchor: ComponentAnchorMode.stretch,
        verticalAnchor: ComponentAnchorMode.start,
        minWidth: 240,
      ),
      responsiveProperties: const {
        'mobile': ComponentResponsiveProperties(
          position: Offset(0, 16),
          size: Size(320, 480),
          isVisible: true,
        ),
      },
      isLocked: true,
    );

    final geometry = component.toSharedBuilderGeometry(zIndex: 3);
    final restored = geometry.toLayoutComponentData();

    expect(geometry.kindKey, 'cart_panel');
    expect(geometry.zIndex, 3);
    expect(
      geometry.constraints.horizontalAnchor,
      BuilderComponentAnchorMode.stretch,
    );
    expect(geometry.responsiveOverrides['mobile']?.size, const Size(320, 480));
    expect(restored.type, ComponentType.cartPanel);
    expect(restored.constraints.horizontalAnchor, ComponentAnchorMode.stretch);
    expect(
      restored.responsiveProperties['mobile']?.position,
      const Offset(0, 16),
    );
    expect(restored.isLocked, isTrue);
  });

  test('exports layout state as a shared builder snapshot', () {
    final state = LayoutState(
      id: 'layout-1',
      name: 'Register Layout',
      gridSettings: const GridSettings(gridSize: 20, snapToGrid: true),
      config: const LayoutConfig(layoutMechanism: LayoutMechanism.autoGrid),
      selectedComponentId: 'button',
      components: [
        ComponentData.create(
          id: 'button',
          type: ComponentType.customButton,
          position: const Offset(20, 40),
        ),
      ],
    );

    final snapshot = state.toSharedBuilderSnapshot();
    final json = snapshot.toJson();
    final restored = BuilderSharedSnapshot.fromJson(json);

    expect(posLayoutBuilderCatalog.byKey('custom_button'), isNotNull);
    expect(
      snapshot.canvasConfig.layoutMechanism,
      BuilderLayoutMechanism.autoGrid,
    );
    expect(snapshot.components.single.kindKey, 'custom_button');
    expect(json['schema'], BuilderSharedSnapshot.schemaId);
    expect(restored.components.single.kindKey, 'custom_button');
    expect(json['selectedComponentId'], 'button');
  });
}
