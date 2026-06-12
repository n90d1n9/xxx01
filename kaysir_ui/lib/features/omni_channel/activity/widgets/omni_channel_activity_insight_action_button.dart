import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_center_query_state.dart';
import '../models/omni_channel_activity_insight.dart';
import '../omni_channel_activity_routes.dart';

/// CTA that opens the activity center at the insight's most relevant context.
class OmniChannelActivityInsightActionButton extends StatelessWidget {
  final OmniChannelActivityInsight insight;
  final ValueChanged<String> onOpenLocation;
  final String path;

  const OmniChannelActivityInsightActionButton({
    super.key,
    required this.insight,
    required this.onOpenLocation,
    this.path = OmniChannelActivityRoutes.activityCenterPath,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const ValueKey('omni-channel-activity-insight-action'),
      onPressed: () => onOpenLocation(_location),
      icon: const Icon(Icons.manage_search_outlined, size: 18),
      label: Text(_label),
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }

  String get _location {
    return OmniChannelActivityCenterQueryState.fromInsight(
      insight,
    ).locationForPath(path);
  }

  String get _label {
    switch (insight.severity) {
      case OmniChannelActivitySeverity.attention:
        return 'Resolve activity';
      case OmniChannelActivitySeverity.review:
        return 'Review activity';
      case OmniChannelActivitySeverity.ready:
        return 'Open activity';
    }
  }
}

@Preview(name: 'Omni-channel activity insight action')
Widget omniChannelActivityInsightActionButtonPreview() {
  final insight = OmniChannelActivityInsight.fromFeed(
    OmniChannelActivityFeed(
      entries: [
        OmniChannelActivityEntry(
          id: 'preview-sync',
          kind: OmniChannelActivityKind.orderSync,
          sourceId: 'point_of_sales',
          sourceLabel: 'Point of sale',
          occurredAt: DateTime(2026, 6, 9, 11, 30),
          title: 'Order sync failed',
          detail: 'Retry queued counter order.',
          severity: OmniChannelActivitySeverity.attention,
          channelId: 'web_store',
          orderId: 'POS-2026-014',
        ),
      ],
    ),
  );

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: OmniChannelActivityInsightActionButton(
          insight: insight,
          onOpenLocation: (_) {},
        ),
      ),
    ),
  );
}
