import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';

/// Shared reset and submit action row for project workflow forms.
class ProjectWorkflowActionBar extends StatelessWidget {
  const ProjectWorkflowActionBar({
    required this.submitLabel,
    required this.onReset,
    required this.onSubmit,
    this.resetLabel = 'Reset',
    this.resetIcon = Icons.restart_alt_rounded,
    this.submitIcon = Icons.playlist_add_check_outlined,
    super.key,
  });

  final String resetLabel;
  final String submitLabel;
  final IconData resetIcon;
  final IconData submitIcon;
  final VoidCallback onReset;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      children: [
        AppActionButton(
          label: resetLabel,
          icon: resetIcon,
          variant: AppActionButtonVariant.secondary,
          onPressed: onReset,
        ),
        AppActionButton(
          label: submitLabel,
          icon: submitIcon,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

@Preview(name: 'Project workflow action bar')
Widget projectWorkflowActionBarPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProjectWorkflowActionBar(
          submitLabel: 'Queue Response',
          onReset: () {},
          onSubmit: () {},
        ),
      ),
    ),
  );
}
