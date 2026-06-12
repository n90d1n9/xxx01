import '../../../point_of_sales/order/models/order.dart' as pos_order;
import '../models/order_active_filter_summary.dart';
import '../models/order_saved_workspace.dart';

typedef OrderStatusChanged =
    void Function(pos_order.Order order, String status);
typedef OrderSavedWorkspacePinChanged =
    void Function(OrderSavedWorkspace workspace, bool isPinned);
typedef OrderSavedWorkspaceRenamed =
    void Function(OrderSavedWorkspace workspace, String label);
typedef OrderSavedWorkspaceDescriptionChanged =
    void Function(OrderSavedWorkspace workspace, String description);
typedef OrderSavedWorkspaceDescriptionReset =
    void Function(
      OrderSavedWorkspace workspace,
      List<OrderActiveFilterSummaryItem> summaryItems,
    );
typedef OrderSavedWorkspaceMoved =
    void Function(
      OrderSavedWorkspace workspace,
      OrderSavedWorkspaceMoveDirection direction,
    );
