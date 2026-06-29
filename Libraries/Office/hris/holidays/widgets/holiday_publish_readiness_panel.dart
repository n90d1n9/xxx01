import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_publish_models.dart';

class HolidayPublishReadinessPanel extends StatelessWidget {
  final HolidayPublishReadiness readiness;

  const HolidayPublishReadinessPanel({super.key, required this.readiness});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.rocket_launch_outlined,
      title: 'Publish readiness',
      subtitle: 'Calendar release checklist',
      children: [
        _PublishScoreSurface(readiness: readiness),
        for (final item in readiness.items) _PublishChecklistTile(item: item),
      ],
    );
  }
}

class _PublishScoreSurface extends StatelessWidget {
  final HolidayPublishReadiness readiness;

  const _PublishScoreSurface({required this.readiness});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final score = _PublishScore(readiness: readiness);
          final stats = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PublishStat(
                icon: Icons.block_outlined,
                label: 'Blocked',
                value: '${readiness.blockedCount}',
              ),
              _PublishStat(
                icon: Icons.rate_review_outlined,
                label: 'Review',
                value: '${readiness.attentionCount}',
              ),
              _PublishStat(
                icon: Icons.verified_outlined,
                label: 'Ready',
                value: '${readiness.readyCount}',
              ),
            ],
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                score,
                const SizedBox(height: 14),
                stats,
                const SizedBox(height: 12),
                _NextAction(readiness: readiness),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              score,
              const SizedBox(width: 20),
              Expanded(child: stats),
              const SizedBox(width: 20),
              Expanded(child: _NextAction(readiness: readiness)),
            ],
          );
        },
      ),
    );
  }
}

class _PublishScore extends StatelessWidget {
  final HolidayPublishReadiness readiness;

  const _PublishScore({required this.readiness});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(readiness.status);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${readiness.readinessScore}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              readiness.status.label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Release score',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
          ],
        ),
      ],
    );
  }
}

class _NextAction extends StatelessWidget {
  final HolidayPublishReadiness readiness;

  const _NextAction({required this.readiness});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.flag_circle_outlined,
          color: HrisColors.primary,
          size: 19,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Next action',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: HrisColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                readiness.nextAction,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PublishStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PublishStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: HrisColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PublishChecklistTile extends StatelessWidget {
  final HolidayPublishChecklistItem item;

  const _PublishChecklistTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              HrisStatusPill(
                label: item.status.label,
                color: _statusColor(item.status),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.detail,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.checklist_rtl_outlined,
                color: HrisColors.muted,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.action,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _statusColor(HolidayPublishStatus status) {
  return switch (status) {
    HolidayPublishStatus.blocked => Colors.red.shade700,
    HolidayPublishStatus.attention => Colors.orange.shade700,
    HolidayPublishStatus.ready => Colors.green.shade700,
  };
}
