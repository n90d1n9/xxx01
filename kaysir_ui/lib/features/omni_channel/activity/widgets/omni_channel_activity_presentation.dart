import 'package:flutter/material.dart';

import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_action.dart';
import '../models/omni_channel_activity_filter.dart';

enum OmniChannelActivityTone { neutral, info, success, warning, danger }

/// Icon, label, and tone metadata used by activity UI components.
class OmniChannelActivityVisuals {
  final IconData icon;
  final String label;
  final OmniChannelActivityTone tone;

  const OmniChannelActivityVisuals({
    required this.icon,
    required this.label,
    required this.tone,
  });
}

/// Presentation adapter for rendering an activity entry consistently.
class OmniChannelActivityEntryPresentation {
  final OmniChannelActivityEntry entry;

  const OmniChannelActivityEntryPresentation(this.entry);

  String get title => entry.title;

  String get detail {
    final detail = entry.detail.trim();
    return detail.isEmpty ? entry.kind.label : detail;
  }

  String get supportText {
    final supportSummary = entry.supportSummary?.trim();
    if (supportSummary != null && supportSummary.isNotEmpty) {
      return supportSummary;
    }

    return detail;
  }

  String get contextLabel {
    final parts = <String>[
      entry.sourceLabel,
      if (_hasValue(entry.channelLabel)) entry.channelLabel!.trim(),
      if (_hasValue(entry.orderId)) entry.orderId!.trim(),
    ];

    return parts.join(' / ');
  }

  OmniChannelActivityVisuals get severityVisuals {
    return omniChannelActivitySeverityVisuals(entry.severity);
  }

  OmniChannelActivityVisuals get kindVisuals {
    return omniChannelActivityKindVisuals(entry.kind);
  }
}

/// Presentation adapter for rendering activity actions consistently.
class OmniChannelActivityActionPresentation {
  final OmniChannelActivityAction action;

  const OmniChannelActivityActionPresentation(this.action);

  String get label => action.label;

  String get tooltip => action.effectiveTooltip;

  bool get isEnabled => action.isEnabled;

  IconData get icon => visuals.icon;

  OmniChannelActivityTone get tone => visuals.tone;

  OmniChannelActivityVisuals get visuals {
    switch (action.intent) {
      case OmniChannelActivityActionIntent.retry:
        return const OmniChannelActivityVisuals(
          icon: Icons.replay_circle_filled_outlined,
          label: 'Retry',
          tone: OmniChannelActivityTone.danger,
        );
      case OmniChannelActivityActionIntent.review:
        return const OmniChannelActivityVisuals(
          icon: Icons.rate_review_outlined,
          label: 'Review',
          tone: OmniChannelActivityTone.warning,
        );
      case OmniChannelActivityActionIntent.inspect:
        return const OmniChannelActivityVisuals(
          icon: Icons.manage_search_outlined,
          label: 'Inspect',
          tone: OmniChannelActivityTone.info,
        );
      case OmniChannelActivityActionIntent.navigate:
        return const OmniChannelActivityVisuals(
          icon: Icons.open_in_new_outlined,
          label: 'Open',
          tone: OmniChannelActivityTone.neutral,
        );
    }
  }
}

/// Filter-chip metadata for an activity status option.
class OmniChannelActivityFilterOptionPresentation {
  final OmniChannelActivityFilterStatus status;
  final String label;
  final int count;
  final IconData icon;
  final OmniChannelActivityTone tone;

  const OmniChannelActivityFilterOptionPresentation({
    required this.status,
    required this.label,
    required this.count,
    required this.icon,
    required this.tone,
  });

  bool get hasActivity => count > 0;

  factory OmniChannelActivityFilterOptionPresentation.fromStatus({
    required OmniChannelActivityFilterStatus status,
    required OmniChannelActivityFilterCounts counts,
  }) {
    final visuals = omniChannelActivityFilterStatusVisuals(status);

    return OmniChannelActivityFilterOptionPresentation(
      status: status,
      label: visuals.label,
      count: counts.countFor(status),
      icon: visuals.icon,
      tone: visuals.tone,
    );
  }
}

/// Builds every filter-chip option with counts from the current activity feed.
List<OmniChannelActivityFilterOptionPresentation>
omniChannelActivityFilterOptionPresentations({
  required OmniChannelActivityFilterCounts counts,
  Iterable<OmniChannelActivityFilterStatus> statuses =
      OmniChannelActivityFilterStatus.values,
}) {
  return List.unmodifiable(
    statuses.map(
      (status) => OmniChannelActivityFilterOptionPresentation.fromStatus(
        status: status,
        counts: counts,
      ),
    ),
  );
}

