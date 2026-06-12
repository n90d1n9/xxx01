import 'package:flutter/material.dart';

import '../models/billing_invoice_issue_outbox_view_state.dart';

class BillingInvoiceIssueOutboxActiveViewBanner extends StatelessWidget {
  final BillingInvoiceIssueOutboxViewState viewState;
  final int visibleCount;
  final int totalCount;
  final VoidCallback onReset;

  const BillingInvoiceIssueOutboxActiveViewBanner({
    super.key,
    required this.viewState,
    required this.visibleCount,
    required this.totalCount,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final countLabel =
        totalCount == 0 ? '0 commands' : '$visibleCount of $totalCount shown';
    final activeColor =
        viewState.isDefault ? const Color(0xFF334155) : const Color(0xFF2563EB);

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: viewState.isDefault ? Colors.white : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              viewState.isDefault
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.visibility_outlined, size: 17, color: activeColor),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              viewState.activeLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: activeColor,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF94A3B8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              countLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (!viewState.isDefault) ...[
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Reset issue outbox view',
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt_outlined, size: 18),
              color: const Color(0xFF2563EB),
              constraints: const BoxConstraints.tightFor(width: 30, height: 30),
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
