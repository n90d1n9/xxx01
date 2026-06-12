import 'package:flutter/material.dart';

class POSSwitchSectionHeader extends StatelessWidget {
  final String title;
  final String countLabel;
  final BoxConstraints constraints;

  const POSSwitchSectionHeader({
    super.key,
    required this.title,
    required this.countLabel,
    this.constraints = const BoxConstraints(),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: constraints,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            countLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
