import 'package:flutter/material.dart';
import 'package:ky_admin/widgets/admin_content_panel.dart';
import 'package:ky_admin/widgets/admin_legend.dart';

import '../models/dashboard_data.dart';
import '../states/dashboard_provider.dart';
import 'acc_chart.dart';
import 'sales_card.dart';

const _currentSalesColor = Color(0xFF2E7D32);
const _previousSalesColor = Color(0xFF1769AA);

class DashboardPanels extends StatelessWidget {
  const DashboardPanels({
    super.key,
    required this.data,
    required this.selectedFilter,
  });

  final DashboardData data;
  final String selectedFilter;

  @override
  Widget build(BuildContext context) {
    final currentLabel = DashboardFilters.currentSeriesLabel(selectedFilter);
    final previousLabel = DashboardFilters.previousSeriesLabel(selectedFilter);

    return LayoutBuilder(
      builder: (context, constraints) {
        final salesPanel = AdminContentPanel(
          title: 'Revenue trend',
          subtitle: 'Current and previous sales movement.',
          leadingIcon: Icons.show_chart_outlined,
          trailing: AdminLegend(
            entries: [
              AdminLegendEntry(color: _currentSalesColor, label: currentLabel),
              AdminLegendEntry(
                color: _previousSalesColor,
                label: previousLabel,
              ),
            ],
          ),
          child: SalesChart(
            salesData: data.salesData,
            currentLabel: currentLabel,
            previousLabel: previousLabel,
          ),
        );
        final acquisitionPanel = AdminContentPanel(
          title: 'Customer mix',
          subtitle: 'Source contribution by engagement channel.',
          leadingIcon: Icons.pie_chart_outline,
          child: AcquisitionChart(acquisitionData: data.acquisitionData),
        );

        if (constraints.maxWidth < 980) {
          return Column(
            children: [
              salesPanel,
              const SizedBox(height: 16),
              acquisitionPanel,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: salesPanel),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: acquisitionPanel),
          ],
        );
      },
    );
  }
}
