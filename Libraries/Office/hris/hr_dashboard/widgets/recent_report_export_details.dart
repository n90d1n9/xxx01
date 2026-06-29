import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_export_compliance_summary.dart';
import '../models/report_export_next_action_summary.dart';
import '../models/report_export_package_profile.dart';
import '../models/report_generation_job.dart';
import 'recent_report_export_timing.dart';

class RecentReportExportDetails extends StatelessWidget {
  final ReportGenerationJob job;

  const RecentReportExportDetails({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final packageProfile = ReportExportPackageProfile.fromRequest(job.request);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          job.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${job.report.name} - ${job.request.period.label} - '
          '${job.request.scopeLabel} - ${_formatTime(job.requestedAt)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
        const SizedBox(height: 8),
        RecentReportExportTiming(job: job),
        const SizedBox(height: 8),
        _ReportPackageSummary(job: job, packageProfile: packageProfile),
        if (job.failureMessage != null) ...[
          const SizedBox(height: 8),
          _ReportFailureMessage(message: job.failureMessage!),
        ],
      ],
    );
  }
}

class _ReportPackageSummary extends StatelessWidget {
  final ReportGenerationJob job;
  final ReportExportPackageProfile packageProfile;

  const _ReportPackageSummary({
    required this.job,
    required this.packageProfile,
  });

  @override
  Widget build(BuildContext context) {
    final hasContent = job.request.hasSelectedContent;
    final color = hasContent ? HrisColors.primary : Colors.red.shade700;
    final complianceSummary = ReportExportComplianceSummary.fromRequest(
      report: job.report,
      request: job.request,
    );
    final nextActionSummary = ReportExportNextActionSummary.fromJob(job);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _ReportDetailPill(
          icon: Icons.description_outlined,
          label: job.request.format.label,
        ),
        _ReportDetailPill(
          icon: Icons.inventory_2_outlined,
          label: packageProfile.estimatedSizeLabel,
        ),
        _ReportDetailPill(
          icon: Icons.timer_outlined,
          label: packageProfile.estimatedGenerationLabel,
        ),
        _ReportDetailPill(
          icon: _nextActionIcon(nextActionSummary.kind),
          label: nextActionSummary.label,
          color: _nextActionColor(nextActionSummary.kind),
        ),
        _ReportDetailPill(
          icon: _sensitivityIcon(complianceSummary.sensitivity),
          label: complianceSummary.label,
          color: _sensitivityColor(complianceSummary.sensitivity),
        ),
        _ReportDetailPill(
          icon: hasContent ? Icons.fact_check_outlined : Icons.error_outline,
          label: job.request.contentSummary,
          color: color,
        ),
      ],
    );
  }
}

class _ReportFailureMessage extends StatelessWidget {
  final String message;

  const _ReportFailureMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportDetailPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ReportDetailPill({
    required this.icon,
    required this.label,
    this.color = HrisColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
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

IconData _nextActionIcon(ReportExportNextActionKind kind) {
  return switch (kind) {
    ReportExportNextActionKind.wait => Icons.pending_actions_outlined,
    ReportExportNextActionKind.download => Icons.download_rounded,
    ReportExportNextActionKind.retry => Icons.refresh_rounded,
  };
}

Color _nextActionColor(ReportExportNextActionKind kind) {
  return switch (kind) {
    ReportExportNextActionKind.wait => HrisColors.muted,
    ReportExportNextActionKind.download => Colors.green.shade700,
    ReportExportNextActionKind.retry => Colors.red.shade700,
  };
}
