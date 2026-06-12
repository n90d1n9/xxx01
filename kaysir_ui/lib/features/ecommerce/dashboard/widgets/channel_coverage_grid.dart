import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/channel_strategy.dart';
import 'channel_coverage_signal_tile.dart';
import 'responsive_wrap_grid.dart';

class ChannelCoverageGrid extends StatelessWidget {
  final List<ChannelCoverageSignal> signals;
  final int maxColumns;
  final bool showRequirementBadges;

  const ChannelCoverageGrid({
    super.key,
    required this.signals,
    this.maxColumns = 3,
    this.showRequirementBadges = false,
  });

  @override
  Widget build(BuildContext context) {
    if (signals.isEmpty) return const SizedBox.shrink();

    return ResponsiveWrapGrid(
      itemCount: signals.length,
      columnsForWidth:
          (width) => _columnsFor(width: width, maxColumns: maxColumns),
      runSpacing: POSUiTokens.gap,
      itemBuilder: (context, index, width) {
        return ChannelCoverageSignalTile(
          width: width,
          signal: signals[index],
          showRequirementBadge: showRequirementBadges,
        );
      },
    );
  }
}

int _columnsFor({required double width, required int maxColumns}) {
  final cappedMaxColumns = maxColumns < 1 ? 1 : maxColumns;
  final responsiveColumns =
      width >= 760
          ? 3
          : width >= 520
          ? 2
          : 1;

  return responsiveColumns > cappedMaxColumns
      ? cappedMaxColumns
      : responsiveColumns;
}
