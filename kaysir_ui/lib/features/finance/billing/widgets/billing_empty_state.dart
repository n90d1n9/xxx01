import 'package:flutter/material.dart';

class BillingEmptyState extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final Widget? action;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final Color messageColor;
  final Color iconColor;
  final Color iconBackgroundColor;
  final double borderRadius;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;

  const BillingEmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.action,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = const Color(0xFFF8FAFC),
    this.borderColor = const Color(0xFFE2E8F0),
    this.messageColor = const Color(0xFF64748B),
    this.iconColor = const Color(0xFF64748B),
    this.iconBackgroundColor = const Color(0xFFF1F5F9),
    this.borderRadius = 8,
    this.textAlign = TextAlign.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    final title = this.title;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (icon != null) ...[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 10),
          ],
          if (title != null) ...[
            Text(
              title,
              textAlign: textAlign,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            message,
            textAlign: textAlign,
            style: TextStyle(
              color: messageColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}
