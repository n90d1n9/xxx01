import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_export_compliance_summary.dart';
import '../models/report_export_package_profile.dart';
import '../models/report_generation_request.dart';
import '../models/report_type.dart';

class ReportGenerationRequestPreview extends StatelessWidget {
  final ReportType report;
  final ReportGenerationRequest request;

  const ReportGenerationRequestPreview({
    super.key,
    required this.report,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final packageProfile = ReportExportPackageProfile.fromRequest(request);
    final complianceSummary = ReportExportComplianceSummary.fromRequest(
      report: report,
      request: request,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HrisColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insert_drive_file_outlined,
                color: HrisColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  request.exportFileNameFor(report),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PreviewPill(
                icon: Icons.calendar_month_outlined,
                label: request.period.label,
              ),
              _PreviewPill(
                icon: Icons.apartment_outlined,
                label: request.department.label,
              ),
              _PreviewPill(
                icon: Icons.description_outlined,
                label: request.format.label,
              ),
              _PreviewPill(
                icon: Icons.fact_check_outlined,
                label: packageProfile.sectionCountLabel,
              ),
              _PreviewPill(
                icon: Icons.inventory_2_outlined,
                label: packageProfile.estimatedSizeLabel,
              ),
              _PreviewPill(
                icon: Icons.timer_outlined,
                label: packageProfile.estimatedGenerationLabel,
              ),
              _PreviewPill(
                icon: _sensitivityIcon(complianceSummary.sensitivity),
                label: complianceSummary.label,
                color: _sensitivityColor(complianceSummary.sensitivity),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                request.hasSelectedContent
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                color:
                    request.hasSelectedContent
                        ? HrisColors.primary
                        : Colors.red.shade700,
                size: 17,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.contentSummary,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color:
                        request.hasSelectedContent
                            ? HrisColors.muted
                            : Colors.red.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PreviewPill({
    required this.icon,
    required this.label,
    this.color = HrisColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _sensitivityIcon(ReportExportSensitivity sensitivity) {
  return switch (sensitivity) {
    ReportExportSensitivity.internal => Icons.shield_outlined,
    ReportExportSensitivity.confidential => Icons.lock_outline_rounded,
    ReportExportSensitivity.payrollSensitive => Icons.privacy_tip_outlined,
  };
}

Color _sensitivityColor(ReportExportSensitivity sensitivity) {
  return switch (sensitivity) {
    ReportExportSensitivity.internal => HrisColors.primary,
    ReportExportSensitivity.confidential => Colors.orange.shade800,
    ReportExportSensitivity.payrollSensitive => Colors.red.shade700,
  };
}
