import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_export_queue_date_section.dart';

class RecentReportExportDateHeader extends StatelessWidget {
  final String label;
  final String countLabel;
  final List<ReportExportQueueDateStatusCount> statusCounts;
  final String? keySuffix;
  final bool isExpanded;
  final String? downloadReadyLabel;
  final String? retryFailedLabel;
  final VoidCallback? onToggleExpanded;
  final VoidCallback? onDownloadReady;
  final VoidCallback? onRetryFailed;

  const RecentReportExportDateHeader({
    super.key,
    required this.label,
    required this.countLabel,
    required this.statusCounts,
    this.keySuffix,
    this.isExpanded = true,
    this.downloadReadyLabel,
    this.retryFailedLabel,
    this.onToggleExpanded,
    this.onDownloadReady,
    this.onRetryFailed,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedKeySuffix = keySuffix ?? _keySuffix(label);
    final actions = _DateHeaderActions(
      keySuffix: resolvedKeySuffix,
      downloadReadyLabel: downloadReadyLabel,
      retryFailedLabel: retryFailedLabel,
      onDownloadReady: onDownloadReady,
      onRetryFailed: onRetryFailed,
    );
    final toggle = _DateHeaderToggle(
      label: label,
      keySuffix: resolvedKeySuffix,
      isExpanded: isExpanded,
      onPressed: onToggleExpanded,
    );
    final title = Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_note_outlined,
              color: HrisColors.muted,
              size: 17,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        _DateHeaderPill(label: countLabel, color: HrisColors.muted),
        for (final statusCount in statusCounts)
          _DateHeaderPill(
            label: statusCount.label,
            color: _statusColor(statusCount.kind),
          ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final divider = const SizedBox(
          width: 72,
          child: Divider(color: HrisColors.border),
        );

        if (!actions.hasActions) {
          return _DateHeaderLine(
            toggle: toggle,
            title: title,
            divider: divider,
          );
        }

        if (constraints.maxWidth < 960) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DateHeaderLine(toggle: toggle, title: title, divider: divider),
              const SizedBox(height: 8),
              actions,
            ],
          );
        }

        return Row(
          children: [
            toggle,
            Expanded(child: title),
            const SizedBox(width: 10),
            divider,
            const SizedBox(width: 8),
            actions,
          ],
        );
      },
    );
  }
}

class _DateHeaderLine extends StatelessWidget {
  final Widget toggle;
  final Widget title;
  final Widget divider;

  const _DateHeaderLine({
    required this.toggle,
    required this.title,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        toggle,
        Expanded(child: title),
        const SizedBox(width: 10),
        divider,
      ],
    );
  }
}

class _DateHeaderToggle extends StatelessWidget {
  final String label;
  final String keySuffix;
  final bool isExpanded;
  final VoidCallback? onPressed;

  const _DateHeaderToggle({
    required this.label,
    required this.keySuffix,
    required this.isExpanded,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) return const SizedBox.shrink();

    final actionLabel = isExpanded ? 'Collapse' : 'Expand';
    return IconButton(
      key: Key('recent-export-date-toggle-$keySuffix'),
      tooltip: '$actionLabel $label',
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
      icon: Icon(
        isExpanded
            ? Icons.keyboard_arrow_down_rounded
            : Icons.keyboard_arrow_right_rounded,
        size: 20,
      ),
    );
  }
}

class _DateHeaderActions extends StatelessWidget {
  final String keySuffix;
  final String? downloadReadyLabel;
  final String? retryFailedLabel;
  final VoidCallback? onDownloadReady;
  final VoidCallback? onRetryFailed;

  const _DateHeaderActions({
    required this.keySuffix,
    this.downloadReadyLabel,
    this.retryFailedLabel,
    this.onDownloadReady,
    this.onRetryFailed,
  });

  bool get hasActions => onDownloadReady != null || onRetryFailed != null;

  @override
  Widget build(BuildContext context) {
    if (!hasActions) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (onDownloadReady != null)
          _DateHeaderActionButton(
            key: Key('recent-export-date-download-$keySuffix'),
            icon: Icons.download_rounded,
            label: downloadReadyLabel ?? 'Download ready',
            onPressed: onDownloadReady,
          ),
        if (onRetryFailed != null)
          _DateHeaderActionButton(
            key: Key('recent-export-date-retry-$keySuffix'),
            icon: Icons.refresh_rounded,
            label: retryFailedLabel ?? 'Retry failed',
            onPressed: onRetryFailed,
          ),
      ],
    );
  }
}

class _DateHeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _DateHeaderActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 28),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _DateHeaderPill extends StatelessWidget {
  final String label;
  final Color color;

  const _DateHeaderPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Color _statusColor(ReportExportQueueDateStatusKind kind) {
  return switch (kind) {
    ReportExportQueueDateStatusKind.failed => Colors.red.shade700,
    ReportExportQueueDateStatusKind.active => HrisColors.primary,
    ReportExportQueueDateStatusKind.ready => Colors.green.shade700,
  };
}

String _keySuffix(String label) {
  return label
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
