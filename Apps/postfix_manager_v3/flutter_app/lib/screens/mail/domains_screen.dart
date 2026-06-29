// lib/screens/mail/domains_screen.dart — with search
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class DomainsScreen extends ConsumerStatefulWidget {
  const DomainsScreen({super.key});
  @override
  ConsumerState<DomainsScreen> createState() => _DomainsScreenState();
}

class _DomainsScreenState extends ConsumerState<DomainsScreen> {
  final _searchCtrl = TextEditingController();
  final _addCtrl    = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); _addCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final colors      = Theme.of(context).extension<AppColors>()!;
    final domainsAsync= ref.watch(domainsNotifierProvider);
    final search      = ref.watch(domainSearchProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      body: Column(children: [
        // Toolbar
        Container(
          color: colors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(children: [
            Icon(Icons.domain_outlined, color: colors.accent, size: 20),
            const SizedBox(width: 10),
            Text('Virtual Domains', style: TextStyle(
                color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            domainsAsync.when(
              data: (d) => _chip('${d.length} domain${d.length == 1 ? "" : "s"}', colors),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink()),
            const Spacer(),
            SizedBox(width: 240, child: TextField(
              controller: _searchCtrl,
              style: TextStyle(color: colors.textPrimary, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search domains…',
                prefixIcon: Icon(Icons.search, size: 16, color: colors.textSecondary),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                suffixIcon: search.isNotEmpty ? IconButton(
                  icon: Icon(Icons.close, size: 13, color: colors.textSecondary),
                  onPressed: () {
                    _searchCtrl.clear();
                    ref.read(domainSearchProvider.notifier).state = '';
                  }) : null),
              onChanged: (v) => ref.read(domainSearchProvider.notifier).state = v)),
            const SizedBox(width: 12),
            _AddBtn(colors: colors, onTap: () => _showAdd(context, colors)),
          ])),
        const Divider(height: 1),

        // Table header
        Container(
          color: colors.surface.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(children: [
            Expanded(flex: 3, child: _hdr('DOMAIN', colors)),
            SizedBox(width: 80,  child: _hdr('MAILBOXES', colors)),
            SizedBox(width: 70,  child: _hdr('ALIASES', colors)),
            SizedBox(width: 140, child: _hdr('CREATED', colors)),
            SizedBox(width: 80,  child: _hdr('STATUS', colors)),
            SizedBox(width: 80,  child: _hdr('ACTIONS', colors)),
          ])),
        const Divider(height: 1),

        Expanded(child: domainsAsync.when(
          data: (domains) {
            final filtered = search.isEmpty ? domains : domains
                .where((d) => d.domain.toLowerCase().contains(search.toLowerCase()))
                .toList();
            if (filtered.isEmpty) return _Empty(search: search, colors: colors);
            return ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: colors.border.withOpacity(0.4)),
              itemBuilder: (_, i) => _DomainRow(domain: filtered[i], colors: colors, ref: ref));
          },
          loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
          error: (e, _) => Center(child: Text('Error: $e',
              style: TextStyle(color: colors.accentRed))))),
      ]));
  }

  void _showAdd(BuildContext ctx, AppColors c) {
    _addCtrl.clear();
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), side: BorderSide(color: c.border)),
      title: Text('Add Domain', style: TextStyle(color: c.textPrimary)),
      content: SizedBox(width: 360, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Enter the domain name to add as a virtual domain.',
            style: TextStyle(color: c.textSecondary, fontSize: 12)),
        const SizedBox(height: 16),
        TextField(
          controller: _addCtrl, autofocus: true,
          style: TextStyle(color: c.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'example.com',
            prefixIcon: Icon(Icons.domain_outlined, size: 16, color: c.textSecondary)),
          onSubmitted: (_) => _doAdd(ctx, c)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: c.textSecondary))),
        TextButton(onPressed: () => _doAdd(ctx, c),
            child: Text('Add Domain', style: TextStyle(color: c.accentGreen, fontWeight: FontWeight.bold))),
      ]));
  }

  Future<void> _doAdd(BuildContext ctx, AppColors c) async {
    final domain = _addCtrl.text.trim();
    if (domain.isEmpty) return;
    Navigator.pop(ctx);
    try {
      await ref.read(domainsNotifierProvider.notifier).add(domain);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $domain')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')));
    }
  }

  Widget _chip(String t, AppColors c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(4),
        border: Border.all(color: c.border)),
    child: Text(t, style: TextStyle(color: c.textSecondary, fontSize: 11)));

  Widget _hdr(String t, AppColors c) => Text(t, style: TextStyle(
      color: c.textSecondary, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5));
}

