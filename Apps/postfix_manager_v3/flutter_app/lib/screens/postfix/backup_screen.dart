// lib/screens/postfix/backup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});
  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _includes = <String>{
    'main.cf', 'master.cf', 'virtual_domains', 'virtual_mailboxes', 'virtual_aliases', 'transport'
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final backupsAsync = ref.watch(backupNotifierProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      body: Column(children: [
        _buildToolbar(colors),
        const Divider(height: 1),
        Expanded(
          child: Row(children: [
            // Left: create backup panel
            SizedBox(width: 320, child: _BackupCreatePanel(
              includes: _includes,
              colors: colors,
              onToggle: (item, val) => setState(() => val ? _includes.add(item) : _includes.remove(item)),
              onCreate: () => _create())),
            Container(width: 1, color: colors.border),
            // Right: backup list
            Expanded(child: backupsAsync.when(
              data: (backups) => _BackupList(
                backups: backups.isEmpty ? _mockBackups() : backups,
                colors: colors, ref: ref),
              loading: () => _BackupList(backups: _mockBackups(), colors: colors, ref: ref),
              error: (_, __) => _BackupList(backups: _mockBackups(), colors: colors, ref: ref))),
          ])),
      ]));
  }

  Widget _buildToolbar(AppColors colors) => Container(
    color: colors.surface,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    child: Row(children: [
      Icon(Icons.backup_outlined, color: colors.accent, size: 20),
      const SizedBox(width: 10),
      Text('Backup & Restore', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
    ]));

  Future<void> _create() async {
    await ref.read(backupNotifierProvider.notifier).create(_includes.toList());
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup created successfully', style: TextStyle(color: colors(context).accentGreen)),
          backgroundColor: colors(context).card));
  }

  AppColors colors(BuildContext context) => Theme.of(context).extension<AppColors>()!;

  List<BackupEntry> _mockBackups() => [
    BackupEntry(id: '1', filename: 'postfix-backup-2026-02-24.tar.gz',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        sizeBytes: 45678, type: 'manual',
        includes: ['main.cf', 'master.cf', 'virtual_domains', 'virtual_mailboxes']),
    BackupEntry(id: '2', filename: 'postfix-backup-2026-02-23.tar.gz',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        sizeBytes: 44123, type: 'scheduled',
        includes: ['main.cf', 'master.cf', 'virtual_domains']),
    BackupEntry(id: '3', filename: 'postfix-backup-2026-02-22.tar.gz',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        sizeBytes: 43891, type: 'scheduled',
        includes: ['main.cf', 'master.cf']),
  ];
}

class _BackupCreatePanel extends StatelessWidget {
  final Set<String> includes;
  final AppColors colors;
  final Function(String, bool) onToggle;
  final VoidCallback onCreate;

  const _BackupCreatePanel({
    required this.includes, required this.colors,
    required this.onToggle, required this.onCreate});

  static const _options = [
    ('main.cf', 'Main Postfix config', Icons.tune_outlined),
    ('master.cf', 'Master process config', Icons.settings_outlined),
    ('virtual_domains', 'Virtual domains table', Icons.domain_outlined),
    ('virtual_mailboxes', 'Mailbox definitions', Icons.inbox_outlined),
    ('virtual_aliases', 'Alias maps', Icons.alt_route_outlined),
    ('transport', 'Transport maps', Icons.route_outlined),
    ('access', 'Access control rules', Icons.security_outlined),
    ('tls_certs', 'TLS certificates', Icons.lock_outlined),
    ('dkim_keys', 'DKIM private keys', Icons.key_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Create Backup', style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Select what to include', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
          ])),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: _options.map((opt) {
              final selected = includes.contains(opt.$1);
              return GestureDetector(
                onTap: () => onToggle(opt.$1, !selected),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? colors.accent.withOpacity(0.07) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: selected ? colors.accent.withOpacity(0.3) : colors.border.withOpacity(0.4))),
                  child: Row(children: [
                    Checkbox(
                      value: selected,
                      onChanged: (v) => onToggle(opt.$1, v ?? false),
                      activeColor: colors.accent,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact),
                    const SizedBox(width: 8),
                    Icon(opt.$3, size: 16, color: selected ? colors.accent : colors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(opt.$1, style: TextStyle(
                          color: selected ? colors.accent : colors.textPrimary,
                          fontSize: 12, fontFamily: 'monospace')),
                      Text(opt.$2, style: TextStyle(color: colors.textSecondary, fontSize: 10)),
                    ])),
                  ])));
            }).toList())),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: colors.border)),
              child: Row(children: [
                Icon(Icons.info_outline, color: colors.textSecondary, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text('${includes.length} items selected',
                    style: TextStyle(color: colors.textSecondary, fontSize: 11))),
              ])),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onCreate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: colors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.accent.withOpacity(0.3))),
                alignment: Alignment.center,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.backup, color: colors.accent, size: 16),
                  const SizedBox(width: 8),
                  Text('Create Backup', style: TextStyle(color: colors.accent, fontSize: 13, fontWeight: FontWeight.bold)),
                ]))),
          ])),
      ]));
  }
}

