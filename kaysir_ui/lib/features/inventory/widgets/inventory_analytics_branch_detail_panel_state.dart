import '../models/inventory_analytics_dashboard.dart';

/// Select option data for the branch drill-down panel.
class InventoryAnalyticsBranchDetailOption {
  const InventoryAnalyticsBranchDetailOption({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}

/// Presentation state for the inventory analytics branch drill-down panel.
class InventoryAnalyticsBranchDetailPanelState {
  const InventoryAnalyticsBranchDetailPanelState({
    required this.selectedDetail,
    required this.options,
  });

  final InventoryAnalyticsBranchDetail? selectedDetail;
  final List<InventoryAnalyticsBranchDetailOption> options;

  bool get hasDetail => selectedDetail != null;

  factory InventoryAnalyticsBranchDetailPanelState.fromDetails({
    required List<InventoryAnalyticsBranchDetail> details,
    required String? selectedBranchId,
  }) {
    InventoryAnalyticsBranchDetail? selectedDetail;

    for (final detail in details) {
      if (detail.branchId == selectedBranchId) {
        selectedDetail = detail;
        break;
      }
    }

    if (selectedDetail == null && details.isNotEmpty) {
      selectedDetail = details.first;
    }

    return InventoryAnalyticsBranchDetailPanelState(
      selectedDetail: selectedDetail,
      options: [
        for (final detail in details)
          InventoryAnalyticsBranchDetailOption(
            value: detail.branchId,
            label: detail.branchName,
          ),
      ],
    );
  }
}
