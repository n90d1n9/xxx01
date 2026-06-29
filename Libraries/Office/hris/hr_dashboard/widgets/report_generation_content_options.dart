import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_generation_request.dart';

class ReportGenerationContentOptions extends StatelessWidget {
  final ReportGenerationRequest request;
  final ValueChanged<ReportGenerationRequest> onChanged;

  const ReportGenerationContentOptions({
    super.key,
    required this.request,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final error = request.validationMessage;

    final borderRadius = BorderRadius.circular(8);

    return Material(
      color: HrisColors.surface,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: error == null ? HrisColors.border : Colors.red.shade300,
          ),
        ),
        child: Column(
          children: [
            _ReportContentSwitch(
              key: const Key('report-executive-summary-option'),
              icon: Icons.summarize_outlined,
              title: 'Executive summary',
              subtitle: 'Leadership-ready findings',
              value: request.includeExecutiveSummary,
              onChanged: (value) {
                onChanged(request.copyWith(includeExecutiveSummary: value));
              },
            ),
            const Divider(height: 1, color: HrisColors.border),
            _ReportContentSwitch(
              key: const Key('report-trend-charts-option'),
              icon: Icons.stacked_line_chart_rounded,
              title: 'Trend charts',
              subtitle: 'Visual movement by period',
              value: request.includeTrendCharts,
              onChanged: (value) {
                onChanged(request.copyWith(includeTrendCharts: value));
              },
            ),
            const Divider(height: 1, color: HrisColors.border),
            _ReportContentSwitch(
              key: const Key('report-raw-data-option'),
              icon: Icons.table_chart_outlined,
              title: 'Raw data export',
              subtitle: 'Audit-ready source rows',
              value: request.includeRawData,
              onChanged: (value) {
                onChanged(request.copyWith(includeRawData: value));
              },
            ),
            if (error != null) ...[
              const Divider(height: 1, color: HrisColors.border),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 11),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red.shade700,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReportContentSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ReportContentSwitch({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: HrisColors.primary, size: 20),
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.only(left: 12, right: 8),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: HrisColors.ink,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
