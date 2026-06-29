import 'package:flutter/material.dart';

class GlobalSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String hintText;
  final bool autofocus;
  final bool enabled;
  final bool filled;
  final Color? fillColor;
  final double borderRadius;
  final BorderSide? borderSide;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixIcon;
  final Widget? clearIcon;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Color? cursorColor;

  const GlobalSearchField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hintText = 'Cari...',
    this.autofocus = false,
    this.enabled = true,
    this.filled = true,
    this.fillColor,
    this.borderRadius = 14,
    this.borderSide,
    this.contentPadding,
    this.prefixIcon,
    this.clearIcon,
    this.hintStyle,
    this.textStyle,
    this.cursorColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedFillColor =
        fillColor ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    final resolvedBorderSide = borderSide ?? BorderSide.none;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          autofocus: autofocus,
          enabled: enabled,
          style: textStyle,
          cursorColor: cursorColor,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle,
            prefixIcon: prefixIcon ?? const Icon(Icons.search),
            suffixIcon: value.text.isNotEmpty && onClear != null
                ? IconButton(
                    icon: clearIcon ?? const Icon(Icons.clear),
                    onPressed: onClear,
                  )
                : null,
            filled: filled,
            fillColor: resolvedFillColor,
            contentPadding: contentPadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: resolvedBorderSide,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: resolvedBorderSide,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: resolvedBorderSide,
            ),
          ),
        );
      },
    );
  }
}
