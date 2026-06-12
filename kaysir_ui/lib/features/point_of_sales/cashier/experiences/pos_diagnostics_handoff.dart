import 'pos_diagnostics_activity.dart';
import 'pos_experience_diagnostics.dart';
import 'pos_experience_manifest.dart';

enum POSDiagnosticsHandoffSeverity { ready, review, attention }

class POSDiagnosticsHandoffMetric {
  final String label;
  final String value;

  const POSDiagnosticsHandoffMetric({required this.label, required this.value});
}

class POSDiagnosticsHandoffSummary {
  final POSDiagnosticsHandoffSeverity severity;
  final String title;
  final String headline;
  final String statusLabel;
  final int configurationWarningCount;
  final int activityCount;
  final int activityAttentionCount;
  final int activityReviewCount;
  final int activitySwitchActionCount;
  final int activityChannelSwitchCount;
  final int activityOrderSyncCount;
  final List<POSDiagnosticsHandoffMetric> metrics;
  final List<POSDiagnosticsHandoffMetric> facts;
  final List<String> attentionItems;

  POSDiagnosticsHandoffSummary({
    required this.severity,
    required this.title,
    required this.headline,
    required this.statusLabel,
    required this.configurationWarningCount,
    required this.activityCount,
    required this.activityAttentionCount,
    this.activityReviewCount = 0,
    this.activitySwitchActionCount = 0,
    this.activityChannelSwitchCount = 0,
    this.activityOrderSyncCount = 0,
    Iterable<POSDiagnosticsHandoffMetric> metrics = const [],
    Iterable<POSDiagnosticsHandoffMetric> facts = const [],
    Iterable<String> attentionItems = const [],
  }) : metrics = List.unmodifiable(metrics),
       facts = List.unmodifiable(facts),
       attentionItems = List.unmodifiable(attentionItems);

  factory POSDiagnosticsHandoffSummary.from({
    required POSExperienceDiagnostics diagnostics,
    required POSDiagnosticsActivitySnapshot activity,
  }) {
    final configurationWarningCount = diagnostics.warningCount;
    final activityAttentionCount = activity.attentionCount;
    final activityReviewCount = activity.reviewCount;
    final activitySwitchActionCount = activity.switchActionCount;
    final activityChannelSwitchCount = activity.channelSwitchCount;
    final activityOrderSyncCount = activity.orderSyncCount;
    final severity = _severityFor(
      diagnostics: diagnostics,
      activityAttentionCount: activityAttentionCount,
      activityReviewCount: activityReviewCount,
    );
    final attentionItems = _attentionItemsFor(
      diagnostics: diagnostics,
      activity: activity,
    );

    return POSDiagnosticsHandoffSummary(
      severity: severity,
      title: '${diagnostics.experience.label} handoff',
      headline: _headlineFor(
        severity: severity,
        diagnostics: diagnostics,
        activityAttentionCount: activityAttentionCount,
        activityReviewCount: activityReviewCount,
      ),
      statusLabel: diagnostics.statusLabel,
      configurationWarningCount: configurationWarningCount,
      activityCount: activity.entries.length,
      activityAttentionCount: activityAttentionCount,
      activityReviewCount: activityReviewCount,
      activitySwitchActionCount: activitySwitchActionCount,
      activityChannelSwitchCount: activityChannelSwitchCount,
      activityOrderSyncCount: activityOrderSyncCount,
      metrics: [
        POSDiagnosticsHandoffMetric(
          label: 'Status',
          value: diagnostics.statusLabel,
        ),
        POSDiagnosticsHandoffMetric(
          label: 'Warnings',
          value:
              configurationWarningCount == 0
                  ? 'Clear'
                  : _countLabel(configurationWarningCount, 'warning'),
        ),
        POSDiagnosticsHandoffMetric(
          label: 'Activity',
          value:
              activity.entries.isEmpty
                  ? 'No events'
                  : _countLabel(activity.entries.length, 'event'),
        ),
        POSDiagnosticsHandoffMetric(
          label: 'Switches',
          value:
              activitySwitchActionCount == 0
                  ? 'No attempts'
                  : _countLabel(activitySwitchActionCount, 'attempt'),
        ),
        POSDiagnosticsHandoffMetric(
          label: 'Review',
          value:
              activityReviewCount == 0
                  ? 'Clear'
                  : _countLabel(activityReviewCount, 'event'),
        ),
        POSDiagnosticsHandoffMetric(
          label: 'Attention',
          value:
              activityAttentionCount == 0
                  ? 'Clear'
                  : _countLabel(activityAttentionCount, 'event'),
        ),
      ],
      facts: [
        POSDiagnosticsHandoffMetric(
          label: 'Mode',
          value:
              '${diagnostics.experience.label} (${diagnostics.experience.id})',
        ),
        POSDiagnosticsHandoffMetric(
          label: 'Pack',
          value:
              '${diagnostics.runtimePackLabel} (${diagnostics.runtimePackId})',
        ),
        POSDiagnosticsHandoffMetric(
          label: 'Product',
          value: diagnostics.productProfileLabel,
        ),
        POSDiagnosticsHandoffMetric(
          label: 'Channel',
          value: diagnostics.commerceChannelLabel,
        ),
        POSDiagnosticsHandoffMetric(
          label: 'Layout',
          value: diagnostics.layoutSummary,
        ),
        POSDiagnosticsHandoffMetric(
          label: 'Screen',
          value:
              '${diagnostics.screenFit.formFactorLabel} / '
              '${diagnostics.screenFit.statusLabel}',
        ),
        POSDiagnosticsHandoffMetric(
          label: 'Launch',
          value:
              '${diagnostics.launchChecklist.statusLabel} '
              '(${_countLabel(diagnostics.launchChecklist.failureCount, 'blocker')}, '
              '${_countLabel(diagnostics.launchChecklist.warningCount, 'review item')})',
        ),
        POSDiagnosticsHandoffMetric(
          label: 'Release',
          value: diagnostics.manifest.releaseStage.label,
        ),
      ],
      attentionItems: attentionItems,
    );
  }

