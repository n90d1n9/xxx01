// lib/screens/postfix/queue_screen.dart
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
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final colors   = Theme.of(context).extension<AppColors>()!;
    final queueAsync = ref.watch(queueNotifierProvider);
    final filter   = ref.watch(queueStatusFilterProvider);
    final selected = ref.watch(selectedQueueItemsProvider);
    final search   = ref.watch(queueSearchProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      body: Column(children: [
        // Toolbar
        Container(
          color: colors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(children: [
            Row(children: [
              Icon(Icons.queue_outlined, color: colors.accent, size: 20),
              const SizedBox(width: 10),
              Text('Mail Queue', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              queueAsync.when(
                data: (q) => _chip('${q.length} messages', colors.textSecondary, colors),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink()),
              const Spacer(),
              // Search
              SizedBox(width: 220, child: TextField(
                controller: _searchCtrl,
                style: TextStyle(color: colors.textPrimary, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Search sender, recipient…',
                  prefixIcon: Icon(Icons.search, size: 16, color: colors.textSecondary),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  isDense: true),
                onChanged: (v) => ref.read(queueSearchProvider.notifier).state = v)),
              const SizedBox(width: 12),
              // Batch actions
              if (selected.isNotEmpty) ...[
                _actionBtn('Delete (${selected.length})', Icons.delete_outline, colors.accentRed, colors, () {
                  ref.read(queueNotifierProvider.notifier).deleteSelected(selected.toList());
                }),
                const SizedBox(width: 8),
              ],
              _actionBtn('Flush All', Icons.send, colors.accentOrange, colors, () {
                ref.read(queueNotifierProvider.notifier).flushAll();
              }),
              const SizedBox(width: 8),
              _actionBtn('Refresh', Icons.refresh, colors.accent, colors, () {
                ref.read(queueNotifierProvider.notifier).refresh();
              }),
            ]),
            const SizedBox(height: 12),
            // Status filter chips
            Row(children: [
              for (final f in [null, 'active', 'deferred', 'hold', 'incoming'])
                Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(
                  onTap: () {
                    ref.read(queueStatusFilterProvider.notifier).state = f;
                    ref.read(queueNotifierProvider.notifier).refresh();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: filter == f ? _statusColor(f, colors).withOpacity(0.12) : colors.bg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: filter == f ? _statusColor(f, colors).withOpacity(0.4) : colors.border)),
                    child: Text(f == null ? 'All' : f.capitalize(),
                      style: TextStyle(
                        color: filter == f ? _statusColor(f, colors) : colors.textSecondary,
                        fontSize: 12))))),
            ]),
          ])),
        const Divider(height: 1),
        // Table header
        Container(
          color: colors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(children: [
            SizedBox(width: 36, child: Checkbox(
              tristate: true,
              value: queueAsync.value?.isEmpty == true ? false
                  : selected.length == (queueAsync.value?.length ?? 0) ? true : null,
              onChanged: (v) {
                final items = queueAsync.value ?? [];
                ref.read(selectedQueueItemsProvider.notifier).state =
                    v == true ? items.map((q) => q.id).toSet() : {};
              })),
            Expanded(flex: 2, child: _hdr('SENDER', colors)),
            Expanded(flex: 2, child: _hdr('RECIPIENT', colors)),
            Expanded(flex: 2, child: _hdr('SUBJECT', colors)),
            SizedBox(width: 80, child: _hdr('SIZE', colors)),
            SizedBox(width: 90, child: _hdr('STATUS', colors)),
            SizedBox(width: 130, child: _hdr('ARRIVED', colors)),
            SizedBox(width: 110, child: _hdr('ACTIONS', colors)),
          ])),
        const Divider(height: 1),
        // Queue list
        Expanded(child: queueAsync.when(
          data: (queue) {
            if (queue.isEmpty) return _emptyState(colors, filter, search);
            return ListView.separated(
              itemCount: queue.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: colors.border.withOpacity(0.4)),
              itemBuilder: (_, i) => _QueueRow(
                item: queue[i], colors: colors, ref: ref,
                isSelected: selected.contains(queue[i].id)));
          },
          loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
          error: (e, _) => _QueueError(error: e.toString(), colors: colors))),
      ]));
  }

  Color _statusColor(String? s, AppColors c) => switch (s) {
    'active'   => c.accentGreen,
    'deferred' => c.accentOrange,
    'hold'     => c.accent,
    'incoming' => c.accentPurple,
    _ => c.accent,
  };

  Widget _chip(String text, Color color, AppColors c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(4), border: Border.all(color: c.border)),
    child: Text(text, style: TextStyle(color: color, fontSize: 11)));

  Widget _hdr(String t, AppColors c) => Text(t,
    style: TextStyle(color: c.textSecondary, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5));

  Widget _actionBtn(String label, IconData icon, Color color, AppColors c, VoidCallback onTap) =>
    GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))])));

  Widget _emptyState(AppColors c, String? filter, String search) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inbox_outlined, color: c.textSecondary, size: 48),
      const SizedBox(height: 16),
      Text(search.isNotEmpty ? 'No results for "$search"' : 'Mail queue is empty',
          style: TextStyle(color: c.textSecondary, fontSize: 16)),
      if (filter != null) ...[
        const SizedBox(height: 8),
        Text('No ${filter} messages in queue', style: TextStyle(color: c.textSecondary, fontSize: 12)),
      ],
    ]));
}

