// lib/screens/alerts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final alertsAsync = ref.watch(alertsNotifierProvider);

    // Use mock alerts for demo
    final mockAlerts = _mockAlerts();

    return Scaffold(
      backgroundColor: colors.bg,
      body: Column(children: [
        _buildToolbar(colors, ref, mockAlerts),
        const Divider(height: 1),
        Expanded(child: _AlertList(alerts: mockAlerts, colors: colors, ref: ref)),
      ]));
  }

  Widget _buildToolbar(AppColors colors, WidgetRef ref, List<Alert> alerts) {
    final unread = alerts.where((a) => !a.isRead).length;
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(children: [
        Icon(Icons.notifications_outlined, color: colors.accent, size: 20),
        const SizedBox(width: 10),
        Text('Alerts', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        if (unread > 0) Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: colors.accentRed, borderRadius: BorderRadius.circular(10)),
          child: Text('$unread unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
        const Spacer(),
        GestureDetector(
          onTap: () => ref.read(alertsNotifierProvider.notifier).markAllRead(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(7), border: Border.all(color: colors.border)),
            child: Text('Mark all read', style: TextStyle(color: colors.textSecondary, fontSize: 12)))),
      ]));
  }

  List<Alert> _mockAlerts() => [
    Alert(id: '1', title: 'Mail Queue Threshold Exceeded',
        message: 'Queue size has reached 487 messages (threshold: 100). Delivery may be delayed.',
        severity: AlertSeverity.critical, createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false, actionLabel: 'View Queue', actionRoute: '/queue'),
    Alert(id: '2', title: 'TLS Certificate Expiring',
        message: 'Certificate for mail.company.org expires in 25 days. Renew before expiry to avoid delivery issues.',
        severity: AlertSeverity.warning, createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false, actionLabel: 'Manage TLS', actionRoute: '/tls'),
    Alert(id: '3', title: 'High Error Rate Detected',
        message: 'smtp_error_rate exceeded 15% in the last hour. 23 rejected connections from 45.89.12.0/24.',
        severity: AlertSeverity.critical, createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false, actionLabel: 'View Logs', actionRoute: '/logs'),
    Alert(id: '4', title: 'DMARC Check Failing',
        message: 'Domain example.com has no DMARC policy configured. Messages may be rejected by recipients.',
        severity: AlertSeverity.warning, createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        isRead: true, actionLabel: 'Check DNS', actionRoute: '/dns'),
    Alert(id: '5', title: 'Scheduled Backup Completed',
        message: 'Daily backup completed successfully. Size: 44.1KB, includes: main.cf, master.cf, virtual tables.',
        severity: AlertSeverity.info, createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true, actionLabel: 'View Backups', actionRoute: '/backup'),
    Alert(id: '6', title: 'Postfix Configuration Updated',
        message: 'Parameter message_size_limit changed from 10240000 to 52428800 by admin.',
        severity: AlertSeverity.info, createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true),
  ];
}

class _AlertList extends StatelessWidget {
  final List<Alert> alerts;
  final AppColors colors;
  final WidgetRef ref;
  const _AlertList({required this.alerts, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.notifications_none_outlined, color: colors.textSecondary, size: 48),
        const SizedBox(height: 16),
        Text('No alerts', style: TextStyle(color: colors.textSecondary, fontSize: 16)),
      ]));

    final critical = alerts.where((a) => a.severity == AlertSeverity.critical).toList();
    final warnings = alerts.where((a) => a.severity == AlertSeverity.warning).toList();
    final infos = alerts.where((a) => a.severity == AlertSeverity.info).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (critical.isNotEmpty) ...[
          _sectionHead('Critical', critical.length, colors.accentRed, colors),
          const SizedBox(height: 8),
          ...critical.map((a) => _AlertCard(alert: a, colors: colors, ref: ref, context_: context)),
          const SizedBox(height: 20),
        ],
        if (warnings.isNotEmpty) ...[
          _sectionHead('Warnings', warnings.length, colors.accentOrange, colors),
          const SizedBox(height: 8),
          ...warnings.map((a) => _AlertCard(alert: a, colors: colors, ref: ref, context_: context)),
          const SizedBox(height: 20),
        ],
        if (infos.isNotEmpty) ...[
          _sectionHead('Informational', infos.length, colors.textSecondary, colors),
          const SizedBox(height: 8),
          ...infos.map((a) => _AlertCard(alert: a, colors: colors, ref: ref, context_: context)),
        ],
      ]);
  }

  Widget _sectionHead(String label, int count, Color color, AppColors colors) =>
    Row(children: [
      Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(width: 8),
      Text('($count)', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
      Expanded(child: Container(height: 1, margin: const EdgeInsets.only(left: 12), color: colors.border)),
    ]);
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  final AppColors colors;
  final WidgetRef ref;
  final BuildContext context_;
  const _AlertCard({required this.alert, required this.colors, required this.ref, required this.context_});

  Color get _color => switch (alert.severity) {
    AlertSeverity.critical => colors.accentRed,
    AlertSeverity.warning => colors.accentOrange,
    AlertSeverity.info => colors.accent,
  };

  IconData get _icon => switch (alert.severity) {
    AlertSeverity.critical => Icons.error_outline,
    AlertSeverity.warning => Icons.warning_amber_outlined,
    AlertSeverity.info => Icons.info_outline,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: alert.isRead ? colors.card : colors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: alert.isRead ? colors.border : _color.withOpacity(0.4))),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => ref.read(alertsNotifierProvider.notifier).markRead(alert.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Unread dot
              if (!alert.isRead)
                Container(
                  margin: const EdgeInsets.only(top: 5, right: 10),
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: _color, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: _color.withOpacity(0.5), blurRadius: 4)]))
              else
                const SizedBox(width: 18),
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(_icon, color: _color, size: 18)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(alert.title, style: TextStyle(
                      color: alert.isRead ? colors.textSecondary : colors.textPrimary,
                      fontSize: 13, fontWeight: alert.isRead ? FontWeight.normal : FontWeight.w600))),
                  Text(
                    _timeAgo(alert.createdAt),
                    style: TextStyle(color: colors.textSecondary, fontSize: 11)),
                ]),
                const SizedBox(height: 6),
                Text(alert.message, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                if (alert.actionLabel != null) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () { if (alert.actionRoute != null) context.go(alert.actionRoute!); },
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(alert.actionLabel!, style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 13, color: _color),
                    ])),
                ],
              ])),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.close, size: 14, color: colors.textSecondary),
                onPressed: () => ref.read(alertsNotifierProvider.notifier).delete(alert.id),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24)),
            ])))));
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
