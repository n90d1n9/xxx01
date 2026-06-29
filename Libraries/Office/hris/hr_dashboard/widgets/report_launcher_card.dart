import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_type.dart';

class ReportLauncherCard extends StatelessWidget {
  final ReportType report;
  final VoidCallback onTap;

  const ReportLauncherCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HrisColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: hrisPanelDecoration(color: Colors.transparent),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxHeight < 150) {
                return _CompactReportCardContent(report: report);
              }

              return _StackedReportCardContent(report: report);
            },
          ),
        ),
      ),
    );
  }
}

class _CompactReportCardContent extends StatelessWidget {
  final ReportType report;

  const _CompactReportCardContent({required this.report});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ReportIcon(report: report),
        const SizedBox(width: 14),
        Expanded(child: _ReportCopy(report: report, compact: true)),
        const SizedBox(width: 12),
        const Icon(Icons.arrow_forward_rounded, color: HrisColors.muted),
      ],
    );
  }
}

class _StackedReportCardContent extends StatelessWidget {
  final ReportType report;

  const _StackedReportCardContent({required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _ReportIcon(report: report),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_rounded,
              color: HrisColors.muted,
              size: 20,
            ),
          ],
        ),
        const Spacer(),
        _ReportCopy(report: report),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Configure',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: HrisColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.tune_rounded, color: HrisColors.primary, size: 17),
          ],
        ),
      ],
    );
  }
}

class _ReportIcon extends StatelessWidget {
  final ReportType report;

  const _ReportIcon({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: HrisColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(report.icon, color: HrisColors.primary),
    );
  }
}

class _ReportCopy extends StatelessWidget {
  final ReportType report;
  final bool compact;

  const _ReportCopy({required this.report, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          report.description,
          maxLines: compact ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
      ],
    );
  }
}
