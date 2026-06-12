import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_invoice_aging_bucket.dart';
import '../models/billing_tenant_preferences.dart';
import '../states/billing_dashboard_provider.dart';
import '../utils/billing_invoice_aging_buckets.dart';

class BillingInvoiceAgingBucketSection extends ConsumerWidget {
  final String tenantId;
  final BillingTenantPreferences preferences;
  final DateTime? now;
  final ValueChanged<BillingInvoiceAgingBucket>? onBucketSelected;

  const BillingInvoiceAgingBucketSection({
    super.key,
    required this.tenantId,
    this.preferences = const BillingTenantPreferences(),
    this.now,
    this.onBucketSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(billingInvoicesProvider(tenantId));

    return invoicesAsync.when(
      loading:
          () => const _AgingBucketFrame(
            child: SizedBox(
              height: 112,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      error:
          (error, stack) => const _AgingBucketFrame(
            child: SizedBox(
              height: 112,
              child: Center(child: Text('Unable to load aging distribution')),
            ),
          ),
      data: (invoices) {
        final summary = summarizeBillingInvoiceAgingBuckets(
          invoices,
          preferences: preferences,
          now: now,
        );

        return BillingInvoiceAgingBucketPanel(
          summary: summary,
          onBucketSelected: onBucketSelected,
        );
      },
    );
  }
}

class BillingInvoiceAgingBucketPanel extends StatelessWidget {
  final BillingInvoiceAgingBucketSummary summary;
  final ValueChanged<BillingInvoiceAgingBucket>? onBucketSelected;

  const BillingInvoiceAgingBucketPanel({
    super.key,
    required this.summary,
    this.onBucketSelected,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _AgingRiskVisuals.fromRisk(summary.risk);

    return _AgingBucketFrame(
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
                      'Aging distribution',
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
          _AgingDistributionBar(buckets: summary.buckets),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 680;
              final isTight = constraints.maxWidth < 380;
              final visibleBuckets =
                  isTight
                      ? summary.buckets
                          .where((bucket) => bucket.hasInvoices)
                          .toList()
                      : summary.buckets;
              final buckets =
                  visibleBuckets.isEmpty ? summary.buckets : visibleBuckets;
              final itemWidth =
                  isCompact
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 10,
                children:
                    buckets.map((bucket) {
                      return SizedBox(
                        width: itemWidth,
                        child: _AgingBucketTile(
                          bucket: bucket,
                          onTap:
                              onBucketSelected == null || !bucket.hasInvoices
                                  ? null
                                  : () => onBucketSelected?.call(bucket),
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AgingBucketFrame extends StatelessWidget {
  final Widget child;

  const _AgingBucketFrame({required this.child});

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

class _AgingDistributionBar extends StatelessWidget {
  final List<BillingInvoiceAgingBucket> buckets;

  const _AgingDistributionBar({required this.buckets});

  @override
  Widget build(BuildContext context) {
    final activeBuckets = buckets.where((bucket) => bucket.amount > 0).toList();

    if (activeBuckets.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Container(height: 10, color: const Color(0xFFE2E8F0)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Row(
        children:
            activeBuckets.map((bucket) {
              final visuals = _AgingBucketVisuals.fromKind(bucket.kind);
              return Expanded(
                flex: (bucket.share * 1000).round().clamp(1, 1000),
                child: Container(height: 10, color: visuals.color),
              );
            }).toList(),
      ),
    );
  }
}

class _AgingBucketTile extends StatelessWidget {
  final BillingInvoiceAgingBucket bucket;
  final VoidCallback? onTap;

  const _AgingBucketTile({required this.bucket, this.onTap});

  @override
  Widget build(BuildContext context) {
    final visuals = _AgingBucketVisuals.fromKind(bucket.kind);
    final percent = '${(bucket.share * 100).round()}%';

    return Material(
      color: visuals.surfaceColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: visuals.borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 42,
                decoration: BoxDecoration(
                  color: visuals.color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bucket.label,
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          percent,
                          style: TextStyle(
                            color: visuals.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bucket.amountText,
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
                      '${bucket.count} ${bucket.count == 1 ? 'invoice' : 'invoices'}',
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
}

class _AgingRiskVisuals {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _AgingRiskVisuals({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  factory _AgingRiskVisuals.fromRisk(BillingInvoiceAgingRisk risk) {
    switch (risk) {
      case BillingInvoiceAgingRisk.high:
        return const _AgingRiskVisuals(
          icon: Icons.priority_high_outlined,
          color: Color(0xFFBE123C),
          backgroundColor: Color(0xFFFFE4E6),
        );
      case BillingInvoiceAgingRisk.medium:
        return const _AgingRiskVisuals(
          icon: Icons.warning_amber_outlined,
          color: Color(0xFFB45309),
          backgroundColor: Color(0xFFFEF3C7),
        );
      case BillingInvoiceAgingRisk.low:
        return const _AgingRiskVisuals(
          icon: Icons.insights_outlined,
          color: Color(0xFF2563EB),
          backgroundColor: Color(0xFFDBEAFE),
        );
      case BillingInvoiceAgingRisk.settled:
        return const _AgingRiskVisuals(
          icon: Icons.verified_outlined,
          color: Color(0xFF047857),
          backgroundColor: Color(0xFFD1FAE5),
        );
    }
  }
}

class _AgingBucketVisuals {
  final Color color;
  final Color surfaceColor;
  final Color borderColor;

  const _AgingBucketVisuals({
    required this.color,
    required this.surfaceColor,
    required this.borderColor,
  });

  factory _AgingBucketVisuals.fromKind(BillingInvoiceAgingBucketKind kind) {
    switch (kind) {
      case BillingInvoiceAgingBucketKind.overdue31Plus:
        return const _AgingBucketVisuals(
          color: Color(0xFFBE123C),
          surfaceColor: Color(0xFFFFF7F7),
          borderColor: Color(0xFFFECDD3),
        );
      case BillingInvoiceAgingBucketKind.overdue1To30:
        return const _AgingBucketVisuals(
          color: Color(0xFFB45309),
          surfaceColor: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFDE68A),
        );
      case BillingInvoiceAgingBucketKind.dueSoon:
        return const _AgingBucketVisuals(
          color: Color(0xFF2563EB),
          surfaceColor: Color(0xFFF8FAFC),
          borderColor: Color(0xFFBFDBFE),
        );
      case BillingInvoiceAgingBucketKind.futureDue:
        return const _AgingBucketVisuals(
          color: Color(0xFF047857),
          surfaceColor: Color(0xFFF7FEFB),
          borderColor: Color(0xFFA7F3D0),
        );
    }
  }
}
