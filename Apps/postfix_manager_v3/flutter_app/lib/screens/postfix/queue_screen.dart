// lib/screens/postfix/queue_screen.dart — Paginated with infinite scroll
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});
  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  final _searchCtrl  = TextEditingController();
  final _scrollCtrl  = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load next page when 200px from bottom
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      final notifier = ref.read(queueNotifierProvider.notifier);
      if (notifier.hasMore) notifier.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors   = Theme.of(context).extension<AppColors>()!;
    final queueAsync = ref.watch(queueNotifierProvider);
    final filter     = ref.watch(queueStatusFilterProvider);
    final selected   = ref.watch(selectedQueueItemsProvider);
    final search     = ref.watch(queueSearchProvider);
    final notifier   = ref.read(queueNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: colors.bg,
      body: Column(children: [
        // ── Toolbar ──────────────────────────────────────────────────────────
        Container(
          color: colors.surface,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Column(children: [
            Row(children: [
              Icon(Icons.queue_outlined, color: colors.accent, size: 20),
              const SizedBox(width: 10),
              Text('Mail Queue', style: TextStyle(
                  color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),

              // Total count
              queueAsync.when(
                data: (_) {
                  final total = notifier.total;
                  final loaded = queueAsync.value?.length ?? 0;
                  return _chip(
                    total > loaded ? '$loaded / $total' : '$total messages',
                    total > 0 ? colors.accent : colors.textSecondary, colors);
                },
                loading: () => const SizedBox.shrink(),
                error:   (_, __) => const SizedBox.shrink()),

              const Spacer(),

              // Search
              SizedBox(width: 240, child: TextField(
                controller: _searchCtrl,
                style: TextStyle(color: colors.textPrimary, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Search sender, recipient, subject…',
                  prefixIcon: Icon(Icons.search, size: 16, color: colors.textSecondary),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  suffixIcon: search.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, size: 14, color: colors.textSecondary),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(queueSearchProvider.notifier).state = '';
                          notifier.refresh();
                        })
                    : null),
                onSubmitted: (v) {
                  ref.read(queueSearchProvider.notifier).state = v;
                  notifier.refresh();
                })),
              const SizedBox(width: 12),

              // Batch delete
              if (selected.isNotEmpty) ...[
                _ActionBtn(
                  label: 'Delete (${selected.length})',
                  icon: Icons.delete_outline,
                  color: colors.accentRed, colors: colors,
                  onTap: () => _confirmBatchDelete(context, colors, selected.toList(), notifier)),
                const SizedBox(width: 8),
              ],

              _ActionBtn(label: 'Flush All', icon: Icons.send_outlined,
                  color: colors.accentOrange, colors: colors,
                  onTap: () => _confirmFlush(context, colors, notifier)),
              const SizedBox(width: 8),
              _ActionBtn(label: 'Refresh', icon: Icons.refresh,
                  color: colors.accent, colors: colors,
                  onTap: () => notifier.refresh()),
            ]),
            const SizedBox(height: 10),

            // Status filter chips
            Row(children: [
              for (final f in [null, 'active', 'deferred', 'hold', 'incoming'])
                Padding(padding: const EdgeInsets.only(right: 8), child:
                  _FilterChip(
                    label: f == null ? 'All' : _cap(f),
                    active: filter == f,
                    color: _statusColor(f, colors),
                    colors: colors,
                    onTap: () {
                      ref.read(queueStatusFilterProvider.notifier).state = f;
                      notifier.refresh();
                    })),
              const Spacer(),
              // Sort
              _SortButton(colors: colors, onChanged: () => notifier.refresh()),
            ]),
            const SizedBox(height: 4),
          ])),
        const Divider(height: 1),

        // ── Column headers ───────────────────────────────────────────────────
        Container(
          color: colors.surface.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(children: [
            SizedBox(width: 36, child: Checkbox(
              tristate: true,
              value: queueAsync.value?.isEmpty == true ? false
                  : selected.isNotEmpty &&
                    selected.length == (queueAsync.value?.length ?? 0) ? true : null,
              onChanged: (v) {
                final items = queueAsync.value ?? [];
                ref.read(selectedQueueItemsProvider.notifier).state =
                    v == true ? items.map((q) => q.id).toSet() : {};
              })),
            Expanded(flex: 3, child: _hdr('FROM', colors)),
            Expanded(flex: 3, child: _hdr('TO', colors)),
            Expanded(flex: 3, child: _hdr('SUBJECT', colors)),
            SizedBox(width: 75,  child: _hdr('SIZE', colors)),
            SizedBox(width: 90,  child: _hdr('STATUS', colors)),
            SizedBox(width: 120, child: _hdr('ARRIVED', colors)),
            SizedBox(width: 100, child: _hdr('ACTIONS', colors)),
          ])),
        const Divider(height: 1),

        // ── List ─────────────────────────────────────────────────────────────
        Expanded(child: queueAsync.when(
          data: (queue) {
            if (queue.isEmpty) return _Empty(search: search, filter: filter, colors: colors);
            return ListView.separated(
              controller: _scrollCtrl,
              itemCount: queue.length + (notifier.hasMore ? 1 : 0),
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: colors.border.withOpacity(0.4)),
              itemBuilder: (_, i) {
                if (i >= queue.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: colors.accent, strokeWidth: 2))));
                }
                return _QueueRow(
                  item: queue[i], colors: colors, ref: ref,
                  isSelected: selected.contains(queue[i].id));
              });
          },
          loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
          error: (e, _) => _Error(error: e.toString(), colors: colors,
              onRetry: () => notifier.refresh()))),
      ]));
  }

  void _confirmFlush(BuildContext ctx, AppColors c, QueueNotifier n) {
    showDialog(context: ctx, builder: (_) => _ConfirmDialog(
      title: 'Flush All Messages',
      message: 'Force delivery of all deferred messages?',
      confirmLabel: 'Flush All',
      confirmColor: c.accentOrange,
      colors: c,
      onConfirm: () { n.flushAll(); _toast(ctx, 'Flushing queue…', c); }));
  }

  void _confirmBatchDelete(BuildContext ctx, AppColors c,
      List<String> ids, QueueNotifier n) {
    showDialog(context: ctx, builder: (_) => _ConfirmDialog(
      title: 'Delete ${ids.length} Messages',
      message: 'This will permanently delete the selected messages from the queue.',
      confirmLabel: 'Delete',
      confirmColor: c.accentRed,
      colors: c,
      onConfirm: () { n.deleteSelected(ids); _toast(ctx, 'Deleted ${ids.length} messages', c); }));
  }

  void _toast(BuildContext ctx, String msg, AppColors c) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(msg),
          duration: const Duration(seconds: 2)));
  }

  Color _statusColor(String? s, AppColors c) => switch (s) {
    'active'   => c.accentGreen,
    'deferred' => c.accentOrange,
    'hold'     => c.accent,
    'incoming' => c.accentPurple,
    _ => c.accent,
  };

  static String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  Widget _chip(String t, Color color, AppColors c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: c.bg, borderRadius: BorderRadius.circular(4),
        border: Border.all(color: c.border)),
    child: Text(t, style: TextStyle(color: color, fontSize: 11)));

  Widget _hdr(String t, AppColors c) => Text(t,
    style: TextStyle(color: c.textSecondary, fontSize: 10,
        fontWeight: FontWeight.w600, letterSpacing: 0.5));
}

