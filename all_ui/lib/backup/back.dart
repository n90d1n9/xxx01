import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';

// Data models
class BackupItem {
  final String id;
  final String name;
  final DateTime date;
  final int size;
  final String location;

  BackupItem({
    required this.id,
    required this.name,
    required this.date,
    required this.size,
    required this.location,
  });
}

// Providers
final backupListProvider =
    StateNotifierProvider<BackupListNotifier, List<BackupItem>>((ref) {
      return BackupListNotifier();
    });

final backupInProgressProvider = StateProvider<bool>((ref) => false);
final recoveryInProgressProvider = StateProvider<bool>((ref) => false);
final selectedBackupProvider = StateProvider<String?>((ref) => null);

// Notifiers
class BackupListNotifier extends StateNotifier<List<BackupItem>> {
  BackupListNotifier()
    : super([
        BackupItem(
          id: '1',
          name: 'Daily Backup',
          date: DateTime.now().subtract(const Duration(hours: 12)),
          size: 256,
          location: 'Cloud Storage',
        ),
        BackupItem(
          id: '2',
          name: 'Weekly Backup',
          date: DateTime.now().subtract(const Duration(days: 3)),
          size: 1024,
          location: 'Local Storage',
        ),
        BackupItem(
          id: '3',
          name: 'Monthly Backup',
          date: DateTime.now().subtract(const Duration(days: 28)),
          size: 4096,
          location: 'External Drive',
        ),
      ]);

  void addBackup(BackupItem backup) {
    state = [...state, backup];
  }

  void removeBackup(String id) {
    state = state.where((backup) => backup.id != id).toList();
  }
}

// Services
class BackupService {
  Future<bool> createBackup(WidgetRef ref) async {
    ref.read(backupInProgressProvider.notifier).state = true;

    // Simulate backup process
    await Future.delayed(const Duration(seconds: 3));

    final newBackup = BackupItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'New Backup',
      date: DateTime.now(),
      size: 512,
      location: 'Cloud Storage',
    );

    ref.read(backupListProvider.notifier).addBackup(newBackup);
    ref.read(backupInProgressProvider.notifier).state = false;
    return true;
  }

  Future<bool> recoverData(String backupId, WidgetRef ref) async {
    ref.read(recoveryInProgressProvider.notifier).state = true;

    // Simulate recovery process
    await Future.delayed(const Duration(seconds: 5));

    ref.read(recoveryInProgressProvider.notifier).state = false;
    return true;
  }
}

// Main Screen
class BackupRecoveryScreen extends ConsumerWidget {
  BackupRecoveryScreen({Key? key}) : super(key: key);

