// lib/screens/postfix/access_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class AccessScreen extends ConsumerWidget {
  const AccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final rulesAsync = ref.watch(accessNotifierProvider);
    final listType = ref.watch(accessListTypeFilterProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      body: Column(children: [
        _buildToolbar(context, colors, ref, listType),
        const Divider(height: 1),
        Expanded(child: rulesAsync.when(
          data: (rules) => _AccessList(rules: rules, colors: colors, ref: ref),
          loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
          error: (e, _) => Center(child: Text(e.toString(), style: TextStyle(color: colors.accentRed))))),
      ]));
  }

  Widget _buildToolbar(BuildContext context, AppColors colors, WidgetRef ref, String? listType) {
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(children: [
        Icon(Icons.security_outlined, color: colors.accent, size: 20),
        const SizedBox(width: 10),
        Text('Access Control', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 24),
        // List type tabs
        _tab('All', null, listType, colors, ref),
        const SizedBox(width: 8),
        _tab('Whitelist', 'whitelist', listType, colors, ref),
        const SizedBox(width: 8),
        _tab('Blacklist', 'blacklist', listType, colors, ref),
        const Spacer(),
        _addBtn(context, colors, ref),
      ]));
  }

  Widget _tab(String label, String? value, String? current, AppColors colors, WidgetRef ref) {
    final active = current == value;
    final color = value == 'blacklist' ? colors.accentRed : value == 'whitelist' ? colors.accentGreen : colors.accent;
    return GestureDetector(
      onTap: () => ref.read(accessListTypeFilterProvider.notifier).state = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: active ? color.withOpacity(0.4) : colors.border)),
        child: Text(label, style: TextStyle(color: active ? color : colors.textSecondary, fontSize: 12))));
  }

  Widget _addBtn(BuildContext context, AppColors colors, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showAddDialog(context, colors, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.accent.withOpacity(0.3))),
        child: Row(children: [
          Icon(Icons.add, color: colors.accent, size: 16),
          const SizedBox(width: 6),
          Text('Add Rule', style: TextStyle(color: colors.accent, fontSize: 12, fontWeight: FontWeight.w600))])));
  }

  void _showAddDialog(BuildContext context, AppColors colors, WidgetRef ref) {
    final patternCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    String listType = 'blacklist';
    String matchType = 'ip';
    String action = 'REJECT';

    final actions = {'blacklist': ['REJECT', 'DISCARD', 'DEFER', 'BAN'],
                      'whitelist': ['PERMIT', 'OK']};

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState) => AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colors.border)),
          title: Text('Add Access Rule', style: TextStyle(color: colors.textPrimary)),
          content: SizedBox(width: 500, child: Column(mainAxisSize: MainAxisSize.min, children: [
            // List type toggle
            Row(children: [
              Expanded(child: _typeToggle('Blacklist', 'blacklist', listType, colors.accentRed, colors, (v) => setState(() { listType = v; action = 'REJECT'; }))),
              const SizedBox(width: 12),
              Expanded(child: _typeToggle('Whitelist', 'whitelist', listType, colors.accentGreen, colors, (v) => setState(() { listType = v; action = 'PERMIT'; }))),
            ]),
            const SizedBox(height: 16),
            // Match type
            Row(children: [
              for (final t in ['ip', 'domain', 'email', 'network'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _matchChip(t, matchType, colors, (v) => setState(() => matchType = v))),
            ]),
            const SizedBox(height: 16),
            TextField(
              controller: patternCtrl,
              style: TextStyle(color: colors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                labelText: _patternLabel(matchType),
                hintText: _patternHint(matchType),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: action,
                dropdownColor: colors.card,
                style: TextStyle(color: colors.textPrimary, fontSize: 13),
                decoration: InputDecoration(labelText: 'Action',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                items: (actions[listType] ?? ['REJECT']).map((a) =>
                    DropdownMenuItem(value: a, child: Text(a))).toList(),
                onChanged: (v) => setState(() => action = v ?? action))),
            ]),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              style: TextStyle(color: colors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Reason (optional)',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: colors.textSecondary))),
            TextButton(
              onPressed: () async {
                if (patternCtrl.text.isNotEmpty) {
                  await ref.read(accessNotifierProvider.notifier).add(AccessRule(
                    pattern: patternCtrl.text.trim(),
                    action: action,
                    listType: listType,
                    matchType: matchType,
                    reason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim(),
                    createdAt: DateTime.now(),
                    isActive: true));
                  Navigator.pop(ctx);
                }
              },
              child: Text('Add', style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold))),
          ])));
  }

  Widget _typeToggle(String label, String value, String current, Color color, AppColors colors, Function(String) onTap) {
    final active = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.12) : colors.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? color.withOpacity(0.4) : colors.border)),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: active ? color : colors.textSecondary, fontWeight: active ? FontWeight.bold : FontWeight.normal))));
  }

  Widget _matchChip(String t, String current, AppColors colors, Function(String) onTap) {
    final active = t == current;
    return GestureDetector(
      onTap: () => onTap(t),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? colors.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: active ? colors.accent.withOpacity(0.4) : colors.border)),
        child: Text(t, style: TextStyle(color: active ? colors.accent : colors.textSecondary, fontSize: 12))));
  }

  String _patternLabel(String t) => switch (t) {
    'ip' => 'IP Address', 'domain' => 'Domain', 'email' => 'Email Address', _ => 'Network (CIDR)'};

  String _patternHint(String t) => switch (t) {
    'ip' => '192.168.1.1', 'domain' => 'spam.example.com', 'email' => 'spammer@example.com', _ => '10.0.0.0/8'};
}