// ─── Sort button ──────────────────────────────────────────────────────────────
class _SortButton extends ConsumerWidget {
  final AppColors colors;
  final VoidCallback onChanged;
  const _SortButton({required this.colors, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final field = ref.watch(queueSortFieldProvider);
    final asc   = ref.watch(queueSortAscProvider);
    return PopupMenuButton<String>(
      color: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), side: BorderSide(color: colors.border)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: field != null ? colors.accent.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: field != null ? colors.accent.withOpacity(0.3) : colors.border)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(asc ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14, color: field != null ? colors.accent : colors.textSecondary),
          const SizedBox(width: 4),
          Text('Sort: ${field ?? "Default"}',
              style: TextStyle(color: field != null ? colors.accent : colors.textSecondary, fontSize: 11)),
        ])),
      onSelected: (val) {
        if (val == field) {
          ref.read(queueSortAscProvider.notifier).state = !asc;
        } else {
          ref.read(queueSortFieldProvider.notifier).state = val.isEmpty ? null : val;
          ref.read(queueSortAscProvider.notifier).state = true;
        }
        onChanged();
      },
      itemBuilder: (_) => [
        for (final opt in [('', 'Default'), ('arrivedAt', 'Arrived'), ('size', 'Size'), ('sender', 'Sender')])
          PopupMenuItem(value: opt.$1,
            child: Row(children: [
              Icon(opt.$1 == (field ?? '') ? Icons.check : Icons.sort,
                  size: 14, color: opt.$1 == (field ?? '') ? colors.accent : colors.textSecondary),
              const SizedBox(width: 8),
              Text(opt.$2, style: TextStyle(color: colors.textPrimary, fontSize: 12)),
            ])),
      ]);
  }
}

