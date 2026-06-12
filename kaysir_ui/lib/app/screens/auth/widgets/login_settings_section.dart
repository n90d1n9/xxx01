import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_checkbox_row.dart';
import 'package:kaysir/widgets/ui/app_icon_action_button.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

class LoginSettingsSection extends StatelessWidget {
  const LoginSettingsSection({
    super.key,
    required this.rememberMe,
    required this.isLoading,
    required this.locale,
    required this.supportedLocales,
    required this.isDarkMode,
    required this.localeLabel,
    required this.onRememberChanged,
    required this.onLocaleChanged,
    required this.onThemeToggle,
  });

  final bool rememberMe;
  final bool isLoading;
  final Locale locale;
  final List<Locale> supportedLocales;
  final bool isDarkMode;
  final String Function(Locale locale) localeLabel;
  final ValueChanged<bool?> onRememberChanged;
  final ValueChanged<Locale?> onLocaleChanged;
  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCheckboxRow(
          title: 'Remember me',
          controlAffinity: ListTileControlAffinity.leading,
          value: rememberMe,
          onChanged: isLoading ? null : onRememberChanged,
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildLanguageDropdown()),
            const SizedBox(width: 12),
            _ThemeToggleButton(
              isDarkMode: isDarkMode,
              onPressed: isLoading ? null : onThemeToggle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown() {
    return AppSelectField<Locale>(
      label: 'Language',
      icon: Icons.language,
      value: locale,
      enabled: !isLoading,
      options: [
        for (final locale in supportedLocales)
          AppSelectOption(value: locale, label: localeLabel(locale)),
      ],
      onChanged: (selectedLocale) => onLocaleChanged(selectedLocale),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.isDarkMode, required this.onPressed});

  final bool isDarkMode;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppIconActionButton(
      icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
      tooltip: isDarkMode ? 'Use light theme' : 'Use dark theme',
      onPressed: onPressed,
      variant: AppIconActionButtonVariant.tonal,
      size: 56,
      iconSize: 22,
    );
  }
}