  bool get hasAttentionItems => attentionItems.isNotEmpty;

  String toShareText() {
    final buffer =
        StringBuffer()
          ..writeln('Kaysir POS diagnostics handoff')
          ..writeln('Status: $statusLabel')
          ..writeln('Summary: $headline')
          ..writeln()
          ..writeln('Context:');

    for (final fact in facts) {
      buffer.writeln('- ${fact.label}: ${fact.value}');
    }

    buffer
      ..writeln()
      ..writeln('Activity:')
      ..writeln('- Events: ${_countLabel(activityCount, 'event')}')
      ..writeln(
        '- Switch attempts: ${_countLabel(activitySwitchActionCount, 'attempt')}',
      )
      ..writeln(
        '- Channel changes: ${_countLabel(activityChannelSwitchCount, 'change')}',
      )
      ..writeln('- Order sync: ${_countLabel(activityOrderSyncCount, 'event')}')
      ..writeln(
        '- Review: '
        '${activityReviewCount == 0 ? 'clear' : _countLabel(activityReviewCount, 'event')}',
      )
      ..writeln(
        '- Attention: '
        '${activityAttentionCount == 0 ? 'clear' : _countLabel(activityAttentionCount, 'event')}',
      )
      ..writeln()
      ..writeln('Attention:');

    if (attentionItems.isEmpty) {
      buffer.writeln('- None');
    } else {
      for (final item in attentionItems) {
        buffer.writeln('- $item');
      }
    }

    return buffer.toString().trimRight();
  }
}

POSDiagnosticsHandoffSeverity _severityFor({
  required POSExperienceDiagnostics diagnostics,
  required int activityAttentionCount,
  required int activityReviewCount,
}) {
  if (diagnostics.warningCount > 0 || activityAttentionCount > 0) {
    return POSDiagnosticsHandoffSeverity.attention;
  }

  if (activityReviewCount > 0) {
    return POSDiagnosticsHandoffSeverity.review;
  }

  if (diagnostics.readiness.level != POSExperienceReadinessLevel.ready) {
    return POSDiagnosticsHandoffSeverity.review;
  }

  return POSDiagnosticsHandoffSeverity.ready;
}

