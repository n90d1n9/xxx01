import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../order/states/order_save_outbox_provider.dart';
import '../experiences/pos_commerce_channel_switch_history.dart';
import '../experiences/pos_diagnostics_activity.dart';
import '../experiences/pos_diagnostics_handoff.dart';
import '../experiences/pos_experience_diagnostics.dart';
import '../experiences/pos_switch_action_history.dart';
import 'pos_switch_preview_pill.dart';
import 'pos_ui.dart';

typedef POSDiagnosticsHandoffCopy = Future<void> Function(String text);

class POSDiagnosticsHandoffPanel extends ConsumerWidget {
  final POSExperienceDiagnostics diagnostics;
  final POSDiagnosticsHandoffCopy? onCopy;

  const POSDiagnosticsHandoffPanel({
    super.key,
    required this.diagnostics,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = POSDiagnosticsActivitySnapshot.fromSources(
      switchHistory: ref.watch(posCommerceChannelSwitchHistoryProvider),
      switchActionHistory: ref.watch(posSwitchActionHistoryProvider),
      outbox: ref.watch(posOrderSaveOutboxProvider),
    );

    return POSDiagnosticsHandoffCard(
      summary: POSDiagnosticsHandoffSummary.from(
        diagnostics: diagnostics,
        activity: snapshot,
      ),
      onCopy: onCopy,
    );
  }
}

class POSDiagnosticsHandoffCard extends StatelessWidget {
  final POSDiagnosticsHandoffSummary summary;
  final POSDiagnosticsHandoffCopy? onCopy;

  const POSDiagnosticsHandoffCard({
    super.key,
    required this.summary,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _HandoffColors.resolve(theme.colorScheme, summary.severity);

    return POSSurface(
      border: Border.all(color: colors.border),
      color: colors.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              POSIconBadge(
                icon: _severityIcon(summary.severity),
                backgroundColor: colors.badgeBackground,
                foregroundColor: colors.badgeForeground,
              ),
              const SizedBox(width: POSUiTokens.gapLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Handoff summary',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _displayTitle(summary.title),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.headline,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: POSUiTokens.gap),
              POSActionButton(
                icon: const Icon(Icons.copy_all_outlined, size: 18),
                label: 'Copy',
                tooltip: 'Copy diagnostics handoff',
                variant: POSActionButtonVariant.tonal,
                onPressed: () => _copySummary(context),
              ),
            ],
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          Wrap(
            spacing: POSUiTokens.gap,
            runSpacing: POSUiTokens.gap,
            children:
                summary.metrics
                    .map(
                      (metric) => POSMetricPill(
                        label: metric.label,
                        value: metric.value,
                        backgroundColor: colors.metricBackground,
                        foregroundColor: colors.metricForeground,
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          _HandoffFactStrip(facts: summary.facts),
          if (summary.hasAttentionItems) ...[
            const SizedBox(height: POSUiTokens.gapLarge),
            _AttentionPreview(items: summary.attentionItems),
          ],
        ],
      ),
    );
  }

  Future<void> _copySummary(BuildContext context) async {
    final copy = onCopy ?? _copyToClipboard;
    await copy(summary.toShareText());
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Diagnostics handoff copied')),
      );
  }
}

class _HandoffFactStrip extends StatelessWidget {
  final List<POSDiagnosticsHandoffMetric> facts;

  const _HandoffFactStrip({required this.facts});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children: [
        _HandoffFactPill(
          icon: Icons.point_of_sale_outlined,
          label: _factValue('Mode'),
        ),
        _HandoffFactPill(
          icon: Icons.inventory_2_outlined,
          label: _factValue('Pack'),
        ),
        _HandoffFactPill(
          icon: Icons.view_quilt_outlined,
          label: _factValue('Layout'),
        ),
        _HandoffFactPill(
          icon: Icons.storefront_outlined,
          label: _factValue('Channel'),
        ),
      ],
    );
  }

  String _factValue(String label) {
    for (final fact in facts) {
      if (fact.label == label) return fact.value;
    }

    return 'Not supplied';
  }
}

class _HandoffFactPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HandoffFactPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return POSSwitchPreviewPill(
      icon: icon,
      label: label,
      tone: POSSwitchPreviewTone.neutral,
    );
  }
}

class _AttentionPreview extends StatelessWidget {
  final List<String> items;

  const _AttentionPreview({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = items.take(2).toList();
    final hiddenCount = items.length - visible.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Needs review',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        for (final item in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.priority_high_outlined,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (hiddenCount > 0)
          Text(
            '+$hiddenCount more',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
            ),
          ),
      ],
    );
  }
}

class _HandoffColors {
  final Color surface;
  final Color border;
  final Color badgeBackground;
  final Color badgeForeground;
  final Color metricBackground;
  final Color metricForeground;

  const _HandoffColors({
    required this.surface,
    required this.border,
    required this.badgeBackground,
    required this.badgeForeground,
    required this.metricBackground,
    required this.metricForeground,
  });

  factory _HandoffColors.resolve(
    ColorScheme colorScheme,
    POSDiagnosticsHandoffSeverity severity,
  ) {
    switch (severity) {
      case POSDiagnosticsHandoffSeverity.ready:
        return _HandoffColors(
          surface: colorScheme.secondaryContainer.withValues(alpha: 0.18),
          border: colorScheme.secondary.withValues(alpha: 0.24),
          badgeBackground: colorScheme.secondaryContainer,
          badgeForeground: colorScheme.onSecondaryContainer,
          metricBackground: colorScheme.surface,
          metricForeground: colorScheme.onSurface,
        );
      case POSDiagnosticsHandoffSeverity.review:
        return _HandoffColors(
          surface: colorScheme.tertiaryContainer.withValues(alpha: 0.18),
          border: colorScheme.tertiary.withValues(alpha: 0.24),
          badgeBackground: colorScheme.tertiaryContainer,
          badgeForeground: colorScheme.onTertiaryContainer,
          metricBackground: colorScheme.surface,
          metricForeground: colorScheme.onSurface,
        );
      case POSDiagnosticsHandoffSeverity.attention:
        return _HandoffColors(
          surface: colorScheme.errorContainer.withValues(alpha: 0.14),
          border: colorScheme.error.withValues(alpha: 0.24),
          badgeBackground: colorScheme.errorContainer,
          badgeForeground: colorScheme.onErrorContainer,
          metricBackground: colorScheme.surface,
          metricForeground: colorScheme.onSurface,
        );
    }
  }
}

IconData _severityIcon(POSDiagnosticsHandoffSeverity severity) {
  switch (severity) {
    case POSDiagnosticsHandoffSeverity.ready:
      return Icons.verified_outlined;
    case POSDiagnosticsHandoffSeverity.review:
      return Icons.rate_review_outlined;
    case POSDiagnosticsHandoffSeverity.attention:
      return Icons.support_agent_outlined;
  }
}

String _displayTitle(String title) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? 'Diagnostics handoff' : trimmed;
}

Future<void> _copyToClipboard(String text) {
  return Clipboard.setData(ClipboardData(text: text));
}
