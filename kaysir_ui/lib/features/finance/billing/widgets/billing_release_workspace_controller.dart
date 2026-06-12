import 'package:flutter/foundation.dart';

import 'billing_release_workspace_composition.dart';
import 'billing_release_workspace_registry.dart';
import 'billing_release_workspace_saved_view.dart';

class BillingReleaseWorkspaceController extends ChangeNotifier {
  BillingReleaseWorkspaceSavedView? _selectedSavedView;

  BillingReleaseWorkspaceController({
    BillingReleaseWorkspaceSavedView? selectedSavedView,
  }) : _selectedSavedView = selectedSavedView;

  BillingReleaseWorkspaceSavedView? get selectedSavedView => _selectedSavedView;

  bool get hasSelection => _selectedSavedView != null;

  void select(BillingReleaseWorkspaceSavedView savedView) {
    if (_selectedSavedView?.id == savedView.id) return;

    _selectedSavedView = savedView;
    notifyListeners();
  }

  bool selectById({
    required String id,
    Iterable<BillingReleaseWorkspaceSavedView> views =
        billingReleaseWorkspaceDefaultSavedViews,
  }) {
    final savedView = findBillingReleaseWorkspaceSavedView(
      id: id,
      views: views,
    );
    if (savedView == null) return false;

    select(savedView);
    return true;
  }

  void clearSelection() {
    if (_selectedSavedView == null) return;

    _selectedSavedView = null;
    notifyListeners();
  }

  BillingReleaseWorkspaceComposition compose({
    required String businessDomain,
    required BillingReleaseWorkspaceRegistry registry,
    Iterable<BillingReleaseWorkspaceSavedView> savedViews =
        billingReleaseWorkspaceDefaultSavedViews,
  }) {
    return BillingReleaseWorkspaceComposition(
      businessDomain: businessDomain,
      registry: registry,
      savedViews: savedViews,
      selectedSavedView: _selectedSavedView,
      allowExternalSelectedView: _selectedSavedView != null,
    );
  }
}
