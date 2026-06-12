import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../experiences/pos_commerce_channel.dart';
import '../experiences/pos_commerce_channel_switch_history.dart';
import '../experiences/pos_commerce_channel_switch_result.dart';
import '../states/pos_layout_provider.dart';
import 'pos_inline_notice.dart';
import 'pos_switch_preview_pill.dart';
import 'pos_ui.dart';

class POSCommerceChannelSwitchHistoryPanel extends ConsumerWidget {
  final int maxEntries;
  final bool showHeader;

  const POSCommerceChannelSwitchHistoryPanel({
    super.key,
    this.maxEntries = 5,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(posCommerceChannelSwitchHistoryProvider);

    return POSCommerceChannelSwitchHistoryList(
      history: history,
      maxEntries: maxEntries,
      showHeader: showHeader,
      onClear:
          history.isEmpty
              ? null
              : () =>
                  ref
                      .read(posCommerceChannelSwitchHistoryProvider.notifier)
                      .clear(),
    );
  }
}

class POSCommerceChannelSwitchHistoryList extends StatelessWidget {
  final POSCommerceChannelSwitchHistory history;
  final int maxEntries;
  final bool showHeader;
  final VoidCallback? onClear;

  const POSCommerceChannelSwitchHistoryList({
    super.key,
    required this.history,
    this.maxEntries = 5,
    this.showHeader = true,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const POSInlineNotice(
        tone: POSInlineNoticeTone.info,
        icon: Icons.history_toggle_off_outlined,
        title: 'No channel switches yet',
        message: 'Recent commerce channel switches will appear here.',
      );
    }

    final entries = history.entries.take(maxEntries).toList();
    final hiddenCount = history.entries.length - entries.length;

    return POSSurface(
      border: Border.all(color: Theme.of(context).dividerColor),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHeader) ...[
            _SwitchHistoryHeader(history: history, onClear: onClear),
            const SizedBox(height: POSUiTokens.gapLarge),
          ] else if (onClear != null) ...[
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Clear switch history',
                icon: const Icon(Icons.clear_all),
                onPressed: onClear,
              ),
            ),
            const SizedBox(height: POSUiTokens.gap),
          ],
          for (var index = 0; index < entries.length; index++) ...[
            if (index > 0) const Divider(height: 18),
            _SwitchHistoryEntryTile(entry: entries[index]),
          ],
          if (hiddenCount > 0) ...[
            const Divider(height: 18),
            Text(
              '+$hiddenCount older ${hiddenCount == 1 ? 'switch' : 'switches'}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SwitchHistoryHeader extends StatelessWidget {
  final POSCommerceChannelSwitchHistory history;
  final VoidCallback? onClear;

  const _SwitchHistoryHeader({required this.history, this.onClear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        POSIconBadge(
          icon: Icons.history_outlined,
          backgroundColor: theme.colorScheme.secondaryContainer,
          foregroundColor: theme.colorScheme.onSecondaryContainer,
        ),
        const SizedBox(width: POSUiTokens.gapLarge),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent channel switches',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _historySummary(history),
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
            tooltip: 'Clear switch history',
            icon: const Icon(Icons.clear_all),
            onPressed: onClear,
          ),
      ],
    );
  }

  String _historySummary(POSCommerceChannelSwitchHistory history) {
    final count = history.entries.length;
    final attention = history.attentionCount;
    final changed = history.changedCount;

    if (attention > 0) {
      return '$count recorded, $attention need attention';
    }

    return '$count recorded, $changed changed workspace';
  }
}

class _SwitchHistoryEntryTile extends StatelessWidget {
  final POSCommerceChannelSwitchHistoryEntry entry;