class _QueueRow extends StatelessWidget {
  final MailQueue item;
  final AppColors colors;
  final WidgetRef ref;
  final bool isSelected;
  const _QueueRow({required this.item, required this.colors, required this.ref, required this.isSelected});

  Color get _statusColor => switch (item.status) {
    'active'   => colors.accentGreen,
    'deferred' => colors.accentOrange,
    'hold'     => colors.accent,
    'incoming' => colors.accentPurple,
    _ => colors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        color: isSelected ? colors.accent.withOpacity(0.05) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(children: [
          SizedBox(width: 36, child: Checkbox(
            value: isSelected,
            onChanged: (v) {
              final sel = ref.read(selectedQueueItemsProvider);
              ref.read(selectedQueueItemsProvider.notifier).state =
                  v == true ? {...sel, item.id} : sel.difference({item.id});
            })),
          Expanded(flex: 2, child: Text(item.sender,
            style: TextStyle(color: colors.textPrimary, fontSize: 12, fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(item.recipient,
            style: TextStyle(color: colors.textSecondary, fontSize: 12, fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(item.subject,
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
            overflow: TextOverflow.ellipsis)),
          SizedBox(width: 80, child: Text(_fmtSize(item.size),
            style: TextStyle(color: colors.textSecondary, fontSize: 12))),
          SizedBox(width: 90, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(item.status.toUpperCase(),
              style: TextStyle(color: _statusColor, fontSize: 10, fontWeight: FontWeight.bold)))),
          SizedBox(width: 130, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(DateFormat('MMM d HH:mm').format(item.arrivedAt),
              style: TextStyle(color: colors.textSecondary, fontSize: 11)),
            if (item.deliveryAttempts > 0)
              Text('${item.deliveryAttempts} attempt${item.deliveryAttempts > 1 ? "s" : ""}',
                style: TextStyle(color: colors.accentOrange, fontSize: 10)),
          ])),
          SizedBox(width: 110, child: Row(mainAxisSize: MainAxisSize.min, children: [
            _iconBtn(Icons.send_outlined, colors.accentGreen, 'Requeue',
                () => ref.read(queueNotifierProvider.notifier).requeueItem(item.id)),
            _iconBtn(Icons.pause_outlined, colors.accent, 'Hold',
                () => ref.read(queueNotifierProvider.notifier).holdItem(item.id)),
            _iconBtn(Icons.play_arrow_outlined, colors.accentOrange, 'Release',
                () => ref.read(queueNotifierProvider.notifier).releaseItem(item.id)),
            _iconBtn(Icons.delete_outline, colors.accentRed, 'Delete',
                () => ref.read(queueNotifierProvider.notifier).deleteItem(item.id)),
          ])),
        ])));
  }

  Widget _iconBtn(IconData icon, Color color, String tooltip, VoidCallback onTap) =>
    Tooltip(message: tooltip, child: IconButton(
      icon: Icon(icon, size: 15, color: color.withOpacity(0.7)),
      onPressed: onTap,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
      hoverColor: color.withOpacity(0.1)));

  String _fmtSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)}K';
    return '${(bytes / 1048576).toStringAsFixed(1)}M';
  }

  void _showDetail(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colors.border)),
      title: Row(children: [
        Icon(Icons.mail_outline, color: colors.accent, size: 20),
        const SizedBox(width: 8),
        Text('Queue Item Detail', style: TextStyle(color: colors.textPrimary)),
      ]),
      content: SizedBox(width: 560, child: Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow('Queue ID',  item.id, colors),
          _detailRow('Sender',    item.sender, colors),
          _detailRow('Recipient', item.recipient, colors),
          _detailRow('Subject',   item.subject, colors),
          _detailRow('Size',      _fmtSize(item.size), colors),
          _detailRow('Status',    item.status.toUpperCase(), colors),
          _detailRow('Arrived',   DateFormat('yyyy-MM-dd HH:mm:ss').format(item.arrivedAt), colors),
          _detailRow('Attempts',  '${item.deliveryAttempts}', colors),
          if (item.lastError != null)
            _detailRow('Last Error', item.lastError!, colors, color: colors.accentRed),
          if (item.nextDelivery != null)
            _detailRow('Next Retry', item.nextDelivery!, colors),
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

  Widget _detailRow(String label, String value, AppColors c, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 100, child: Text(label, style: TextStyle(color: c.textSecondary, fontSize: 12))),
      Expanded(child: Text(value,
        style: TextStyle(color: color ?? c.textPrimary, fontSize: 12, fontFamily: 'monospace'))),
    ]));
}

class _QueueError extends StatelessWidget {
  final String error; final AppColors colors;
  const _QueueError({required this.error, required this.colors});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.wifi_off_outlined, color: colors.accentRed, size: 48),
      const SizedBox(height: 16),
      Text('Cannot load queue', style: TextStyle(color: colors.textPrimary, fontSize: 16)),
      const SizedBox(height: 8),
      Text(error, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
    ]));
}

extension StringExt on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
