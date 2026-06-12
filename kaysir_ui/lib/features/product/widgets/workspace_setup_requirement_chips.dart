import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/product_workspace_setup_target.dart';
import 'workspace_preview_fixtures.dart';
import 'workspace_setup_requirement_visuals.dart';

/// Compact chips for setup requirements on a product workspace target.
class ProductWorkspaceSetupRequirementChips extends StatelessWidget {
  const ProductWorkspaceSetupRequirementChips({
    super.key,
    required this.requirements,
    this.visibleLimit = 3,
  });

  final List<ProductWorkspaceSetupRequirement> requirements;
  final int visibleLimit;

  @override
  Widget build(BuildContext context) {
    if (requirements.isEmpty) return const SizedBox.shrink();

    final visibleRequirements = requirements
        .take(visibleLimit)
        .toList(growable: false);
    final hiddenCount = requirements.length - visibleRequirements.length;
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final requirement in visibleRequirements)
          AppStatusPill(
            label: requirement.label,
            color: productWorkspaceSetupRequirementColor(
              colorScheme,
              requirement.type,
            ),
            icon: productWorkspaceSetupRequirementIcon(requirement.type),
            tooltip: requirement.typeLabel,
            maxWidth: 176,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        if (hiddenCount > 0)
          AppStatusPill(
            label: '+$hiddenCount more',
            color: colorScheme.outline,
            maxWidth: 96,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
      ],
    );
  }
}

@Preview(name: 'Product workspace setup requirements')
Widget workspaceSetupRequirementChipsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductWorkspaceSetupRequirementChips(
          requirements: previewProductWorkspaceSetupRequirements,
          visibleLimit: 4,
        ),
      ),
    ),
  );
}
