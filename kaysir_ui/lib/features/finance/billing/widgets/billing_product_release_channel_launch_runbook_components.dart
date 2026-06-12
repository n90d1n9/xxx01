import 'package:flutter/material.dart';

import 'billing_empty_state.dart';
import 'billing_product_release_channel_launch_runbook.dart';

class BillingProductReleaseChannelLaunchRunbookGroupList
    extends StatelessWidget {
  final BillingProductReleaseChannelLaunchRunbook runbook;

  const BillingProductReleaseChannelLaunchRunbookGroupList({
    super.key,
    required this.runbook,
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
              runbook.groups
                  .map(
                    (group) => SizedBox(
                      width: itemWidth,
                      child: _RunbookGroupSection(group: group),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}

class BillingProductReleaseChannelLaunchRunbookEmptyState
    extends StatelessWidget {
  const BillingProductReleaseChannelLaunchRunbookEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const BillingEmptyState(
      message: 'No channel launch runbook steps are available yet.',
    );
  }
}

class _RunbookGroupSection extends StatelessWidget {
  final BillingProductReleaseChannelLaunchRunbookGroup group;

  const _RunbookGroupSection({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.near_me_outlined,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.destinationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      group.summaryLabel,
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
              _RunbookStatusPill(
                label: '${group.actionableStepCount}/${group.stepCount}',
                isReady: group.needsWorkStepCount == 0,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...group.steps.map(_RunbookStepTile.new),
        ],
      ),
    );
  }
}

class _RunbookStepTile extends StatelessWidget {
  final BillingProductReleaseChannelLaunchRunbookStep step;

  const _RunbookStepTile(this.step);

  @override
  Widget build(BuildContext context) {
    final checklistItems = step.checklistItems.take(3).toList(growable: false);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                step.isActionable
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color:
                    step.isActionable
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      step.detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _RunbookStatusPill(
                label: step.callToActionLabel,
                isReady: step.isActionable,
              ),
            ],
          ),
          if (checklistItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...checklistItems.map(_RunbookChecklistItem.new),
          ],
        ],
      ),
    );
  }
}

class _RunbookChecklistItem extends StatelessWidget {
  final String label;

  const _RunbookChecklistItem(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_outlined, size: 14, color: Color(0xFF64748B)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 11,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RunbookStatusPill extends StatelessWidget {
  final String label;
  final bool isReady;

  const _RunbookStatusPill({required this.label, required this.isReady});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isReady ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isReady ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isReady ? const Color(0xFF047857) : const Color(0xFFB91C1C),
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
