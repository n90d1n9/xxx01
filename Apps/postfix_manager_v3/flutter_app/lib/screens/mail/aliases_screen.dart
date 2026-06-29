// lib/screens/mail/aliases_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class AliasesScreen extends ConsumerWidget {
  const AliasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final aliasAsync = ref.watch(aliasNotifierProvider);
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
            child: aliasAsync.when(
              data: (aliases) => _AliasTable(aliases: aliases, colors: colors, ref: ref),
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
          Text('Mail Aliases', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 24),
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
            onTap: () => _showAddDialog(context, colors, ref),
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
                Text('Add Alias', style: TextStyle(color: colors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppColors colors, WidgetRef ref) {
    final srcCtrl = TextEditingController();
    final dstCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colors.border)),
        title: Text('Add Alias', style: TextStyle(color: colors.textPrimary)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: srcCtrl,
                style: TextStyle(color: colors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Source (e.g. info@example.com)',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.arrow_downward, color: colors.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Text('forwards to', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dstCtrl,
                style: TextStyle(color: colors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Destination (e.g. user@example.com)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: colors.textSecondary))),
          TextButton(
            onPressed: () async {
              if (srcCtrl.text.isNotEmpty && dstCtrl.text.isNotEmpty) {
                await ref.read(aliasNotifierProvider.notifier).addAlias(
                      source: srcCtrl.text.trim(),
                      destination: dstCtrl.text.trim(),
                    );
                Navigator.pop(ctx);
              }
            },
            child: Text('Create', style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _AliasTable extends StatelessWidget {
  final List<MailAlias> aliases;
  final AppColors colors;
  final WidgetRef ref;
  const _AliasTable({required this.aliases, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (aliases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.alt_route_outlined, color: colors.textSecondary, size: 48),
            const SizedBox(height: 16),
            Text('No aliases configured', style: TextStyle(color: colors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          color: colors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('SOURCE', style: TextStyle(color: colors.textSecondary, fontSize: 11, letterSpacing: 0.5))),
              const SizedBox(width: 60),
              Expanded(flex: 3, child: Text('DESTINATION', style: TextStyle(color: colors.textSecondary, fontSize: 11, letterSpacing: 0.5))),
              Expanded(child: Text('STATUS', style: TextStyle(color: colors.textSecondary, fontSize: 11, letterSpacing: 0.5))),
              const SizedBox(width: 50),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: aliases.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: colors.border.withOpacity(0.5)),
            itemBuilder: (_, i) => _AliasRow(alias: aliases[i], colors: colors, ref: ref),
          ),
        ),
      ],
    );
  }
}

class _AliasRow extends StatelessWidget {
  final MailAlias alias;
  final AppColors colors;
  final WidgetRef ref;
  const _AliasRow({required this.alias, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: const Color(0xFF9E6FFF).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Icon(Icons.alternate_email, size: 14, color: const Color(0xFF9E6FFF)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(alias.source, style: TextStyle(color: colors.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          // Arrow
          SizedBox(
            width: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_forward, color: colors.textSecondary.withOpacity(0.4), size: 16),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: colors.accentGreen.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                  child: Icon(Icons.email_outlined, size: 14, color: colors.accentGreen),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(alias.destination, style: TextStyle(color: colors.textSecondary, fontSize: 13), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (alias.isActive ? colors.accentGreen : colors.textSecondary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                alias.isActive ? 'ACTIVE' : 'DISABLED',
                style: TextStyle(
                  color: alias.isActive ? colors.accentGreen : colors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: IconButton(
              icon: Icon(Icons.delete_outline, size: 16, color: colors.accentRed),
              tooltip: 'Delete Alias',
              onPressed: () => ref.read(aliasNotifierProvider.notifier).deleteAlias(alias.source),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ),
        ],
      ),
    );
  }
}
