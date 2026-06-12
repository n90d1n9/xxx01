import 'package:flutter/material.dart';

import '../models/product_profile.dart';
import 'inset_surface.dart';
import 'product_profile_summary.dart';

class ActiveProfileSummary extends StatelessWidget {
  const ActiveProfileSummary({required this.profile, super.key});

  final ProductProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InsetSurface(
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.28),
      border: Border.all(
        color: theme.colorScheme.primary.withValues(alpha: 0.16),
      ),
      child: ProductProfileSummary(
        profile: profile,
        eyebrow: 'Active profile',
        chipLimits: ProductProfileChipLimits.active,
        titleStyle: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w900,
        ),
        descriptionStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
