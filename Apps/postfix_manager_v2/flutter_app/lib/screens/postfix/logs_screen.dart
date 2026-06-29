// lib/screens/postfix/logs_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});
  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  bool _autoScroll = true;

  @override
  void dispose() { _scrollCtrl.dispose(); _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final colors   = Theme.of(context).extension<AppColors>()!;
    final logsAsync = ref.watch(logsProvider);
    final levelFilter = ref.watch(logLevelFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF090D12),
      body: Column(children: [
        // Toolbar
        Container(
          color: colors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(children: [
            Icon(Icons.terminal_outlined, color: colors.accent, size: 20),
            const SizedBox(width: 10),
            Text('Live Logs', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 24),
            // Level filters
            for (final f in [null, 'INFO', 'WARN', 'ERROR'])
              Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(
                onTap: () => ref.read(logLevelFilterProvider.notifier).state = f,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: levelFilter == f ? _levelColor(f, colors).withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: levelFilter == f ? _levelColor(f, colors).withOpacity(0.4) : colors.border)),
                  child: Text(f ?? 'ALL',
                    style: TextStyle(
                      color: levelFilter == f ? _levelColor(f, colors) : colors.textSecondary,
                      fontSize: 11, fontWeight: FontWeight.w600))))),
            const Spacer(),
            // Search
            SizedBox(width: 240, child: TextField(
              controller: _searchCtrl,
              style: TextStyle(color: colors.textPrimary, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search logs…',
                prefixIcon: Icon(Icons.search, size: 16, color: colors.textSecondary),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                isDense: true),
              onChanged: (v) => ref.read(logSearchProvider.notifier).state = v)),
            const SizedBox(width: 12),
            // Auto-scroll toggle
            GestureDetector(
              onTap: () => setState(() => _autoScroll = !_autoScroll),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _autoScroll ? colors.accent.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _autoScroll ? colors.accent.withOpacity(0.3) : colors.border)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.vertical_align_bottom, size: 14,
                      color: _autoScroll ? colors.accent : colors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Auto-scroll',
                    style: TextStyle(color: _autoScroll ? colors.accent : colors.textSecondary, fontSize: 11)),
                ]))),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () { ref.invalidate(logsProvider); },
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(6), border: Border.all(color: colors.border)),
                child: Icon(Icons.refresh, color: colors.textSecondary, size: 16))),
          ])),
        const Divider(height: 1),
        // Log output
        Expanded(child: logsAsync.when(
          data: (logs) {
            if (_autoScroll) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollCtrl.hasClients) {
                  _scrollCtrl.animateTo(
                    _scrollCtrl.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut);
                }
              });
            }
            if (logs.isEmpty) return Center(child: Text('No log entries',
                style: TextStyle(color: colors.textSecondary)));
            return ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: logs.length,
              itemBuilder: (_, i) => _LogLine(log: logs[i], colors: colors));
          },
          loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
          error: (_, __) {
            // Show mock data for demo
            final mock = _mockLogs();
            return ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: mock.length,
              itemBuilder: (_, i) => _LogLine(log: mock[i], colors: colors));
          })),
      ]));
  }

  Color _levelColor(String? level, AppColors c) => switch (level) {
    'ERROR' => c.accentRed,
    'WARN'  => c.accentOrange,
    'INFO'  => c.accentGreen,
    _ => c.accent,
  };

  List<MailLog> _mockLogs() {
    final now = DateTime.now();
    return [
      MailLog(id: '1', timestamp: now.subtract(const Duration(seconds: 30)),
        level: 'INFO', process: 'postfix/smtpd', message: 'connect from mail.google.com[74.125.128.27]',
        host: 'mail.google.com', ip: '74.125.128.27'),
      MailLog(id: '2', timestamp: now.subtract(const Duration(seconds: 28)),
        level: 'INFO', process: 'postfix/smtpd', message: '4A2B3C4D5E: client=mail.google.com[74.125.128.27]',
        queueId: '4A2B3C4D5E', from: 'sender@gmail.com'),
      MailLog(id: '3', timestamp: now.subtract(const Duration(seconds: 25)),
        level: 'INFO', process: 'postfix/cleanup', message: '4A2B3C4D5E: message-id=<abc123@mail.gmail.com>',
        queueId: '4A2B3C4D5E'),
      MailLog(id: '4', timestamp: now.subtract(const Duration(seconds: 24)),
        level: 'INFO', process: 'postfix/qmgr', message: '4A2B3C4D5E: from=<sender@gmail.com>, size=2847, nrcpt=1',
        queueId: '4A2B3C4D5E', from: 'sender@gmail.com'),
      MailLog(id: '5', timestamp: now.subtract(const Duration(seconds: 23)),
        level: 'INFO', process: 'postfix/smtp', message: '4A2B3C4D5E: to=<user@example.com>, relay=localhost, status=sent (250 OK)',
        queueId: '4A2B3C4D5E', to: 'user@example.com', status: 'sent', delay: 2),
      MailLog(id: '6', timestamp: now.subtract(const Duration(seconds: 15)),
        level: 'WARN', process: 'postfix/smtpd', message: 'NOQUEUE: reject: RCPT from unknown[192.168.1.50]: 554 5.7.1 Relay access denied',
        ip: '192.168.1.50'),
      MailLog(id: '7', timestamp: now.subtract(const Duration(seconds: 10)),
        level: 'ERROR', process: 'postfix/smtp', message: 'B1C2D3E4F5: to=<user@example.org>, connect to example.org[93.184.216.34]:25: Connection refused',
        queueId: 'B1C2D3E4F5', to: 'user@example.org', status: 'deferred'),
      MailLog(id: '8', timestamp: now.subtract(const Duration(seconds: 5)),
        level: 'INFO', process: 'postfix/smtpd', message: 'disconnect from mail.sendgrid.net[167.89.0.1] ehlo=1 mail=1 rcpt=1 data=1 quit=1',
        host: 'mail.sendgrid.net'),
    ];
  }
}

