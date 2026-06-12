import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_extension_readiness_service.dart';

class ProjectDomainReadinessCompactPill extends StatelessWidget {
  const ProjectDomainReadinessCompactPill({
    required this.summary,
    this.maxWidth = 178,
    super.key,
  });

  final ProjectDomainExtensionReadinessSummary summary;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _statusColor(colorScheme);

    return AppStatusPill(
      label:
          '${summary.completedReadinessFieldCount}/${summary.readinessFieldCount} ${summary.statusLabel}',
      icon: _statusIcon(),
      color: color,
      maxWidth: maxWidth,
      tooltip: '${summary.businessDomain}: ${summary.guidance}',
    );
  }

  Color _statusColor(ColorScheme colorScheme) {
    switch (summary.status) {
      case ProjectDomainExtensionReadinessStatus.needsContext:
        return Colors.orange.shade700;
      case ProjectDomainExtensionReadinessStatus.inProgress:
        return colorScheme.primary;
      case ProjectDomainExtensionReadinessStatus.ready:
        return Colors.green.shade700;
    }
  }

  IconData _statusIcon() {
    switch (summary.status) {
      case ProjectDomainExtensionReadinessStatus.needsContext:
        return Icons.edit_note_outlined;
      case ProjectDomainExtensionReadinessStatus.inProgress:
        return Icons.pending_actions_outlined;
      case ProjectDomainExtensionReadinessStatus.ready:
        return Icons.verified_outlined;
    }
  }
}
