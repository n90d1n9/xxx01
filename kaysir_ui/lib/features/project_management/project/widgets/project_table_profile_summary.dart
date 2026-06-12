import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_table_view_service.dart';

class ProjectTableProfileSummary extends StatelessWidget {
  const ProjectTableProfileSummary({
    required this.profile,
    required this.recommendedProfile,
    required this.onUseRecommended,
    super.key,
  });

  final ProjectTableColumnProfile profile;
  final ProjectTableColumnProfile recommendedProfile;
  final VoidCallback onUseRecommended;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRecommended = profile == recommendedProfile;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final heading = _ProjectProfileHeading(
                  profile: profile,
                  isRecommended: isRecommended,
                );

                if (constraints.maxWidth < 720) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading,
                      if (!isRecommended) ...[
                        const SizedBox(height: 10),
                        _UseRecommendedButton(
                          recommendedProfile: recommendedProfile,
                          onPressed: onUseRecommended,
                        ),
                      ],
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: heading),
                    if (!isRecommended) ...[
                      const SizedBox(width: 12),
                      _UseRecommendedButton(
                        recommendedProfile: recommendedProfile,
                        onPressed: onUseRecommended,
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final column in profile.orderedColumns)
                  AppStatusPill(
                    label: column.label,
                    icon: Icons.view_column_outlined,
                    color: colorScheme.primary,
                    maxWidth: 190,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectProfileHeading extends StatelessWidget {
  const _ProjectProfileHeading({
    required this.profile,
    required this.isRecommended,
  });

  final ProjectTableColumnProfile profile;
  final bool isRecommended;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(profile.icon, size: 18, color: colorScheme.primary),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${profile.label} Profile',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (isRecommended)
                    AppStatusPill(
                      label: 'Recommended',
                      icon: Icons.auto_awesome_outlined,
                      color: Colors.green.shade700,
                      maxWidth: 132,
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                profile.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UseRecommendedButton extends StatelessWidget {
  const _UseRecommendedButton({
    required this.recommendedProfile,
    required this.onPressed,
  });

  final ProjectTableColumnProfile recommendedProfile;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(recommendedProfile.icon, size: 18),
      label: Text('Use ${recommendedProfile.label}'),
    );
  }
}
