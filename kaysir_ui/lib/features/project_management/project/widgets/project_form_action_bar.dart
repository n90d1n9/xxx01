import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';

class ProjectFormActionBar extends StatelessWidget {
  const ProjectFormActionBar({
    required this.submitLabel,
    required this.onReset,
    required this.onSubmit,
    super.key,
  });

  final String submitLabel;
  final VoidCallback onReset;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const ValueKey('project-form-action-bar'),
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      children: [
        AppActionButton(
          label: 'Reset',
          icon: Icons.restart_alt_rounded,
          variant: AppActionButtonVariant.secondary,
          onPressed: onReset,
        ),
        AppActionButton(
          label: submitLabel,
          icon: Icons.save_outlined,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}
