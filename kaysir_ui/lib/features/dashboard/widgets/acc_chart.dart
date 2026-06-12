import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/dashboard_data.dart';

class AcquisitionChart extends StatelessWidget {
  final AcquisitionData acquisitionData;

  const AcquisitionChart({super.key, required this.acquisitionData});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sections = [
      _AcquisitionSection(
        label: 'Reviews',
        value: acquisitionData.reviews,
        color: const Color(0xFFC2185B),
      ),
      _AcquisitionSection(
        label: 'Education',
        value: acquisitionData.education,
        color: const Color(0xFFB26A00),
      ),
      _AcquisitionSection(
        label: 'Deals',
        value: acquisitionData.deals,
        color: const Color(0xFF1769AA),
      ),
    ];

    return SizedBox(
      height: 300,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chart = PieChart(
            PieChartData(
              sections:
                  sections
                      .map(
                        (section) => PieChartSectionData(
                          value: section.value.toDouble(),
                          color: section.color,
                          title: '${section.value}%',
                          radius: 74,
                          titleStyle: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                      .toList(),
              centerSpaceRadius: 42,
              sectionsSpace: 3,
              borderData: FlBorderData(show: false),
            ),
          );
          final metrics = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                sections
                    .map(
                      (section) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _MetricRow(section: section),
                      ),
                    )
                    .toList(),
          );

          if (constraints.maxWidth < 420) {
            return Column(children: [Expanded(child: chart), metrics]);
          }

          return Row(
            children: [
              Expanded(child: chart),
              const SizedBox(width: 12),
              Expanded(child: metrics),
            ],
          );
        },
      ),
    );
  }
}

class _AcquisitionSection {
  final String label;
  final int value;
  final Color color;

  const _AcquisitionSection({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _MetricRow extends StatelessWidget {
  final _AcquisitionSection section;

  const _MetricRow({required this.section});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: section.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            section.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          '${section.value}%',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
