// lib/screens/postfix/config_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class ConfigScreen extends ConsumerWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final configAsync = ref.watch(configNotifierProvider);
    final category = ref.watch(configCategoryProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      body: Row(
        children: [
          _ConfigSidebar(colors: colors, ref: ref, current: category),
          Container(width: 1, color: colors.border),
          Expanded(
            child: configAsync.when(
              data: (configs) {
                final filtered = category == 'All'
                    ? configs
                    : configs.where((c) => c.category == category).toList();
                return _ConfigList(configs: filtered, colors: colors, ref: ref);
              },
              loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
              error: (e, _) => Center(child: Text(e.toString(), style: TextStyle(color: colors.accentRed))),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigSidebar extends StatelessWidget {
  final AppColors colors;
  final WidgetRef ref;
  final String current;

  const _ConfigSidebar({required this.colors, required this.ref, required this.current});

  static const categories = [
    ('All', Icons.apps_outlined),
    ('General', Icons.tune_outlined),
    ('SMTP', Icons.send_outlined),
    ('TLS/SSL', Icons.lock_outlined),
    ('SASL', Icons.key_outlined),
    ('Spam', Icons.block_outlined),
    ('Limits', Icons.speed_outlined),
    ('Virtual', Icons.folder_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Configuration', style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                Text('main.cf parameters', style: TextStyle(color: colors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...categories.map((cat) => _CatItem(label: cat.$1, icon: cat.$2, current: current, colors: colors, ref: ref)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () async {
                await ref.read(apiServiceProvider).testConfig();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Config test passed!', style: TextStyle(color: colors.accentGreen)), backgroundColor: colors.card),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: colors.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.accentGreen.withOpacity(0.3)),
                ),
                alignment: Alignment.center,
                child: Text('Test Config', style: TextStyle(color: colors.accentGreen, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatItem extends StatelessWidget {
  final String label, current;
  final IconData icon;
  final AppColors colors;
  final WidgetRef ref;
  const _CatItem({required this.label, required this.icon, required this.current, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    final active = current == label;
    return GestureDetector(
      onTap: () => ref.read(configCategoryProvider.notifier).state = label,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? colors.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? colors.accent.withOpacity(0.3) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: active ? colors.accent : colors.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: active ? colors.accent : colors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ConfigList extends StatelessWidget {
  final List<PostfixConfig> configs;
  final AppColors colors;
  final WidgetRef ref;

  const _ConfigList({required this.configs, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          color: colors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Text('${configs.length} parameters', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: configs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ConfigRow(config: configs[i], colors: colors, ref: ref),
          ),
        ),
      ],
    );
  }
}

class _ConfigRow extends StatefulWidget {
  final PostfixConfig config;
  final AppColors colors;
  final WidgetRef ref;
  const _ConfigRow({required this.config, required this.colors, required this.ref});

  @override
  State<_ConfigRow> createState() => _ConfigRowState();
}

class _ConfigRowState extends State<_ConfigRow> {
  bool _editing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.config.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _editing ? c.accent.withOpacity(0.5) : c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: c.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(widget.config.key, style: TextStyle(color: c.accent, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(4)),
                child: Text(widget.config.category, style: TextStyle(color: c.textSecondary, fontSize: 10)),
              ),
              const Spacer(),
              if (!_editing)
                GestureDetector(
                  onTap: () => setState(() => _editing = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: c.border)),
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 13, color: c.textSecondary),
                      const SizedBox(width: 4),
                      Text('Edit', style: TextStyle(color: c.textSecondary, fontSize: 11)),
                    ]),
                  ),
                )
              else ...[
                GestureDetector(
                  onTap: () => setState(() { _editing = false; _controller.text = widget.config.value; }),
                  child: Text('Cancel', style: TextStyle(color: c.textSecondary, fontSize: 12)),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    await widget.ref.read(configNotifierProvider.notifier).updateConfig(widget.config.key, _controller.text);
                    setState(() => _editing = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Updated ${widget.config.key}'), backgroundColor: c.card),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: c.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: c.accent.withOpacity(0.3))),
                    child: Text('Save', style: TextStyle(color: c.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
          if (widget.config.description != null) ...[
            const SizedBox(height: 8),
            Text(widget.config.description!, style: TextStyle(color: c.textSecondary, fontSize: 11)),
          ],
          const SizedBox(height: 10),
          if (_editing)
            TextField(
              controller: _controller,
              style: TextStyle(color: c.textPrimary, fontSize: 13, fontFamily: 'monospace'),
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
              autofocus: true,
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: c.border.withOpacity(0.5)),
              ),
              child: Text(widget.config.value, style: TextStyle(color: c.textPrimary, fontSize: 13, fontFamily: 'monospace')),
            ),
        ],
      ),
    );
  }
}
