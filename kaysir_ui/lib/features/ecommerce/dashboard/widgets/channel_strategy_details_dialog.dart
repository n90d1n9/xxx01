import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/channel_recommendation.dart';
import '../models/channel_strategy.dart';
import 'channel_coverage_grid.dart';
import 'channel_recommendations.dart';
import 'channel_strategy_channel_list.dart';
import 'dialog_close_button.dart';
import 'dialog_header.dart';
import 'dialog_section.dart';

Future<void> showChannelStrategyDetailsDialog({
  required BuildContext context,
  required ChannelStrategy strategy,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => ChannelStrategyDetailsDialog(strategy: strategy),
  );
}

class ChannelStrategyDetailsDialog extends StatelessWidget {
  final ChannelStrategy strategy;

  const ChannelStrategyDetailsDialog({super.key, required this.strategy});

  @override
  Widget build(BuildContext context) {
    final recommendations = strategy.recommendations;

    return AlertDialog(
      key: const ValueKey('channel_strategy_dialog'),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      title: DialogHeader(
        icon: Icons.route_outlined,
        title: 'Channel strategy details',
      ),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogSection(
                title: 'Coverage',
                child: ChannelCoverageGrid(
                  signals: strategy.coverageSignals,
                  maxColumns: 2,
                  showRequirementBadges: true,
                ),
              ),
              if (recommendations.isNotEmpty) ...[
                const SizedBox(height: POSUiTokens.gapLarge),
                ChannelRecommendations(
                  recommendations: recommendations,
                  showHeader: true,
                ),
              ],
              const SizedBox(height: POSUiTokens.gapLarge),
              DialogSection(
                title: 'Channels',
                child: ChannelStrategyChannelList(channels: strategy.channels),
              ),
            ],
          ),
        ),
      ),
      actions: [const DialogCloseButton()],
    );
  }
}
