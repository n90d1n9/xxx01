import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/workforce_planning_models.dart';
import 'workforce_planning_status_styles.dart';

class CapacityRiskPanel extends StatelessWidget {
  final List<CapacityRisk> risks;

  const CapacityRiskPanel({super.key, required this.risks});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.speed_outlined,
      title: 'Capacity Risks',
      subtitle: '${risks.length} signals',
      emptyMessage: 'No matching capacity risks',
      children: risks.map((risk) => _CapacityRiskTile(risk: risk)).toList(),
    );
  }
}

class _CapacityRiskTile extends StatelessWidget {
  final CapacityRisk risk;

  const _CapacityRiskTile({required this.risk});

  @override
  Widget build(BuildContext context) {
    final riskColor = capacityRiskColor(risk.riskLevel);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  risk.signal,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(
                label: capacityRiskLabel(risk.riskLevel),
                color: riskColor,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${risk.department} - ${risk.ownerName}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: risk.loadRate,
            color: riskColor,
            label:
                '${risk.currentLoad}% current load against ${risk.targetLoad}% target',
          ),
          const SizedBox(height: 10),
          Text(
            risk.mitigation,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF374151)),
          ),
        ],
      ),
    );
  }
}
