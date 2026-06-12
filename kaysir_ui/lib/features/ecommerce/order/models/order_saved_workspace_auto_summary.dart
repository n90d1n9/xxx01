import 'order_active_filter_summary.dart';
import 'order_saved_workspace_identity.dart';
import 'order_saved_workspace_model.dart';

String ecommerceOrderSavedWorkspaceAutoSummaryPreviewDescription(
  OrderSavedWorkspace workspace,
) {
  return ecommerceOrderSavedWorkspaceDescriptionFromSummary(
    ecommerceOrderActiveFilterSummary(
      filter: workspace.filter,
      sortMode: workspace.sortMode,
    ),
  );
}
