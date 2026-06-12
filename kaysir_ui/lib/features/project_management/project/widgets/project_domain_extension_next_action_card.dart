import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';

import '../services/project_domain_extension_next_action_service.dart';

class ProjectDomainExtensionNextActionCard extends StatelessWidget {
  const ProjectDomainExtensionNextActionCard({
    required this.action,
    required this.onFocusField,
    super.key,
  });

  final ProjectDomainExtensionNextAction action;
  final VoidCallback onFocusField;

  @override
  Widget build(BuildContext context) {
    if (!action.hasField) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final tone = _toneColor(colorScheme);
    final button = AppActionButton(
      key: ValueKey('project-domain-extension-next-action-${action.fieldKey}'),
      label: action.actionLabel,
      icon: Icons.center_focus_strong_outlined,
      variant: AppActionButtonVariant.secondary,
      compact: true,
      onPressed: onFocusField,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;
        final row = AppInfoRow(
          title: action.title,
          subtitle: action.detail,
          icon: _icon(),
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: tone.withValues(alpha: 0.12),
          iconForegroundColor: tone,
          titleMaxLines: 2,
          subtitleMaxLines: 3,
          trailing: isNarrow ? null : button,
        );

        if (!isNarrow) return row;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            row,
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: button),
          ],
        );
      },
    );
  }

  Color _toneColor(ColorScheme colorScheme) {
    switch (action.kind) {
      case ProjectDomainExtensionNextActionKind.requiredField:
        return colorScheme.error;
      case ProjectDomainExtensionNextActionKind.watchedField:
        return colorScheme.tertiary;
      case ProjectDomainExtensionNextActionKind.recommendedField:
        return colorScheme.primary;
      case ProjectDomainExtensionNextActionKind.complete:
        return Colors.green.shade700;
    }
  }

  IconData _icon() {
    switch (action.kind) {
      case ProjectDomainExtensionNextActionKind.requiredField:
        return Icons.priority_high_rounded;
      case ProjectDomainExtensionNextActionKind.watchedField:
        return Icons.sensors_outlined;
      case ProjectDomainExtensionNextActionKind.recommendedField:
        return Icons.fact_check_outlined;
      case ProjectDomainExtensionNextActionKind.complete:
        return Icons.verified_outlined;
    }
  }
}
