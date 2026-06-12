import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';

void main() {
  group('LayoutStateNotifier component constraints', () {
    test('keeps end insets when canvas size changes', () {
      final notifier = _constraintsNotifier();
      notifier.addComponent(
        _component(
          'anchored',
          position: const Offset(300, 120),
          size: const Size(100, 80),
          constraints: const ComponentConstraints(
            horizontalAnchor: ComponentAnchorMode.end,
            verticalAnchor: ComponentAnchorMode.end,
          ),
        ),
      );

      notifier.updateCanvasSize(const Size(600, 500));

      final anchored = _componentById(notifier, 'anchored');
      expect(anchored.position, const Offset(400, 220));
      expect(anchored.size, const Size(100, 80));
    });

    test('keeps center offset when canvas size changes', () {
      final notifier = _constraintsNotifier();
      notifier.addComponent(
        _component(
          'centered',
          position: const Offset(200, 120),
          size: const Size(100, 80),
          constraints: const ComponentConstraints(
            horizontalAnchor: ComponentAnchorMode.center,
            verticalAnchor: ComponentAnchorMode.center,
          ),
        ),
      );

      notifier.updateCanvasSize(const Size(700, 500));

      expect(
        _componentById(notifier, 'centered').position,
        const Offset(300, 170),
      );
    });

    test('stretches while respecting max limits', () {
      final notifier = _constraintsNotifier();
      notifier.addComponent(
        _component(
          'stretch',
          position: const Offset(50, 40),
          size: const Size(200, 80),
          constraints: const ComponentConstraints(
            horizontalAnchor: ComponentAnchorMode.stretch,
            maxWidth: 360,
          ),
        ),
      );

      notifier.updateCanvasSize(const Size(800, 400));

      final stretch = _componentById(notifier, 'stretch');
      expect(stretch.position, const Offset(50, 40));
      expect(stretch.size, const Size(360, 80));
    });

    test('constrains manual resizing with min max and aspect rules', () {
      final notifier = _constraintsNotifier();
      notifier.addComponent(
        _component(
          'limited',
          position: Offset.zero,
          size: const Size(100, 50),
          constraints: const ComponentConstraints(
            maintainAspectRatio: true,
            minWidth: 120,
            maxHeight: 120,
          ),
        ),
      );

      notifier.updateComponentSize('limited', const Size(300, 100));

      expect(_componentById(notifier, 'limited').size, const Size(240, 120));
    });

    test('generates responsive override from constraints', () {
      final notifier = _constraintsNotifier();
      notifier.addComponent(
        _component(
          'anchored',
          position: const Offset(300, 120),
          size: const Size(100, 80),
          constraints: const ComponentConstraints(
            horizontalAnchor: ComponentAnchorMode.end,
            verticalAnchor: ComponentAnchorMode.end,
          ),
        ),
      );
      notifier.updateResponsiveProperties(
        'anchored',
        'mobile',
        const ComponentResponsiveProperties(isVisible: false),
      );

      notifier.applyResponsiveConstraints(
        'anchored',
        'mobile',
        const Size(390, 844),
      );

      final anchored = _componentById(notifier, 'anchored');
      final mobile = anchored.responsiveProperties['mobile'];
      expect(anchored.position, const Offset(300, 120));
      expect(mobile?.position, const Offset(190, 564));
      expect(mobile?.size, const Size(100, 80));
      expect(mobile?.isVisible, isFalse);
    });

    test(
      'applies selected responsive constraints only to eligible components',
      () {
        final notifier = _constraintsNotifier();
        notifier.addComponents([
          _component(
            'stretch',
            position: const Offset(50, 40),
            size: const Size(200, 80),
            constraints: const ComponentConstraints(
              horizontalAnchor: ComponentAnchorMode.stretch,
              maxWidth: 360,
            ),
          ),
          _component('free', position: Offset.zero),
          _component(
            'locked',
            position: const Offset(300, 120),
            constraints: const ComponentConstraints(
              horizontalAnchor: ComponentAnchorMode.end,
            ),
            isLocked: true,
          ),
        ]);
        notifier.selectComponents({'stretch', 'free', 'locked'});

        notifier.applySelectedResponsiveConstraintsForDevices({
          'mobile': const Size(800, 844),
          'tablet': const Size(768, 1024),
        });

        final stretch = _componentById(notifier, 'stretch');
        expect(stretch.responsiveProperties.keys, {'mobile', 'tablet'});
        expect(
          stretch.responsiveProperties['mobile']?.position,
          const Offset(50, 40),
        );
        expect(
          stretch.responsiveProperties['mobile']?.size,
          const Size(360, 80),
        );
        expect(_componentById(notifier, 'free').responsiveProperties, isEmpty);
        expect(
          _componentById(notifier, 'locked').responsiveProperties,
          isEmpty,
        );
      },
    );
  });

  group('Component constraints serialization', () {
    test('round-trips anchor and size limits through JSON', () {
      final component = _component(
        'serializable',
        position: Offset.zero,
        constraints: const ComponentConstraints(
          horizontalAnchor: ComponentAnchorMode.stretch,
          verticalAnchor: ComponentAnchorMode.center,
          maintainAspectRatio: true,
          minWidth: 120,
          minHeight: 80,
          maxWidth: 420,
          maxHeight: 300,
        ),
      );

      final decoded = ComponentData.fromJson(component.toJson());

      expect(decoded.constraints.horizontalAnchor, ComponentAnchorMode.stretch);
      expect(decoded.constraints.verticalAnchor, ComponentAnchorMode.center);
      expect(decoded.constraints.maintainAspectRatio, isTrue);
      expect(decoded.constraints.minWidth, 120);
      expect(decoded.constraints.minHeight, 80);
      expect(decoded.constraints.maxWidth, 420);
      expect(decoded.constraints.maxHeight, 300);
    });
  });
}

LayoutStateNotifier _constraintsNotifier() {
  final notifier = LayoutStateNotifier();
  notifier.updateLayoutConfig(
    const LayoutConfig(
      canvasWidth: 500,
      canvasHeight: 400,
      minComponentWidth: 20,
      minComponentHeight: 20,
      layoutMechanism: LayoutMechanism.freeform,
    ),
  );
  notifier.updateGridSettings(const GridSettings(snapToGrid: false));
  return notifier;
}

ComponentData _component(
  String id, {
  required Offset position,
  Size size = const Size(100, 80),
  ComponentConstraints constraints = const ComponentConstraints(),
  bool isLocked = false,
}) {
  return ComponentData.create(
    id: id,
    type: ComponentType.customButton,
    position: position,
    size: size,
  ).copyWith(constraints: constraints, isLocked: isLocked);
}

ComponentData _componentById(LayoutStateNotifier notifier, String id) {
  return notifier.state.components.firstWhere(
    (component) => component.id == id,
  );
}
