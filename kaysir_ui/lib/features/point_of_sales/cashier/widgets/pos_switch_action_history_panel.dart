import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../experiences/pos_switch_action_history.dart';
import '../experiences/pos_switch_action_history_filter.dart';
import '../experiences/pos_switch_action_history_insight.dart';
import 'pos_filter_search_field.dart';
import 'pos_inline_notice.dart';
import 'pos_switch_action_insight_banner.dart';
import 'pos_switch_action_presentation.dart';
import 'pos_switch_preview_pill.dart';
import 'pos_switch_status_filter_bar.dart';
import 'pos_ui.dart';

class POSSwitchActionHistoryPanel extends ConsumerWidget {
  final int maxEntries;
  final bool showHeader;

  const POSSwitchActionHistoryPanel({
    super.key,
    this.maxEntries = 5,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(posSwitchActionHistoryProvider);

    return POSSwitchActionHistoryList(
      history: history,
      maxEntries: maxEntries,
      showHeader: showHeader,
      onClear:
          history.isEmpty
              ? null
              : () => ref.read(posSwitchActionHistoryProvider.notifier).clear(),
    );
  }
}

const posSwitchActionHistoryScrollKey = ValueKey(
  'pos_switch_action_history_scroll',
);

class POSSwitchActionHistoryList extends StatelessWidget {
  final POSSwitchActionHistory history;
  final int maxEntries;
  final bool showHeader;
  final VoidCallback? onClear;

  const POSSwitchActionHistoryList({
    super.key,
    required this.history,
    this.maxEntries = 5,
    this.showHeader = true,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return POSSwitchActionHistoryFilteredList(
      history: history,
      maxEntries: maxEntries,
      showHeader: showHeader,
      onClear: onClear,
    );
  }
}

class POSSwitchActionHistoryFilteredList extends StatefulWidget {
  final POSSwitchActionHistory history;
  final int maxEntries;
  final bool showHeader;
  final VoidCallback? onClear;

  const POSSwitchActionHistoryFilteredList({
    super.key,
    required this.history,
    this.maxEntries = 5,
    this.showHeader = true,
    this.onClear,
  });

