import 'package:flutter/material.dart';

import '../../cashier/widgets/pos_inline_notice.dart';
import '../utils/order_save_outbox_freshness.dart';

class OrderSaveOutboxFreshnessNotice extends StatelessWidget {
  final POSOrderSaveOutboxFreshnessState freshnessState;

  const OrderSaveOutboxFreshnessNotice({
    super.key,
    required this.freshnessState,
  });

  @override
  Widget build(BuildContext context) {
    if (!freshnessState.shouldSurface) return const SizedBox.shrink();

    return POSInlineNotice(
      tone: _tone(),
      icon: _icon(),
      title: freshnessState.title,
      message: freshnessState.message,
    );
  }

  POSInlineNoticeTone _tone() {
    switch (freshnessState.level) {
      case POSOrderSaveOutboxFreshnessLevel.fresh:
        return POSInlineNoticeTone.info;
      case POSOrderSaveOutboxFreshnessLevel.aging:
        return POSInlineNoticeTone.info;
      case POSOrderSaveOutboxFreshnessLevel.stale:
        return freshnessState.hasStaleFailed
            ? POSInlineNoticeTone.danger
            : POSInlineNoticeTone.warning;
    }
  }

  IconData _icon() {
    switch (freshnessState.level) {
      case POSOrderSaveOutboxFreshnessLevel.fresh:
        return Icons.schedule_outlined;
      case POSOrderSaveOutboxFreshnessLevel.aging:
        return Icons.hourglass_bottom_outlined;
      case POSOrderSaveOutboxFreshnessLevel.stale:
        return freshnessState.hasStaleFailed
            ? Icons.sync_problem_outlined
            : Icons.schedule_send_outlined;
    }
  }
}