  final BackupService _backupService = BackupService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backups = ref.watch(backupListProvider);
    final backupInProgress = ref.watch(backupInProgressProvider);
    final recoveryInProgress = ref.watch(recoveryInProgressProvider);
    final selectedBackupId = ref.watch(selectedBackupProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Backup & Recovery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_done, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Backup Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Last backup: ${backups.isNotEmpty ? _formatDate(backups.first.date) : 'None'}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total backups: ${backups.length}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          backupInProgress
                              ? null
                              : () => _backupService.createBackup(ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child:
                              backupInProgress
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'Backup Now',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Backup List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Backup History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Sort'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child:
                backups.isEmpty
                    ? const Center(child: Text('No backups available'))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: backups.length,
                      itemBuilder: (context, index) {
                        final backup = backups[index];
                        final isSelected = backup.id == selectedBackupId;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  isSelected
                                      ? Colors.blue.shade400
                                      : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              ref.read(selectedBackupProvider.notifier).state =
                                  isSelected ? null : backup.id;
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getBackupIcon(backup.location),
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          backup.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_formatDate(backup.date)} • ${_formatSize(backup.size)}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          backup.location,
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () {
                                      _showBackupOptions(context, backup, ref);
                                    },
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar:
          selectedBackupId != null
              ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed:
                        recoveryInProgress
                            ? null
                            : () {
                              _showRecoveryConfirmation(
                                context,
                                selectedBackupId!,
                                ref,
                              );
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child:
                        recoveryInProgress
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Recover Selected Backup',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              )
              : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatSize(int sizeInMB) {
    if (sizeInMB < 1000) {
      return '$sizeInMB MB';
    } else {
      final sizeInGB = (sizeInMB / 1024).toStringAsFixed(1);
      return '$sizeInGB GB';
    }
  }

  IconData _getBackupIcon(String location) {
    switch (location) {
      case 'Cloud Storage':
        return Icons.cloud_upload;
      case 'Local Storage':
        return Icons.smartphone;
      case 'External Drive':
        return Icons.storage;
      default:
        return Icons.backup;
    }
  }

  void _showBackupOptions(
    BuildContext context,
    BackupItem backup,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Backup Details'),
                  onTap: () {
                    Navigator.pop(context);
                    _showBackupDetails(context, backup);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Restore from this Backup'),
                  onTap: () {
                    Navigator.pop(context);
                    _showRecoveryConfirmation(context, backup.id, ref);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share Backup'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Delete Backup',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, backup, ref);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBackupDetails(BuildContext context, BackupItem backup) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Backup Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Name', backup.name),
              _detailRow('Date', _formatDate(backup.date)),
              _detailRow('Size', _formatSize(backup.size)),
              _detailRow('Location', backup.location),
              _detailRow('ID', backup.id),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showRecoveryConfirmation(
    BuildContext context,
    String backupId,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recover Data'),
          content: const Text(
            'Are you sure you want to recover data from this backup? This will replace your current data.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performRecovery(backupId, ref, context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
              ),
              child: const Text('Recover'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    BackupItem backup,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Backup'),
          content: Text('Are you sure you want to delete "${backup.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(backupListProvider.notifier).removeBackup(backup.id);
                if (ref.read(selectedBackupProvider) == backup.id) {
                  ref.read(selectedBackupProvider.notifier).state = null;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${backup.name} deleted')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performRecovery(
    String backupId,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final result = await _backupService.recoverData(backupId, ref);

    if (!context.mounted) return;

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data recovered successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recovery failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Main app widget
class BackupRecoveryApp extends ConsumerWidget {
  const BackupRecoveryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
      ),
      home: BackupRecoveryScreen(),
    );
  }
}

// Entry point
void main() {
  runApp(const ProviderScope(child: BackupRecoveryApp()));
}

// Optional: Add these utility functions and classes if you want more comprehensive backup functionality

// Backup scheduler
class BackupScheduler {
  final Stream<DateTime> _dailyTrigger;
  final Stream<DateTime> _weeklyTrigger;
  StreamSubscription? _dailySubscription;
  StreamSubscription? _weeklySubscription;
  final WidgetRef _ref;

  BackupScheduler(this._ref)
    : _dailyTrigger = Stream.periodic(
        const Duration(days: 1),
        (count) => DateTime.now(),
      ),
      _weeklyTrigger = Stream.periodic(
        const Duration(days: 7),
        (count) => DateTime.now(),
      );

  void startScheduling() {
    final backupService = BackupService();

    _dailySubscription = _dailyTrigger.listen((_) {
      backupService.createBackup(_ref);
    });

    _weeklySubscription = _weeklyTrigger.listen((_) {
      backupService.createBackup(_ref);
    });
  }

  void stopScheduling() {
    _dailySubscription?.cancel();
    _weeklySubscription?.cancel();
  }
}

// Backup configuration
class BackupConfig {
  final bool autoBackup;
  final bool wifiOnly;
  final int retentionDays;
  final String backupLocation;

  BackupConfig({
    this.autoBackup = true,
    this.wifiOnly = true,
    this.retentionDays = 30,
    this.backupLocation = 'Cloud Storage',
  });
}

// Backup configuration provider
final backupConfigProvider = StateProvider<BackupConfig>((ref) {
  return BackupConfig();
});

// Settings screen (bonus content)
class BackupSettingsScreen extends ConsumerWidget {
  const BackupSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(backupConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Backup Schedule',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Automatic Backup'),
                    subtitle: const Text('Backup data automatically'),
                    value: config.autoBackup,
                    onChanged: (value) {
                      ref
                          .read(backupConfigProvider.notifier)
                          .state = BackupConfig(
                        autoBackup: value,
                        wifiOnly: config.wifiOnly,
                        retentionDays: config.retentionDays,
                        backupLocation: config.backupLocation,
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Wi-Fi Only'),
                    subtitle: const Text('Only backup when connected to Wi-Fi'),
                    value: config.wifiOnly,
                    onChanged:
                        config.autoBackup
                            ? (value) {
                              ref
                                  .read(backupConfigProvider.notifier)
                                  .state = BackupConfig(
                                autoBackup: config.autoBackup,
                                wifiOnly: value,
                                retentionDays: config.retentionDays,
                                backupLocation: config.backupLocation,
                              );
                            }
                            : null,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Storage Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Backup Location',
                      border: OutlineInputBorder(),
                    ),
                    value: config.backupLocation,
                    items: const [
                      DropdownMenuItem(
                        value: 'Cloud Storage',
                        child: Text('Cloud Storage'),
                      ),
                      DropdownMenuItem(
                        value: 'Local Storage',
                        child: Text('Local Storage'),
                      ),
                      DropdownMenuItem(
                        value: 'External Drive',
                        child: Text('External Drive'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(backupConfigProvider.notifier)
                            .state = BackupConfig(
                          autoBackup: config.autoBackup,
                          wifiOnly: config.wifiOnly,
                          retentionDays: config.retentionDays,
                          backupLocation: value,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Keep backups for ${config.retentionDays} days',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: config.retentionDays.toDouble(),
                    min: 7,
                    max: 90,
                    divisions: 12,
                    label: '${config.retentionDays} days',
                    onChanged: (value) {
                      ref
                          .read(backupConfigProvider.notifier)
                          .state = BackupConfig(
                        autoBackup: config.autoBackup,
                        wifiOnly: config.wifiOnly,
                        retentionDays: value.toInt(),
                        backupLocation: config.backupLocation,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Security',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const SwitchListTile(
                    title: Text('Encrypt Backups'),
                    subtitle: Text('Secure your data with encryption'),
                    value: true,
                    onChanged: null, // Set as always enabled
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Password Protection'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
