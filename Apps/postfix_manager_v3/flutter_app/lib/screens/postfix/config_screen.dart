// lib/screens/postfix/config_screen.dart — Save feedback + unsaved-changes warning
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class ConfigScreen extends ConsumerStatefulWidget {
  const ConfigScreen({super.key});
  @override
  ConsumerState<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> {
  final _searchCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<bool> _onWillPop() async {
    final hasPending = ref.read(configNotifierProvider.notifier).hasPending;
    if (!hasPending) return true;
    return await showDialog<bool>(
      context: context,
      builder: (_) => _UnsavedDialog(
          colors: Theme.of(context).extension<AppColors>()!)) ?? false;
  }

  Future<void> _saveAll(AppColors c) async {
    setState(() => _saving = true);
    final results = await ref.read(configNotifierProvider.notifier).saveAll();
    setState(() => _saving = false);

    if (!mounted) return;
    final failed = results.entries.where((e) => !e.value).length;
    final saved  = results.entries.where((e) =>  e.value).length;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(failed == 0 ? Icons.check_circle_outline : Icons.warning_outlined,
          color: failed == 0 ? c.accentGreen : c.accentOrange, size: 18),
        const SizedBox(width: 10),
        Text(failed == 0
          ? '$saved setting${saved > 1 ? "s" : ""} saved successfully'
          : '$saved saved, $failed failed'),
      ]),
      duration: const Duration(seconds: 3)));
  }

  @override
  Widget build(BuildContext context) {
    final colors      = Theme.of(context).extension<AppColors>()!;
    final configAsync = ref.watch(configNotifierProvider);
    final search      = ref.watch(configSearchProvider);
    final notifier    = ref.read(configNotifierProvider.notifier);

    return PopScope(
      canPop: !notifier.hasPending,
      onPopInvoked: (popped) async {
        if (!popped && notifier.hasPending) {
          final ok = await _onWillPop();
          if (ok && mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: colors.bg,
        body: Column(children: [
          // ── Toolbar ────────────────────────────────────────────────────────
          Container(
            color: colors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(children: [
              Icon(Icons.tune_outlined, color: colors.accent, size: 20),
              const SizedBox(width: 10),
              Text('Configuration', style: TextStyle(
                  color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),

              // Pending badge
              if (notifier.hasPending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accentOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.accentOrange.withOpacity(0.35))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.edit_outlined, size: 12, color: colors.accentOrange),
                    const SizedBox(width: 5),
                    Text('${notifier.pendingCount} unsaved',
                      style: TextStyle(color: colors.accentOrange, fontSize: 11)),
                  ])),

              const Spacer(),

              // Search
              SizedBox(width: 260, child: TextField(
                controller: _searchCtrl,
                style: TextStyle(color: colors.textPrimary, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Search parameters…',
                  prefixIcon: Icon(Icons.search, size: 16, color: colors.textSecondary),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  suffixIcon: search.isNotEmpty ? IconButton(
                    icon: Icon(Icons.close, size: 14, color: colors.textSecondary),
                    onPressed: () {
                      _searchCtrl.clear();
                      ref.read(configSearchProvider.notifier).state = '';
                    }) : null),
                onChanged: (v) => ref.read(configSearchProvider.notifier).state = v)),
              const SizedBox(width: 12),

              // Test Config
              _Btn(label: 'Test Config', icon: Icons.check_outlined,
                  color: colors.accentGreen, colors: colors,
                  onTap: () async {
                    final ok = await ref.read(apiServiceProvider).testConfig();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(children: [
                        Icon(ok ? Icons.check_circle_outline : Icons.error_outline,
                          color: ok ? colors.accentGreen : colors.accentRed, size: 16),
                        const SizedBox(width: 8),
                        Text(ok ? 'Configuration is valid' : 'Configuration has errors'),
                      ])));
                  }),
              const SizedBox(width: 8),

              // Discard
              if (notifier.hasPending) ...[
                _Btn(label: 'Discard', icon: Icons.undo_outlined,
                    color: colors.accentRed, colors: colors,
                    onTap: () => notifier.discardEdits()),
                const SizedBox(width: 8),
              ],

              // Save All
              _Btn(
                label: _saving ? 'Saving…' : 'Save All',
                icon: _saving ? Icons.hourglass_empty : Icons.save_outlined,
                color: notifier.hasPending ? colors.accentGreen : colors.textSecondary,
                colors: colors,
                onTap: notifier.hasPending && !_saving ? () => _saveAll(colors) : null),
            ])),
          const Divider(height: 1),

          // ── Config table ───────────────────────────────────────────────────
          Expanded(child: configAsync.when(
            data: (all) {
              // Apply search filter
              final filtered = search.isEmpty ? all : all.where((c) =>
                c.key.toLowerCase().contains(search.toLowerCase()) ||
                (c.description?.toLowerCase().contains(search.toLowerCase()) ?? false) ||
                c.value.toLowerCase().contains(search.toLowerCase())).toList();

              if (filtered.isEmpty) return Center(
                child: Text('No matching parameters',
                    style: TextStyle(color: colors.textSecondary)));

              // Group by category
              final groups = <String, List<PostfixConfig>>{};
              for (final c in filtered) {
                groups.putIfAbsent(c.category, () => []).add(c);
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: groups.entries.map((entry) =>
                    _ConfigGroup(
                      category: entry.key,
                      items: entry.value,
                      colors: colors,
                      onEdit: (key, value) => notifier.stageEdit(key, value),
                      onSave: (key, value) async {
                        setState(() => _saving = true);
                        try {
                          await notifier.saveOne(key, value);
                          if (mounted) _showSaveToast(key, true, colors);
                        } catch (_) {
                          if (mounted) _showSaveToast(key, false, colors);
                        } finally {
                          if (mounted) setState(() => _saving = false);
                        }
                      },
                    )).toList());
            },
            loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
            error: (e, _) => Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.error_outline, color: colors.accentRed, size: 40),
                const SizedBox(height: 12),
                Text('Failed to load config', style: TextStyle(color: colors.textPrimary)),
                const SizedBox(height: 8),
                Text(e.toString(), style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                const SizedBox(height: 16),
                _Btn(label: 'Retry', icon: Icons.refresh, color: colors.accent, colors: colors,
                    onTap: () => ref.read(configNotifierProvider.notifier).reload()),
              ]))));
        ])));
  }

  void _showSaveToast(String key, bool ok, AppColors c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(ok ? Icons.check_circle_outline : Icons.error_outline,
          color: ok ? c.accentGreen : c.accentRed, size: 16),
        const SizedBox(width: 8),
        Text(ok ? 'Saved $key' : 'Failed to save $key'),
      ]),
      duration: const Duration(seconds: 2)));
  }
}

