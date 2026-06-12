import 'package:flutter/material.dart';

import '../models/billing_invoice_activity.dart';
import '../models/billing_tenant_preferences.dart';
import '../utils/billing_formatters.dart';

class BillingInvoiceActivityTimeline extends StatelessWidget {
  final List<BillingInvoiceActivityEntry> entries;
  final BillingTenantPreferences preferences;
  final String title;

  const BillingInvoiceActivityTimeline({
    super.key,
    required this.entries,
    this.preferences = const BillingTenantPreferences(),
    this.title = 'Activity',
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timeline_outlined,
                color: Color(0xFF475569),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(entries.length, (index) {
            return _BillingInvoiceActivityTile(
              entry: entries[index],
              preferences: preferences,
              isLast: index == entries.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _BillingInvoiceActivityTile extends StatelessWidget {
  final BillingInvoiceActivityEntry entry;
  final BillingTenantPreferences preferences;
  final bool isLast;

  const _BillingInvoiceActivityTile({
    required this.entry,
    required this.preferences,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _BillingInvoiceActivityVisuals.fromEntry(entry);
    final date = entry.date;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 34,
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: visuals.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(visuals.icon, color: visuals.color, size: 16),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 44,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  color: const Color(0xFFE2E8F0),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: visuals.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: visuals.borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _BillingInvoiceActivityStatePill(
                          label: visuals.label,
                          color: visuals.color,
                          backgroundColor: visuals.backgroundColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.description,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    if (date != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        formatBillingDate(date, preferences: preferences),
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BillingInvoiceActivityStatePill extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;

  const _BillingInvoiceActivityStatePill({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _BillingInvoiceActivityVisuals {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color borderColor;

  const _BillingInvoiceActivityVisuals({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.borderColor,
  });

  factory _BillingInvoiceActivityVisuals.fromEntry(
    BillingInvoiceActivityEntry entry,
  ) {
    final state = entry.state;

    switch (state) {
      case BillingInvoiceActivityState.completed:
        return _BillingInvoiceActivityVisuals(
          icon: _iconFor(entry.type),
          label: 'Done',
          color: const Color(0xFF047857),
          backgroundColor: const Color(0xFFD1FAE5),
          surfaceColor: const Color(0xFFF7FEFB),
          borderColor: const Color(0xFFA7F3D0),
        );
      case BillingInvoiceActivityState.current:
        return _BillingInvoiceActivityVisuals(
          icon: _iconFor(entry.type),
          label: 'Now',
          color: const Color(0xFF2563EB),
          backgroundColor: const Color(0xFFDBEAFE),
          surfaceColor: const Color(0xFFF8FAFC),
          borderColor: const Color(0xFFBFDBFE),
        );
      case BillingInvoiceActivityState.upcoming:
        return _BillingInvoiceActivityVisuals(
          icon: _iconFor(entry.type),
          label: 'Next',
          color: const Color(0xFFB45309),
          backgroundColor: const Color(0xFFFEF3C7),
          surfaceColor: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFDE68A),
        );
      case BillingInvoiceActivityState.blocked:
        return _BillingInvoiceActivityVisuals(
          icon: _iconFor(entry.type),
          label: 'Closed',
          color: const Color(0xFFBE123C),
          backgroundColor: const Color(0xFFFFE4E6),
          surfaceColor: const Color(0xFFFFF7F7),
          borderColor: const Color(0xFFFECDD3),
        );
    }
  }

  static IconData _iconFor(BillingInvoiceActivityType type) {
    switch (type) {
      case BillingInvoiceActivityType.draftReview:
        return Icons.edit_note_outlined;
      case BillingInvoiceActivityType.issued:
        return Icons.receipt_long_outlined;
      case BillingInvoiceActivityType.paymentDue:
        return Icons.schedule_outlined;
      case BillingInvoiceActivityType.paymentReceived:
        return Icons.verified_outlined;
      case BillingInvoiceActivityType.overdueNotice:
        return Icons.notification_important_outlined;
      case BillingInvoiceActivityType.reminder:
        return Icons.mark_email_unread_outlined;
      case BillingInvoiceActivityType.collectPayment:
        return Icons.payments_outlined;
      case BillingInvoiceActivityType.voided:
        return Icons.block_outlined;
    }
  }
}
