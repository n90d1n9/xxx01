import 'package:flutter/material.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.hintText,
    this.controller,
    this.focusNode,
    this.displayText,
    this.onChanged,
    this.onSubmitted,
    this.onKeyEvent,
    this.onTap,
    this.trailing,
    this.tooltip,
    this.autofocus = false,
    this.readOnly = false,
    this.width,
    this.height = 44,
    this.icon = Icons.search,
    this.borderRadius = 8,
    this.backgroundColor,
    this.borderColor,
  });

  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? displayText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusOnKeyEventCallback? onKeyEvent;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? tooltip;
  final bool autofocus;
  final bool readOnly;
  final double? width;
  final double height;
  final IconData icon;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final field = SizedBox(
      width: width,
      height: height,
      child:
          readOnly
              ? _buildReadOnlyField(context)
              : _buildEditableField(context),
    );

    if (tooltip == null) return field;

    return Tooltip(message: tooltip, child: field);
  }

  Widget _buildReadOnlyField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = displayText ?? hintText;

    final field = Material(
      color: Colors.transparent,
      child: Ink(
        decoration: _decoration(colorScheme),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 10), trailing!],
              ],
            ),
          ),
        ),
      ),
    );

    if (onKeyEvent == null) return field;

    return Focus(onKeyEvent: onKeyEvent, child: field);
  }

  Widget _buildEditableField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: _decoration(colorScheme),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            isDense: true,
            prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
            prefixIconConstraints: const BoxConstraints(minWidth: 42),
            suffixIcon:
                trailing == null
                    ? null
                    : Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: trailing,
                    ),
            suffixIconConstraints: BoxConstraints(
              minWidth: 0,
              minHeight: height,
            ),
          ),
          textInputAction: TextInputAction.search,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }

  BoxDecoration _decoration(ColorScheme? colorScheme) {
    final scheme = colorScheme;
    return BoxDecoration(
      color: backgroundColor ?? scheme?.surfaceContainerLow,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? scheme?.outlineVariant ?? Colors.transparent,
      ),
    );
  }
}
