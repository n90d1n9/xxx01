import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_invoice_attention.dart';
import '../models/billing_tenant_preferences.dart';
import '../states/billing_dashboard_provider.dart';
import '../utils/billing_invoice_attention.dart';

class BillingInvoiceAttentionSection extends ConsumerWidget {
  final String tenantId;
  final BillingTenantPreferences preferences;
  final DateTime? now;
  final ValueChanged<BillingInvoiceAttentionItem>? onItemSelected;

  const BillingInvoiceAttentionSection({
    super.key,
    required this.tenantId,
    this.preferences = const BillingTenantPreferences(),
    this.now,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(billingInvoicesProvider(tenantId));

    return invoicesAsync.when(
      loading:
          () => const _BillingInvoiceAttentionFrame(
            child: SizedBox(
              height: 112,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      error:
          (error, stack) => const _BillingInvoiceAttentionFrame(
            child: SizedBox(
              height: 112,
              child: Center(
                child: Text('Unable to load receivables attention'),
              ),
            ),
          ),
      data: (invoices) {
        final summary = summarizeBillingInvoiceAttention(
          invoices,
          preferences: preferences,
          now: now,
        );

        return BillingInvoiceAttentionPanel(
          summary: summary,
          onItemSelected: onItemSelected,
        );
      },
    );
  }
}

class BillingInvoiceAttentionPanel extends StatelessWidget {
  final BillingInvoiceAttentionSummary summary;
  final ValueChanged<BillingInvoiceAttentionItem>? onItemSelected;

  const BillingInvoiceAttentionPanel({
    super.key,
    required this.summary,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _BillingInvoiceAttentionVisuals.fromLevel(summary.level);

    return _BillingInvoiceAttentionFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: visuals.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(visuals.icon, color: visuals.color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Receivables attention',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.headline,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.supportingText,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 640;
              final tiles =
                  summary.items
                      .map(
                        (item) => _BillingInvoiceAttentionTile(
                          item: item,
                          onTap:
                              onItemSelected == null || item.count == 0
                                  ? null
                                  : () => onItemSelected?.call(item),
                        ),
                      )
                      .toList();

              if (isCompact) {
                return Column(
                  children:
                      tiles
                          .map(
                            (tile) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: tile,
                            ),
                          )
                          .toList(),
                );
              }

              return Row(
                children: List.generate(tiles.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == tiles.length - 1 ? 0 : 10,
                      ),
                      child: tiles[index],
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BillingInvoiceAttentionFrame extends StatelessWidget {
  final Widget child;

  const _BillingInvoiceAttentionFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}

class _BillingInvoiceAttentionTile extends StatelessWidget {
  final BillingInvoiceAttentionItem item;
  final VoidCallback? onTap;

  const _BillingInvoiceAttentionTile({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final visuals = _BillingInvoiceAttentionVisuals.fromLevel(item.level);
    final icon = _iconFor(item.kind);

    return Material(
      color: visuals.surfaceColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 92),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: visuals.borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: visuals.color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(BillingInvoiceAttentionKind kind) {
    switch (kind) {
      case BillingInvoiceAttentionKind.overdue:
        return Icons.report_problem_outlined;
      case BillingInvoiceAttentionKind.dueSoon:
        return Icons.schedule_outlined;
      case BillingInvoiceAttentionKind.openBalance:
        return Icons.account_balance_wallet_outlined;
    }
  }
}

class _BillingInvoiceAttentionVisuals {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color borderColor;

  const _BillingInvoiceAttentionVisuals({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.borderColor,
  });

  factory _BillingInvoiceAttentionVisuals.fromLevel(
    BillingInvoiceAttentionLevel level,
  ) {
    switch (level) {
      case BillingInvoiceAttentionLevel.urgent:
        return const _BillingInvoiceAttentionVisuals(
          icon: Icons.notification_important_outlined,
          color: Color(0xFFBE123C),
          backgroundColor: Color(0xFFFFE4E6),
          surfaceColor: Color(0xFFFFF7F7),
          borderColor: Color(0xFFFECDD3),
        );
      case BillingInvoiceAttentionLevel.watch:
        return const _BillingInvoiceAttentionVisuals(
          icon: Icons.mark_email_unread_outlined,
          color: Color(0xFFB45309),
          backgroundColor: Color(0xFFFEF3C7),
          surfaceColor: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFDE68A),
        );
      case BillingInvoiceAttentionLevel.calm:
        return const _BillingInvoiceAttentionVisuals(
          icon: Icons.insights_outlined,
          color: Color(0xFF2563EB),
          backgroundColor: Color(0xFFDBEAFE),
          surfaceColor: Color(0xFFF8FAFC),
          borderColor: Color(0xFFBFDBFE),
        );
      case BillingInvoiceAttentionLevel.settled:
        return const _BillingInvoiceAttentionVisuals(
          icon: Icons.verified_outlined,
          color: Color(0xFF047857),
          backgroundColor: Color(0xFFD1FAE5),
          surfaceColor: Color(0xFFF7FEFB),
          borderColor: Color(0xFFA7F3D0),
        );
    }
  }
}