  @override
  State<POSSwitchActionHistoryFilteredList> createState() =>
      _POSSwitchActionHistoryFilteredListState();
}

class _POSSwitchActionHistoryFilteredListState
    extends State<POSSwitchActionHistoryFilteredList> {
  final _searchController = TextEditingController();
  POSSwitchActionHistoryFilter _filter = const POSSwitchActionHistoryFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = widget.history;
    if (history.isEmpty) {
      return const POSInlineNotice(
        tone: POSInlineNoticeTone.info,
        icon: Icons.history_toggle_off_outlined,
        title: 'No switch attempts yet',
        message:
            'Mode, runtime pack, and channel switch attempts will appear here.',
      );
    }

    final filteredEntries = _filter.apply(history.entries);
    final entries = filteredEntries.take(widget.maxEntries).toList();
    final hiddenCount = filteredEntries.length - entries.length;
    final queryFilter = const POSSwitchActionHistoryFilter().copyWith(
      query: _filter.query,
    );
    final counts = POSSwitchActionHistoryFilterCounts.fromEntries(
      history.entries.where(queryFilter.matches),
    );
    final insight = POSSwitchActionHistoryInsight.fromHistory(history);

    return POSSurface(
      border: Border.all(color: Theme.of(context).dividerColor),
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        key: posSwitchActionHistoryScrollKey,
        padding: EdgeInsets.zero,
        primary: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showHeader) ...[
              _SwitchActionHistoryHeader(
                insight: insight,
                visibleCount: filteredEntries.length,
                onClear: widget.onClear,
              ),
              const SizedBox(height: POSUiTokens.gapLarge),
              POSSwitchActionInsightBanner(insight: insight),
              const SizedBox(height: POSUiTokens.gapLarge),
            ] else if (widget.onClear != null) ...[
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Clear switch attempts',
                  icon: const Icon(Icons.clear_all),
                  onPressed: widget.onClear,
                ),
              ),
              const SizedBox(height: POSUiTokens.gap),
            ],
            POSFilterSearchField(
              controller: _searchController,
              hintText: 'Search switch attempts',
              onChanged:
                  (query) => setState(() {
                    _filter = _filter.copyWith(query: query);
                  }),
            ),
            const SizedBox(height: POSUiTokens.gap),
            POSSwitchStatusFilterBar<POSSwitchActionHistoryFilterStatus>(
              selectedValue: _filter.status,
              options: POSSwitchStatusFilterOption.fromValues(
                POSSwitchActionHistoryFilterStatus.values,
                labelBuilder: (status) => status.label,
                countBuilder: counts.countFor,
              ),
              onSelected:
                  (status) => setState(() {
                    _filter = _filter.copyWith(status: status);
                  }),
            ),
            const SizedBox(height: POSUiTokens.gapLarge),
            if (entries.isEmpty)
              const POSInlineNotice(
                tone: POSInlineNoticeTone.info,
                icon: Icons.search_off_outlined,
                title: 'No matching switch attempts',
                message: 'Adjust the search or switch filter.',
              )
            else ...[
              for (var index = 0; index < entries.length; index++) ...[
                if (index > 0) const Divider(height: 18),
                _SwitchActionHistoryEntryTile(entry: entries[index]),
              ],
              if (hiddenCount > 0) ...[
                const Divider(height: 18),
                Text(
                  '+$hiddenCount older ${hiddenCount == 1 ? 'attempt' : 'attempts'}',
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

class _SwitchActionHistoryHeader extends StatelessWidget {
  final POSSwitchActionHistoryInsight insight;
  final int visibleCount;
  final VoidCallback? onClear;

  const _SwitchActionHistoryHeader({
    required this.insight,
    required this.visibleCount,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        POSIconBadge(
          icon: Icons.rule_folder_outlined,
          backgroundColor: theme.colorScheme.tertiaryContainer,
          foregroundColor: theme.colorScheme.onTertiaryContainer,
        ),
        const SizedBox(width: POSUiTokens.gapLarge),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent switch attempts',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _historySummary(insight, visibleCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (onClear != null)
          IconButton(
            tooltip: 'Clear switch attempts',
            icon: const Icon(Icons.clear_all),
            onPressed: onClear,
          ),
      ],
    );
  }

  String _historySummary(
    POSSwitchActionHistoryInsight insight,
    int visibleCount,
  ) {
    final count = insight.recordedCount;
    if (visibleCount != count) {
      return '$visibleCount visible of $count recorded';
    }

    return insight.summaryLabel;
  }
}

class _SwitchActionHistoryEntryTile extends StatelessWidget {
  final POSSwitchActionHistoryEntry entry;

  const _SwitchActionHistoryEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = entry.result;
    final attention = entry.requiresAttention;
    final presentation = POSSwitchActionPresentation.fromResult(result);
    final colors = presentation.badgePalette(theme.colorScheme);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        POSIconBadge(
          icon: presentation.outcomeIcon,
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
                      entry.summaryLabel,
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
                presentation.historyMessage,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (presentation.operatorGuidance != null) ...[
                const SizedBox(height: 6),
                _SwitchActionGuidanceRow(
                  message: presentation.operatorGuidance!,
                  tone: presentation.outcomeTone,
                ),
              ],
              const SizedBox(height: POSUiTokens.gap),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  POSSwitchPreviewPill(
                    icon: presentation.kindIcon,
                    label: result.kindLabel,
                    tone: POSSwitchPreviewTone.neutral,
                  ),
                  POSSwitchPreviewPill(
                    icon: presentation.outcomeIcon,
                    label: result.outcomeLabel,
                    tone: presentation.outcomeTone,
                  ),
                  if (attention)
                    const POSSwitchPreviewPill(
                      icon: Icons.priority_high_outlined,
                      label: 'Attention',
                      tone: POSSwitchPreviewTone.danger,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _timeLabel(BuildContext context, DateTime value) {
    return TimeOfDay.fromDateTime(value).format(context);
  }
}

class _SwitchActionGuidanceRow extends StatelessWidget {
  final String message;
  final POSSwitchPreviewTone tone;

  const _SwitchActionGuidanceRow({required this.message, required this.tone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = POSSwitchPreviewPillColors.resolve(theme.colorScheme, tone);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.tips_and_updates_outlined,
          size: 15,
          color: colors.foreground,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
