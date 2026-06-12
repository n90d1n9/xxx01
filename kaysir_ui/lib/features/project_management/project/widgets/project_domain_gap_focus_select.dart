import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

import '../services/project_domain_gap_focus_service.dart';

class ProjectDomainGapFocusSelect extends StatelessWidget {
  const ProjectDomainGapFocusSelect({
    required this.value,
    required this.onChanged,
    this.fieldKey,
    this.label = 'Gaps',
    this.width = 190,
    super.key,
  });

  final ProjectDomainGapFocus value;
  final ValueChanged<ProjectDomainGapFocus> onChanged;
  final Key? fieldKey;
  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<ProjectDomainGapFocus>(
      key: fieldKey,
      label: label,
      value: value,
      width: width,
      icon: value.icon,
      options: [
        for (final focus in ProjectDomainGapFocus.values)
          AppSelectOption(value: focus, label: focus.label),
      ],
      onChanged: onChanged,
    );
  }
}
