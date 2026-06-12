import 'product_catalog_preview_data.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_product_catalog_presentation_state.dart';
import '../models/inventory_product_catalog_saved_view.dart';
import '../models/inventory_product_catalog_table_preferences.dart';
import '../states/product_catalog_panel_trailing_controls_state.dart';
import 'inventory_product_catalog_presentation_controls.dart';
import 'inventory_product_catalog_saved_view_button.dart';
import 'inventory_product_catalog_table_column_contribution.dart';
import 'inventory_product_catalog_table_controls.dart';
import 'product_catalog_preview_data.dart';

/// Trailing control group for catalog saved views and presentation settings.
class InventoryProductCatalogPanelTrailingControls extends StatelessWidget {
  const InventoryProductCatalogPanelTrailingControls({
    super.key,
    required this.presentationState,
    required this.savedViews,
    this.activeSavedViewId,
    this.defaultSavedViewId,
    this.onSavedViewSelected,
    this.onSaveCurrentView,
    this.onSavedViewCopied,
    this.onSavedViewRenamed,
    this.onSavedViewUpdated,
    this.onSavedViewDeleted,
    this.onDefaultSavedViewChanged,
    this.canCopySavedView,
    this.canRenameSavedView,
    this.canUpdateSavedView,
    this.canDeleteSavedView,
    this.canSetDefaultSavedView,
    this.savedViewSectionLabel,
    required this.onPresentationStateChanged,
    required this.onTablePreferencesChanged,
    required this.onTablePresetSelected,
    this.columnContributions =
        const <InventoryProductCatalogTableColumnContribution>[],
  });

  final InventoryProductCatalogPresentationState presentationState;
  final List<InventoryProductCatalogSavedView> savedViews;
  final String? activeSavedViewId;
  final String? defaultSavedViewId;
  final ValueChanged<InventoryProductCatalogSavedView>? onSavedViewSelected;
  final ValueChanged<InventoryProductCatalogPresentationState>?
  onSaveCurrentView;
  final ValueChanged<InventoryProductCatalogSavedView>? onSavedViewCopied;
  final ValueChanged<InventoryProductCatalogSavedView>? onSavedViewRenamed;
  final InventoryProductCatalogSavedViewStateChanged? onSavedViewUpdated;
  final ValueChanged<InventoryProductCatalogSavedView>? onSavedViewDeleted;
  final InventoryProductCatalogSavedViewDefaultChanged?
  onDefaultSavedViewChanged;
  final InventoryProductCatalogSavedViewActionPredicate? canCopySavedView;
  final InventoryProductCatalogSavedViewActionPredicate? canRenameSavedView;
  final InventoryProductCatalogSavedViewActionPredicate? canUpdateSavedView;
  final InventoryProductCatalogSavedViewActionPredicate? canDeleteSavedView;
  final InventoryProductCatalogSavedViewActionPredicate? canSetDefaultSavedView;
  final InventoryProductCatalogSavedViewSectionLabel? savedViewSectionLabel;
  final ValueChanged<InventoryProductCatalogPresentationState>
  onPresentationStateChanged;
  final ValueChanged<InventoryProductCatalogTablePreferences>
  onTablePreferencesChanged;
  final ValueChanged<InventoryProductCatalogTablePreset> onTablePresetSelected;
  final List<InventoryProductCatalogTableColumnContribution>
  columnContributions;

  @override
  Widget build(BuildContext context) {
    final controlState =
        InventoryProductCatalogPanelTrailingControlsState.resolve(
          presentationState: presentationState,
          hasSavedViews: savedViews.isNotEmpty,
          hasSaveCurrentHandler: onSaveCurrentView != null,
        );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (controlState.showSavedViews)
          InventoryProductCatalogSavedViewButton(
            savedViews: savedViews,
            activeSavedViewId: activeSavedViewId,
            defaultSavedViewId: defaultSavedViewId,
            currentPresentationState: presentationState,
            onSelected: onSavedViewSelected,
            onSaveCurrent: onSaveCurrentView,
            onCopySavedView: onSavedViewCopied,
            onRenameSavedView: onSavedViewRenamed,
            onUpdateSavedView: onSavedViewUpdated,
            onDeleteSavedView: onSavedViewDeleted,
            onDefaultSavedViewChanged: onDefaultSavedViewChanged,
            canCopySavedView: canCopySavedView,
            canRenameSavedView: canRenameSavedView,
            canUpdateSavedView: canUpdateSavedView,
            canDeleteSavedView: canDeleteSavedView,
            canSetDefaultSavedView: canSetDefaultSavedView,
            savedViewSectionLabel: savedViewSectionLabel,
          ),
        InventoryProductCatalogPresentationControls(
          presentationState: presentationState,
          showBadge: controlState.showPresentationBadge,
          onChanged: onPresentationStateChanged,
        ),
        if (controlState.showTableControls)
          InventoryProductCatalogTableControls(
            preferences: presentationState.tableViewState.preferences,
            onChanged: onTablePreferencesChanged,
            onPresetSelected: onTablePresetSelected,
            columnContributions: columnContributions,
          ),
      ],
    );
  }
}

@Preview(name: 'Inventory product catalog panel trailing controls')
Widget inventoryProductCatalogPanelTrailingControlsPreview() {
  final savedViews = inventoryProductCatalogPreviewSavedViews();

  return inventoryProductCatalogPreviewScaffold(
    Align(
      alignment: Alignment.topRight,
      child: InventoryProductCatalogPanelTrailingControls(
        presentationState:
            InventoryProductCatalogPresentationPreset.pricing.presentationState,
        savedViews: savedViews,
        activeSavedViewId: savedViews.first.id,
        defaultSavedViewId: savedViews.first.id,
        onPresentationStateChanged: (_) {},
        onTablePreferencesChanged: (_) {},
        onTablePresetSelected: (_) {},
        onSaveCurrentView: (_) {},
      ),
    ),
  );
}
