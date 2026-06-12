import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:kaysir/features/layout_builder/models/layout_drag_preview.dart';
import 'package:kaysir/features/layout_builder/utils/layout_clear_spot_labels.dart';

void main() {
  group('LayoutClearSpotActionState', () {
    test('reports no-selection disabled reason', () {
      final action = LayoutClearSpotActionState(
        hasSelection: false,
        preview: _previewItem(
          source: LayoutConflictResolutionSource.direct,
          ruleLabel: 'Grid c4 r2',
        ),
      );

      expect(action.isAvailable, isFalse);
      expect(action.disabledReason, 'Select a component first');
      expect(action.detailLabel, isNull);
      expect(action.menuActionLabel(prefix: 'Move to'), 'Move to clear spot');
      expect(action.sentenceTargetLabel, 'clear spot');
      expect(action.unavailableStatusLabel, 'Select a component first');
      expect(action.moveTooltipLabel(), 'Select a component first');
    });

    test('normalizes stale previews when created from selection state', () {
      final action = LayoutClearSpotActionState.fromSelection(
        hasSelection: false,
        preview: _previewItem(
          source: LayoutConflictResolutionSource.direct,
          ruleLabel: 'Grid c4 r2',
        ),
      );

      expect(action.preview, isNull);
      expect(action.isAvailable, isFalse);
      expect(action.detailLabel, isNull);
      expect(action.menuActionLabel(prefix: 'Move to'), 'Move to clear spot');
    });

    test('reports unavailable selected state', () {
      const action = LayoutClearSpotActionState(
        hasSelection: true,
        preview: null,
      );

      expect(action.isAvailable, isFalse);
      expect(action.disabledReason, 'No clear spot available');
      expect(action.unavailableStatusLabel, 'No clear spot available');
      expect(action.moveTooltipLabel(), 'No clear spot available');
    });

    test('formats direct clear spot destination labels', () {
      final action = LayoutClearSpotActionState(
        hasSelection: true,
        preview: _previewItem(
          source: LayoutConflictResolutionSource.direct,
          ruleLabel: 'Grid c4 r2',
        ),
      );

      expect(action.isAvailable, isTrue);
      expect(action.disabledReason, isNull);
      expect(action.detailLabel, 'Clear spot: Grid c4 r2');
      expect(
        action.menuActionLabel(prefix: 'Move selection to'),
        'Move selection to clear spot (Grid c4 r2)',
      );
      expect(action.sentenceTargetLabel, 'clear spot at Grid c4 r2');
      expect(
        action.movedStatusLabel(),
        'Moved selection to clear spot at Grid c4 r2',
      );
      expect(
        action.moveTooltipLabel(),
        'Move selection to clear spot at Grid c4 r2',
      );
    });

    test('formats nearby clear spot destination labels', () {
      final action = LayoutClearSpotActionState(
        hasSelection: true,
        preview: _previewItem(
          source: LayoutConflictResolutionSource.nearbySearch,
          ruleLabel: 'Grid c5 r3',
        ),
      );

      expect(action.detailLabel, 'Nearby clear spot: Grid c5 r3');
      expect(
        action.menuActionLabel(prefix: 'Move to'),
        'Move to nearby clear spot (Grid c5 r3)',
      );
      expect(action.sentenceTargetLabel, 'nearby clear spot at Grid c5 r3');
      expect(
        action.movedStatusLabel(subject: 'active group'),
        'Moved active group to nearby clear spot at Grid c5 r3',
      );
      expect(
        action.moveTooltipLabel(subject: 'active group'),
        'Move active group to nearby clear spot at Grid c5 r3',
      );
    });
  });
}

LayoutDragPreviewItem _previewItem({
  required LayoutConflictResolutionSource source,
  required String ruleLabel,
}) {
  return LayoutDragPreviewItem(
    componentId: 'selected',
    currentBounds: const Rect.fromLTWH(20, 20, 40, 40),
    ruleBounds: const Rect.fromLTWH(20, 20, 40, 40),
    ruleLabel: 'Grid c2 r2',
    hasConflict: true,
    conflictResolvedBounds: const Rect.fromLTWH(60, 20, 40, 40),
    conflictResolutionSource: source,
    conflictResolvedRuleLabel: ruleLabel,
  );
}
