import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_health_dashboard_models.dart';
import '../states/incoming_talent_health_dashboard_provider.dart';
import 'incoming_talent_health_signal_tile.dart';
import 'talent_meta_label.dart';

class IncomingTalentHealthDashboardPanel extends ConsumerWidget {
  const IncomingTalentHealthDashboardPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(incomingTalentHealthDashboardProvider);
    final color = incomingTalentHealthStatusColor(dashboard.status);

    return HrisSectionPanel(
      icon: Icons.monitor_heart_outlined,
      title: 'Talent health dashboard',
      subtitle: dashboard.nextAction,
      emptyMessage: 'No talent health signals',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Health',
              value: '${dashboard.healthScore}%',
            ),
            HrisMetricStripItem(
              label: 'Signals',
              value: '${dashboard.attentionSignalCount}',
            ),
            HrisMetricStripItem(
              label: 'Support',
              value: '${dashboard.openCareerSupportActions}',
            ),
            HrisMetricStripItem(
              label: 'Outcomes',
              value: '${dashboard.developmentOutcomeAttentionCount}',
            ),
            HrisMetricStripItem(
              label: 'Milestones',
              value: '${dashboard.programMilestoneRevisions}',
            ),
            HrisMetricStripItem(
              label: 'Complete',
              value: '${dashboard.roleReadyProgramCompletions}',
            ),
            HrisMetricStripItem(
              label: 'Promo follow-ups',
              value: '${dashboard.promotionFollowUpAttentionCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  HrisStatusPill(label: dashboard.status.label, color: color),
                  const Spacer(),
                  Text(
                    '${dashboard.totalPortfolios} IDP portfolios',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: HrisColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              HrisProgressBar(
                value: dashboard.healthRatio,
                color: color,
                label: '${dashboard.healthScore}% weighted health score',
              ),
              const SizedBox(height: 12),
              HrisProgressBar(
                value: _confidenceRatio(dashboard.averageConfidenceScore),
                color: HrisColors.primary,
                label:
                    '${dashboard.averageConfidenceScore.toStringAsFixed(1)} average check-in confidence',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  TalentMetaLabel(
                    icon: Icons.add_road_outlined,
                    label:
                        '${dashboard.atRiskRoadmaps}/${dashboard.totalRoadmaps} roadmaps risk',
                  ),
                  TalentMetaLabel(
                    icon: Icons.assignment_turned_in_outlined,
                    label:
                        '${dashboard.watchPortfolios} IDP portfolios on watch',
                  ),
                  TalentMetaLabel(
                    icon: Icons.account_tree_outlined,
                    label:
                        '${dashboard.blockedCareerPaths}/${dashboard.totalCareerPaths} career paths blocked',
                  ),
                  TalentMetaLabel(
                    icon: Icons.build_circle_outlined,
                    label:
                        '${dashboard.criticalCareerSupportActions} critical career support actions',
                  ),
                  TalentMetaLabel(
                    icon: Icons.insights_outlined,
                    label:
                        '${dashboard.monitorCareerSupportOutcomes} support outcomes on watch',
                  ),
                  TalentMetaLabel(
                    icon: Icons.fact_check_outlined,
                    label:
                        '${dashboard.programMilestoneRevisions}/${dashboard.totalProgramMilestones} milestone revisions',
                  ),
                  TalentMetaLabel(
                    icon: Icons.event_note_outlined,
                    label:
                        '${dashboard.duePortfolioReviews} portfolio reviews due',
                  ),
                  TalentMetaLabel(
                    icon: Icons.pending_actions_outlined,
                    label: '${dashboard.dueProgramMilestones} milestones due',
                  ),
                  TalentMetaLabel(
                    icon: Icons.workspace_premium_outlined,
                    label:
                        '${dashboard.programCompletionExtensions}/${dashboard.totalProgramCompletions} completion extensions',
                  ),
                  TalentMetaLabel(
                    icon: Icons.verified_outlined,
                    label:
                        '${dashboard.roleReadyProgramCompletions} role-ready credentials',
                  ),
                  TalentMetaLabel(
                    icon: Icons.report_problem_outlined,
                    label:
                        '${dashboard.criticalInterventions} critical interventions',
                  ),
                  TalentMetaLabel(
                    icon: Icons.rule_folder_outlined,
                    label:
                        '${dashboard.releaseEvidenceInterventions} release evidence interventions',
                  ),
                  TalentMetaLabel(
                    icon: Icons.health_and_safety_outlined,
                    label:
                        '${dashboard.developmentOutcomeAttentionCount} intervention outcomes on watch',
                  ),
                  TalentMetaLabel(
                    icon: Icons.trending_up_outlined,
                    label:
                        '${dashboard.averageDevelopmentOutcomeConfidence.toStringAsFixed(1)} outcome confidence',
                  ),
                  TalentMetaLabel(
                    icon: Icons.add_task_outlined,
                    label:
                        '${dashboard.developmentFollowUpDueSoonCount} intervention follow-ups due',
                  ),
                  TalentMetaLabel(
                    icon: Icons.fact_check_outlined,
                    label:
                        '${dashboard.developmentFollowUpResolutionAttentionCount} follow-up reviews on watch',
                  ),
                  TalentMetaLabel(
                    icon: Icons.trending_up_outlined,
                    label:
                        '${dashboard.averageDevelopmentFollowUpResolutionConfidence.toStringAsFixed(1)} review confidence',
                  ),
                  if (dashboard.developmentFollowUpOverdueCount > 0)
                    TalentMetaLabel(
                      icon: Icons.event_busy_outlined,
                      label:
                          '${dashboard.developmentFollowUpOverdueCount} follow-ups overdue',
                    ),
                  if (dashboard.developmentFollowUpEscalatedCount > 0)
                    TalentMetaLabel(
                      icon: Icons.report_problem_outlined,
                      label:
                          '${dashboard.developmentFollowUpEscalatedCount} follow-ups escalated',
                    ),
                  if (dashboard.developmentFollowUpResolutionEscalatedCount > 0)
                    TalentMetaLabel(
                      icon: Icons.report_problem_outlined,
                      label:
                          '${dashboard.developmentFollowUpResolutionEscalatedCount} follow-up reviews escalated',
                    ),
                  if (dashboard.totalPromotionStabilizationReviews > 0)
                    TalentMetaLabel(
                      icon: Icons.rate_review_outlined,
                      label:
                          '${dashboard.promotionStabilizationAttentionCount} promotion reviews on watch',
                    ),
                  if (dashboard.totalPromotionFollowUpActions > 0)
                    TalentMetaLabel(
                      icon: Icons.playlist_add_check_outlined,
                      label:
                          '${dashboard.openPromotionFollowUpActions} promotion follow-ups open',
                    ),
                  if (dashboard.criticalPromotionFollowUpActions > 0)
                    TalentMetaLabel(
                      icon: Icons.priority_high_outlined,
                      label:
                          '${dashboard.criticalPromotionFollowUpActions} critical promotion follow-ups',
                    ),
                  if (dashboard.promotionFollowUpDueSoonCount > 0)
                    TalentMetaLabel(
                      icon: Icons.event_note_outlined,
                      label:
                          '${dashboard.promotionFollowUpDueSoonCount} promotion follow-ups due',
                    ),
                  if (dashboard.totalPromotionFollowUpResolutions > 0)
                    TalentMetaLabel(
                      icon: Icons.fact_check_outlined,
                      label:
                          '${dashboard.promotionResolutionAttentionCount} promotion resolutions on watch',
                    ),
                  if (dashboard.promotionResolutionEscalatedCount > 0 ||
                      dashboard.promotionResolutionReopenedCount > 0)
                    TalentMetaLabel(
                      icon: Icons.report_problem_outlined,
                      label:
                          '${dashboard.promotionResolutionEscalatedCount} escalated, ${dashboard.promotionResolutionReopenedCount} reopened promotion resolutions',
                    ),
                ],
              ),
            ],
          ),
        ),
        for (final signal in dashboard.signals)
          IncomingTalentHealthSignalTile(signal: signal),
      ],
    );
  }
}

Color incomingTalentHealthStatusColor(IncomingTalentHealthStatus status) {
  return switch (status) {
    IncomingTalentHealthStatus.strong => const Color(0xFF15803D),
    IncomingTalentHealthStatus.watch => const Color(0xFFD97706),
    IncomingTalentHealthStatus.critical => const Color(0xFFDC2626),
  };
}

double _confidenceRatio(double confidenceScore) {
  final ratio = confidenceScore / 5;
  if (ratio < 0) return 0;
  if (ratio > 1) return 1;
  return ratio;
}
