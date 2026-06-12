import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/payable_cash_forecast.dart';
import '../states/payable_cash_forecast_provider.dart';

class PayableCashForecastCard extends ConsumerWidget {
  const PayableCashForecastCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecast = ref.watch(payableCashForecastProvider);
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('MMM d');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ForecastHeader(
              forecast: forecast,
              currency: currency,
              dateFormat: dateFormat,
            ),
            const SizedBox(height: 16),
            for (final bucket in forecast.buckets) ...[
              _ForecastBucketBar(
                bucket: bucket,
                currency: currency,
                maxAmount: forecast.totalOpen,
              ),
              if (bucket != forecast.buckets.last) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _ForecastHeader extends StatelessWidget {
  final PayableCashForecast forecast;
  final NumberFormat currency;
  final DateFormat dateFormat;

  const _ForecastHeader({
    required this.forecast,
    required this.currency,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextDueDate = forecast.nextDueDate;

    return Row(
      children: [
        Icon(Icons.account_balance_outlined, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Cash Forecast',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _ForecastMetric(
          label: '30 Days',
          value: currency.format(forecast.next30Days),
        ),
        const SizedBox(width: 16),
        _ForecastMetric(
          label: 'Next Due',
          value: nextDueDate == null ? '-' : dateFormat.format(nextDueDate),
        ),
      ],
    );
  }
}

class _ForecastMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ForecastMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        Text(
          value,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ForecastBucketBar extends StatelessWidget {
  final PayableCashForecastBucket bucket;
  final NumberFormat currency;
  final double maxAmount;

  const _ForecastBucketBar({
    required this.bucket,
    required this.currency,
    required this.maxAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _bucketColor(theme.colorScheme, bucket.id);
    final fill =
        maxAmount <= 0
            ? 0.0
            : (bucket.amount / maxAmount).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                bucket.label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              currency.format(bucket.amount),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: fill,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _billCountLabel(bucket.billCount),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Color _bucketColor(ColorScheme colorScheme, String bucketId) {
    switch (bucketId) {
      case PayableCashForecastBucketIds.dueNow:
        return Colors.red;
      case PayableCashForecastBucketIds.next7Days:
        return Colors.deepOrange;
      case PayableCashForecastBucketIds.days8To14:
        return Colors.amber.shade700;
      case PayableCashForecastBucketIds.days15To30:
        return Colors.teal;
      case PayableCashForecastBucketIds.after30Days:
        return Colors.blueGrey;
      default:
        return colorScheme.primary;
    }
  }

  String _billCountLabel(int count) {
    return count == 1 ? '1 bill' : '$count bills';
  }
}
