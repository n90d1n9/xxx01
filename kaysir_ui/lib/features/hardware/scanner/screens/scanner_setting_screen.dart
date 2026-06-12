import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class ScannerSettingsScreen extends ConsumerStatefulWidget {
  const ScannerSettingsScreen({super.key});

  @override
  ConsumerState<ScannerSettingsScreen> createState() =>
      _ScannerSettingsScreenState();
}

class _ScannerSettingsScreenState extends ConsumerState<ScannerSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(scannerSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _testScanner,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDeviceSettings(),
            _buildScannerBehavior(),
            _buildFormatSettings(),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
