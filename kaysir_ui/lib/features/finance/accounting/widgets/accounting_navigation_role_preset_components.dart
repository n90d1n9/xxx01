import 'package:flutter/material.dart';

import '../../../../utils/helper.dart';
import '../models/accounting_workspace_role_preset.dart';

class AccountingNavigationRolePresetSelector extends StatelessWidget {
  const AccountingNavigationRolePresetSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final AccountingWorkspaceRolePreset value;
  final ValueChanged<AccountingWorkspaceRolePreset> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final title = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.badge_rounded, color: colorScheme.primary, size: 19),
                const SizedBox(width: 8),
                Text(
                  'Role Preset',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            );
            final selector = SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<AccountingWorkspaceRolePreset>(
                showSelectedIcon: false,
                segments: [
                  for (final item in AccountingWorkspaceRolePreset.values)
                    ButtonSegment<AccountingWorkspaceRolePreset>(
                      value: item,
                      label: Text(compact ? item.shortLabel : item.label),
                      icon: Icon(getIconData(item.icon), size: 17),
                    ),
                ],
                selected: {value},
                onSelectionChanged: (selection) {
                  final selected = selection.firstOrNull;
                  if (selected != null) {
                    onChanged(selected);
                  }
                },
              ),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 10), selector],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                title,
                const SizedBox(width: 16),
                Expanded(child: selector),
              ],
            );
          },
        ),
      ),
    );
  }
}
