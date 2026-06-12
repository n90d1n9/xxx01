import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../order/states/order_save_outbox_provider.dart';
import '../experiences/pos_commerce_channel_switch_history.dart';
import '../experiences/pos_diagnostics_activity.dart';
import '../experiences/pos_diagnostics_activity_insight.dart';
import '../experiences/pos_switch_action_history.dart';
import 'pos_diagnostics_activity_insight_banner.dart';
import 'pos_filter_search_field.dart';
import 'pos_inline_notice.dart';
import 'pos_switch_preview_pill.dart';
import 'pos_switch_status_filter_bar.dart';
import 'pos_ui.dart';

class POSDiagnosticsActivityPanel extends ConsumerWidget {
  final int maxEntries;

  const POSDiagnosticsActivityPanel({super.key, this.maxEntries = 6});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = POSDiagnosticsActivitySnapshot.fromSources(
      switchHistory: ref.watch(posCommerceChannelSwitchHistoryProvider),
      switchActionHistory: ref.watch(posSwitchActionHistoryProvider),
      outbox: ref.watch(posOrderSaveOutboxProvider),
    );

    return POSDiagnosticsActivityList(
      snapshot: snapshot,
      maxEntries: maxEntries,
    );
  }
}

const posDiagnosticsActivityScrollKey = ValueKey(
  'pos_diagnostics_activity_scroll',
);

class POSDiagnosticsActivityList extends StatefulWidget {
  final POSDiagnosticsActivitySnapshot snapshot;
  final int maxEntries;

  const POSDiagnosticsActivityList({
    super.key,
    required this.snapshot,
    this.maxEntries = 6,
  });

  @override
  State<POSDiagnosticsActivityList> createState() =>
      _POSDiagnosticsActivityListState();
}

