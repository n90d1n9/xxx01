import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

/// Shared status header for project workflow panels.
class ProjectWorkflowHeader extends StatelessWidget {
  const ProjectWorkflowHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.statusLabel,
    required this.statusIcon,
    this.statusColor,
    this.statusMaxWidth = 132,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String statusLabel;
  final IconData statusIcon;
  final Color? statusColor;
  final double statusMaxWidth;

  @override
  Widget build(BuildContext context) {
    return AppInfoRow(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: color.withValues(alpha: 0.12),
      iconForegroundColor: color,
      titleMaxLines: 2,
      subtitleMaxLines: 2,
      trailing: AppStatusPill(
        label: statusLabel,
        icon: statusIcon,
        color: statusColor ?? color,
        maxWidth: statusMaxWidth,
      ),
    );
  }
}

@Preview(name: 'Project workflow header')
Widget projectWorkflowHeaderPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Builder(
          builder: (context) {
            final colorScheme = Theme.of(context).colorScheme;

            return ProjectWorkflowHeader(
              title: 'Budget change request flow',
              subtitle:
                  'Warehouse modernization - 2 queued changes - Sponsor route',
              icon: Icons.rule_folder_outlined,
              color: colorScheme.primary,
              statusLabel: 'Sponsor route',
              statusIcon: Icons.route_outlined,
              statusMaxWidth: 142,
            );
          },
        ),
      ),
    ),
  );
}