  const _SwitchHistoryEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = entry.result;
    final attention = entry.requiresAttention;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        POSIconBadge(
          icon:
              attention
                  ? Icons.assignment_late_outlined
                  : Icons.swap_horiz_outlined,
          backgroundColor:
              attention
                  ? theme.colorScheme.tertiaryContainer
                  : theme.colorScheme.primaryContainer,
          foregroundColor:
              attention
                  ? theme.colorScheme.onTertiaryContainer
                  : theme.colorScheme.onPrimaryContainer,
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
                _entryMessage(result),
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
                  for (final item in _visibleItems(result).take(3))
                    POSSwitchPreviewPill(
                      icon: _iconFor(item),
                      label: _labelFor(item),
                      tone: _toneFor(item),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _entryMessage(POSCommerceChannelSwitchResult result) {
    final layout = result.plan.targetLayoutPreference.label;
    final fulfillment = result.resolvedFulfillmentContext.mode.label;

    if (result.requiresAttention) {
      return '$layout layout, $fulfillment fulfillment, review required.';
    }

    if (result.activeOrderPreserved) {
      return '$layout layout, $fulfillment fulfillment, order preserved.';
    }

    return '$layout layout, $fulfillment fulfillment.';
  }

  String _timeLabel(BuildContext context, DateTime value) {
    return TimeOfDay.fromDateTime(value).format(context);
  }

  Iterable<POSCommerceChannelSwitchResultItem> _visibleItems(
    POSCommerceChannelSwitchResult result,
  ) {
    final items =
        result.items
            .where(
              (item) =>
                  item.changed ||
                  item.requiresAttention ||
                  item.role ==
                      POSCommerceChannelSwitchResultItemRole.activeOrder,
            )
            .toList();
    items.sort((a, b) {
      final priority = _priorityFor(a).compareTo(_priorityFor(b));
      if (priority != 0) return priority;
      return result.items.indexOf(a).compareTo(result.items.indexOf(b));
    });
    return items;
  }

  int _priorityFor(POSCommerceChannelSwitchResultItem item) {
    if (item.requiresAttention) return 0;

    switch (item.role) {
      case POSCommerceChannelSwitchResultItemRole.completedRequirement:
        return 1;
      case POSCommerceChannelSwitchResultItemRole.channel:
        return 2;
      case POSCommerceChannelSwitchResultItemRole.layout:
        return 3;
      case POSCommerceChannelSwitchResultItemRole.activeOrder:
        return 4;
      case POSCommerceChannelSwitchResultItemRole.fulfillment:
        return 5;
      case POSCommerceChannelSwitchResultItemRole.unresolvedRequirement:
        return 0;
    }
  }

  String _labelFor(POSCommerceChannelSwitchResultItem item) {
    final value = item.message.trim();
    if (item.role ==
            POSCommerceChannelSwitchResultItemRole.completedRequirement &&
        value.isNotEmpty) {
      return '${item.label.replaceFirst(' completed', '')}: $value';
    }

    return item.label;
  }

  IconData _iconFor(POSCommerceChannelSwitchResultItem item) {
    switch (item.role) {
      case POSCommerceChannelSwitchResultItemRole.channel:
        return Icons.swap_horiz_outlined;
      case POSCommerceChannelSwitchResultItemRole.layout:
        return Icons.splitscreen_outlined;
      case POSCommerceChannelSwitchResultItemRole.activeOrder:
        return Icons.receipt_long_outlined;
      case POSCommerceChannelSwitchResultItemRole.fulfillment:
        return Icons.local_shipping_outlined;
      case POSCommerceChannelSwitchResultItemRole.completedRequirement:
        return Icons.check_circle_outline;
      case POSCommerceChannelSwitchResultItemRole.unresolvedRequirement:
        return Icons.assignment_late_outlined;
    }
  }

  POSSwitchPreviewTone _toneFor(POSCommerceChannelSwitchResultItem item) {
    if (item.requiresAttention) return POSSwitchPreviewTone.warning;

    switch (item.role) {
      case POSCommerceChannelSwitchResultItemRole.channel:
      case POSCommerceChannelSwitchResultItemRole.completedRequirement:
        return POSSwitchPreviewTone.positive;
      case POSCommerceChannelSwitchResultItemRole.layout:
      case POSCommerceChannelSwitchResultItemRole.fulfillment:
        return POSSwitchPreviewTone.neutral;
      case POSCommerceChannelSwitchResultItemRole.activeOrder:
        return POSSwitchPreviewTone.positive;
      case POSCommerceChannelSwitchResultItemRole.unresolvedRequirement:
        return POSSwitchPreviewTone.warning;
    }
  }
}