class _LogLine extends StatelessWidget {
  final MailLog log;
  final AppColors colors;
  const _LogLine({required this.log, required this.colors});

  Color get _levelColor => switch (log.level) {
    'ERROR' => colors.accentRed,
    'WARN'  => colors.accentOrange,
    'INFO'  => colors.accentGreen,
    _ => colors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => Clipboard.setData(ClipboardData(
          text: '${DateFormat("HH:mm:ss").format(log.timestamp)} ${log.level} ${log.process}: ${log.message}')),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Timestamp
          SizedBox(width: 70, child: Text(
            DateFormat('HH:mm:ss').format(log.timestamp),
            style: TextStyle(color: colors.textSecondary.withOpacity(0.6), fontSize: 11, fontFamily: 'monospace'))),
          // Level badge
          SizedBox(width: 48, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: _levelColor.withOpacity(0.1), borderRadius: BorderRadius.circular(3)),
            child: Text(log.level.length > 4 ? log.level.substring(0, 4) : log.level,
              style: TextStyle(color: _levelColor, fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center))),
          const SizedBox(width: 4),
          // Process
          SizedBox(width: 160, child: Text(log.process,
            style: TextStyle(color: colors.accent.withOpacity(0.6), fontSize: 11, fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 4),
          // Message with email highlighting
          Expanded(child: _buildMessage(log.message)),
        ])));
  }

  Widget _buildMessage(String msg) {
    // Highlight queue IDs, emails and IPs
    final spans = <TextSpan>[];
    final pattern = RegExp(r'([A-F0-9]{10,}|[\w.+-]+@[\w.-]+\.\w+|\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b)');
    int last = 0;
    for (final match in pattern.allMatches(msg)) {
      if (match.start > last) {
        spans.add(TextSpan(text: msg.substring(last, match.start),
          style: TextStyle(color: colors.textPrimary.withOpacity(0.8))));
      }
      final matched = match.group(0)!;
      final isEmail = matched.contains('@');
      final isQueueId = RegExp(r'^[A-F0-9]{10,}$').hasMatch(matched);
      spans.add(TextSpan(text: matched, style: TextStyle(
        color: isEmail ? colors.accentOrange : isQueueId ? colors.accent : colors.accentGreen,
        fontWeight: FontWeight.w600)));
      last = match.end;
    }
    if (last < msg.length) {
      spans.add(TextSpan(text: msg.substring(last),
        style: TextStyle(color: colors.textPrimary.withOpacity(0.8))));
    }
    return RichText(text: TextSpan(
      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
      children: spans));
  }
}