String _headlineFor({
  required POSDiagnosticsHandoffSeverity severity,
  required POSExperienceDiagnostics diagnostics,
  required int activityAttentionCount,
  required int activityReviewCount,
}) {
  switch (severity) {
    case POSDiagnosticsHandoffSeverity.ready:
      return 'Mode is healthy and ready for operator handoff.';
    case POSDiagnosticsHandoffSeverity.review:
      if (activityReviewCount > 0) {
        return 'Review ${_countLabel(activityReviewCount, 'activity event')} before rollout.';
      }

      return '${diagnostics.statusLabel} mode is healthy; validate the workflow before rollout.';
    case POSDiagnosticsHandoffSeverity.attention:
      final parts = <String>[
        if (diagnostics.warningCount > 0)
          _countLabel(diagnostics.warningCount, 'configuration warning'),
        if (activityAttentionCount > 0)
          _countLabel(activityAttentionCount, 'activity event'),
      ];

      return 'Review ${parts.join(' and ')} before rollout.';
  }
}

List<String> _attentionItemsFor({
  required POSExperienceDiagnostics diagnostics,
  required POSDiagnosticsActivitySnapshot activity,
}) {
  final items = <String>[];

  if (diagnostics.runtimePackIssueCount > 0) {
    items.add(
      '${_countLabel(diagnostics.runtimePackIssueCount, 'runtime pack issue')} found.',
    );
  }
  if (diagnostics.usedFallback) {
    items.add(diagnostics.fallbackReason ?? 'Default POS mode is active.');
  }
  if (diagnostics.layoutIssueCount > 0) {
    items.add(
      '${_countLabel(diagnostics.layoutIssueCount, 'layout issue')} found.',
    );
  }
  if (diagnostics.commerceChannelIssueCount > 0) {
    items.add(
      '${_countLabel(diagnostics.commerceChannelIssueCount, 'commerce channel issue')} found.',
    );
  }
  if (diagnostics.productProfileCatalogIssueCount > 0) {
    items.add(
      '${_countLabel(diagnostics.productProfileCatalogIssueCount, 'product catalog issue')} found.',
    );
  }
  if (diagnostics.commandActionIssueCount > 0) {
    items.add(
      '${_countLabel(diagnostics.commandActionIssueCount, 'command issue')} found.',
    );
  }
  if (diagnostics.shortcutIssueCount > 0) {
    items.add(
      '${_countLabel(diagnostics.shortcutIssueCount, 'shortcut issue')} found.',
    );
  }
  if (diagnostics.runtimeActionIssueCount > 0) {
    items.add(
      '${_countLabel(diagnostics.runtimeActionIssueCount, 'enabled action')} missing module support.',
    );
  }
  if (!diagnostics.screenFit.supported) {
    items.add(diagnostics.screenFit.message);
  }

  final launchChecklist = diagnostics.launchChecklist;
  if (diagnostics.isProductProfileBacked && launchChecklist.failureCount > 0) {
    items.add(
      '${_countLabel(launchChecklist.failureCount, 'launch blocker')} found.',
    );
  }
  if (diagnostics.isProductProfileBacked && launchChecklist.warningCount > 0) {
    items.add(
      '${_countLabel(launchChecklist.warningCount, 'launch review item')} found.',
    );
  }
  if (activity.attentionCount > 0) {
    items.add(
      '${_countLabel(activity.attentionCount, 'recent activity event')} needs review.',
    );

    for (final entry in activity.attentionEntries.take(2)) {
      items.add(entry.supportSummary ?? entry.title);
    }
  }
  if (activity.reviewCount > 0) {
    items.add(
      '${_countLabel(activity.reviewCount, 'recent activity review item')} should be checked.',
    );

    for (final entry in activity.reviewEntries.take(2)) {
      items.add(entry.supportSummary ?? entry.title);
    }
  }

  return items;
}

String _countLabel(int count, String singular) {
  return '$count $singular${count == 1 ? '' : 's'}';
}
