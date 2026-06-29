// Settings Page
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/settings_provider.dart';

class RadioSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Radio Player Settings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<RadioSettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            children: [
              SwitchListTile(
                title: Text('Auto Play Next Stream'),
                subtitle: Text(
                  'Automatically switch to next stream on failure',
                ),
                value: settingsProvider.autoPlayNextStream,
                onChanged: (bool value) {
                  settingsProvider.setAutoPlayNextStream(value);
                },
              ),
              SwitchListTile(
                title: Text('Save Data Mode'),
                subtitle: Text('Reduce stream quality to save bandwidth'),
                value: settingsProvider.saveDataMode,
                onChanged: (bool value) {
                  settingsProvider.setSaveDataMode(value);
                },
              ),
              ListTile(
                title: Text('Preferred Category'),
                subtitle: Text(settingsProvider.preferredCategory),
                onTap: () {
                  _showCategoryDialog(context, settingsProvider);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCategoryDialog(
    BuildContext context,
    RadioSettingsProvider provider,
  ) {
    final categories = ['All', 'News', 'Music', 'Sports', 'Talk'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Select Preferred Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  categories
                      .map(
                        (category) => ListTile(
                          title: Text(category),
                          onTap: () {
                            provider.setPreferredCategory(category);
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }
}
