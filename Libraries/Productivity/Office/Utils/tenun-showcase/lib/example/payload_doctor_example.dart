import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide Align, FontWeight;

class PayloadDoctorExample extends StatelessWidget {
  const PayloadDoctorExample({super.key});

  static const _scenarios = [
    _PayloadDoctorScenario(
      name: 'Missing sankey links',
      payload: {
        'type': 'sankey',
        'nodes': [
          {'id': 'signup'},
          {'id': 'paid'},
        ],
      },
    ),
    _PayloadDoctorScenario(
      name: 'Repairable renko prices',
      payload: {
        'type': 'renko',
        'brickSize': -2,
        'series': [
          {
            'name': 'Price',
            'data': [100, '101', 'bad', 102],
          },
        ],
      },
    ),
    _PayloadDoctorScenario(
      name: 'Treemap shorthand',
      payload: {
        'type': 'treemap',
        'nodes': [
          {'name': 'Products', 'value': 48},
          {'name': 'Services', 'value': 32},
          {'name': 'Subscriptions', 'value': 20},
        ],
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final reports = [
      for (final scenario in _scenarios)
        _PayloadDoctorScenarioReport(
          scenario: scenario,
          report: ChartPayloadDoctor.inspect(scenario.payload),
        ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payload Doctor', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final item in reports) ...[
            _PayloadDoctorCard(item: item),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PayloadDoctorCard extends StatelessWidget {
  const _PayloadDoctorCard({required this.item});

  final _PayloadDoctorScenarioReport item;

  @override
  Widget build(BuildContext context) {
    final report = item.report;
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _statusIcon(report.status),
                  color: _statusColor(colors, report.status),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.scenario.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        report.summary,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: report.status),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _SmallChip(label: 'type.${report.typeString}'),
                _SmallChip(
                  label:
                      'contract.${report.payloadContract.seriesStrategy.name}',
                ),
                _SmallChip(label: 'api.${report.apiContract.name}'),
                _SmallChip(label: 'shape.${report.inferredShape.name}'),
                _SmallChip(label: 'expected.${report.expectedShape.name}'),
              ],
            ),
            const SizedBox(height: 10),
            _FindingList(findings: report.findings),
            if (report.quickFixes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final fix in report.quickFixes.take(3))
                    _SmallChip(label: fix),
                ],
              ),
            ],
            if (report.normalization.changed) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final path in report.normalization.changedPaths.take(6))
                    _SmallChip(label: path),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FindingList extends StatelessWidget {
  const _FindingList({required this.findings});

  final List<ChartPayloadDoctorFinding> findings;

  @override
  Widget build(BuildContext context) {
    if (findings.isEmpty) {
      return Text(
        'No blocking findings.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final finding in findings.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_severityIcon(finding.severity), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${finding.code}: ${finding.message}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ChartPayloadDoctorStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Chip(
      label: Text(status.name, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: _statusColor(colors, status).withValues(alpha: 0.12),
      side: BorderSide(
        color: _statusColor(colors, status).withValues(alpha: 0.35),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 10)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}

class _PayloadDoctorScenario {
  final String name;
  final Map<String, dynamic> payload;

  const _PayloadDoctorScenario({required this.name, required this.payload});
}

class _PayloadDoctorScenarioReport {
  final _PayloadDoctorScenario scenario;
  final ChartPayloadDoctorReport report;

  const _PayloadDoctorScenarioReport({
    required this.scenario,
    required this.report,
  });
}

IconData _statusIcon(ChartPayloadDoctorStatus status) {
  switch (status) {
    case ChartPayloadDoctorStatus.healthy:
      return Icons.check_circle_outline;
    case ChartPayloadDoctorStatus.warning:
      return Icons.warning_amber_outlined;
    case ChartPayloadDoctorStatus.repairable:
      return Icons.auto_fix_high;
    case ChartPayloadDoctorStatus.invalid:
      return Icons.error_outline;
  }
}

IconData _severityIcon(ValidationSeverity severity) {
  switch (severity) {
    case ValidationSeverity.error:
      return Icons.error_outline;
    case ValidationSeverity.warning:
      return Icons.warning_amber_outlined;
    case ValidationSeverity.info:
      return Icons.info_outline;
  }
}

Color _statusColor(ColorScheme colors, ChartPayloadDoctorStatus status) {
  switch (status) {
    case ChartPayloadDoctorStatus.healthy:
      return colors.primary;
    case ChartPayloadDoctorStatus.warning:
      return colors.tertiary;
    case ChartPayloadDoctorStatus.repairable:
      return colors.secondary;
    case ChartPayloadDoctorStatus.invalid:
      return colors.error;
  }
}