class _DomainRow extends StatelessWidget {
  final VirtualDomain domain; final AppColors colors; final WidgetRef ref;
  const _DomainRow({required this.domain, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    child: Row(children: [
      Expanded(flex: 3, child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(
          color: domain.isActive ? colors.accentGreen : colors.textSecondary,
          shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text(domain.domain, style: TextStyle(
            color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
      ])),
      SizedBox(width: 80, child: Text('${domain.mailboxCount}',
          style: TextStyle(color: colors.textSecondary, fontSize: 12))),
      SizedBox(width: 70, child: Text('${domain.aliasCount}',
          style: TextStyle(color: colors.textSecondary, fontSize: 12))),
      SizedBox(width: 140, child: Text(
          DateFormat('MMM d, yyyy').format(domain.createdAt),
          style: TextStyle(color: colors.textSecondary, fontSize: 12))),
      SizedBox(width: 80, child: _StatusBadge(active: domain.isActive, colors: colors)),
      SizedBox(width: 80, child: Row(children: [
        _ToggleBtn(active: domain.isActive, colors: colors,
            onTap: () => ref.read(domainsNotifierProvider.notifier)
                .toggle(domain.domain, !domain.isActive)),
        IconButton(
          icon: Icon(Icons.delete_outline, size: 15, color: colors.accentRed.withOpacity(0.7)),
          onPressed: () => _confirmDelete(context),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
      ])),
    ]));

  void _confirmDelete(BuildContext ctx) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), side: BorderSide(color: colors.border)),
      title: Text('Delete ${domain.domain}?',
          style: TextStyle(color: colors.textPrimary)),
      content: Text('All mailboxes and aliases under this domain will also be deleted.',
          style: TextStyle(color: colors.textSecondary, fontSize: 13)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary))),
        TextButton(onPressed: () {
          Navigator.pop(ctx);
          ref.read(domainsNotifierProvider.notifier).remove(domain.domain);
        }, child: Text('Delete', style: TextStyle(color: colors.accentRed, fontWeight: FontWeight.bold))),
      ]));
  }
}

class _StatusBadge extends StatelessWidget {
  final bool active; final AppColors colors;
  const _StatusBadge({required this.active, required this.colors});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: (active ? colors.accentGreen : colors.textSecondary).withOpacity(0.1),
      borderRadius: BorderRadius.circular(4)),
    child: Text(active ? 'ACTIVE' : 'DISABLED', style: TextStyle(
      color: active ? colors.accentGreen : colors.textSecondary,
      fontSize: 10, fontWeight: FontWeight.bold)));
}

class _ToggleBtn extends StatelessWidget {
  final bool active; final AppColors colors; final VoidCallback onTap;
  const _ToggleBtn({required this.active, required this.colors, required this.onTap});
  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(active ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
        size: 17, color: active ? colors.accentGreen : colors.textSecondary),
    onPressed: onTap,
    tooltip: active ? 'Disable' : 'Enable',
    padding: const EdgeInsets.all(4),
    constraints: const BoxConstraints(minWidth: 28, minHeight: 28));
}

class _AddBtn extends StatelessWidget {
  final AppColors colors; final VoidCallback onTap;
  const _AddBtn({required this.colors, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.accentGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(7),
        border: Border.all(color: colors.accentGreen.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add, size: 16, color: colors.accentGreen),
        const SizedBox(width: 6),
        Text('Add Domain', style: TextStyle(
            color: colors.accentGreen, fontSize: 12, fontWeight: FontWeight.w600)),
      ])));
}

class _Empty extends StatelessWidget {
  final String search; final AppColors colors;
  const _Empty({required this.search, required this.colors});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.domain_outlined, color: colors.textSecondary, size: 48),
      const SizedBox(height: 16),
      Text(search.isNotEmpty ? 'No domains matching "$search"' : 'No domains configured',
          style: TextStyle(color: colors.textSecondary, fontSize: 15)),
    ]));
}
