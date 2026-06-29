// lib/screens/postfix/transport_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class TransportScreen extends ConsumerWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final transportAsync = ref.watch(transportNotifierProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      body: Column(children: [
        _toolbar(context, colors, ref),
        const Divider(height: 1),
        Expanded(child: transportAsync.when(
          data: (maps) => _TransportList(maps: maps, colors: colors, ref: ref),
          loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
          error: (e, _) => _err(e.toString(), colors))),
      ]));
  }

  Widget _toolbar(BuildContext context, AppColors colors, WidgetRef ref) {
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(children: [
        Icon(Icons.route_outlined, color: colors.accent, size: 20),
        const SizedBox(width: 10),
        Text('Transport Maps', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        _infoChip('transport', colors),
        const Spacer(),
        _btn('Reload Maps', Icons.refresh, colors.accentOrange, colors, () async {
          await ref.read(transportNotifierProvider.notifier).reload();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Transport maps reloaded', style: TextStyle(color: colors.accentGreen)),
                  backgroundColor: colors.card));
        }),
        const SizedBox(width: 8),
        _btn('Add Rule', Icons.add, colors.accent, colors, () => _showAddDialog(context, colors, ref)),
      ]));
  }

  void _showAddDialog(BuildContext context, AppColors colors, WidgetRef ref) {
    final patternCtrl = TextEditingController();
    final transportCtrl = TextEditingController(text: 'smtp');
    final nexthopCtrl = TextEditingController();
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colors.border)),
        title: Row(children: [
          Icon(Icons.add_road, color: colors.accent, size: 20),
          const SizedBox(width: 8),
          Text('Add Transport Rule', style: TextStyle(color: colors.textPrimary))]),
        content: SizedBox(width: 480, child: Column(mainAxisSize: MainAxisSize.min, children: [
          _field(patternCtrl, 'Pattern (e.g. example.com or .)', colors, hint: 'Domain pattern or . for catch-all'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _field(transportCtrl, 'Transport', colors, hint: 'smtp, relay, local')),
            const SizedBox(width: 12),
            Expanded(child: _field(nexthopCtrl, 'Next-hop (optional)', colors, hint: '[relay.example.com]:587')),
          ]),
          const SizedBox(height: 12),
          _field(commentCtrl, 'Comment (optional)', colors),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: colors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Examples:', style: TextStyle(color: colors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _example('example.com', 'smtp', '[mail.example.com]:587', colors),
              _example('.', 'relay', '[smtp.sendgrid.net]:587', colors),
              _example('localhost', 'local', '', colors),
            ])),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: colors.textSecondary))),
          TextButton(
            onPressed: () async {
              if (patternCtrl.text.isNotEmpty && transportCtrl.text.isNotEmpty) {
                await ref.read(transportNotifierProvider.notifier).add(TransportMap(
                  pattern: patternCtrl.text.trim(),
                  transport: transportCtrl.text.trim(),
                  nexthop: nexthopCtrl.text.trim().isEmpty ? null : nexthopCtrl.text.trim(),
                  isActive: true,
                  comment: commentCtrl.text.trim().isEmpty ? null : commentCtrl.text.trim()));
                Navigator.pop(ctx);
              }
            },
            child: Text('Add', style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold))),
        ]));
  }

  Widget _example(String pattern, String transport, String nexthop, AppColors c) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Text('  $pattern  →  $transport${nexthop.isNotEmpty ? "  [$nexthop]" : ""}',
        style: TextStyle(color: c.accent.withOpacity(0.7), fontSize: 11, fontFamily: 'monospace')));

  Widget _field(TextEditingController ctrl, String label, AppColors colors, {String? hint}) =>
    TextField(controller: ctrl, style: TextStyle(color: colors.textPrimary, fontSize: 13),
      decoration: InputDecoration(labelText: label, hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)));

  Widget _infoChip(String text, AppColors colors) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(4), border: Border.all(color: colors.border)),
    child: Text(text, style: TextStyle(color: colors.textSecondary, fontSize: 11, fontFamily: 'monospace')));

  Widget _btn(String label, IconData icon, Color color, AppColors colors, VoidCallback onTap) =>
    GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))])));

  Widget _err(String msg, AppColors colors) => Center(child: Text(msg, style: TextStyle(color: colors.accentRed)));
}

class _TransportList extends StatelessWidget {
  final List<TransportMap> maps;
  final AppColors colors;
  final WidgetRef ref;
  const _TransportList({required this.maps, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (maps.isEmpty) return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.route_outlined, color: colors.textSecondary, size: 48),
        const SizedBox(height: 16),
        Text('No transport rules configured', style: TextStyle(color: colors.textSecondary, fontSize: 16)),
        const SizedBox(height: 8),
        Text('Add rules to control how mail is delivered', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
      ]));

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Header hint
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: colors.accent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.accent.withOpacity(0.2))),
          child: Row(children: [
            Icon(Icons.info_outline, color: colors.accent, size: 16),
            const SizedBox(width: 10),
            Expanded(child: Text(
              'Transport map rules override Postfix\'s default delivery. Pattern \'.\' matches all domains. Rules are applied in order.',
              style: TextStyle(color: colors.textSecondary, fontSize: 12))),
          ])),
        // Rules table
        Container(
          decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border)),
          child: Column(children: [
            _header(),
            ...maps.asMap().entries.map((e) => _TransportRow(
              map: e.value, colors: colors, ref: ref,
              isLast: e.key == maps.length - 1)),
          ])),
      ]);
  }

  Widget _header() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(color: colors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
    child: Row(children: [
      Expanded(flex: 2, child: _hcol('PATTERN')),
      Expanded(child: _hcol('TRANSPORT')),
      Expanded(flex: 2, child: _hcol('NEXT-HOP')),
      Expanded(flex: 2, child: _hcol('COMMENT')),
      _hcol('STATUS'),
      const SizedBox(width: 80),
    ]));

  Widget _hcol(String label) => Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 10, letterSpacing: 0.8, fontWeight: FontWeight.w600));
}

class _TransportRow extends StatelessWidget {
  final TransportMap map;
  final AppColors colors;
  final WidgetRef ref;
  final bool isLast;
  const _TransportRow({required this.map, required this.colors, required this.ref, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: isLast ? BorderSide.none : BorderSide(color: colors.border.withOpacity(0.5)))),
      child: Row(children: [
        Expanded(flex: 2, child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: map.pattern == '.' ? colors.accentOrange.withOpacity(0.1) : colors.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4)),
            child: Text(map.pattern,
                style: TextStyle(
                  color: map.pattern == '.' ? colors.accentOrange : colors.accent,
                  fontSize: 13, fontFamily: 'monospace', fontWeight: FontWeight.w600))),
        ])),
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: colors.accentGreen.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
          child: Text(map.transport, style: TextStyle(color: colors.accentGreen, fontSize: 12, fontFamily: 'monospace')))),
        Expanded(flex: 2, child: Text(map.nexthop ?? '—', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontFamily: 'monospace'))),
        Expanded(flex: 2, child: Text(map.comment ?? '', style: TextStyle(color: colors.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: (map.isActive ? colors.accentGreen : colors.textSecondary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4)),
          child: Text(map.isActive ? 'ACTIVE' : 'OFF',
              style: TextStyle(color: map.isActive ? colors.accentGreen : colors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold))),
        const SizedBox(width: 16),
        IconButton(
          icon: Icon(Icons.delete_outline, size: 16, color: colors.accentRed.withOpacity(0.7)),
          onPressed: () => ref.read(transportNotifierProvider.notifier).delete(map.pattern),
          padding: const EdgeInsets.all(4), constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
      ]));
  }
}
