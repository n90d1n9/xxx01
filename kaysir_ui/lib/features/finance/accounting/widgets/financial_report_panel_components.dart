import 'package:flutter/material.dart';

import '../../../../widgets/ui/app_icon_badge.dart';
import '../../../../widgets/ui/app_surface.dart';
import '../../../../widgets/ui/app_text_cluster.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportPanelSurface extends StatelessWidget {
  const FinancialReportPanelSurface({
    required this.child,
    required this.isDarkMode,
    this.muted = false,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderColor,
    this.elevated = false,
    super.key,
  });

  final Widget child;
  final bool isDarkMode;
  final bool muted;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: padding,
      backgroundColor:
          backgroundColor ??
          financialReportPanelBackground(isDarkMode, muted: muted),
      borderColor: borderColor ?? financialReportPanelBorder(isDarkMode),
      elevated: elevated,
      child: child,
    );
  }
}

class FinancialReportPanelHeader extends StatelessWidget {
  const FinancialReportPanelHeader({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.isDarkMode,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isDarkMode;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;
        final titleBlock = _FinancialReportPanelTitleBlock(
          title: title,
          subtitle: subtitle,
          icon: icon,
          accentColor: accentColor,
          isDarkMode: isDarkMode,
        );

        if (trailing == null) {
          return titleBlock;
        }

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: trailing),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            Flexible(
              flex: 2,
              child: Align(alignment: Alignment.centerRight, child: trailing),
            ),
          ],
        );
      },
    );
  }
}

class FinancialReportPanelBadge extends StatelessWidget {
  const FinancialReportPanelBadge({
    required this.label,
    required this.color,
    required this.isDarkMode,
    this.icon,
    super.key,
  });

  final String label;
  final Color color;
  final bool isDarkMode;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FinancialReportTintedSurface(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      fillAlpha: isDarkMode ? 0.14 : 0.08,
      borderAlpha: 0.2,
      borderRadius: 999,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.white : color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialReportPanelEmptyState extends StatelessWidget {
  const FinancialReportPanelEmptyState({
    required this.title,
    required this.icon,
    required this.isDarkMode,
    this.message,
    this.accentColor,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;
  final bool isDarkMode;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color =
        accentColor ??
        (isDarkMode ? Colors.grey.shade400 : Colors.blueGrey.shade700);
    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final messageColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

    return FinancialReportTintedSurface(
      color: color,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      fillAlpha: isDarkMode ? 0.14 : 0.08,
      borderAlpha: 0.22,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    message!,
                    style: TextStyle(color: messageColor, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color financialReportPanelBackground(bool isDarkMode, {bool muted = false}) {
  if (isDarkMode) {
    return const Color(0xFF252538);
  }
  return muted ? const Color(0xFFF8FAFC) : Colors.white;
}

Color financialReportPanelBorder(bool isDarkMode) {
  return isDarkMode ? Colors.white12 : Colors.grey.shade200;
}

class _FinancialReportPanelTitleBlock extends StatelessWidget {
  const _FinancialReportPanelTitleBlock({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.isDarkMode,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBadge(
          icon: icon,
          size: 38,
          iconSize: 20,
          backgroundColor: accentColor.withValues(
            alpha: isDarkMode ? 0.16 : 0.1,
          ),
          foregroundColor: accentColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppTextCluster(
            title: title,
            subtitle: subtitle,
            titleStyle: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            subtitleStyle: TextStyle(color: mutedColor),
            titleGap: 4,
            subtitleMaxLines: 3,
          ),
        ),
      ],
    );
  }
}
