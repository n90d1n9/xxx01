import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class CashDrawerSettingsScreen extends ConsumerStatefulWidget {
  const CashDrawerSettingsScreen({super.key});

  @override
  ConsumerState<CashDrawerSettingsScreen> createState() =>
      _CashDrawerSettingsScreenState();
}

class _CashDrawerSettingsScreenState
    extends ConsumerState<CashDrawerSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(cashDrawerSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Drawer Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _testCashDrawer,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPortSettings(),
            _buildBehaviorSettings(),
            _buildSecuritySettings(),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testCashDrawer() async {
    final approved = await ref
        .read(supervisorProvider.notifier)
        .requestApproval(
          actionType: 'TEST_CASH_DRAWER',
          reason: 'Testing cash drawer configuration',
        );

    if (approved) {
      // Implement cash drawer test
    }
  }
}
