import 'package:flutter/material.dart';

import '../../../widgets/ui/app_select_field.dart';
import '../../../widgets/ui/app_toggle_row.dart';
import 'admin_dialog_header.dart';
import 'admin_dialog_surface.dart';

class AdminAccountSettingsPanel extends StatelessWidget {
  const AdminAccountSettingsPanel({
    super.key,
    required this.themeMode,
    required this.locale,
    required this.supportedLocales,
    required this.onToggleTheme,
    required this.onLocaleChanged,
    this.onClose,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final List<Locale> supportedLocales;
  final VoidCallback onToggleTheme;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return AdminDialogSurface(
      maxWidth: 460,
      maxHeight: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdminDialogHeader(
            icon: Icons.tune,
            title: 'Settings',
            subtitle: 'Theme and workspace language',
            onClose: onClose,
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppToggleRow(
                  contained: true,
                  iconBadge: true,
                  icon:
                      themeMode == ThemeMode.dark
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                  title: 'Dark mode',
                  subtitle: 'Switch the admin shell appearance',
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) => onToggleTheme(),
                ),
                const SizedBox(height: 14),
                AppSelectField<Locale>(
                  label: 'Language',
                  icon: Icons.language,
                  value: locale,
                  options:
                      supportedLocales
                          .map(
                            (locale) => AppSelectOption<Locale>(
                              value: locale,
                              label: localeLabel(locale),
                            ),
                          )
                          .toList(),
                  onChanged: onLocaleChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String localeLabel(Locale locale) {
    switch (locale.languageCode) {
      case 'id':
        return 'Bahasa Indonesia';
      case 'en':
        return 'English';
      default:
        return locale.toLanguageTag();
    }
  }
}
