import 'package:flutter/material.dart';

class AppSelectOption<T> {
  const AppSelectOption({required this.value, required this.label});

  final T value;
  final String label;
}

class AppSelectField<T> extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon,
    this.width,
    this.enabled = true,
    this.fillColor,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 12,
    ),
    this.validator,
    this.borderRadius = 8,
    this.menuMaxHeight,
    this.focusNode,
    this.autofocus = false,
  });

  final String label;
  final T value;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T> onChanged;
  final IconData? icon;
  final double? width;
  final bool enabled;
  final Color? fillColor;
  final EdgeInsetsGeometry contentPadding;
  final FormFieldValidator<T>? validator;
  final double borderRadius;
  final double? menuMaxHeight;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(borderRadius);
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );
    final field = FormField<T>(
      key: ValueKey(value),
      initialValue: value,
      validator: validator,
      builder: (state) {
        return InputDecorator(
          isEmpty: state.value == null,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: icon == null ? null : Icon(icon, size: 18),
            filled: true,
            fillColor: fillColor ?? colorScheme.surface,
            contentPadding: contentPadding,
            border: border,
            enabled: enabled,
            enabledBorder: border,
            errorText: state.errorText,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: state.value,
                isExpanded: true,
                borderRadius: radius,
                menuMaxHeight: menuMaxHeight,
                focusNode: focusNode,
                autofocus: autofocus,
                items: [
                  for (final option in options)
                    DropdownMenuItem<T>(
                      value: option.value,
                      child: Text(
                        option.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged:
                    enabled
                        ? (selected) {
                          final selectedValue = selected as T;
                          state.didChange(selectedValue);
                          onChanged(selectedValue);
                        }
                        : null,
              ),
            ),
          ),
        );
      },
    );

    if (width == null) return field;

    return SizedBox(width: width, child: field);
  }
}
