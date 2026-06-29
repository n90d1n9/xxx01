import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading_mode.dart';
import '../models/reading_preferences.dart';
import '../states/quran_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(readingPreferencesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: prefsAsync.when(
        data:
            (prefs) => ListView(
              children: [
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.view_agenda),
                  title: const Text('Reading Mode'),
                  subtitle: Text(
                    prefs.readingMode == ReadingMode.pageByPage
                        ? 'Page by Page'
                        : 'Continuous',
                  ),
                  trailing: Switch(
                    value: prefs.readingMode == ReadingMode.pageByPage,
                    onChanged: (value) async {
                      final newPrefs = prefs.copyWith(
                        readingMode:
                            value
                                ? ReadingMode.pageByPage
                                : ReadingMode.continuous,
                      );
                      await ref
                          .read(preferencesServiceProvider)
                          .savePreferences(newPrefs);
                      ref.invalidate(readingPreferencesProvider);
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.format_size),
                  title: const Text('Arabic Font Size'),
                  subtitle: Text('${prefs.arabicFontSize.toInt()}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Slider(
                    value: prefs.arabicFontSize,
                    min: 16,
                    max: 36,
                    divisions: 20,
                    label: prefs.arabicFontSize.toInt().toString(),
                    onChanged: (value) async {
                      final newPrefs = prefs.copyWith(arabicFontSize: value);
                      await ref
                          .read(preferencesServiceProvider)
                          .savePreferences(newPrefs);
                      ref.invalidate(readingPreferencesProvider);
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.format_size),
                  title: const Text('Translation Font Size'),
                  subtitle: Text('${prefs.translationFontSize.toInt()}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Slider(
                    value: prefs.translationFontSize,
                    min: 12,
                    max: 24,
                    divisions: 12,
                    label: prefs.translationFontSize.toInt().toString(),
                    onChanged: (value) async {
                      final newPrefs = prefs.copyWith(
                        translationFontSize: value,
                      );
                      await ref
                          .read(preferencesServiceProvider)
                          .savePreferences(newPrefs);
                      ref.invalidate(readingPreferencesProvider);
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.translate),
                  title: const Text('Translation'),
                  subtitle: Text(
                    _getTranslationName(ref.watch(selectedTranslationProvider)),
                  ),
                  onTap: () => _showTranslationPicker(context, ref),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.record_voice_over),
                  title: const Text('Reciter'),
                  subtitle: Text(_getReciterName(prefs.reciter)),
                  onTap: () => _showReciterPicker(context, ref, prefs),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About'),
                  subtitle: Text('Quran Reader App\nVersion 1.0.0'),
                ),
              ],
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _getTranslationName(String code) {
    final Map<String, String> translations = {
      'en.sahih': 'Sahih International',
      'en.pickthall': 'Pickthall',
      'en.yusufali': 'Yusuf Ali',
      'en.hilali': 'Hilali & Khan',
      'id.indonesian': 'Indonesian (Bahasa Indonesia)',
    };
    return translations[code] ?? code;
  }

  String _getReciterName(String code) {
    final Map<String, String> reciters = {
      'ar.alafasy': 'Mishary Alafasy',
      'ar.abdulbasit': 'Abdul Basit',
      'ar.husary': 'Mahmoud Khalil Al-Hussary',
      'ar.minshawi': 'Mohamed Siddiq El-Minshawi',
      'ar.shaatree': "Abu Bakr al-Shatri",
    };
    return reciters[code] ?? code;
  }

  void _showTranslationPicker(BuildContext context, WidgetRef ref) {
    final translations = {
      'en.sahih': 'Sahih International',
      'en.pickthall': 'Pickthall',
      'en.yusufali': 'Yusuf Ali',
      'en.hilali': 'Hilali & Khan',
      'id.indonesian': 'Indonesian (Bahasa Indonesia)',
    };
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Translation'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children:
                    translations.entries.map((entry) {
                      return RadioListTile<String>(
                        title: Text(entry.value),
                        value: entry.key,
                        groupValue: ref.read(selectedTranslationProvider),
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(selectedTranslationProvider.notifier)
                                .state = value;
                            Navigator.pop(context);
                          }
                        },
                      );
                    }).toList(),
              ),
            ),
          ),
    );
  }

  void _showReciterPicker(
    BuildContext context,
    WidgetRef ref,
    ReadingPreferences prefs,
  ) {
    final reciters = {
      'ar.alafasy': 'Mishary Alafasy',
      'ar.abdulbasit': 'Abdul Basit',
      'ar.husary': 'Mahmoud Khalil Al-Hussary',
      'ar.minshawi': 'Mohamed Siddiq El-Minshawi',
      'ar.shaatree': "Abu Bakr al-Shatri",
    };
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Reciter'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children:
                    reciters.entries.map((entry) {
                      return RadioListTile<String>(
                        title: Text(entry.value),
                        value: entry.key,
                        groupValue: prefs.reciter,
                        onChanged: (value) async {
                          if (value != null) {
                            final newPrefs = prefs.copyWith(reciter: value);
                            await ref
                                .read(preferencesServiceProvider)
                                .savePreferences(newPrefs);
                            ref.invalidate(readingPreferencesProvider);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        },
                      );
                    }).toList(),
              ),
            ),
          ),
    );
  }
}
