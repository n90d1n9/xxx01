import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';

import '../services/project_delivery_saved_lens_service.dart';

class ProjectDeliverySavedLensProfileBar extends StatelessWidget {
  const ProjectDeliverySavedLensProfileBar({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final ProjectDeliverySavedLensProfile value;
  final ValueChanged<ProjectDeliverySavedLensProfile> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppFilterChipGroup<ProjectDeliverySavedLensProfile>(
      value: value,
      options: [
        for (final profile in ProjectDeliverySavedLensProfile.values)
          AppFilterChipOption<ProjectDeliverySavedLensProfile>(
            value: profile,
            label: profile.label,
            icon: profile.icon,
          ),
      ],
      onChanged: onChanged,
    );
  }
}
