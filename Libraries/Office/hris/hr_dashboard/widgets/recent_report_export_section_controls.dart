import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

class RecentReportExportSectionControls extends StatelessWidget {
  final int sectionCount;
  final int collapsedCount;
  final VoidCallback? onCollapseAll;
  final VoidCallback? onExpandAll;

  const RecentReportExportSectionControls({
    super.key,
    required this.sectionCount,
    required this.collapsedCount,
    this.onCollapseAll,
    this.onExpandAll,
  });

  bool get _canCollapse => collapsedCount < sectionCount;

  bool get _canExpand => collapsedCount > 0;

  String get _summaryLabel {
    final visibleLabel =
        '$sectionCount ${sectionCount == 1 ? 'day' : 'days'} visible';
    if (collapsedCount == 0) return visibleLabel;

    return '$visibleLabel - $collapsedCount collapsed';
  }

  @override
  Widget build(BuildContext context) {
    final title = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.view_agenda_outlined,
          color: HrisColors.muted,
          size: 18,
        ),
        const SizedBox(width: 8),
        HrisStatusPill(label: _summaryLabel, color: HrisColors.muted),
      ],
    );
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SectionControlButton(
          key: const Key('recent-export-collapse-all-sections'),
          icon: Icons.unfold_less_rounded,
          label: 'Collapse all',
          onPressed: _canCollapse ? onCollapseAll : null,
        ),
        _SectionControlButton(
          key: const Key('recent-export-expand-all-sections'),
          icon: Icons.unfold_more_rounded,
          label: 'Expand all',
          onPressed: _canExpand ? onExpandAll : null,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 8), actions],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 10),
            actions,
          ],
        );
      },
    );
  }
}

class _SectionControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _SectionControlButton({
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
        minimumSize: const Size(0, 30),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(icon, size: 17),
      label: Text(label),
    );
  }
}