class _POSDiagnosticsActivityListState
    extends State<POSDiagnosticsActivityList> {
  final _searchController = TextEditingController();
  POSDiagnosticsActivityFilter _filter = const POSDiagnosticsActivityFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.snapshot.isEmpty) {
      return const POSInlineNotice(
        tone: POSInlineNoticeTone.info,
        icon: Icons.manage_search_outlined,
        title: 'No POS activity yet',
        message:
            'Switch attempts, channel changes, and order sync events will appear here.',
      );
    }

    final visibleEntries = widget.snapshot.apply(_filter);
    final limitedEntries = visibleEntries.take(widget.maxEntries).toList();
    final hiddenCount = visibleEntries.length - limitedEntries.length;
    final counts = widget.snapshot.countsForQuery(_filter.query);
    final insight = POSDiagnosticsActivityInsight.fromSnapshot(widget.snapshot);

    return POSSurface(
      border: Border.all(color: Theme.of(context).dividerColor),
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        key: posDiagnosticsActivityScrollKey,
        padding: EdgeInsets.zero,
        primary: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            POSDiagnosticsActivityInsightBanner(insight: insight),
            const SizedBox(height: POSUiTokens.gapLarge),
            POSFilterSearchField(
              controller: _searchController,
              hintText: 'Search activity',
              onChanged:
                  (query) => setState(() {
                    _filter = _filter.copyWith(query: query);
                  }),
            ),
            const SizedBox(height: POSUiTokens.gap),
            POSSwitchStatusFilterBar<POSDiagnosticsActivityFilterStatus>(
              selectedValue: _filter.status,
              options: POSSwitchStatusFilterOption.fromValues(
                POSDiagnosticsActivityFilterStatus.values,
                labelBuilder: (status) => status.label,
                countBuilder: counts.countFor,
              ),
              onSelected:
                  (status) => setState(() {
                    _filter = _filter.copyWith(status: status);
                  }),
            ),
            const SizedBox(height: POSUiTokens.gapLarge),
            if (limitedEntries.isEmpty)
              const POSInlineNotice(
                tone: POSInlineNoticeTone.info,
                icon: Icons.search_off_outlined,
                title: 'No matching activity',
                message: 'Adjust the search or activity filter.',
              )
            else ...[
              for (var index = 0; index < limitedEntries.length; index++) ...[
                if (index > 0) const Divider(height: 18),
                _DiagnosticsActivityRow(entry: limitedEntries[index]),
              ],
              if (hiddenCount > 0) ...[
                const Divider(height: 18),
                Text(
                  '+$hiddenCount older ${hiddenCount == 1 ? 'event' : 'events'}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _DiagnosticsActivityRow extends StatelessWidget {
  final POSDiagnosticsActivityEntry entry;

  const _DiagnosticsActivityRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _ActivityColors.resolve(theme.colorScheme, entry);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        POSIconBadge(
          icon: _sourceIcon(entry),
          backgroundColor: colors.background,
          foregroundColor: colors.foreground,
          size: 32,
          iconSize: 18,
        ),
        const SizedBox(width: POSUiTokens.gapLarge),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: POSUiTokens.gap),
                  Text(
                    _timeLabel(context, entry.occurredAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                entry.detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: POSUiTokens.gap),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  POSSwitchPreviewPill(
                    icon: _sourceIcon(entry),
                    label: entry.source.label,
                    tone: _severityTone(entry),
                  ),
                  if (entry.requiresAttention)
                    const POSSwitchPreviewPill(
                      icon: Icons.priority_high_outlined,
                      label: 'Attention',
                      tone: POSSwitchPreviewTone.danger,
                    )
                  else if (entry.requiresReview)
                    const POSSwitchPreviewPill(
                      icon: Icons.pending_actions_outlined,
                      label: 'Review',
                      tone: POSSwitchPreviewTone.warning,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _sourceIcon(POSDiagnosticsActivityEntry entry) {
    switch (entry.source) {
      case POSDiagnosticsActivitySource.channelSwitch:
        return Icons.swap_horiz_outlined;
      case POSDiagnosticsActivitySource.switchAction:
        switch (entry.severity) {
          case POSDiagnosticsActivitySeverity.attention:
            return Icons.rule_folder_outlined;
          case POSDiagnosticsActivitySeverity.review:
            return Icons.pending_actions_outlined;
          case POSDiagnosticsActivitySeverity.ready:
            return Icons.published_with_changes_outlined;
        }
      case POSDiagnosticsActivitySource.orderSync:
        return entry.requiresAttention
            ? Icons.sync_problem_outlined
            : Icons.cloud_sync_outlined;
    }
  }

  String _timeLabel(BuildContext context, DateTime value) {
    return TimeOfDay.fromDateTime(value).format(context);
  }

  POSSwitchPreviewTone _severityTone(POSDiagnosticsActivityEntry entry) {
    switch (entry.severity) {
      case POSDiagnosticsActivitySeverity.attention:
        return POSSwitchPreviewTone.danger;
      case POSDiagnosticsActivitySeverity.review:
        return POSSwitchPreviewTone.warning;
      case POSDiagnosticsActivitySeverity.ready:
        return POSSwitchPreviewTone.neutral;
    }
  }
}

class _ActivityColors {
  final Color background;
  final Color foreground;

  const _ActivityColors({required this.background, required this.foreground});

  factory _ActivityColors.resolve(
    ColorScheme colorScheme,
    POSDiagnosticsActivityEntry entry,
  ) {
    if (entry.requiresAttention) {
      return _ActivityColors(
        background: colorScheme.errorContainer,
        foreground: colorScheme.onErrorContainer,
      );
    }
    if (entry.requiresReview) {
      return _ActivityColors(
        background: colorScheme.tertiaryContainer,
        foreground: colorScheme.onTertiaryContainer,
      );
    }

    switch (entry.source) {
      case POSDiagnosticsActivitySource.channelSwitch:
        return _ActivityColors(
          background: colorScheme.primaryContainer,
          foreground: colorScheme.onPrimaryContainer,
        );
      case POSDiagnosticsActivitySource.switchAction:
        return _ActivityColors(
          background: colorScheme.tertiaryContainer,
          foreground: colorScheme.onTertiaryContainer,
        );
      case POSDiagnosticsActivitySource.orderSync:
        return _ActivityColors(
          background: colorScheme.secondaryContainer,
          foreground: colorScheme.onSecondaryContainer,
        );
    }
  }
}
