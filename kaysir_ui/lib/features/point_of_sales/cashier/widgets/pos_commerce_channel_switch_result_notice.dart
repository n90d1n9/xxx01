import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../experiences/pos_commerce_channel.dart';
import '../experiences/pos_commerce_channel_controller.dart';
import '../experiences/pos_commerce_channel_switch_result.dart';
import '../states/pos_layout_provider.dart';
import 'pos_inline_notice.dart';
import 'pos_switch_preview_pill.dart';

class POSCommerceChannelSwitchResultBanner extends ConsumerWidget {
  final EdgeInsetsGeometry padding;
  final Duration transitionDuration;

  const POSCommerceChannelSwitchResultBanner({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(12, 8, 12, 0),
    this.transitionDuration = const Duration(milliseconds: 180),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(posCommerceChannelSwitchResultProvider);

    return AnimatedSwitcher(
      duration: transitionDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child:
          result == null
              ? const SizedBox.shrink(key: ValueKey('empty-switch-result'))
              : Padding(
                key: ValueKey(result.summaryLabel),
                padding: padding,
                child: POSCommerceChannelSwitchResultNotice(
                  result: result,
                  onDismiss:
                      () =>
                          ref
                              .read(
                                posCommerceChannelSwitchResultProvider.notifier,
                              )
                              .state = null,
                ),
              ),
    );
  }
}

class POSCommerceChannelSwitchResultNotice extends StatelessWidget {
  final POSCommerceChannelSwitchResult result;
  final VoidCallback? onDismiss;
  final int maxItems;
  final bool includePassiveItems;

  const POSCommerceChannelSwitchResultNotice({
    super.key,
    required this.result,
    this.onDismiss,
    this.maxItems = 4,
    this.includePassiveItems = false,
  });

  @override
  Widget build(BuildContext context) {
    final visibleItems = _visibleItems().toList();
    final hiddenCount = _importantItems().length - visibleItems.length;

    return POSInlineNotice(
      tone: result.requiresAttention ? POSInlineNoticeTone.warning : _tone,
      icon:
          result.requiresAttention
              ? Icons.assignment_late_outlined
              : _headlineIcon,
      title: result.summaryLabel,
      message: _message,
      trailing:
          onDismiss == null
              ? null
              : IconButton(
                tooltip: 'Dismiss switch result',
                icon: const Icon(Icons.close),
                onPressed: onDismiss,
              ),
      footer:
          visibleItems.isEmpty
              ? null
              : Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final item in visibleItems)
                    Tooltip(
                      message: _tooltipFor(item),
                      child: POSSwitchPreviewPill(
                        icon: _iconFor(item),
                        label: _labelFor(item),
                        tone: _toneFor(item),
                      ),
                    ),
                  if (hiddenCount > 0)
                    POSSwitchPreviewPill(
                      icon: Icons.more_horiz,
                      label: '+$hiddenCount more',
                    ),
                ],
              ),
    );
  }

  POSInlineNoticeTone get _tone {
    if (!result.hasChanges) return POSInlineNoticeTone.info;
    return POSInlineNoticeTone.success;
  }

  IconData get _headlineIcon {
    if (!result.hasChanges) return Icons.radio_button_checked;
    if (result.completedRequirementCount > 0) {
      return Icons.fact_check_outlined;
    }
    return Icons.check_circle_outline;
  }

  String get _message {
    final layout = result.plan.targetLayoutPreference.label;
    final fulfillment = result.resolvedFulfillmentContext.mode.label;

    if (result.requiresAttention) {
      return '$layout layout, $fulfillment fulfillment. Review the remaining '
          'details before closing the order.';
    }

    if (!result.hasChanges) {
      return '$layout layout and $fulfillment fulfillment are already ready.';
    }

    final orderMessage =
        result.activeOrderPreserved
            ? ' Active order was preserved.'
            : ' Workspace is ready.';

    return '$layout layout, $fulfillment fulfillment.$orderMessage';
  }

  Iterable<POSCommerceChannelSwitchResultItem> _visibleItems() sync* {
    var yielded = 0;
    for (final item in _importantItems()) {
      if (yielded >= maxItems) break;
      yield item;
      yielded += 1;
    }
  }

  List<POSCommerceChannelSwitchResultItem> _importantItems() {
    final items = result.items.where(_shouldShow).toList();
    items.sort((a, b) {
      final priority = _priorityFor(a).compareTo(_priorityFor(b));
      if (priority != 0) return priority;
      return result.items.indexOf(a).compareTo(result.items.indexOf(b));
    });
    return items;
  }

  bool _shouldShow(POSCommerceChannelSwitchResultItem item) {
    if (includePassiveItems) return true;
    if (item.changed || item.requiresAttention) return true;
    return item.role == POSCommerceChannelSwitchResultItemRole.activeOrder &&
        result.activeOrderPreserved;
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
      final label = item.label.replaceFirst(' completed', '');
      return '$label: $value';
    }

    return item.label;
  }

  String _tooltipFor(POSCommerceChannelSwitchResultItem item) {
    final value = item.message.trim();
    if (value.isEmpty) return item.label;
    return '${item.label}: $value';
  }

  IconData _iconFor(POSCommerceChannelSwitchResultItem item) {
    switch (item.role) {
      case POSCommerceChannelSwitchResultItemRole.channel:
        return item.changed ? Icons.swap_horiz_outlined : Icons.store_outlined;
      case POSCommerceChannelSwitchResultItemRole.layout:
        return item.changed
            ? Icons.splitscreen_outlined
            : Icons.dashboard_outlined;
      case POSCommerceChannelSwitchResultItemRole.activeOrder:
        return Icons.receipt_long_outlined;
      case POSCommerceChannelSwitchResultItemRole.fulfillment:
        return item.requiresAttention
            ? Icons.assignment_late_outlined
            : Icons.local_shipping_outlined;
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
        return item.changed
            ? POSSwitchPreviewTone.positive
            : POSSwitchPreviewTone.neutral;
      case POSCommerceChannelSwitchResultItemRole.layout:
      case POSCommerceChannelSwitchResultItemRole.fulfillment:
        return item.changed
            ? POSSwitchPreviewTone.neutral
            : POSSwitchPreviewTone.neutral;
      case POSCommerceChannelSwitchResultItemRole.activeOrder:
        return result.activeOrderPreserved
            ? POSSwitchPreviewTone.positive
            : POSSwitchPreviewTone.neutral;
      case POSCommerceChannelSwitchResultItemRole.unresolvedRequirement:
        return POSSwitchPreviewTone.warning;
    }
  }
}