/// Resolves severity visuals shared by activity rows and detail panels.
OmniChannelActivityVisuals omniChannelActivitySeverityVisuals(
  OmniChannelActivitySeverity severity,
) {
  switch (severity) {
    case OmniChannelActivitySeverity.ready:
      return const OmniChannelActivityVisuals(
        icon: Icons.check_circle_outline,
        label: 'Ready',
        tone: OmniChannelActivityTone.success,
      );
    case OmniChannelActivitySeverity.review:
      return const OmniChannelActivityVisuals(
        icon: Icons.pending_actions_outlined,
        label: 'Review',
        tone: OmniChannelActivityTone.warning,
      );
    case OmniChannelActivitySeverity.attention:
      return const OmniChannelActivityVisuals(
        icon: Icons.priority_high_outlined,
        label: 'Attention',
        tone: OmniChannelActivityTone.danger,
      );
  }
}

/// Resolves event-kind visuals shared by activity rows and detail panels.
OmniChannelActivityVisuals omniChannelActivityKindVisuals(
  OmniChannelActivityKind kind,
) {
  switch (kind) {
    case OmniChannelActivityKind.order:
      return const OmniChannelActivityVisuals(
        icon: Icons.receipt_long_outlined,
        label: 'Order',
        tone: OmniChannelActivityTone.info,
      );
    case OmniChannelActivityKind.orderSync:
      return const OmniChannelActivityVisuals(
        icon: Icons.sync_outlined,
        label: 'Order sync',
        tone: OmniChannelActivityTone.info,
      );
    case OmniChannelActivityKind.channelSwitch:
      return const OmniChannelActivityVisuals(
        icon: Icons.hub_outlined,
        label: 'Channel switch',
        tone: OmniChannelActivityTone.neutral,
      );
    case OmniChannelActivityKind.switchAction:
      return const OmniChannelActivityVisuals(
        icon: Icons.swap_horiz_outlined,
        label: 'Switch action',
        tone: OmniChannelActivityTone.neutral,
      );
    case OmniChannelActivityKind.fulfillment:
      return const OmniChannelActivityVisuals(
        icon: Icons.local_shipping_outlined,
        label: 'Fulfillment',
        tone: OmniChannelActivityTone.info,
      );
    case OmniChannelActivityKind.payment:
      return const OmniChannelActivityVisuals(
        icon: Icons.payments_outlined,
        label: 'Payment',
        tone: OmniChannelActivityTone.success,
      );
    case OmniChannelActivityKind.system:
      return const OmniChannelActivityVisuals(
        icon: Icons.settings_suggest_outlined,
        label: 'System',
        tone: OmniChannelActivityTone.neutral,
      );
  }
}

/// Resolves filter status visuals shared by the filter bar and summaries.
OmniChannelActivityVisuals omniChannelActivityFilterStatusVisuals(
  OmniChannelActivityFilterStatus status,
) {
  switch (status) {
    case OmniChannelActivityFilterStatus.all:
      return const OmniChannelActivityVisuals(
        icon: Icons.dashboard_customize_outlined,
        label: 'All',
        tone: OmniChannelActivityTone.neutral,
      );
    case OmniChannelActivityFilterStatus.attention:
      return const OmniChannelActivityVisuals(
        icon: Icons.priority_high_outlined,
        label: 'Attention',
        tone: OmniChannelActivityTone.danger,
      );
    case OmniChannelActivityFilterStatus.review:
      return const OmniChannelActivityVisuals(
        icon: Icons.pending_actions_outlined,
        label: 'Review',
        tone: OmniChannelActivityTone.warning,
      );
    case OmniChannelActivityFilterStatus.orders:
      return omniChannelActivityKindVisuals(OmniChannelActivityKind.order);
    case OmniChannelActivityFilterStatus.orderSync:
      return omniChannelActivityKindVisuals(OmniChannelActivityKind.orderSync);
    case OmniChannelActivityFilterStatus.channelSwitches:
      return const OmniChannelActivityVisuals(
        icon: Icons.hub_outlined,
        label: 'Channels',
        tone: OmniChannelActivityTone.neutral,
      );
    case OmniChannelActivityFilterStatus.switchActions:
      return const OmniChannelActivityVisuals(
        icon: Icons.swap_horiz_outlined,
        label: 'Switches',
        tone: OmniChannelActivityTone.neutral,
      );
    case OmniChannelActivityFilterStatus.fulfillment:
      return omniChannelActivityKindVisuals(
        OmniChannelActivityKind.fulfillment,
      );
    case OmniChannelActivityFilterStatus.payments:
      return omniChannelActivityKindVisuals(OmniChannelActivityKind.payment);
    case OmniChannelActivityFilterStatus.system:
      return omniChannelActivityKindVisuals(OmniChannelActivityKind.system);
  }
}

/// Maps an activity tone to a Material color for the current theme.
Color omniChannelActivityToneColor(
  ColorScheme colorScheme,
  OmniChannelActivityTone tone,
) {
  switch (tone) {
    case OmniChannelActivityTone.success:
      return colorScheme.primary;
    case OmniChannelActivityTone.warning:
      return colorScheme.tertiary;
    case OmniChannelActivityTone.danger:
      return colorScheme.error;
    case OmniChannelActivityTone.info:
      return colorScheme.secondary;
    case OmniChannelActivityTone.neutral:
      return colorScheme.onSurfaceVariant;
  }
}

bool _hasValue(String? value) {
  return value?.trim().isNotEmpty ?? false;
}
