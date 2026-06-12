import 'package:flutter/material.dart';

import '../admin_status_badge.dart';

class AdminSidebarBrand extends StatelessWidget {
  const AdminSidebarBrand({
    super.key,
    required this.isCompact,
    this.title = 'Kaysir',
    this.subtitle = 'Commerce workspace',
    this.badgeLabel = 'Live',
  });

  final bool isCompact;
  final String title;
  final String subtitle;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    final trimmedTitle = title.trim();

    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Tooltip(
            message: '$title - $subtitle',
            child: _BrandMark(
              label: trimmedTitle.isEmpty ? 'K' : trimmedTitle[0],
            ),
          ),
          if (!isCompact) ...[
            const SizedBox(width: 12),
            Expanded(child: _BrandCopy(title: title, subtitle: subtitle)),
            const SizedBox(width: 8),
            AdminStatusBadge(label: badgeLabel),
          ],
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BrandCopy extends StatelessWidget {
  const _BrandCopy({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
