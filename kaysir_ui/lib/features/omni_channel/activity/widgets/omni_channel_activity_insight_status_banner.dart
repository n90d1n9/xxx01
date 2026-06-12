import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_insight.dart';
import '../states/omni_channel_activity_provider.dart';
import 'omni_channel_activity_insight_action_button.dart';
import 'omni_channel_activity_insight_banner.dart';

typedef OmniChannelActivityInsightTrailingBuilder =
    Widget? Function(BuildContext context, OmniChannelActivityInsight insight);

/// Provider-connected activity status banner for POS and ecommerce shells.
class OmniChannelActivityInsightStatusBanner extends ConsumerWidget {
  final EdgeInsetsGeometry padding;
  final Duration transitionDuration;
  final bool showReadyState;
  final bool showNextStep;
  final ValueChanged<String>? onOpenActivityCenter;
  final OmniChannelActivityInsightTrailingBuilder? trailingBuilder;

  const OmniChannelActivityInsightStatusBanner({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(12, 8, 12, 0),
    this.transitionDuration = const Duration(milliseconds: 180),
    this.showReadyState = false,
    this.showNextStep = true,
    this.onOpenActivityCenter,
    this.trailingBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(omniChannelActivityInsightProvider);
    final shouldShow =
        showReadyState || insight.severity != OmniChannelActivitySeverity.ready;

    return AnimatedSwitcher(
      duration: transitionDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child:
          shouldShow
              ? Padding(
                key: ValueKey(_insightKey(insight)),
                padding: padding,
                child: OmniChannelActivityInsightBanner(
                  insight: insight,
                  showNextStep: showNextStep,
                  trailing:
                      trailingBuilder?.call(context, insight) ??
                      _activityCenterAction(insight),
                ),
              )
              : const SizedBox.shrink(
                key: ValueKey('empty-omni-channel-activity-insight'),
              ),
    );
  }

  Widget? _activityCenterAction(OmniChannelActivityInsight insight) {
    final handler = onOpenActivityCenter;
    if (handler == null) return null;

    return OmniChannelActivityInsightActionButton(
      insight: insight,
      onOpenLocation: handler,
    );
  }
}

@Preview(name: 'Omni-channel activity insight status banner')
Widget omniChannelActivityInsightStatusBannerPreview() {
  final insight = OmniChannelActivityInsight.fromFeed(
    OmniChannelActivityFeed(
      entries: [
        OmniChannelActivityEntry(
          id: 'preview-review',
          kind: OmniChannelActivityKind.order,
          sourceId: 'ecommerce',
          sourceLabel: 'Ecommerce',
          occurredAt: DateTime(2026, 6, 9, 10),
          title: 'Marketplace pickup needs review',
          detail: 'Confirm pickup counter capacity before handoff.',
          severity: OmniChannelActivitySeverity.review,
          channelId: 'marketplace',
          orderId: 'ECOM-2026-017',
        ),
      ],
    ),
  );

  return ProviderScope(
    overrides: [omniChannelActivityInsightProvider.overrideWithValue(insight)],
    child: const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 560,
            child: OmniChannelActivityInsightStatusBanner(),
          ),
        ),
      ),
    ),
  );
}

String _insightKey(OmniChannelActivityInsight insight) {
  return 'omni-channel-activity-${insight.severity.name}-'
      '${insight.eventCount}-${insight.attentionCount}-${insight.reviewCount}';
}
