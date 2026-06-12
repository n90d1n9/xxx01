import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../experiences/default_pos_touch_layout_profiles.dart';
import '../experiences/pos_experience_manifest.dart';
import '../experiences/pos_experience_screen_fit.dart';
import '../models/pos_quick_button.dart';
import '../models/pos_quick_button_customization.dart';
import '../models/pos_quick_button_customization_view.dart';
import '../models/pos_touch_layout_profile.dart';
import '../models/pos_touch_layout_profile_catalog.dart';
import '../states/pos_catalog_filter_provider.dart';
import '../states/pos_layout_provider.dart';
import '../states/pos_quick_button_customization_provider.dart';
import '../states/pos_touch_layout_profile_provider.dart';
import '../utils/pos_quick_button_actions.dart';
import 'pos_quick_button_customization_sheet.dart';
import 'pos_touch_layout_profile_selector.dart';
import 'pos_touch_quick_button_board.dart';
import 'pos_ui.dart';

/// Provider-backed quick-button panel for the active POS touch layout profile.
class POSTouchQuickButtonPanel extends ConsumerWidget {
  final POSQuickButtonSurface surface;
  final bool dense;
  final POSQuickButtonActionHandlers actionHandlers;

  const POSTouchQuickButtonPanel({
    super.key,
    this.surface = POSQuickButtonSurface.primaryGrid,
    this.dense = false,
    this.actionHandlers = const POSQuickButtonActionHandlers(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(posQuickButtonCustomizationHydrationProvider);
    final catalog = ref.watch(posTouchLayoutProfileCatalogProvider);
    final profile = ref.watch(posTouchLayoutProfileProvider);
    final layoutPreference = ref.watch(posLayoutPreferenceProvider);
    final customization = ref.watch(posQuickButtonCustomizationProvider);
    final customizationController = ref.watch(
      posQuickButtonCustomizationControllerProvider,
    );
    final controller = ref.watch(posTouchLayoutProfileControllerProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final formFactor = resolvePOSRuntimeFormFactor(constraints.maxWidth);
        final handlers = _composeHandlers(ref, actionHandlers);
        final effectiveDensity = customization.effectiveDensityFor(
          profile.density,
        );
        final customizationView = _customizationViewFor(
          profile: profile,
          surface: surface,
          formFactor: formFactor,
          layoutPreference: layoutPreference,
          customization: customization,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TouchProfileHeader(
              catalog: catalog,
              selectedProfile: profile,
              customizationView: customizationView,
              hasCustomization: !customization.isEmpty,
              effectiveDensity: effectiveDensity,
              dense: dense,
              onProfileSelected: controller.select,
              onOpenCustomization: () {
                showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (context) {
                    return POSQuickButtonCustomizationSheet(
                      view: customizationView,
                      profileDensity: profile.density,
                      selectedDensity: effectiveDensity,
                      onTogglePinned: customizationController.togglePinned,
                      onToggleHidden: customizationController.toggleHidden,
                      onDensityChanged:
                          customizationController.setDensityOverride,
                      onMovePinnedUp:
                          (buttonId) =>
                              customizationController.movePinned(buttonId, -1),
                      onMovePinnedDown:
                          (buttonId) =>
                              customizationController.movePinned(buttonId, 1),
                      onReset: customizationController.reset,
                    );
                  },
                );
              },
              onResetCustomization:
                  customization.isEmpty ? null : customizationController.reset,
            ),
            const SizedBox(height: POSUiTokens.gap),
            POSTouchQuickButtonBoard(
              profile: profile,
              surface: surface,
              formFactor: formFactor,
              layoutPreference: layoutPreference,
              actionHandlers: handlers,
              customization: customization,
              touchDensity: effectiveDensity,
              onTogglePinned: customizationController.togglePinned,
              onHide: customizationController.toggleHidden,
              dense: dense,
            ),
          ],
        );
      },
    );
  }

  POSQuickButtonActionHandlers _composeHandlers(
    WidgetRef ref,
    POSQuickButtonActionHandlers extraHandlers,
  ) {
    return POSQuickButtonActionHandlers(
      onCommandAction: extraHandlers.onCommandAction,
      onProductSelected: extraHandlers.onProductSelected,
      onCategorySelected: (categoryId) {
        ref.read(posCatalogFilterProvider.notifier).state = POSCatalogFilter(
          query: _catalogShortcutQuery(categoryId),
        );
        extraHandlers.onCategorySelected?.call(categoryId);
      },
      onDiscountSelected: extraHandlers.onDiscountSelected,
      onModifierSetSelected: extraHandlers.onModifierSetSelected,
      onCustomerAction: extraHandlers.onCustomerAction,
      onLayoutProfileSelected: (profileId) {
        ref.read(posTouchLayoutProfileControllerProvider).select(profileId);
        extraHandlers.onLayoutProfileSelected?.call(profileId);
      },
      onCustomFlow: extraHandlers.onCustomFlow,
    );
  }
}

