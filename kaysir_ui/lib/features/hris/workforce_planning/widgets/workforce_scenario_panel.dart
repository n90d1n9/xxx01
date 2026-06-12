import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/workforce_planning_models.dart';
import 'workforce_planning_status_styles.dart';

class WorkforceScenarioPanel extends StatelessWidget {
  final List<WorkforceScenario> scenarios;

  const WorkforceScenarioPanel({super.key, required this.scenarios});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.account_tree_outlined,
      title: 'Planning Scenarios',
      subtitle: '${scenarios.length} scenarios',
      emptyMessage: 'No matching planning scenarios',
      children:
          scenarios
              .map((scenario) => _ScenarioTile(scenario: scenario))
              .toList(),
    );
  }
}

class _ScenarioTile extends StatelessWidget {
  final WorkforceScenario scenario;

  const _ScenarioTile({required this.scenario});

  @override
  Widget build(BuildContext context) {
    final confidenceColor = scenarioConfidenceColor(scenario.confidence);
    final currency = NumberFormat.compactCurrency(
      symbol: '\$',
      decimalDigits: 0,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scenario.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      scenario.department,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              HrisStatusPill(
                label: scenarioConfidenceLabel(scenario.confidence),
                color: confidenceColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            scenario.assumption,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF374151)),
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Projected HC',
                value: '${scenario.projectedHeadcount}',
              ),
              HrisMetricStripItem(
                label: 'Cost',
                value: currency.format(scenario.projectedCost),
              ),
              HrisMetricStripItem(
                label: 'Impact',
                value: '${scenario.impactScore}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
