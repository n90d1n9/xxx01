import 'package:flutter/material.dart';

import '../utils/billing_product_release_channel.dart';
import 'billing_product_release_channel_visuals.dart';

class BillingProductReleaseChannelMatrixGrid extends StatelessWidget {
  final BillingProductReleaseChannelMatrix matrix;

  const BillingProductReleaseChannelMatrixGrid({
    super.key,
    required this.matrix,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 920;
        final itemWidth =
            isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              matrix.rows
                  .map(
                    (row) => SizedBox(
                      width: itemWidth,
                      child: BillingProductReleaseChannelCard(row: row),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}

class BillingProductReleaseChannelCard extends StatelessWidget {
  final BillingProductReleaseChannelRow row;

  const BillingProductReleaseChannelCard({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
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
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.hub_outlined,
                  color: Color(0xFF2563EB),
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.channel.label,
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
                      '${row.channel.surfaceLabel} - ${row.channel.key}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ChannelCountBadge(row: row),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            row.channel.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _ChannelEditionChips(row: row),
          const SizedBox(height: 12),
          _ChannelReadinessSummary(row: row),
        ],
      ),
    );
  }
}

class _ChannelCountBadge extends StatelessWidget {
  final BillingProductReleaseChannelRow row;

  const _ChannelCountBadge({required this.row});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          '${row.targetedCount} targets',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1D4ED8),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ChannelEditionChips extends StatelessWidget {
  final BillingProductReleaseChannelRow row;

  const _ChannelEditionChips({required this.row});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children:
          row.targetedCells
              .map((cell) => _ChannelEditionChip(cell: cell))
              .toList(),
    );
  }
}

class _ChannelEditionChip extends StatelessWidget {
  final BillingProductReleaseChannelCell cell;

  const _ChannelEditionChip({required this.cell});

  @override
  Widget build(BuildContext context) {
    final colors = billingProductReleaseChannelCellColors(cell.state);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              cell.editionPlan.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 6),
            BillingProductReleaseChannelCellBadge(cell: cell),
          ],
        ),
      ),
    );
  }
}

class _ChannelReadinessSummary extends StatelessWidget {
  final BillingProductReleaseChannelRow row;

  const _ChannelReadinessSummary({required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.insights_outlined,
            size: 17,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _summaryLabel(row),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _summaryLabel(BillingProductReleaseChannelRow row) {
    if (row.blockedCount > 0) {
      return '${row.blockedCount} channel targets need blockers cleared.';
    }
    if (row.publishNowCount > 0 && row.reviewCount > 0) {
      return '${row.publishNowCount} can publish; ${row.reviewCount} need review.';
    }
    if (row.reviewCount > 0) {
      return '${row.reviewCount} channel targets need review.';
    }

    return '${row.publishNowCount} channel targets can publish now.';
  }
}
