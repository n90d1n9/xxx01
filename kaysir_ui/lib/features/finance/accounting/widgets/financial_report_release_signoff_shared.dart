import 'package:flutter/material.dart';

import 'financial_report_panel_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportReleaseSignOffSurface extends StatelessWidget {
  final Widget child;

  const FinancialReportReleaseSignOffSurface({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return FinancialReportPanelSurface(
      isDarkMode: theme.brightness == Brightness.dark,
      padding: const EdgeInsets.all(16),
      backgroundColor: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: child,
    );
  }
}

class FinancialReportReleaseSignOffIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const FinancialReportReleaseSignOffIcon({
    required this.icon,
    required this.color,
    this.size = 42,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FinancialReportTintedSurface(
      color: color,
      width: size,
      minHeight: size,
      padding: EdgeInsets.zero,
      fillAlpha: 0.1,
      borderAlpha: 0.24,
      child: Center(child: Icon(icon, color: color, size: size * 0.52)),
    );
  }
}

class FinancialReportReleaseSignOffBadge extends StatelessWidget {
  final String label;
  final Color color;

  const FinancialReportReleaseSignOffBadge({
    required this.label,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 230),
      child: FinancialReportTintedSurface(
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        fillAlpha: 0.1,
        borderAlpha: 0.24,
        borderRadius: 999,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class FinancialReportReleaseSignOffSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const FinancialReportReleaseSignOffSectionTitle({
    required this.icon,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
