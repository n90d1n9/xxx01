import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_custom_attribute_extension_suggestion_service.dart';
import 'project_domain_gap_repair_action_chip.dart';

class ProjectCustomAttributeExtensionSuggestionStrip extends StatelessWidget {
  const ProjectCustomAttributeExtensionSuggestionStrip({
    required this.suggestionSet,
    required this.onAddSuggestion,
    super.key,
  });

  final ProjectCustomAttributeExtensionSuggestionSet suggestionSet;
  final ValueChanged<ProjectCustomAttributeExtensionSuggestion> onAddSuggestion;

  @override
  Widget build(BuildContext context) {
    if (!suggestionSet.hasSuggestions) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final suggestion in suggestionSet.visibleSuggestions)
          ProjectDomainGapRepairActionChip(
            chipKey: ValueKey(
              'project-custom-attribute-suggestion-${suggestion.key}',
            ),
            label: suggestion.actionLabel,
            icon: _icon(suggestion.kind),
            color: _color(suggestion.kind, colorScheme),
            tooltip: suggestion.reason,
            maxWidth: 220,
            onPressed: () => onAddSuggestion(suggestion),
          ),
        if (suggestionSet.hasHiddenSuggestions)
          AppStatusPill(
            label: '+${suggestionSet.hiddenSuggestionCount} more',
            icon: Icons.more_horiz_rounded,
            color: colorScheme.secondary,
            maxWidth: 120,
          ),
      ],
    );
  }

  IconData _icon(ProjectCustomAttributeExtensionSuggestionKind kind) {
    switch (kind) {
      case ProjectCustomAttributeExtensionSuggestionKind.governance:
        return Icons.account_tree_outlined;
      case ProjectCustomAttributeExtensionSuggestionKind.operations:
        return Icons.route_outlined;
      case ProjectCustomAttributeExtensionSuggestionKind.success:
        return Icons.track_changes_outlined;
      case ProjectCustomAttributeExtensionSuggestionKind.dependency:
        return Icons.hub_outlined;
    }
  }

  Color _color(
    ProjectCustomAttributeExtensionSuggestionKind kind,
    ColorScheme colorScheme,
  ) {
    switch (kind) {
      case ProjectCustomAttributeExtensionSuggestionKind.governance:
        return colorScheme.primary;
      case ProjectCustomAttributeExtensionSuggestionKind.operations:
        return colorScheme.tertiary;
      case ProjectCustomAttributeExtensionSuggestionKind.success:
        return Colors.green.shade700;
      case ProjectCustomAttributeExtensionSuggestionKind.dependency:
        return colorScheme.secondary;
    }
  }
}
