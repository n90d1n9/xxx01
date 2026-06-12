import '../models/order_saved_workspace.dart';

class OrderSavedWorkspaceDetailsDialogPresentation {
  final String title;
  final String filterSectionTitle;
  final bool showAutoSummaryPreview;
  final OrderSavedWorkspaceDetailsLinePresentation shortcutLine;

  const OrderSavedWorkspaceDetailsDialogPresentation({
    required this.title,
    required this.filterSectionTitle,
    required this.showAutoSummaryPreview,
    required this.shortcutLine,
  });

  factory OrderSavedWorkspaceDetailsDialogPresentation.fromWorkspace(
    OrderSavedWorkspace workspace,
  ) {
    return OrderSavedWorkspaceDetailsDialogPresentation(
      title: 'Workspace details',
      filterSectionTitle: 'Exact filters',
      showAutoSummaryPreview: workspace.isDescriptionCustom,
      shortcutLine: OrderSavedWorkspaceDetailsLinePresentation(
        label: 'Shortcut id',
        value: workspace.id,
      ),
    );
  }
}

class OrderSavedWorkspaceDetailsLinePresentation {
  final String label;
  final String value;

  const OrderSavedWorkspaceDetailsLinePresentation({
    required this.label,
    required this.value,
  });
}
