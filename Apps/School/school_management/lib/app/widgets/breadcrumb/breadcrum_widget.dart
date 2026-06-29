import 'package:flutter/material.dart';

/// A modern, customizable breadcrumb navigation widget.
///
/// This widget displays a horizontal list of breadcrumb items with
/// separators between them. It supports customization of appearance
/// and handles item selection.
class ModernBreadcrumb extends StatelessWidget {
  /// List of breadcrumb items to display
  final List<BreadcrumbItem> items;

  /// Color scheme for the breadcrumb
  final BreadcrumbColors colors;

  /// Typography settings for the breadcrumb
  final BreadcrumbTypography typography;

  /// Callback when a breadcrumb item is tapped
  final void Function(BreadcrumbItem item)? onItemTap;

  /// Separator widget between breadcrumb items
  final Widget separator;

  /// Animation duration for hover/press effects
  final Duration animationDuration;

  const ModernBreadcrumb({
    super.key,
    required this.items,
    this.colors = const BreadcrumbColors(),
    this.typography = const BreadcrumbTypography(),
    this.onItemTap,
    this.separator = const Icon(Icons.chevron_right, size: 16),
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _buildBreadcrumbItems(),
      ),
    );
  }

  List<Widget> _buildBreadcrumbItems() {
    final List<Widget> breadcrumbWidgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      // Add breadcrumb item
      breadcrumbWidgets.add(
        _BreadcrumbItemWidget(
          item: item,
          isLast: isLast,
          colors: colors,
          typography: typography,
          onTap: onItemTap != null ? () => onItemTap!(item) : null,
          animationDuration: animationDuration,
        ),
      );

      // Add separator if not the last item
      if (!isLast) {
        breadcrumbWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconTheme(
              data: IconThemeData(color: colors.separatorColor, size: 16),
              child: separator,
            ),
          ),
        );
      }
    }

    return breadcrumbWidgets;
  }
}

/// Individual breadcrumb item widget
class _BreadcrumbItemWidget extends StatefulWidget {
  final BreadcrumbItem item;
  final bool isLast;
  final BreadcrumbColors colors;
  final BreadcrumbTypography typography;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const _BreadcrumbItemWidget({
    Key? key,
    required this.item,
    required this.isLast,
    required this.colors,
    required this.typography,
    this.onTap,
    required this.animationDuration,
  }) : super(key: key);

  @override
  State<_BreadcrumbItemWidget> createState() => _BreadcrumbItemWidgetState();
}

class _BreadcrumbItemWidgetState extends State<_BreadcrumbItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle =
        widget.isLast
            ? widget.typography.activeTextStyle
            : widget.typography.inactiveTextStyle;

    final Color backgroundColor =
        widget.isLast
            ? widget.colors.activeBackgroundColor
            : (_isHovered
                ? widget.colors.hoverBackgroundColor
                : Colors.transparent);

    final Color borderColor =
        widget.isLast
            ? widget.colors.activeBorderColor
            : (_isHovered
                ? widget.colors.hoverBorderColor
                : Colors.transparent);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor:
          widget.onTap != null && !widget.isLast
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: !widget.isLast ? widget.onTap : null,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(widget.typography.borderRadius),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.item.icon != null) ...[
                Icon(
                  widget.item.icon,
                  size: widget.typography.iconSize,
                  color:
                      widget.isLast
                          ? widget.colors.activeIconColor
                          : widget.colors.inactiveIconColor,
                ),
                const SizedBox(width: 6),
              ],
              Text(widget.item.label, style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data class for breadcrumb item
class BreadcrumbItem {
  final String label;
  final IconData? icon;
  final String id;
  final Map<String, dynamic>? data;

  const BreadcrumbItem({required this.label, this.icon, String? id, this.data})
    : id = id ?? label;
}

/// Customizable color scheme for the breadcrumb
class BreadcrumbColors {
  final Color activeBackgroundColor;
  final Color activeBorderColor;
  final Color activeTextColor;
  final Color activeIconColor;

  final Color inactiveTextColor;
  final Color inactiveIconColor;

  final Color hoverBackgroundColor;
  final Color hoverBorderColor;
  final Color hoverTextColor;

  final Color separatorColor;

  const BreadcrumbColors({
    this.activeBackgroundColor = const Color(0xFFEDF2F7),
    this.activeBorderColor = const Color(0xFFE2E8F0),
    this.activeTextColor = const Color(0xFF2D3748),
    this.activeIconColor = const Color(0xFF2D3748),

    this.inactiveTextColor = const Color(0xFF718096),
    this.inactiveIconColor = const Color(0xFF718096),

    this.hoverBackgroundColor = const Color(0xFFF7FAFC),
    this.hoverBorderColor = const Color(0xFFE2E8F0),
    this.hoverTextColor = const Color(0xFF4A5568),

    this.separatorColor = const Color(0xFFCBD5E0),
  });
}

/// Typography settings for the breadcrumb
class BreadcrumbTypography {
  final TextStyle activeTextStyle;
  final TextStyle inactiveTextStyle;
  final TextStyle hoverTextStyle;
  final double iconSize;
  final double borderRadius;

  const BreadcrumbTypography({
    this.activeTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF2D3748),
    ),
    this.inactiveTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFF718096),
    ),
    this.hoverTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFF4A5568),
    ),
    this.iconSize = 16,
    this.borderRadius = 6,
  });
}