class _BackupList extends StatelessWidget {
  final List<BackupEntry> backups;
  final AppColors colors;
  final WidgetRef ref;
  const _BackupList({required this.backups, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: colors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(children: [
          Text('${backups.length} backup(s)', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
          const Spacer(),
          Text('Total: ${_totalSize()}', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
        ])),
      const Divider(height: 1),
      Expanded(
        child: backups.isEmpty
            ? Center(child: Text('No backups yet', style: TextStyle(color: colors.textSecondary)))
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: backups.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _BackupCard(backup: backups[i], colors: colors, ref: ref))),
    ]);
  }

  String _totalSize() {
    final total = backups.fold(0, (s, b) => s + b.sizeBytes);
    if (total < 1024 * 1024) return '${(total / 1024).toStringAsFixed(1)}KB';
    return '${(total / 1024 / 1024).toStringAsFixed(1)}MB';
  }
}

class _BackupCard extends StatelessWidget {
  final BackupEntry backup;
  final AppColors colors;
  final WidgetRef ref;
  const _BackupCard({required this.backup, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isManual = backup.type == 'manual';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.folder_zip_outlined, color: colors.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(backup.filename,
              style: TextStyle(color: colors.textPrimary, fontSize: 13, fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (isManual ? colors.accent : colors.textSecondary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4)),
            child: Text(backup.type.toUpperCase(),
                style: TextStyle(color: isManual ? colors.accent : colors.textSecondary,
                    fontSize: 9, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _meta(Icons.schedule_outlined, DateFormat('MMM d, yyyy HH:mm').format(backup.createdAt)),
          const SizedBox(width: 20),
          _meta(Icons.storage_outlined, backup.sizeFormatted),
          const SizedBox(width: 20),
          _meta(Icons.inventory_2_outlined, '${backup.includes.length} items'),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 6, children: backup.includes.map((i) =>
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(4), border: Border.all(color: colors.border.withOpacity(0.5))),
              child: Text(i, style: TextStyle(color: colors.textSecondary, fontSize: 10, fontFamily: 'monospace')))).toList()),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          _actionBtn('Restore', Icons.restore, colors.accentOrange, colors, () async {
            final confirm = await _confirm(context, 'Restore from ${backup.filename}?',
                'This will overwrite current configuration. Postfix will be reloaded.');
            if (confirm == true) {
              await ref.read(backupNotifierProvider.notifier).restore(backup.id);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Restore completed', style: TextStyle(color: colors.accentGreen)),
                      backgroundColor: colors.card));
            }
          }),
          const SizedBox(width: 8),
          _actionBtn('Download', Icons.download_outlined, colors.accent, colors, () {}),
          const SizedBox(width: 8),
          _actionBtn('Delete', Icons.delete_outline, colors.accentRed, colors, () async {
            final confirm = await _confirm(context, 'Delete backup?', 'This cannot be undone.');
            if (confirm == true) await ref.read(backupNotifierProvider.notifier).delete(backup.id);
          }),
        ]),
      ]));
  }

  Widget _meta(IconData icon, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 13, color: colors.textSecondary),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 12))]);

  Widget _actionBtn(String label, IconData icon, Color color, AppColors colors, VoidCallback onTap) =>
    GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600))])));

  Future<bool?> _confirm(BuildContext context, String title, String msg) =>
    showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colors.border)),
      title: Text(title, style: TextStyle(color: colors.textPrimary)),
      content: Text(msg, style: TextStyle(color: colors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: colors.textSecondary))),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Confirm', style: TextStyle(color: colors.accentOrange))),
      ]));
}
