import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/project_custom_attribute.dart';
import '../services/project_domain_attribute_metadata_service.dart';

class ProjectDomainAttributeMetadataChipBar extends StatelessWidget {
  const ProjectDomainAttributeMetadataChipBar({
    required this.metadata,
    super.key,
  });

  final ProjectDomainAttributeMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppStatusPill(
          label: metadata.sourceLabel,
          icon: _sourceIcon(),
          color: _sourceColor(colorScheme),
          maxWidth: 132,
          tooltip: _sourceTooltip(),
        ),
        if (metadata.isRiskWatched)
          AppStatusPill(
            label: 'Risk signal',
            icon: Icons.sensors_outlined,
            color: colorScheme.tertiary,
            maxWidth: 132,
            tooltip: 'This field can trigger domain risk prompts.',
          ),
      ],
    );
  }

  IconData _sourceIcon() {
    if (!metadata.isDomainTemplate) return Icons.add_task_outlined;

    switch (metadata.importance) {
      case ProjectCustomAttributeImportance.requiredField:
        return Icons.priority_high_rounded;
      case ProjectCustomAttributeImportance.recommended:
        return Icons.fact_check_outlined;
      case ProjectCustomAttributeImportance.optional:
        return Icons.tune_outlined;
    }
  }

  Color _sourceColor(ColorScheme colorScheme) {
    if (!metadata.isDomainTemplate) return colorScheme.secondary;

    switch (metadata.importance) {
      case ProjectCustomAttributeImportance.requiredField:
        return colorScheme.error;
      case ProjectCustomAttributeImportance.recommended:
        return colorScheme.primary;
      case ProjectCustomAttributeImportance.optional:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _sourceTooltip() {
    if (!metadata.isDomainTemplate) {
      return 'Custom field for this project.';
    }

    switch (metadata.importance) {
      case ProjectCustomAttributeImportance.requiredField:
        return 'Required for this business domain.';
      case ProjectCustomAttributeImportance.recommended:
        return 'Recommended for higher quality handoff.';
      case ProjectCustomAttributeImportance.optional:
        return 'Optional context for this business domain.';
    }
  }
}
