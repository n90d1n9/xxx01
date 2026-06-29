import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/performance_models.dart';
import 'performance_meta_label.dart';
import 'performance_status_styles.dart';

class CalibrationPanel extends StatelessWidget {
  final List<CalibrationItem> items;

  const CalibrationPanel({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Calibration',
      icon: Icons.tune_outlined,
      subtitle: '${items.length} items',
      emptyMessage: 'No calibration items match filters',
      children: items.map((item) => _CalibrationTile(item: item)).toList(),
    );
  }
}

class _CalibrationTile extends StatelessWidget {
  final CalibrationItem item;

  const _CalibrationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = calibrationStatusColor(item.status);

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
            child: Icon(Icons.compare_arrows_outlined, color: color),
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
                        item.employeeName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    HrisStatusPill(
                      label: calibrationStatusLabel(item.status),
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.proposedRating} -> ${item.calibratedRating}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                PerformanceMetaLabel(
                  icon: Icons.person_outline,
                  label: item.managerName,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
