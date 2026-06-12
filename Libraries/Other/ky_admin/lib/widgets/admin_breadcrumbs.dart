import 'package:flutter/material.dart';

class AdminBreadcrumbs extends StatelessWidget {
  const AdminBreadcrumbs({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Text(
            items[index],
            style: textTheme.labelMedium?.copyWith(
              color:
                  index == items.length - 1
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (index < items.length - 1)
            Icon(
              Icons.chevron_right,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
        ],
      ],
    );
  }
}
