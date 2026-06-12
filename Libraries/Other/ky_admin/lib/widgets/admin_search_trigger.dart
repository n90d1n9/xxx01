import 'package:flutter/material.dart';

import '../../../widgets/ui/app_icon_action_button.dart';
import '../../../widgets/ui/app_search_field.dart';
import 'admin_shell_shortcuts.dart';
import 'admin_shortcut_hint.dart';

class AdminSearchTrigger extends StatelessWidget {
  const AdminSearchTrigger({
    super.key,
    required this.expanded,
    required this.onPressed,
    this.hintText = 'Search pages...',
  });

  final bool expanded;
  final VoidCallback onPressed;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    if (!expanded) {
      return AppIconActionButton(
        icon: Icons.search,
        tooltip: 'Search pages',
        onPressed: onPressed,
      );
    }

    return AppSearchField(
      width: 300,
      hintText: hintText,
      readOnly: true,
      tooltip: 'Search pages',
      onTap: onPressed,
      trailing: const AdminShortcutHint(
        icon: Icons.keyboard_command_key,
        label: 'K',
        semanticLabel:
            'Search shortcut ${AdminShellShortcuts.searchShortcutLabel}',
      ),
    );
  }
}
