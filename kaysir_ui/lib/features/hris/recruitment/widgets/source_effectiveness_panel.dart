import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/recruitment_models.dart';
import 'recruitment_status_styles.dart';

class SourceEffectivenessPanel extends StatelessWidget {
  final List<SourceMetric> sources;

  const SourceEffectivenessPanel({super.key, required this.sources});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Source Effectiveness',
      icon: Icons.campaign_outlined,
      subtitle: '${sources.length} sources',
      emptyMessage: 'No source metrics match filters',
      children: sources.isEmpty ? [] : [_SourceWrap(sources: sources)],
    );
  }
}

class _SourceWrap extends StatelessWidget {
  final List<SourceMetric> sources;

  const _SourceWrap({required this.sources});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              sources.map((source) {
                return SizedBox(
                  width:
                      isCompact
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 12) / 2,
                  child: _SourceCard(source: source),
                );
              }).toList(),
        );
      },
    );
  }
}

class _SourceCard extends StatelessWidget {
  final SourceMetric source;

  const _SourceCard({required this.source});

  @override
  Widget build(BuildContext context) {
    final color = sourceHealthColor(source.health);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  source.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(
                label: sourceHealthLabel(source.health),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: source.hireRate,
            color: color,
            label:
                '${source.candidates} candidates, ${source.interviews} interviews, ${source.hires} hires',
          ),
          const SizedBox(height: 8),
          Text(
            '\$${source.costPerHire} cost per hire',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}
