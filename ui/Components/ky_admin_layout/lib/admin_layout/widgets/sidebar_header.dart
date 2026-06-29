import 'package:flutter/material.dart';

class SidebarHeader extends StatelessWidget {
  final bool isMinimized;
  final ThemeData theme;
  final void Function()? onPressed;
  const SidebarHeader(
      {super.key,
      required this.isMinimized,
      required this.theme,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.admin_panel_settings,
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          if (!isMinimized) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Panel',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Management System',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Add expand button when minimized
          if (isMinimized)
            IconButton(
              icon: Icon(Icons.chevron_right, size: 20),
              onPressed: onPressed,
              tooltip: 'Expand Sidebar',
            ),
        ],
      ),
    );
  }
}
