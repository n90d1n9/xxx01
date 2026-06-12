import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_status_presentation.dart';

class OrderSavedWorkspaceDetailsHeaderPresentation {
  final String label;
  final String description;
  final List<OrderSavedWorkspaceStatusBadgePresentation> badges;

  const OrderSavedWorkspaceDetailsHeaderPresentation({
    required this.label,
    required this.description,
    required this.badges,
  });

  factory OrderSavedWorkspaceDetailsHeaderPresentation.fromWorkspace(
    OrderSavedWorkspace workspace,
  ) {
    final status = OrderSavedWorkspaceStatusPresentation(workspace: workspace);

    return OrderSavedWorkspaceDetailsHeaderPresentation(
      label: workspace.label,
      description: workspace.description,
      badges: status.detailBadges,
    );
  }
}
