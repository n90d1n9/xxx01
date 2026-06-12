import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/engagement_models.dart';
import 'engagement_meta_label.dart';
import 'engagement_status_styles.dart';

class WellbeingPanel extends StatelessWidget {
  final List<WellbeingRisk> risks;

  const WellbeingPanel({super.key, required this.risks});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Wellbeing Watch',
      icon: Icons.spa_outlined,
      subtitle: '${risks.length} risks',
      emptyMessage: 'No wellbeing risks match filters',
      children: risks.map((risk) => _WellbeingTile(risk: risk)).toList(),
    );
  }
}

class _WellbeingTile extends StatelessWidget {
  final WellbeingRisk risk;

  const _WellbeingTile({required this.risk});

  @override
  Widget build(BuildContext context) {
    final color = wellbeingRiskColor(risk.level);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.spa_outlined, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        risk.employeeName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    HrisStatusPill(
                      label: wellbeingRiskLabel(risk.level),
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  risk.signal,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    EngagementMetaLabel(
                      icon: Icons.person_outline,
                      label: risk.ownerName,
                    ),
                    EngagementMetaLabel(
                      icon: Icons.calendar_today_outlined,
                      label: DateFormat('MMM d').format(risk.reviewDate),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