// ─── Queue Row ────────────────────────────────────────────────────────────────
class _QueueRow extends StatelessWidget {
  final MailQueue item; final AppColors colors;
  final WidgetRef ref; final bool isSelected;
  const _QueueRow({required this.item, required this.colors,
      required this.ref, required this.isSelected});

  Color get _sc => switch (item.status) {
    'active'   => colors.accentGreen,
    'deferred' => colors.accentOrange,
    'hold'     => colors.accent,
    'incoming' => colors.accentPurple,
    _ => colors.textSecondary,
  };

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _detail(context),
    child: Container(
      color: isSelected ? colors.accent.withOpacity(0.04) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
      child: Row(children: [
        SizedBox(width: 36, child: Checkbox(
          value: isSelected,
          onChanged: (v) {
            final sel = ref.read(selectedQueueItemsProvider);
            ref.read(selectedQueueItemsProvider.notifier).state =
                v == true ? {...sel, item.id} : sel.difference({item.id});
          })),
        Expanded(flex: 3, child: Text(item.sender,
          style: TextStyle(color: colors.textPrimary, fontSize: 12, fontFamily: 'monospace'),
          overflow: TextOverflow.ellipsis)),
        Expanded(flex: 3, child: Text(item.recipient,
          style: TextStyle(color: colors.textSecondary, fontSize: 12, fontFamily: 'monospace'),
          overflow: TextOverflow.ellipsis)),
        Expanded(flex: 3, child: Text(item.subject,
          style: TextStyle(color: colors.textSecondary, fontSize: 12),
          overflow: TextOverflow.ellipsis)),
        SizedBox(width: 75, child: Text(_fmtSize(item.size),
          style: TextStyle(color: colors.textSecondary, fontSize: 12))),
        SizedBox(width: 90, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: _sc.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(item.status.toUpperCase(),
            style: TextStyle(color: _sc, fontSize: 10, fontWeight: FontWeight.bold)))),
        SizedBox(width: 120, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(DateFormat('MMM d HH:mm').format(item.arrivedAt),
            style: TextStyle(color: colors.textSecondary, fontSize: 11)),
          if (item.deliveryAttempts > 0)
            Text('${item.deliveryAttempts}× tried',
              style: TextStyle(color: colors.accentOrange, fontSize: 10)),
        ])),
        SizedBox(width: 100, child: Row(mainAxisSize: MainAxisSize.min, children: [
          _IBtn(Icons.send_outlined,  colors.accentGreen,  'Requeue',
              () => ref.read(queueNotifierProvider.notifier).requeueItem(item.id)),
          _IBtn(Icons.pause_outlined, colors.accent,       'Hold',
              () => ref.read(queueNotifierProvider.notifier).holdItem(item.id)),
          _IBtn(Icons.play_arrow,     colors.accentOrange, 'Release',
              () => ref.read(queueNotifierProvider.notifier).releaseItem(item.id)),
          _IBtn(Icons.delete_outline, colors.accentRed,    'Delete',
              () {
                ref.read(queueNotifierProvider.notifier).deleteItem(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted ${item.id}'),
                      duration: const Duration(seconds: 2)));
              }),
        ])),
      ])));

  Widget _IBtn(IconData icon, Color c, String tip, VoidCallback fn) =>
    Tooltip(message: tip, child: IconButton(
      icon: Icon(icon, size: 15, color: c.withOpacity(0.7)),
      onPressed: fn,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24)));

  String _fmtSize(int b) {
    if (b < 1024)        return '${b}B';
    if (b < 1048576)     return '${(b/1024).toStringAsFixed(1)}K';
    return '${(b/1048576).toStringAsFixed(1)}M';
  }

  void _detail(BuildContext ctx) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), side: BorderSide(color: colors.border)),
      title: Row(children: [
        Icon(Icons.mail_outline, color: colors.accent, size: 18),
        const SizedBox(width: 8),
        Text('Queue Item: ${item.id}',
            style: TextStyle(color: colors.textPrimary, fontSize: 14)),
      ]),
      content: SizedBox(width: 580, child: Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dr('Queue ID',  item.id),
          _dr('Sender',    item.sender),
          _dr('Recipient', item.recipient),
          if (item.allRecipients.length > 1)
            _dr('All Recipients', item.allRecipients.join(', ')),
          _dr('Subject',   item.subject),
          _dr('Size',      _fmtSize(item.size)),
          _dr('Status',    item.status.toUpperCase()),
          _dr('Arrived',   DateFormat('yyyy-MM-dd HH:mm:ss').format(item.arrivedAt)),
          _dr('Attempts',  '${item.deliveryAttempts}'),
          if (item.nextDelivery != null)
            _dr('Next Retry', item.nextDelivery!),
          if (item.lastError != null)
            _dr('Last Error', item.lastError!, color: colors.accentRed),
        ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: TextStyle(color: colors.textSecondary))),
        TextButton(onPressed: () {
          ref.read(queueNotifierProvider.notifier).requeueItem(item.id);
          Navigator.pop(ctx);
        }, child: Text('Requeue', style: TextStyle(color: colors.accentGreen))),
        TextButton(onPressed: () {
          ref.read(queueNotifierProvider.notifier).deleteItem(item.id);
          Navigator.pop(ctx);
        }, child: Text('Delete', style: TextStyle(color: colors.accentRed))),
      ]));
  }

  Widget _dr(String label, String value, {Color? color}) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 100, child: Text(label,
          style: TextStyle(color: colors.textSecondary, fontSize: 12))),
        Expanded(child: Text(value, style: TextStyle(
          color: color ?? colors.textPrimary, fontSize: 12, fontFamily: 'monospace'))),
      ]));
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label; final bool active;
  final Color color; final AppColors colors;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.active, required this.color,
      required this.colors, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color:  active ? color.withOpacity(0.12) : colors.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: active ? color.withOpacity(0.4) : colors.border)),
      child: Text(label, style: TextStyle(
        color: active ? color : colors.textSecondary, fontSize: 12))));
}

