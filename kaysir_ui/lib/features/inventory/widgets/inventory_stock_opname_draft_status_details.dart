import '../models/inventory_stock_opname_draft_status.dart';

/// Visual tone for a stock opname draft status badge.
enum InventoryStockOpnameDraftStatusBadgeTone { edited, invalid }

/// Presentation details for one stock opname draft status badge.
class InventoryStockOpnameDraftStatusBadgeDetails {
  const InventoryStockOpnameDraftStatusBadgeDetails({
    required this.label,
    required this.tone,
  });

  final String label;
  final InventoryStockOpnameDraftStatusBadgeTone tone;
}

/// Presentation details for a stock opname draft status banner.
class InventoryStockOpnameDraftStatusDetails {
  const InventoryStockOpnameDraftStatusDetails({
    required this.title,
    required this.subtitle,
    required this.reviewActionLabel,
    required this.reviewMessage,
    required this.resetActionLabel,
    required this.badges,
    required this.hasInvalidDrafts,
  });

  final String title;
  final String subtitle;
  final String reviewActionLabel;
  final String reviewMessage;
  final String resetActionLabel;
  final List<InventoryStockOpnameDraftStatusBadgeDetails> badges;
  final bool hasInvalidDrafts;
}

/// Resolves stock opname draft status copy from the saved-vs-edited state.
InventoryStockOpnameDraftStatusDetails inventoryStockOpnameDraftStatusDetails(
  InventoryStockOpnameDraftStatus status,
) {
  final hasInvalidDrafts = status.hasInvalidActualQuantityDrafts;

  if (hasInvalidDrafts) {
    return InventoryStockOpnameDraftStatusDetails(
      title: 'Fix count input before saving',
      subtitle: _inventoryStockOpnameInvalidDraftSubtitle(status),
      reviewActionLabel: 'Fix first input',
      reviewMessage: 'Review the invalid count input before saving',
      resetActionLabel: 'Discard edits',
      badges: _inventoryStockOpnameDraftStatusBadges(status),
      hasInvalidDrafts: true,
    );
  }

  if (status.hasUnsavedChanges) {
    return InventoryStockOpnameDraftStatusDetails(
      title: 'Unsaved count sheet changes',
      subtitle: _inventoryStockOpnameChangedLineSubtitle(status),
      reviewActionLabel: 'Review first change',
      reviewMessage: 'Review the edited count line',
      resetActionLabel: 'Discard edits',
      badges: _inventoryStockOpnameDraftStatusBadges(status),
      hasInvalidDrafts: false,
    );
  }

  return const InventoryStockOpnameDraftStatusDetails(
    title: 'No pending count sheet changes',
    subtitle: 'Count sheet is aligned with saved values.',
    reviewActionLabel: 'Review first change',
    reviewMessage: 'No count sheet changes to review',
    resetActionLabel: 'Discard edits',
    badges: [],
    hasInvalidDrafts: false,
  );
}

String _inventoryStockOpnameChangedLineSubtitle(
  InventoryStockOpnameDraftStatus status,
) {
  final lineLabel = status.changedLineCount == 1 ? 'line' : 'lines';
  final verb = status.changedLineCount == 1 ? 'is' : 'are';

  return '${status.changedLineCount} edited $lineLabel $verb ready to save as draft or complete.';
}

String _inventoryStockOpnameInvalidDraftSubtitle(
  InventoryStockOpnameDraftStatus status,
) {
  final inputLabel =
      status.invalidActualQuantityLineCount == 1 ? 'input' : 'inputs';
  final inputVerb =
      status.invalidActualQuantityLineCount == 1 ? 'needs' : 'need';
  final changedSuffix =
      status.changedLineCount == 0
          ? ''
          : ' ${status.changedLineCount} edited ${status.changedLineCount == 1 ? 'line' : 'lines'} also need saving.';

  return '${status.invalidActualQuantityLineCount} count $inputLabel $inputVerb a valid whole number.$changedSuffix';
}

List<InventoryStockOpnameDraftStatusBadgeDetails>
_inventoryStockOpnameDraftStatusBadges(InventoryStockOpnameDraftStatus status) {
  return [
    if (status.hasChangedLines)
      InventoryStockOpnameDraftStatusBadgeDetails(
        label:
            '${status.changedLineCount} edited ${status.changedLineCount == 1 ? 'line' : 'lines'}',
        tone: InventoryStockOpnameDraftStatusBadgeTone.edited,
      ),
    if (status.hasInvalidActualQuantityDrafts)
      InventoryStockOpnameDraftStatusBadgeDetails(
        label:
            '${status.invalidActualQuantityLineCount} invalid ${status.invalidActualQuantityLineCount == 1 ? 'input' : 'inputs'}',
        tone: InventoryStockOpnameDraftStatusBadgeTone.invalid,
      ),
  ];
}
