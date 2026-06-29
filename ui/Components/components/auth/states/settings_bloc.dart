import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/helper.dart';

final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
final localeProvider = StateProvider<Locale>((ref) => supportedLocales.first);

final appThemeProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeProvider);
  return themeMode == ThemeMode.dark ? darkTheme : lightTheme;
});
/* 
final settingsBloc = ChangeNotifierProvider<SettingsBloc>((ref) => SettingsBloc());

class SettingsBloc extends ChangeNotifier {

  bool isLightTheme = true;
  Locale locale = const Locale('en', 'EN');

  final List<Locale> supportedLocales = [
      const Locale('en', 'EN'),
      const Locale('id', 'ID'),
    ];

  switchTheme() {
    isLightTheme = isLightTheme ? false:true;
    notifyListeners();
  }

  switchLocale(String flag) {
    locale = Locale(flag.toLowerCase(), flag);
    notifyListeners();
  }
}
 */