import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_portfolio_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentDevelopmentPortfolioTile extends StatelessWidget {
  final IncomingTalentDevelopmentPortfolio portfolio;

  const IncomingTalentDevelopmentPortfolioTile({
    super.key,
    required this.portfolio,
  });

  @override
  Widget build(BuildContext context) {
    final color = _stageColor(portfolio.stage);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_turned_in_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      portfolio.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      portfolio.competencyFocus,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: portfolio.stage.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: portfolio.readinessRatio,
            color: color,
            label: '${portfolio.sourceReadinessScore}% source readiness',
          ),
          const SizedBox(height: 10),
          Text(
            portfolio.growthGoal,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            portfolio.learningPath,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: portfolio.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: portfolio.portfolioOwnerName,
              ),
              TalentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: portfolio.mentorName,
              ),
              TalentMetaLabel(
                icon: Icons.repeat_outlined,
                label: portfolio.reviewCadence.label,
              ),
              TalentMetaLabel(
                icon: Icons.fact_check_outlined,
                label: DateFormat('MMM d').format(portfolio.nextReviewDate),
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: portfolio.priority.label,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _stageColor(IncomingTalentDevelopmentPortfolioStage stage) {
  return switch (stage) {
    IncomingTalentDevelopmentPortfolioStage.designing => const Color(
      0xFF2563EB,
    ),
    IncomingTalentDevelopmentPortfolioStage.active => const Color(0xFF059669),
    IncomingTalentDevelopmentPortfolioStage.watch => const Color(0xFFDC2626),
    IncomingTalentDevelopmentPortfolioStage.graduated => const Color(
      0xFF15803D,
    ),
  };
}
