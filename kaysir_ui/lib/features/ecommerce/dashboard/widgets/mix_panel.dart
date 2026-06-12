import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../../order/models/order_insights.dart';
import 'order_breakdown_list.dart';
import 'panel_header.dart';
import 'panel_surface.dart';
import 'responsive_wrap_grid.dart';

class MixPanel extends StatelessWidget {
  final OrderInsights insights;

  const MixPanel({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return PanelSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PanelHeader(
            icon: Icons.hub_outlined,
            title: 'Channel and fulfillment mix',
            subtitle: 'Where orders are coming from and how they move.',
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          ResponsiveWrapGrid(
            itemCount: 2,
            columnsForWidth: _columnsForWidth,
            itemBuilder: (context, index, width) {
              final isChannels = index == 0;

              return SizedBox(
                width: width,
                child: OrderBreakdownList(
                  title: isChannels ? 'Sales channels' : 'Fulfillment modes',
                  emptyMessage:
                      isChannels
                          ? 'No channel activity yet'
                          : 'No fulfillment activity yet',
                  rows:
                      isChannels
                          ? insights.channelBreakdown
                          : insights.fulfillmentBreakdown,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

int _columnsForWidth(double width) {
  return width >= 720 ? 2 : 1;
}
