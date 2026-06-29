import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/performance_models.dart';
import 'performance_meta_label.dart';
import 'performance_status_styles.dart';

class RetentionRiskPanel extends StatelessWidget {
  final List<RetentionRisk> risks;

  const RetentionRiskPanel({super.key, required this.risks});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Retention Risk',
      icon: Icons.health_and_safety_outlined,
      subtitle: '${risks.length} risks',
      emptyMessage: 'No retention risks match filters',
      children: risks.isEmpty ? [] : [_RetentionWrap(risks: risks)],
    );
  }
}

class _RetentionWrap extends StatelessWidget {
  final List<RetentionRisk> risks;

  const _RetentionWrap({required this.risks});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              risks.map((risk) {
                return SizedBox(
                  width:
                      isCompact
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 12) / 2,
                  child: _RetentionCard(risk: risk),
                );
              }).toList(),
        );
      },
    );
  }
}

class _RetentionCard extends StatelessWidget {
  final RetentionRisk risk;

  const _RetentionCard({required this.risk});

  @override
  Widget build(BuildContext context) {
    final color = retentionRiskColor(risk.level);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  risk.employeeName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(
                label: retentionRiskLabel(risk.level),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 8),
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
              PerformanceMetaLabel(
                icon: Icons.person_outline,
                label: risk.actionOwner,
              ),
              PerformanceMetaLabel(
                icon: Icons.calendar_today_outlined,
                label: DateFormat('MMM d').format(risk.reviewDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
