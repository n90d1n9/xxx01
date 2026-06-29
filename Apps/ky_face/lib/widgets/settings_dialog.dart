import 'package:flutter/material.dart';

import '../models/face_auth_state.dart';
import '../states/face_auth_provider.dart';

class SettingsDialog extends StatefulWidget {
  final FaceAuthState authState;
  final EnhancedFaceAuthNotifier authNotifier;

  const SettingsDialog({
    super.key,
    required this.authState,
    required this.authNotifier,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late Map<String, dynamic> _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = Map.from(widget.authState.settings);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Authentication Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Enable Fallback to Biometric'),
              value: _currentSettings['biometric_fallback'] ?? true,
              onChanged: (value) {
                setState(() {
                  _currentSettings['biometric_fallback'] = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Require Strong Match'),
              subtitle: const Text('Higher security, lower convenience'),
              value: _currentSettings['strong_match'] ?? false,
              onChanged: (value) {
                setState(() {
                  _currentSettings['strong_match'] = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Privacy Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Store Metadata'),
              subtitle: const Text('Device info, location, etc.'),
              value: _currentSettings['store_metadata'] ?? true,
              onChanged: (value) {
                setState(() {
                  _currentSettings['store_metadata'] = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Analytics'),
              subtitle: const Text('Help improve the app'),
              value: _currentSettings['analytics'] ?? true,
              onChanged: (value) {
                setState(() {
                  _currentSettings['analytics'] = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.authNotifier.updateSettings(_currentSettings);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
