import 'package:flutter/material.dart';

import '../models/product_profile_search.dart';
import 'icon_label_chip.dart';
import 'profile_search_tone.dart';

class ProfileSearchMatchBadge extends StatelessWidget {
  final ProductProfileSearchMatch match;

  const ProfileSearchMatchBadge({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = profileSearchMatchBadgeColors(theme.colorScheme, match.type);

    return Tooltip(
      message: _tooltipMessage(match),
      child: IconLabelChip(
        key: const ValueKey('profile_search_match'),
        icon: profileSearchIcon(match.type),
        label: '${match.categoryLabel}: ${match.label}',
        colors: colors,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

String _tooltipMessage(ProductProfileSearchMatch match) {
  final detail = match.detail.trim();
  if (detail.isEmpty || detail == match.label) {
    return '${match.categoryLabel} match: ${match.label}';
  }

  return '${match.categoryLabel} match: ${match.label} - $detail';
}