class _ActionBtn extends StatelessWidget {
  final String label; final IconData icon;
  final Color color; final AppColors colors;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.color,
      required this.colors, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))])));
}

class _ConfirmDialog extends StatelessWidget {
  final String title, message, confirmLabel;
  final Color confirmColor; final AppColors colors;
  final VoidCallback onConfirm;
  const _ConfirmDialog({required this.title, required this.message,
      required this.confirmLabel, required this.confirmColor,
      required this.colors, required this.onConfirm});
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: colors.card,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), side: BorderSide(color: colors.border)),
    title: Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 15)),
    content: Text(message, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: colors.textSecondary))),
      TextButton(onPressed: () { Navigator.pop(context); onConfirm(); },
          child: Text(confirmLabel, style: TextStyle(color: confirmColor, fontWeight: FontWeight.bold))),
    ]);
}

class _Empty extends StatelessWidget {
  final String search; final String? filter; final AppColors colors;
  const _Empty({required this.search, required this.filter, required this.colors});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inbox_outlined, color: colors.textSecondary, size: 48),
      const SizedBox(height: 16),
      Text(search.isNotEmpty ? 'No results for "$search"' : 'Queue is empty',
          style: TextStyle(color: colors.textSecondary, fontSize: 16)),
      if (filter != null) ...[
        const SizedBox(height: 8),
        Text('No $filter messages found',
            style: TextStyle(color: colors.textSecondary, fontSize: 12)),
      ],
    ]));
}

class _Error extends StatelessWidget {
  final String error; final AppColors colors; final VoidCallback onRetry;
  const _Error({required this.error, required this.colors, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.wifi_off_outlined, color: colors.accentRed, size: 40),
      const SizedBox(height: 16),
      Text('Cannot load queue', style: TextStyle(color: colors.textPrimary, fontSize: 15)),
      const SizedBox(height: 8),
      Text(error, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
      const SizedBox(height: 16),
      GestureDetector(onTap: onRetry, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: colors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(7),
          border: Border.all(color: colors.accent.withOpacity(0.3))),
        child: Text('Retry', style: TextStyle(color: colors.accent)))),
    ]));
}
