import 'package:flutter/material.dart';
import 'package:tenun/tenun.dart' hide FontWeight;

class TenunChartJsonForceTypeExample extends StatelessWidget {
  const TenunChartJsonForceTypeExample({super.key});

  static const Map<String, dynamic> _barPayload = {
    'type': 'bar',
    'title': {'text': 'Quarterly Revenue'},
    'legend': {'show': true},
    'tooltip': {'show': true},
    'xAxis': {
      'show': true,
      'data': ['Q1', 'Q2', 'Q3', 'Q4'],
    },
    'yAxis': {'show': true},
    'series': [
      {
        'name': 'Revenue',
        'data': [120, 165, 142, 190],
        'color': '#3178C6',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final panels = [
              _buildPanel(
                context,
                title: 'Blocked target',
                description:
                    'Treemap needs cross-shape conversion. The widget blocks it and renders custom UI.',
                child: TenunChartJson(
                  jsonConfig: _barPayload,
                  forceType: ChartType.treemap,
                  forceCrossShapeSwitch: false,
                  switchErrorBuilder: _buildSwitchFallback,
                ),
              ),
              _buildPanel(
                context,
                title: 'Allowed with force',
                description:
                    'Enable forceCrossShapeSwitch when lossy conversion is an intentional product choice.',
                child: const TenunChartJson(
                  jsonConfig: _barPayload,
                  forceType: ChartType.treemap,
                  forceCrossShapeSwitch: true,
                ),
              ),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TenunChartJson forceType guardrails',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'The same JSON payload is previewed as a treemap. One panel keeps the switch strict; the other opts into force conversion.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                if (compact)
                  Column(
                    children: [
                      panels[0],
                      const SizedBox(height: 12),
                      panels[1],
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: panels[0]),
                      const SizedBox(width: 12),
                      Expanded(child: panels[1]),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Widget _buildPanel(
    BuildContext context, {
    required String title,
    required String description,
    required Widget child,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(description, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            SizedBox(height: 260, child: child),
          ],
        ),
      ),
    );
  }

  static Widget _buildSwitchFallback(
    BuildContext context,
    ValidatedChartTypeSwitchResult result,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.error.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: colors.error),
          const SizedBox(height: 8),
          Text(
            'Custom switch fallback',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Blocked target: ${result.targetTypeString}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            result.renderSafetyMessage,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
