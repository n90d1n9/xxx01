import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.errorText,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.showVisibilityToggle = false,
    this.isPasswordVisible = false,
    this.onVisibilityToggle,
    this.onFieldSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool showVisibilityToggle;
  final bool isPasswordVisible;
  final VoidCallback? onVisibilityToggle;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        filled: true,
        fillColor: colorScheme.surface,
        prefixIcon: Icon(icon),
        suffixIcon: _buildSuffixIcon(),
        border: _border(colorScheme.outlineVariant),
        enabledBorder: _border(colorScheme.outlineVariant),
        focusedBorder: _border(colorScheme.primary, width: 1.4),
        errorBorder: _border(colorScheme.error),
        focusedErrorBorder: _border(colorScheme.error, width: 1.4),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (!showVisibilityToggle) {
      return null;
    }

    return IconButton(
      tooltip: isPasswordVisible ? 'Hide password' : 'Show password',
      onPressed: onVisibilityToggle,
      icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