// ─── Config Group ─────────────────────────────────────────────────────────────
class _ConfigGroup extends StatelessWidget {
  final String category;
  final List<PostfixConfig> items;
  final AppColors colors;
  final void Function(String key, String value) onEdit;
  final Future<void> Function(String key, String value) onSave;

  const _ConfigGroup({required this.category, required this.items,
      required this.colors, required this.onEdit, required this.onSave});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Row(children: [
          Container(width: 3, height: 14,
              decoration: BoxDecoration(color: colors.accent,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text(category.toUpperCase(), style: TextStyle(
              color: colors.accent, fontSize: 11, fontWeight: FontWeight.w700,
              letterSpacing: 1.2)),
        ])),
      Container(
        decoration: BoxDecoration(
          color: colors.card, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border)),
        child: Column(children: items.asMap().entries.map((e) =>
            Column(children: [
              _ConfigRow(item: e.value, colors: colors,
                  onEdit: onEdit, onSave: onSave),
              if (e.key < items.length - 1)
                Divider(height: 1, color: colors.border.withOpacity(0.5)),
            ])).toList())),
      const SizedBox(height: 20),
    ]);
}

// ─── Config Row ───────────────────────────────────────────────────────────────
class _ConfigRow extends StatefulWidget {
  final PostfixConfig item;
  final AppColors colors;
  final void Function(String key, String value) onEdit;
  final Future<void> Function(String key, String value) onSave;
  const _ConfigRow({required this.item, required this.colors,
      required this.onEdit, required this.onSave});
  @override
  State<_ConfigRow> createState() => _ConfigRowState();
}

