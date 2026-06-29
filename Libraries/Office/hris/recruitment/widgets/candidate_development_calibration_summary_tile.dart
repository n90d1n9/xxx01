import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_development_calibration_models.dart';

class CandidateDevelopmentCalibrationSummaryTile extends StatelessWidget {
  final CandidateDevelopmentCalibrationSummary summary;

  const CandidateDevelopmentCalibrationSummaryTile({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.fact_check_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calibration action',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: HrisColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      summary.nextAction,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CalibrationStat(
                label: 'Profiles',
                value: '${summary.totalCount}',
              ),
              _CalibrationStat(label: 'Ready', value: '${summary.readyCount}'),
              _CalibrationStat(
                label: 'Monitor',
                value: '${summary.monitorCount}',
              ),
              _CalibrationStat(
                label: 'Blocked',
                value: '${summary.blockedCount}',
              ),
              _CalibrationStat(
                label: 'Avg score',
                value: '${summary.averageReadinessScore.round()}%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalibrationStat extends StatelessWidget {
  final String label;
  final String value;

  const _CalibrationStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}
