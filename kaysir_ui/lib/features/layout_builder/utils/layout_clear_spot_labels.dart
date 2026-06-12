import '../models/layout_drag_preview.dart';

/// Describes clear-spot action availability and reusable display labels.
class LayoutClearSpotActionState {
  final bool hasSelection;
  final LayoutDragPreviewItem? preview;

  const LayoutClearSpotActionState({
    required this.hasSelection,
    required this.preview,
  });

  factory LayoutClearSpotActionState.fromSelection({
    required bool hasSelection,
    required LayoutDragPreviewItem? preview,
  }) {
    return LayoutClearSpotActionState(
      hasSelection: hasSelection,
      preview: hasSelection ? preview : null,
    );
  }

  bool get isAvailable => hasSelection && preview != null;

  LayoutDragPreviewItem? get _availablePreview => isAvailable ? preview : null;

  String? get disabledReason {
    if (!hasSelection) return 'Select a component first';
    if (preview == null) return 'No clear spot available';
    return null;
  }

  String? get detailLabel => layoutClearSpotDetailLabel(_availablePreview);

  String get sentenceTargetLabel {
    final item = _availablePreview;
    if (item == null) return 'clear spot';

    return layoutClearSpotSentenceTargetLabel(item);
  }

  String get unavailableStatusLabel =>
      disabledReason ?? 'No clear spot is currently available';

  String movedStatusLabel({String subject = 'selection'}) {
    return 'Moved $subject to $sentenceTargetLabel';
  }

  String moveTooltipLabel({String subject = 'selection'}) {
    final reason = disabledReason;
    if (reason != null) return reason;

    return 'Move $subject to $sentenceTargetLabel';
  }

  String menuActionLabel({required String prefix}) {
    final item = _availablePreview;
    if (item == null) return '$prefix clear spot';

    return layoutClearSpotMenuActionLabel(item, prefix: prefix);
  }
}

/// Returns short, reusable text for layout-rule clear-spot actions.
String? layoutClearSpotDetailLabel(LayoutDragPreviewItem? item) {
  if (item == null) return null;

  final ruleLabel = item.conflictResolvedRuleLabel.trim();
  final sourceLabel =
      item.usesNearbyConflictResolution ? 'Nearby clear spot' : 'Clear spot';
  if (ruleLabel.isEmpty) return sourceLabel;

  return '$sourceLabel: $ruleLabel';
}

/// Returns a menu label that includes the destination rule slot when known.
String layoutClearSpotMenuActionLabel(
  LayoutDragPreviewItem item, {
  required String prefix,
}) {
  final ruleLabel = item.conflictResolvedRuleLabel.trim();
  final sourceLabel =
      item.usesNearbyConflictResolution ? 'nearby clear spot' : 'clear spot';
  if (ruleLabel.isEmpty) return '$prefix $sourceLabel';

  return '$prefix $sourceLabel ($ruleLabel)';
}

/// Returns a sentence fragment for tooltip or status text.
String layoutClearSpotSentenceTargetLabel(LayoutDragPreviewItem item) {
  final ruleLabel = item.conflictResolvedRuleLabel.trim();
  final sourceLabel =
      item.usesNearbyConflictResolution ? 'nearby clear spot' : 'clear spot';
  if (ruleLabel.isEmpty) return sourceLabel;

  return '$sourceLabel at $ruleLabel';
}
