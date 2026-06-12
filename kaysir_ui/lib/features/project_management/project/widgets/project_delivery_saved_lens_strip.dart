import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_delivery_command_service.dart';
import '../services/project_delivery_saved_lens_service.dart';

class ProjectDeliverySavedLensStrip extends StatelessWidget {
  const ProjectDeliverySavedLensStrip({
    required this.commands,
    required this.filter,
    required this.onFilterChanged,
    this.lenses = defaultProjectDeliverySavedCommandLenses,
    super.key,
  });

  final List<ProjectDeliveryCommand> commands;
  final ProjectDeliveryCommandFilter filter;
  final ValueChanged<ProjectDeliveryCommandFilter> onFilterChanged;
  final List<ProjectDeliverySavedCommandLens> lenses;

  @override
  Widget build(BuildContext context) {
    if (lenses.isEmpty) return const SizedBox.shrink();

    final counts = countProjectDeliverySavedLenses(commands, lenses: lenses);
    final selectedLens = projectDeliverySavedLensForFilter(
      filter,
      lenses: lenses,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final columns =
            constraints.maxWidth >= 920
                ? 4
                : constraints.maxWidth >= 620
                ? 2
                : 1;
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved Lenses',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final lens in lenses)
                  SizedBox(
                    width: tileWidth,
                    child: _SavedLensTile(
                      lens: lens,
                      count: counts[lens] ?? 0,
                      selected: selectedLens?.id == lens.id,
                      onTap: () => onFilterChanged(lens.filter),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SavedLensTile extends StatelessWidget {
  const _SavedLensTile({
    required this.lens,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final ProjectDeliverySavedCommandLens lens;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground =
        selected ? colorScheme.onPrimaryContainer : colorScheme.onSurface;
    final supporting =
        selected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                selected
                    ? colorScheme.primaryContainer.withValues(alpha: 0.72)
                    : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  selected
                      ? colorScheme.primary.withValues(alpha: 0.62)
                      : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SavedLensIcon(icon: lens.icon, selected: selected),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lens.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lens.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: supporting,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppStatusPill(
                label: count.toString(),
                icon: Icons.rule_outlined,
                color: selected ? colorScheme.primary : colorScheme.secondary,
                maxWidth: 72,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedLensIcon extends StatelessWidget {
  const _SavedLensIcon({required this.icon, required this.selected});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            selected
                ? colorScheme.primary.withValues(alpha: 0.16)
                : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 20,
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
