import 'pos_quick_button.dart';
import 'pos_quick_button_customization.dart';

/// Read model for presenting quick-button customization controls.
///
/// It resolves button IDs in the customization overlay against the currently
/// available quick buttons, keeping dialog widgets free from lookup logic.
class POSQuickButtonCustomizationView {
  final List<POSQuickButton> allButtons;
  final List<POSQuickButton> visibleButtons;
  final List<POSQuickButton> pinnedButtons;
  final List<POSQuickButton> hiddenButtons;
  final List<String> unknownPinnedButtonIds;
  final List<String> unknownHiddenButtonIds;

  const POSQuickButtonCustomizationView({
    required this.allButtons,
    required this.visibleButtons,
    required this.pinnedButtons,
    required this.hiddenButtons,
    this.unknownPinnedButtonIds = const [],
    this.unknownHiddenButtonIds = const [],
  });

  factory POSQuickButtonCustomizationView.fromButtons({
    required Iterable<POSQuickButton> buttons,
    required POSQuickButtonCustomization customization,
  }) {
    final allButtons = buttons.toList(growable: false);
    final buttonsById = {for (final button in allButtons) button.id: button};
    final hidden = <POSQuickButton>[];
    final pinned = <POSQuickButton>[];
    final unknownHidden = <String>[];
    final unknownPinned = <String>[];

    for (final buttonId in customization.hiddenButtonIds) {
      final button = buttonsById[buttonId];
      if (button == null) {
        unknownHidden.add(buttonId);
      } else {
        hidden.add(button);
      }
    }

    for (final buttonId in customization.pinnedButtonIds) {
      final button = buttonsById[buttonId];
      if (button == null) {
        unknownPinned.add(buttonId);
      } else if (!customization.isHidden(buttonId)) {
        pinned.add(button);
      }
    }

    return POSQuickButtonCustomizationView(
      allButtons: List.unmodifiable(allButtons),
      visibleButtons: customization.applyTo(allButtons),
      pinnedButtons: List.unmodifiable(pinned),
      hiddenButtons: List.unmodifiable(hidden),
      unknownPinnedButtonIds: List.unmodifiable(unknownPinned),
      unknownHiddenButtonIds: List.unmodifiable(unknownHidden),
    );
  }

  bool get hasCustomization =>
      pinnedButtons.isNotEmpty ||
      hiddenButtons.isNotEmpty ||
      unknownPinnedButtonIds.isNotEmpty ||
      unknownHiddenButtonIds.isNotEmpty;

  int get pinnedCount => pinnedButtons.length + unknownPinnedButtonIds.length;

  int get hiddenCount => hiddenButtons.length + unknownHiddenButtonIds.length;
}
