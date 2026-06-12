import 'package:flutter/material.dart';

import '../../../widgets/ui/app_icon_badge.dart';
import '../models/admin_route_search_entry.dart';
import '../services/admin_route_icon_resolver.dart';

class AdminRouteSearchResultTile extends StatelessWidget {
  const AdminRouteSearchResultTile({
    super.key,
    required this.entry,
    required this.onTap,
    this.highlighted = false,
  });

  final AdminRouteSearchEntry entry;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        color:
            highlighted
                ? colorScheme.primaryContainer.withValues(alpha: 0.22)
                : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side:
              highlighted
                  ? BorderSide(color: colorScheme.primary)
                  : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                AppIconBadge(
                  icon: resolveAdminRouteIcon(entry.route),
                  size: 38,
                  iconSize: 20,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.section == null
                            ? entry.path
                            : '${entry.section} - ${entry.path}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
