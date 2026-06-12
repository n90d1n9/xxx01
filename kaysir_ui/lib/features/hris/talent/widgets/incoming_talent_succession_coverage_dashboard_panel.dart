import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_coverage_dashboard_provider.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionCoverageDashboardPanel extends ConsumerWidget {
  const IncomingTalentSuccessionCoverageDashboardPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(
      incomingTalentSuccessionCoverageDashboardProvider,
    );
    final healthColor = _healthColor(dashboard.health);

    return HrisSectionPanel(
      icon: Icons.dashboard_customize_outlined,
      title: 'Succession coverage dashboard',
      subtitle: dashboard.nextAction,
      emptyMessage: 'No succession coverage signals',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Coverage',
              value: '${dashboard.coverageScore}%',
            ),
            HrisMetricStripItem(
              label: 'Ready now',
              value: '${dashboard.readyNowCount}',
            ),
            HrisMetricStripItem(
              label: 'Open actions',
              value: '${dashboard.openBenchActionCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  HrisStatusPill(
                    label: dashboard.health.label,
                    color: healthColor,
                  ),
                  const Spacer(),
                  Text(
                    '${dashboard.attentionSignalCount} signals',
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
                value: dashboard.coverageRatio,
                color: healthColor,
                label:
                    '${dashboard.coverageScore}% weighted succession coverage',
              ),
              const SizedBox(height: 12),
              HrisProgressBar(
                value: dashboard.readyCoverageRatio,
                color: HrisColors.primary,
                label:
                    '${dashboard.readyCoverageCount} of ${dashboard.totalCandidates} successors ready now or soon',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  TalentMetaLabel(
                    icon: Icons.groups_2_outlined,
                    label: '${dashboard.totalCandidates} candidates',
                  ),
                  TalentMetaLabel(
                    icon: Icons.rocket_launch_outlined,
                    label: '${dashboard.activationPlanCount} activations',
                  ),
                  TalentMetaLabel(
                    icon: Icons.monitor_heart_outlined,
                    label:
                        '${dashboard.transitionPulseAtRiskCount}/${dashboard.transitionPulseCount} transition risks',
                  ),
                  TalentMetaLabel(
                    icon: Icons.account_tree_outlined,
                    label:
                        '${dashboard.criticalBenchPlanCount}/${dashboard.benchPlanCount} bench critical',
                  ),
                  TalentMetaLabel(
                    icon: Icons.fact_check_outlined,
                    label:
                        '${dashboard.benchCheckInAttentionCount} bench check-ins need attention',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _healthColor(IncomingTalentSuccessionCoverageHealth health) {
    return switch (health) {
      IncomingTalentSuccessionCoverageHealth.strong => Colors.green,
      IncomingTalentSuccessionCoverageHealth.watch => Colors.amber,
      IncomingTalentSuccessionCoverageHealth.critical => Colors.red,
    };
  }
}