class _AccessList extends StatelessWidget {
  final List<AccessRule> rules;
  final AppColors colors;
  final WidgetRef ref;
  const _AccessList({required this.rules, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.security_outlined, color: colors.textSecondary, size: 48),
        const SizedBox(height: 16),
        Text('No access rules configured', style: TextStyle(color: colors.textSecondary, fontSize: 16)),
      ]));

    final blacklist = rules.where((r) => r.listType == 'blacklist').toList();
    final whitelist = rules.where((r) => r.listType == 'whitelist').toList();
    final all = rules;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (whitelist.isNotEmpty) ...[
          _sectionHeader('Whitelist', whitelist.length, colors.accentGreen, colors),
          const SizedBox(height: 8),
          ...whitelist.map((r) => _AccessRuleCard(rule: r, colors: colors, ref: ref)),
          const SizedBox(height: 20),
        ],
        if (blacklist.isNotEmpty) ...[
          _sectionHeader('Blacklist', blacklist.length, colors.accentRed, colors),
          const SizedBox(height: 8),
          ...blacklist.map((r) => _AccessRuleCard(rule: r, colors: colors, ref: ref)),
        ],
      ]);
  }

  Widget _sectionHeader(String label, int count, Color color, AppColors colors) => Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(label == 'Whitelist' ? Icons.check_circle_outline : Icons.block_outlined, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Text('$count', style: TextStyle(color: color.withOpacity(0.7), fontSize: 12)),
      ])),
    Expanded(child: Container(height: 1, margin: const EdgeInsets.only(left: 12), color: colors.border)),
  ]);
}

class _AccessRuleCard extends StatelessWidget {
  final AccessRule rule;
  final AppColors colors;
  final WidgetRef ref;
  const _AccessRuleCard({required this.rule, required this.colors, required this.ref});

  Color get _color => rule.listType == 'blacklist' ? colors.accentRed : colors.accentGreen;

  IconData get _matchIcon => switch (rule.matchType) {
    'ip' => Icons.router_outlined,
    'domain' => Icons.domain_outlined,
    'email' => Icons.email_outlined,
    _ => Icons.lan_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: rule.isActive ? colors.border : colors.border.withOpacity(0.3))),
      child: Row(children: [
        // Match type icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
          child: Icon(_matchIcon, color: _color, size: 16)),
        const SizedBox(width: 12),
        // Pattern
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(rule.pattern, style: TextStyle(color: colors.textPrimary, fontSize: 13, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
            const SizedBox(width: 10),
            _badge(rule.matchType, colors.textSecondary, colors),
            const SizedBox(width: 6),
            _badge(rule.action, _color, colors),
          ]),
          if (rule.reason != null)
            Padding(padding: const EdgeInsets.only(top: 3),
                child: Text(rule.reason!, style: TextStyle(color: colors.textSecondary, fontSize: 11))),
        ])),
        // Date
        Text(DateFormat('MMM d').format(rule.createdAt), style: TextStyle(color: colors.textSecondary, fontSize: 11)),
        const SizedBox(width: 16),
        // Expire indicator
        if (rule.expiresAt != null) Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: colors.accentOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
          child: Text('Exp ${DateFormat('MMM d').format(rule.expiresAt!)}',
              style: TextStyle(color: colors.accentOrange, fontSize: 10))),
        const SizedBox(width: 8),
        // Toggle
        Switch(value: rule.isActive,
            onChanged: (v) => ref.read(accessNotifierProvider.notifier).toggle(rule.pattern, v),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        // Delete
        IconButton(
          icon: Icon(Icons.delete_outline, size: 16, color: colors.accentRed.withOpacity(0.6)),
          onPressed: () => ref.read(accessNotifierProvider.notifier).delete(rule.pattern),
          padding: const EdgeInsets.all(4), constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
      ]));
  }

  Widget _badge(String label, Color color, AppColors colors) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
    child: Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)));
}
