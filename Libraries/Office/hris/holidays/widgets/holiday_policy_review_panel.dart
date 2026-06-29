import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_policy_models.dart';

class HolidayPolicyReviewPanel extends StatelessWidget {
  final HolidayPolicyReview review;

  const HolidayPolicyReviewPanel({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.rule_folder_outlined,
      title: 'Policy review',
      subtitle: '${review.checkedRules} automated calendar checks',
      children: [
        _PolicyScoreSurface(review: review),
        if (review.issues.isEmpty)
          const HrisEmptyState(message: 'Holiday policy checks are clear')
        else
          for (final issue in review.issues) _PolicyIssueTile(issue: issue),
      ],
    );
  }
}

class _PolicyScoreSurface extends StatelessWidget {
  final HolidayPolicyReview review;

  const _PolicyScoreSurface({required this.review});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final score = _PolicyScoreBadge(review: review);
          final stats = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PolicyStat(
                icon: Icons.error_outline,
                label: 'Critical',
                value: '${review.criticalCount}',
              ),
              _PolicyStat(
                icon: Icons.warning_amber_outlined,
                label: 'Warnings',
                value: '${review.warningCount}',
              ),
              _PolicyStat(
                icon: Icons.info_outline,
                label: 'Advisory',
                value: '${review.advisoryCount}',
              ),
              _PolicyStat(
                icon: Icons.fact_check_outlined,
                label: 'Checks',
                value: '${review.checkedRules}',
              ),
            ],
          );

          if (constraints.maxWidth < 680) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [score, const SizedBox(height: 14), stats],
            );
          }

          return Row(
            children: [
              score,
              const SizedBox(width: 20),
              Expanded(child: stats),
            ],
          );
        },
      ),
    );
  }
}

class _PolicyScoreBadge extends StatelessWidget {
  final HolidayPolicyReview review;

  const _PolicyScoreBadge({required this.review});

  @override
  Widget build(BuildContext context) {
    final color = _policyColor(review);

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
              '${review.policyScore}',
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
              review.policyLabel,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Policy score',
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

class _PolicyStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PolicyStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 118),
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

class _PolicyIssueTile extends StatelessWidget {
  final HolidayPolicyIssue issue;

  const _PolicyIssueTile({required this.issue});

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
                issue.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              HrisStatusPill(
                label: issue.severity.label,
                color: _severityColor(issue.severity),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            issue.detail,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.checklist_outlined,
                size: 18,
                color: HrisColors.muted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  issue.action,
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

Color _policyColor(HolidayPolicyReview review) {
  if (review.criticalCount > 0 || review.policyScore < 70) {
    return Colors.red.shade700;
  }
  if (review.warningCount > 0 || review.advisoryCount > 0) {
    return Colors.orange.shade700;
  }
  return Colors.green.shade700;
}

Color _severityColor(HolidayPolicyIssueSeverity severity) {
  return switch (severity) {
    HolidayPolicyIssueSeverity.critical => Colors.red.shade700,
    HolidayPolicyIssueSeverity.warning => Colors.orange.shade700,
    HolidayPolicyIssueSeverity.advisory => Colors.blueGrey.shade700,
  };
}