class _ConfigRowState extends State<_ConfigRow> {
  late TextEditingController _ctrl;
  bool _editing = false;
  bool _saving  = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.item.value);
  }

  @override
  void didUpdateWidget(_ConfigRow old) {
    super.didUpdateWidget(old);
    if (!_editing) _ctrl.text = widget.item.value;
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  AppColors get c => widget.colors;

  @override
  Widget build(BuildContext context) {
    final modified = widget.item.isModified;
    return Container(
      color: modified ? c.accentOrange.withOpacity(0.03) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Key + description
        Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(widget.item.key, style: TextStyle(
                color: c.textPrimary, fontSize: 13, fontFamily: 'monospace',
                fontWeight: FontWeight.w600)),
            if (modified) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: c.accentOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4)),
                child: Text('modified', style: TextStyle(
                    color: c.accentOrange, fontSize: 9, fontWeight: FontWeight.bold))),
            ],
            if (widget.item.defaultValue != null &&
                widget.item.value != widget.item.defaultValue &&
                !modified) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: c.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4)),
                child: Text('custom', style: TextStyle(
                    color: c.accent, fontSize: 9))),
            ],
          ]),
          if (widget.item.description != null) ...[
            const SizedBox(height: 3),
            Text(widget.item.description!,
              style: TextStyle(color: c.textSecondary, fontSize: 11),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          if (widget.item.defaultValue != null && modified) ...[
            const SizedBox(height: 4),
            Row(children: [
              Text('default: ', style: TextStyle(color: c.textSecondary, fontSize: 10)),
              Text(widget.item.defaultValue!,
                style: TextStyle(color: c.textSecondary, fontSize: 10,
                    fontFamily: 'monospace',
                    decoration: TextDecoration.lineThrough)),
            ]),
          ],
        ])),

        const SizedBox(width: 20),

        // Value editor
        Expanded(flex: 2, child: _editing
          ? Row(children: [
              Expanded(child: TextField(
                controller: _ctrl,
                autofocus: true,
                style: TextStyle(color: c.textPrimary, fontSize: 12, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: c.accent)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: c.accent, width: 1.5))),
                onChanged: (v) => widget.onEdit(widget.item.key, v),
                onSubmitted: (_) => _doSave())),
              const SizedBox(width: 6),
              IconButton(
                icon: _saving
                  ? SizedBox(width: 14, height: 14,
                      child: CircularProgressIndicator(color: c.accentGreen, strokeWidth: 2))
                  : Icon(Icons.check, size: 16, color: c.accentGreen),
                onPressed: _saving ? null : _doSave,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
              IconButton(
                icon: Icon(Icons.close, size: 16, color: c.textSecondary),
                onPressed: () => setState(() {
                  _editing = false;
                  _ctrl.text = widget.item.value;
                }),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
            ])
          : Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _editing = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: c.bg, borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: modified ? c.accentOrange.withOpacity(0.4) : c.border)),
                  child: Text(widget.item.value,
                    style: TextStyle(color: c.textPrimary, fontSize: 12,
                        fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis)))),
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 14, color: c.textSecondary.withOpacity(0.6)),
                onPressed: () => setState(() => _editing = true),
                tooltip: 'Edit',
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
              IconButton(
                icon: Icon(Icons.copy_outlined, size: 14, color: c.textSecondary.withOpacity(0.6)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.item.value));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Copied ${widget.item.key}'),
                    duration: const Duration(seconds: 1)));
                },
                tooltip: 'Copy value',
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
              if (widget.item.defaultValue != null &&
                  widget.item.value != widget.item.defaultValue)
                IconButton(
                  icon: Icon(Icons.restore_outlined, size: 14, color: c.accentOrange.withOpacity(0.7)),
                  onPressed: () {
                    _ctrl.text = widget.item.defaultValue!;
                    widget.onEdit(widget.item.key, widget.item.defaultValue!);
                  },
                  tooltip: 'Reset to default',
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
            ])),
      ]));
  }

  Future<void> _doSave() async {
    setState(() { _saving = true; _editing = false; });
    await widget.onSave(widget.item.key, _ctrl.text);
    if (mounted) setState(() => _saving = false);
  }
}

// ─── Unsaved changes dialog ───────────────────────────────────────────────────
class _UnsavedDialog extends StatelessWidget {
  final AppColors colors;
  const _UnsavedDialog({required this.colors});
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: colors.card,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), side: BorderSide(color: colors.border)),
    title: Row(children: [
      Icon(Icons.warning_outlined, color: colors.accentOrange, size: 20),
      const SizedBox(width: 8),
      Text('Unsaved Changes', style: TextStyle(color: colors.textPrimary)),
    ]),
    content: Text('You have unsaved configuration changes. Leave without saving?',
        style: TextStyle(color: colors.textSecondary, fontSize: 13)),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false),
          child: Text('Stay', style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold))),
      TextButton(onPressed: () => Navigator.pop(context, true),
          child: Text('Leave', style: TextStyle(color: colors.accentRed))),
    ]);
}

// ─── Small button ─────────────────────────────────────────────────────────────
class _Btn extends StatelessWidget {
  final String label; final IconData icon;
  final Color color; final AppColors colors;
  final VoidCallback? onTap;
  const _Btn({required this.label, required this.icon, required this.color,
      required this.colors, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Opacity(
      opacity: onTap == null ? 0.4 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color.withOpacity(0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))]))));
}
