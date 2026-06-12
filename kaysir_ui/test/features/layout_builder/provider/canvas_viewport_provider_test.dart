import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/models/layout_drag_preview.dart';
import 'package:kaysir/features/layout_builder/provider/canvas_viewport_provider.dart';

void main() {
  group('CanvasViewportNotifier drag previews', () {
    test('derives Auto Grid occupancy preview from layout drag preview', () {
      final notifier = CanvasViewportNotifier();
      final preview = LayoutDragPreview(
        mechanism: LayoutMechanism.autoGrid,
        items: [
          LayoutDragPreviewItem(
            componentId: 'draft-card',
            currentBounds: const Rect.fromLTWH(13, 27, 80, 48),
            ruleBounds: const Rect.fromLTWH(20, 20, 80, 48),
            ruleLabel: 'Auto Grid c1 r1 1x1',
            hasConflict: false,
          ),
        ],
      );

      notifier.setLayoutDragPreview(preview);

      expect(notifier.state.layoutDragPreview, preview);
      expect(notifier.state.autoGridPreview, isNotNull);
      expect(
        notifier.state.autoGridPreview!.items.single.componentId,
        'draft-card',
      );
      expect(
        notifier.state.autoGridPreview!.items.single.bounds,
        const Rect.fromLTWH(20, 20, 80, 48),
      );
    });

    test(
      'clears Auto Grid occupancy when preview is non Auto Grid or cleared',
      () {
        final notifier = CanvasViewportNotifier();
        notifier.setLayoutDragPreview(
          LayoutDragPreview(
            mechanism: LayoutMechanism.autoGrid,
            items: [
              LayoutDragPreviewItem(
                componentId: 'draft-card',
                currentBounds: const Rect.fromLTWH(13, 27, 80, 48),
                ruleBounds: const Rect.fromLTWH(20, 20, 80, 48),
                ruleLabel: 'Auto Grid c1 r1 1x1',
                hasConflict: false,
              ),
            ],
          ),
        );

        notifier.setLayoutDragPreview(
          LayoutDragPreview(
            mechanism: LayoutMechanism.grid,
            items: [
              LayoutDragPreviewItem(
                componentId: 'draft-card',
                currentBounds: const Rect.fromLTWH(13, 27, 80, 48),
                ruleBounds: const Rect.fromLTWH(20, 20, 80, 48),
                ruleLabel: 'Grid c2 r2',
                hasConflict: false,
              ),
            ],
          ),
        );

        expect(notifier.state.layoutDragPreview, isNotNull);
        expect(notifier.state.autoGridPreview, isNull);

        notifier.clearLayoutDragPreview();

        expect(notifier.state.layoutDragPreview, isNull);
        expect(notifier.state.autoGridPreview, isNull);
      },
    );
  });
}
