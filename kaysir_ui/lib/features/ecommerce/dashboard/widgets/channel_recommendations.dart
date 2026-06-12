import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/channel_recommendation.dart';
import 'channel_recommendation_tile.dart';
import 'empty_state.dart';

class ChannelRecommendations extends StatelessWidget {
  final List<ChannelRecommendation> recommendations;
  final int? maxVisible;
  final bool showHeader;
  final bool showEmptyState;

  const ChannelRecommendations({
    super.key,
    required this.recommendations,
    this.maxVisible,
    this.showHeader = true,
    this.showEmptyState = false,
  });

  @override
  Widget build(BuildContext context) {
    final visibleRecommendations = _visibleRecommendations;
    if (visibleRecommendations.isEmpty) {
      if (!showEmptyState) return const SizedBox.shrink();
      return const _EmptyRecommendations();
    }

    return Column(
      key: const ValueKey('channel_recommendations'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader) ...[
          Text(
            'Playbook',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: POSUiTokens.gap),
        ],
        ...visibleRecommendations.map(
          (recommendation) =>
              ChannelRecommendationTile(recommendation: recommendation),
        ),
        if (_hiddenCount > 0) ...[
          const SizedBox(height: POSUiTokens.gap),
          Text(
            '$_hiddenCount more in channel details',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }

  int get _effectiveMaxVisible {
    final requestedMax = maxVisible;
    if (requestedMax == null || requestedMax <= 0) {
      return recommendations.length;
    }
    return requestedMax;
  }

  int get _hiddenCount {
    final hiddenCount = recommendations.length - _visibleRecommendations.length;
    return hiddenCount < 0 ? 0 : hiddenCount;
  }

  List<ChannelRecommendation> get _visibleRecommendations {
    return List.unmodifiable(recommendations.take(_effectiveMaxVisible));
  }
}

class _EmptyRecommendations extends StatelessWidget {
  const _EmptyRecommendations();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(message: 'No channel playbook recommendations.');
  }
}
