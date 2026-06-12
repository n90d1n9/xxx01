import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_gap_repair_field_hint_service.dart';
import 'project_custom_attribute_type_ui.dart';

class ProjectDomainGapRepairFieldHintChip extends StatelessWidget {
  const ProjectDomainGapRepairFieldHintChip({required this.hint, super.key});

  final ProjectDomainGapRepairFieldHint hint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppStatusPill(
      label: hint.label,
      icon: hint.type.icon,
      color: hint.type.accentColor(colorScheme),
      tooltip: hint.detail,
      maxWidth: 160,
    );
  }
}
