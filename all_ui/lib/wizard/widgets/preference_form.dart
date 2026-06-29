// Step 3: Preferences Form
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/preference.dart';
import '../states/user_profile_provider.dart';

class PreferencesForm extends ConsumerStatefulWidget {
  const PreferencesForm({super.key});

  @override
  ConsumerState<PreferencesForm> createState() => _PreferencesFormState();
}

class _PreferencesFormState extends ConsumerState<PreferencesForm> {
  bool _notifications = true;
  String _theme = 'light';
  bool _newsletter = false;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(preferencesProvider);
    if (prefs != null) {
      _notifications = prefs.notifications;
      _theme = prefs.theme;
      _newsletter = prefs.newsletter;
    }
  }

  void _savePreferences() {
    ref.read(preferencesProvider.notifier).state = Preference(
      notifications: _notifications,
      theme: _theme,
      newsletter: _newsletter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive updates and alerts'),
                value: _notifications,
                onChanged: (value) {
                  setState(() {
                    _notifications = value;
                  });
                  _savePreferences();
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Theme'),
                subtitle: const Text('Choose your preferred theme'),
                trailing: DropdownButton<String>(
                  value: _theme,
                  items: const [
                    DropdownMenuItem(value: 'light', child: Text('Light')),
                    DropdownMenuItem(value: 'dark', child: Text('Dark')),
                    DropdownMenuItem(value: 'auto', child: Text('Auto')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _theme = value;
                      });
                      _savePreferences();
                    }
                  },
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Newsletter Subscription'),
                subtitle: const Text('Receive weekly updates via email'),
                value: _newsletter,
                onChanged: (value) {
                  setState(() {
                    _newsletter = value;
                  });
                  _savePreferences();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
