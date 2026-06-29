// lib/screens/mail/domains_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class DomainsScreen extends ConsumerWidget {
  const DomainsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final domainsAsync = ref.watch(domainsNotifierProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      body: Column(
        children: [
          _buildToolbar(context, colors, ref),
          const Divider(height: 1),
          Expanded(
            child: domainsAsync.when(
              data: (domains) => _DomainGrid(domains: domains, colors: colors, ref: ref),
              loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
              error: (e, _) => Center(child: Text(e.toString(), style: TextStyle(color: colors.accentRed))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, AppColors colors, WidgetRef ref) {
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Text('Virtual Domains', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          GestureDetector(
            onTap: () => _showAddDialog(context, colors, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: colors.accent, size: 16),
                  const SizedBox(width: 6),
                  Text('Add Domain', style: TextStyle(color: colors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppColors colors, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colors.border)),
        title: Text('Add Virtual Domain', style: TextStyle(color: colors.textPrimary)),
        content: TextField(
          controller: ctrl,
          style: TextStyle(color: colors.textPrimary, fontSize: 14),
          decoration: const InputDecoration(labelText: 'Domain (e.g. example.com)', prefixIcon: Icon(Icons.domain_outlined)),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: colors.textSecondary))),
          TextButton(
            onPressed: () async {
              if (ctrl.text.isNotEmpty) {
                await ref.read(domainsNotifierProvider.notifier).addDomain(ctrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: Text('Add', style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _DomainGrid extends StatelessWidget {
  final List<VirtualDomain> domains;
  final AppColors colors;
  final WidgetRef ref;
  const _DomainGrid({required this.domains, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (domains.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.domain_outlined, color: colors.textSecondary, size: 48),
            const SizedBox(height: 16),
            Text('No domains configured', style: TextStyle(color: colors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),
      itemCount: domains.length,
      itemBuilder: (_, i) => _DomainCard(domain: domains[i], colors: colors, ref: ref),
    );
  }
}

class _DomainCard extends StatelessWidget {
  final VirtualDomain domain;
  final AppColors colors;
  final WidgetRef ref;
  const _DomainCard({required this.domain, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: domain.isActive ? colors.border : colors.border.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.domain, color: colors.accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(domain.domain, style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ),
              Switch(
                value: domain.isActive,
                onChanged: (v) => ref.read(domainsNotifierProvider.notifier).toggleDomain(domain.domain, v),
                activeColor: colors.accentGreen,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _Pill('${domain.mailboxCount} mailboxes', Icons.inbox_outlined, colors),
              const SizedBox(width: 8),
              _Pill('${domain.aliasCount} aliases', Icons.alt_route_outlined, colors),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(DateFormat('MMM d, yyyy').format(domain.createdAt), style: TextStyle(color: colors.textSecondary, fontSize: 11)),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final confirm = await _confirmDialog(context, colors, 'Delete ${domain.domain}?', 'This will delete all mailboxes and aliases.');
                  if (confirm == true) await ref.read(domainsNotifierProvider.notifier).deleteDomain(domain.domain);
                },
                child: Icon(Icons.delete_outline, color: colors.accentRed.withOpacity(0.6), size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;
  final AppColors colors;
  const _Pill(this.label, this.icon, this.colors);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

Future<bool?> _confirmDialog(BuildContext context, AppColors colors, String title, String message) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colors.border)),
      title: Text(title, style: TextStyle(color: colors.textPrimary)),
      content: Text(message, style: TextStyle(color: colors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: colors.textSecondary))),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: colors.accentRed))),
      ],
    ),
  );
}
