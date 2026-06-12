import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/channel_recommendation.dart';
import '../models/channel_strategy.dart';
import 'action_button.dart';
import 'channel_chips.dart';
import 'channel_coverage_grid.dart';
import 'channel_recommendations.dart';
import 'channel_strategy_details_dialog.dart';
import 'panel_header.dart';
import 'panel_surface.dart';

class ChannelStrategyPanel extends StatelessWidget {
  final ChannelStrategy strategy;

  const ChannelStrategyPanel({super.key, required this.strategy});

  @override
  Widget build(BuildContext context) {
    if (!strategy.hasChannels) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return PanelSurface(
      key: const ValueKey('channel_strategy_panel'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useCompact = constraints.maxWidth < 760;
          final recommendations = strategy.recommendations;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanelHeader(
                icon: Icons.route_outlined,
                title: 'Channel strategy',
                subtitle: strategy.coverageHeadline,
                subtitleColor:
                    strategy.hasCoverageGaps
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                trailing: useCompact ? null : _inspectChannelsButton(context),
              ),
              if (useCompact) ...[
                const SizedBox(height: POSUiTokens.gap),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _inspectChannelsButton(context),
                ),
              ],
              const SizedBox(height: POSUiTokens.gapLarge),
              ChannelChips(
                channels: strategy.channels,
                maxVisible: useCompact ? 3 : 6,
              ),
              const SizedBox(height: POSUiTokens.gapLarge),
              ChannelCoverageGrid(
                signals: strategy.coverageSignals,
                maxColumns: useCompact ? 1 : 3,
              ),
              if (recommendations.isNotEmpty) ...[
                const SizedBox(height: POSUiTokens.gapLarge),
                ChannelRecommendations(
                  recommendations: recommendations,
                  maxVisible: 1,
                  showHeader: false,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _inspectChannelsButton(BuildContext context) {
    return ActionButton(
      icon: Icons.manage_search_outlined,
      label: 'Inspect channels',
      onPressed:
          () => showChannelStrategyDetailsDialog(
            context: context,
            strategy: strategy,
          ),
    );
  }
}
