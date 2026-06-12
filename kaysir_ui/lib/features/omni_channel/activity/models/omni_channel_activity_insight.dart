import 'omni_channel_activity.dart';

class OmniChannelActivityInsight {
  final OmniChannelActivitySeverity severity;
  final int eventCount;
  final int attentionCount;
  final int reviewCount;
  final int orderCount;
  final int orderSyncCount;
  final int channelSwitchCount;
  final int switchActionCount;
  final int channelCount;
  final String summaryLabel;
  final String headline;
  final String detail;
  final String nextStep;
  final OmniChannelActivityEntry? referenceEntry;

  const OmniChannelActivityInsight({
    required this.severity,
    required this.eventCount,
    required this.attentionCount,
    required this.reviewCount,
    required this.orderCount,
    required this.orderSyncCount,
    required this.channelSwitchCount,
    required this.switchActionCount,
    required this.channelCount,
    required this.summaryLabel,
    required this.headline,
    required this.detail,
    required this.nextStep,
    this.referenceEntry,
  });

  factory OmniChannelActivityInsight.fromFeed(OmniChannelActivityFeed feed) {
    final attentionEntry = feed.attentionEntries.firstOrNull;
    if (attentionEntry != null) {
      return OmniChannelActivityInsight(
        severity: OmniChannelActivitySeverity.attention,
        eventCount: feed.entries.length,
        attentionCount: feed.attentionCount,
        reviewCount: feed.reviewCount,
        orderCount: feed.orderCount,
        orderSyncCount: feed.orderSyncCount,
        channelSwitchCount: feed.channelSwitchCount,
        switchActionCount: feed.switchActionCount,
        channelCount: _channelCount(feed),
        summaryLabel: _summaryLabel(feed),
        headline: 'Omni-channel activity needs attention',
        detail: _entryDetail(attentionEntry),
        nextStep: 'Resolve attention events before the next handoff.',
        referenceEntry: attentionEntry,
      );
    }

    final reviewEntry = feed.reviewEntries.firstOrNull;
    if (reviewEntry != null) {
      return OmniChannelActivityInsight(
        severity: OmniChannelActivitySeverity.review,
        eventCount: feed.entries.length,
        attentionCount: feed.attentionCount,
        reviewCount: feed.reviewCount,
        orderCount: feed.orderCount,
        orderSyncCount: feed.orderSyncCount,
        channelSwitchCount: feed.channelSwitchCount,
        switchActionCount: feed.switchActionCount,
        channelCount: _channelCount(feed),
        summaryLabel: _summaryLabel(feed),
        headline: 'Omni-channel activity needs review',
        detail: _entryDetail(reviewEntry),
        nextStep: 'Review pending order and switch activity before handoff.',
        referenceEntry: reviewEntry,
      );
    }

    if (feed.isEmpty) {
      return const OmniChannelActivityInsight(
        severity: OmniChannelActivitySeverity.ready,
        eventCount: 0,
        attentionCount: 0,
        reviewCount: 0,
        orderCount: 0,
        orderSyncCount: 0,
        channelSwitchCount: 0,
        switchActionCount: 0,
        channelCount: 0,
        summaryLabel: 'No activity recorded',
        headline: 'No omni-channel activity yet',
        detail:
            'POS, ecommerce, sync, and channel events will appear here as they happen.',
        nextStep: 'Run activity through POS or ecommerce to start monitoring.',
      );
    }

    return OmniChannelActivityInsight(
      severity: OmniChannelActivitySeverity.ready,
      eventCount: feed.entries.length,
      attentionCount: feed.attentionCount,
      reviewCount: feed.reviewCount,
      orderCount: feed.orderCount,
      orderSyncCount: feed.orderSyncCount,
      channelSwitchCount: feed.channelSwitchCount,
      switchActionCount: feed.switchActionCount,
      channelCount: _channelCount(feed),
      summaryLabel: _summaryLabel(feed),
      headline: 'Omni-channel activity is healthy',
      detail: 'All recorded POS and ecommerce activity is clear.',
      nextStep: 'Continue monitoring orders, sync, and channel switches.',
      referenceEntry: feed.entries.first,
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    for (final value in this) {
      return value;
    }

    return null;
  }
}

String _entryDetail(OmniChannelActivityEntry entry) {
  final supportSummary = entry.supportSummary?.trim();
  if (supportSummary != null && supportSummary.isNotEmpty) {
    return supportSummary;
  }

  final detail = entry.detail.trim();
  if (detail.isNotEmpty) return detail;

  return entry.title;
}

String _summaryLabel(OmniChannelActivityFeed feed) {
  final parts = <String>[
    _countLabel(feed.entries.length, 'event'),
    if (feed.orderCount > 0) _countLabel(feed.orderCount, 'order'),
    if (_channelCount(feed) > 0) _countLabel(_channelCount(feed), 'channel'),
    if (feed.attentionCount > 0) _countLabel(feed.attentionCount, 'attention'),
    if (feed.reviewCount > 0) _countLabel(feed.reviewCount, 'review'),
  ];

  return parts.join(', ');
}

int _channelCount(OmniChannelActivityFeed feed) {
  final channels = <String>{};
  for (final entry in feed.entries) {
    final channelId = entry.channelId?.trim();
    if (channelId != null && channelId.isNotEmpty) {
      channels.add(channelId);
    }
  }

  return channels.length;
}

String _countLabel(int count, String singular) {
  return '$count $singular${count == 1 ? '' : 's'}';
}
