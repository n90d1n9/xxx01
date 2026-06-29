// lib/screens/mail/mailboxes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class MailboxesScreen extends ConsumerWidget {
  const MailboxesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final mailboxAsync = ref.watch(mailboxNotifierProvider);
    final domainsAsync = ref.watch(domainsNotifierProvider);
    final selectedDomain = ref.watch(selectedDomainProvider);

    final domains = domainsAsync.value ?? [];

    return Scaffold(
      backgroundColor: colors.bg,
      body: Column(
        children: [
          _buildToolbar(context, colors, ref, domains, selectedDomain),
          const Divider(height: 1),
          Expanded(
            child: mailboxAsync.when(
              data: (boxes) => _MailboxList(mailboxes: boxes, colors: colors, ref: ref),
              loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
              error: (e, _) => Center(child: Text(e.toString(), style: TextStyle(color: colors.accentRed))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, AppColors colors, WidgetRef ref,
      List<VirtualDomain> domains, String? selectedDomain) {
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Text('Mailboxes', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 24),
          // Domain filter dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: colors.border)),
            child: DropdownButton<String?>(
              value: selectedDomain,
              hint: Text('All Domains', style: TextStyle(color: colors.textSecondary, fontSize: 13)),
              dropdownColor: colors.card,
              underline: const SizedBox.shrink(),
              style: TextStyle(color: colors.textPrimary, fontSize: 13),
              items: [
                DropdownMenuItem<String?>(value: null, child: Text('All Domains', style: TextStyle(color: colors.textSecondary, fontSize: 13))),
                ...domains.map((d) => DropdownMenuItem<String?>(value: d.domain, child: Text(d.domain))),
              ],
              onChanged: (v) => ref.read(selectedDomainProvider.notifier).state = v,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showAddDialog(context, colors, ref, domains),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.accent.withOpacity(0.3)),
              ),
              child: Row(children: [
                Icon(Icons.add, color: colors.accent, size: 16),
                const SizedBox(width: 6),
                Text('Add Mailbox', style: TextStyle(color: colors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppColors colors, WidgetRef ref, List<VirtualDomain> domains) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    int quota = 1024;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState) => AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colors.border)),
          title: Text('Add Mailbox', style: TextStyle(color: colors.textPrimary)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailCtrl,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  style: TextStyle(color: colors.textPrimary),
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outlined)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Quota: ${quota}MB', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: quota.toDouble(),
                        min: 100,
                        max: 10240,
                        divisions: 20,
                        activeColor: colors.accent,
                        onChanged: (v) => setState(() => quota = v.toInt()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: colors.textSecondary))),
            TextButton(
              onPressed: () async {
                if (emailCtrl.text.isNotEmpty && passCtrl.text.isNotEmpty) {
                  await ref.read(mailboxNotifierProvider.notifier).addMailbox(
                        email: emailCtrl.text.trim(),
                        password: passCtrl.text,
                        quotaMb: quota,
                      );
                  Navigator.pop(ctx);
                }
              },
              child: Text('Create', style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MailboxList extends StatelessWidget {
  final List<VirtualMailbox> mailboxes;
  final AppColors colors;
  final WidgetRef ref;
  const _MailboxList({required this.mailboxes, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (mailboxes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, color: colors.textSecondary, size: 48),
            const SizedBox(height: 16),
            Text('No mailboxes found', style: TextStyle(color: colors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Table header
        Container(
          color: colors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            children: [
              _hcol('Email', flex: 3, colors: colors),
              _hcol('Domain', flex: 2, colors: colors),
              _hcol('Quota Usage', flex: 2, colors: colors),
              _hcol('Status', flex: 1, colors: colors),
              _hcol('Last Login', flex: 2, colors: colors),
              _hcol('Created', flex: 2, colors: colors),
              const SizedBox(width: 100),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: mailboxes.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: colors.border.withOpacity(0.5)),
            itemBuilder: (_, i) => _MailboxRow(mailbox: mailboxes[i], colors: colors, ref: ref),
          ),
        ),
      ],
    );
  }

  Widget _hcol(String label, {required int flex, required AppColors colors}) => Expanded(
        flex: flex,
        child: Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 11, letterSpacing: 0.5)),
      );
}

class _MailboxRow extends StatelessWidget {
  final VirtualMailbox mailbox;
  final AppColors colors;
  final WidgetRef ref;
  const _MailboxRow({required this.mailbox, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    final usagePct = mailbox.usagePercent;
    final usageColor = usagePct > 90 ? colors.accentRed : usagePct > 70 ? colors.accentOrange : colors.accentGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(mailbox.localPart.isNotEmpty ? mailbox.localPart[0].toUpperCase() : '?',
                      style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(mailbox.email, style: TextStyle(color: colors.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(mailbox.domain, style: TextStyle(color: colors.textSecondary, fontSize: 12))),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${mailbox.usedMb}MB / ${mailbox.quotaMb}MB', style: TextStyle(color: colors.textSecondary, fontSize: 11)),
                    const Spacer(),
                    Text('${usagePct.toStringAsFixed(0)}%', style: TextStyle(color: usageColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: usagePct / 100,
                  backgroundColor: colors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(usageColor),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Switch(
              value: mailbox.isActive,
              onChanged: (v) => ref.read(mailboxNotifierProvider.notifier).toggleMailbox(mailbox.email, v),
              activeColor: colors.accentGreen,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              mailbox.lastLogin != null ? DateFormat('MMM d, HH:mm').format(mailbox.lastLogin!) : 'Never',
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(DateFormat('MMM d, yyyy').format(mailbox.createdAt), style: TextStyle(color: colors.textSecondary, fontSize: 12)),
          ),
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.key_outlined, size: 16, color: colors.accentOrange),
                  tooltip: 'Change Password',
                  onPressed: () => _changePassword(context),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 16, color: colors.accentRed),
                  tooltip: 'Delete',
                  onPressed: () async {
                    await ref.read(mailboxNotifierProvider.notifier).deleteMailbox(mailbox.email);
                  },
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _changePassword(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colors.border)),
        title: Text('Change Password', style: TextStyle(color: colors.textPrimary)),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          style: TextStyle(color: colors.textPrimary),
          decoration: const InputDecoration(labelText: 'New Password', prefixIcon: Icon(Icons.lock_outlined)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: colors.textSecondary))),
          TextButton(
            onPressed: () async {
              if (ctrl.text.isNotEmpty) {
                await ref.read(apiServiceProvider).updateMailboxPassword(mailbox.email, ctrl.text);
                Navigator.pop(ctx);
              }
            },
            child: Text('Update', style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
