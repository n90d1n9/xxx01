import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_icon_action_button.dart';
import '../models/inventory_product_catalog_presentation_state.dart';
import 'inventory_product_catalog_presentation_badge.dart';
import 'inventory_product_catalog_presentation_preset_button.dart';
import 'inventory_product_catalog_view_mode_toggle.dart';
import 'product_catalog_preview_data.dart';

/// Compact controls for switching, presetting, and resetting catalog views.
class InventoryProductCatalogPresentationControls extends StatelessWidget {
  const InventoryProductCatalogPresentationControls({
    super.key,
    required this.presentationState,
    required this.onChanged,
    this.showBadge = true,
  });

  final InventoryProductCatalogPresentationState presentationState;
  final ValueChanged<InventoryProductCatalogPresentationState> onChanged;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (showBadge)
          InventoryProductCatalogPresentationBadge(
            presentationState: presentationState,
          ),
        InventoryProductCatalogPresentationPresetButton(
          presentationState: presentationState,
          onPresetSelected: (preset) => onChanged(preset.presentationState),
        ),
        InventoryProductCatalogViewModeToggle(
          value: presentationState.viewMode,
          onChanged:
              (viewMode) =>
                  onChanged(presentationState.copyWith(viewMode: viewMode)),
        ),
        if (!presentationState.isDefault)
          AppIconActionButton(
            icon: Icons.restart_alt_rounded,
            tooltip: 'Reset catalog view',
            variant: AppIconActionButtonVariant.outlined,
            size: 34,
            iconSize: 18,
            onPressed:
                () => onChanged(
                  InventoryProductCatalogPresentationState.defaults,
                ),
          ),
      ],
    );
  }
}

@Preview(name: 'Inventory product catalog presentation controls')
Widget inventoryProductCatalogPresentationControlsPreview() {
  return inventoryProductCatalogPreviewScaffold(
    InventoryProductCatalogPresentationControls(
      presentationState:
          InventoryProductCatalogPresentationPreset.pricing.presentationState,
      onChanged: (_) {},
    ),
  );
}