POSQuickButtonCustomizationView _customizationViewFor({
  required POSTouchLayoutProfile profile,
  required POSQuickButtonSurface surface,
  required POSExperienceFormFactor formFactor,
  required POSLayoutPreference layoutPreference,
  required POSQuickButtonCustomization customization,
}) {
  final context = profile.contextFor(
    surface: surface,
    formFactor: formFactor,
    layoutPreference: layoutPreference,
  );
  final buttons = [
    for (final group in profile.groupsForSurface(surface))
      ...group.visibleButtonsFor(context),
  ];

  return POSQuickButtonCustomizationView.fromButtons(
    buttons: buttons,
    customization: customization,
  );
}

String _catalogShortcutQuery(String categoryId) {
  return categoryId.trim().replaceAll('_', ' ');
}

class _TouchProfileHeader extends StatelessWidget {
  final POSTouchLayoutProfileCatalog catalog;
  final POSTouchLayoutProfile selectedProfile;
  final POSQuickButtonCustomizationView customizationView;
  final bool hasCustomization;
  final POSTouchLayoutDensity effectiveDensity;
  final bool dense;
  final ValueChanged<String> onProfileSelected;
  final VoidCallback onOpenCustomization;
  final VoidCallback? onResetCustomization;

  const _TouchProfileHeader({
    required this.catalog,
    required this.selectedProfile,
    required this.customizationView,
    required this.hasCustomization,
    required this.effectiveDensity,
    required this.dense,
    required this.onProfileSelected,
    required this.onOpenCustomization,
    required this.onResetCustomization,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Touch layout',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (!dense)
                Text(
                  '${selectedProfile.catalogEmphasis.label} | ${selectedProfile.orderPanelPlacement.label} order panel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: POSUiTokens.gap),
        Flexible(
          child: Tooltip(
            message: 'Manage quick-button customization',
            child: TextButton.icon(
              onPressed: onOpenCustomization,
              icon: const Icon(Icons.tune),
              label: Text(
                '${customizationView.pinnedCount} pin | ${customizationView.hiddenCount} hide | ${effectiveDensity.label}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        if (hasCustomization) ...[
          Tooltip(
            message: 'Reset quick-button customization',
            child: IconButton.filledTonal(
              onPressed: onResetCustomization,
              icon: const Icon(Icons.restart_alt),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: POSUiTokens.gap),
        ],
        POSTouchLayoutProfileSelector(
          catalog: catalog,
          selectedProfile: selectedProfile,
          compact: dense,
          onProfileSelected: onProfileSelected,
        ),
      ],
    );
  }
}

@Preview(name: 'POS touch quick button panel')
Widget posTouchQuickButtonPanelPreview() {
  return ProviderScope(
    overrides: [
      posTouchLayoutProfileCatalogProvider.overrideWithValue(
        defaultPOSTouchLayoutProfileCatalog,
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: POSTouchQuickButtonPanel(),
        ),
      ),
    ),
  );
}
