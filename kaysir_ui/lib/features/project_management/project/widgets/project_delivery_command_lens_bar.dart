import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';

import '../services/project_delivery_command_lens_service.dart';
import '../services/project_delivery_command_service.dart';

class ProjectDeliveryCommandLensBar extends StatelessWidget {
  const ProjectDeliveryCommandLensBar({
    required this.commands,
    required this.filter,
    required this.onFilterChanged,
    super.key,
  });

  final List<ProjectDeliveryCommand> commands;
  final ProjectDeliveryCommandFilter filter;
  final ValueChanged<ProjectDeliveryCommandFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final counts = countProjectDeliveryCommandLenses(commands);
    final activeLens = projectDeliveryCommandLensForFilter(filter);

    return AppFilterChipGroup<ProjectDeliveryCommandLens?>(
      value: activeLens,
      options: [
        for (final lens in ProjectDeliveryCommandLens.values)
          AppFilterChipOption<ProjectDeliveryCommandLens?>(
            value: lens,
            label: lens.label,
            icon: lens.icon,
            count: counts[lens] ?? 0,
          ),
      ],
      onChanged: (lens) {
        if (lens != null) onFilterChanged(lens.filter);
      },
    );
  }
}
