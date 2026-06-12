import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_cash_forecast.dart';
import '../models/billing_tenant_preferences.dart';
import '../states/billing_dashboard_provider.dart';
import '../utils/billing_cash_forecast.dart';

class BillingCashForecastSection extends ConsumerWidget {
  final String tenantId;
  final BillingTenantPreferences preferences;
  final DateTime? now;
  final ValueChanged<BillingCashForecastBucket>? onBucketSelected;

  const BillingCashForecastSection({
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
          () => const _CashForecastFrame(
            child: SizedBox(
              height: 112,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      error:
          (error, stack) => const _CashForecastFrame(
            child: SizedBox(
              height: 112,
              child: Center(child: Text('Unable to load cash forecast')),
            ),
          ),
      data: (invoices) {
        final summary = summarizeBillingCashForecast(
          invoices,
          preferences: preferences,
          now: now,
        );

        return BillingCashForecastPanel(
          summary: summary,
          onBucketSelected: onBucketSelected,
        );
      },
    );
  }
}

class BillingCashForecastPanel extends StatelessWidget {
  final BillingCashForecastSummary summary;
  final ValueChanged<BillingCashForecastBucket>? onBucketSelected;

  const BillingCashForecastPanel({
    super.key,
    required this.summary,
    this.onBucketSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _CashForecastFrame(
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
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.savings_outlined,
                  color: Color(0xFF047857),
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cash forecast',
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
          _CashForecastBar(buckets: summary.buckets),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 680;
              final visibleBuckets =
                  constraints.maxWidth < 380
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
                        child: _CashForecastBucketTile(
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

class _CashForecastFrame extends StatelessWidget {
  final Widget child;

  const _CashForecastFrame({required this.child});

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

class _CashForecastBar extends StatelessWidget {
  final List<BillingCashForecastBucket> buckets;

  const _CashForecastBar({required this.buckets});

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
              final visuals = _CashForecastBucketVisuals.fromKind(bucket.kind);
              return Expanded(
                flex: (bucket.share * 1000).round().clamp(1, 1000),
                child: Container(height: 10, color: visuals.color),
              );
            }).toList(),
      ),
    );
  }
}

class _CashForecastBucketTile extends StatelessWidget {
  final BillingCashForecastBucket bucket;
  final VoidCallback? onTap;

  const _CashForecastBucketTile({required this.bucket, this.onTap});

  @override
  Widget build(BuildContext context) {
    final visuals = _CashForecastBucketVisuals.fromKind(bucket.kind);
    final invoiceLabel =
        '${bucket.count} ${bucket.count == 1 ? 'invoice' : 'invoices'}';

    return Material(
      color: visuals.surfaceColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 104),
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
                height: 48,
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
                    Text(
                      bucket.label,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bucket.projectedAmountText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _CashForecastChip(label: invoiceLabel),
                        _CashForecastChip(label: bucket.confidence.label),
                      ],
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

class _CashForecastChip extends StatelessWidget {
  final String label;

  const _CashForecastChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CashForecastBucketVisuals {
  final Color color;
  final Color surfaceColor;
  final Color borderColor;

  const _CashForecastBucketVisuals({
    required this.color,
    required this.surfaceColor,
    required this.borderColor,
  });

  factory _CashForecastBucketVisuals.fromKind(
    BillingCashForecastBucketKind kind,
  ) {
    switch (kind) {
      case BillingCashForecastBucketKind.overdueRecovery:
        return const _CashForecastBucketVisuals(
          color: Color(0xFFBE123C),
          surfaceColor: Color(0xFFFFF7F7),
          borderColor: Color(0xFFFECDD3),
        );
      case BillingCashForecastBucketKind.next7Days:
        return const _CashForecastBucketVisuals(
          color: Color(0xFF047857),
          surfaceColor: Color(0xFFF7FEFB),
          borderColor: Color(0xFFA7F3D0),
        );
      case BillingCashForecastBucketKind.next30Days:
        return const _CashForecastBucketVisuals(
          color: Color(0xFF2563EB),
          surfaceColor: Color(0xFFF8FAFC),
          borderColor: Color(0xFFBFDBFE),
        );
      case BillingCashForecastBucketKind.later:
        return const _CashForecastBucketVisuals(
          color: Color(0xFF7C3AED),
          surfaceColor: Color(0xFFFAF5FF),
          borderColor: Color(0xFFE9D5FF),
        );
    }
  }
}
