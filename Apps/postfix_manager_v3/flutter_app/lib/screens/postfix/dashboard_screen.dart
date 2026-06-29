// lib/screens/postfix/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors   = Theme.of(context).extension<AppColors>()!;
    final statusAsync = ref.watch(serverStatusProvider);
    final statsAsync  = ref.watch(statsProvider);
    final period      = ref.watch(statsPeriodProvider);
    final alertsAsync = ref.watch(alertsNotifierProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      body: Column(children: [
        // Top bar
        _TopBar(colors: colors, ref: ref, period: period),
        const Divider(height: 1),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Server status card
            statusAsync.when(
              data: (s) => _ServerStatusCard(status: s, colors: colors, ref: ref),
              loading: () => _LoadingCard(colors: colors, height: 120),
              error: (_, __) => _ErrorCard(msg: 'Cannot reach backend', colors: colors)),
            const SizedBox(height: 20),

            // Unread alerts banner
            alertsAsync.when(
              data: (alerts) {
                final critical = alerts.where((a) => !a.isRead && a.severity == AlertSeverity.critical).length;
                if (critical == 0) return const SizedBox.shrink();
                return _AlertBanner(count: critical, colors: colors);
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink()),

            // Stat tiles
            statsAsync.when(
              data: (s) => _StatGrid(stats: s, colors: colors),
              loading: () => _LoadingCard(colors: colors, height: 110),
              error: (_, __) => _ErrorCard(msg: 'Could not load stats', colors: colors)),
            const SizedBox(height: 20),

            // Charts row
            statsAsync.when(
              data: (s) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _VolumeChart(stats: s, colors: colors)),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _DeliveryPieChart(stats: s, colors: colors)),
                ]),
              loading: () => _LoadingCard(colors: colors, height: 280),
              error: (_, __) => const SizedBox.shrink()),
            const SizedBox(height: 20),

            // Tables row: top senders + top domains
            statsAsync.when(
              data: (s) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _TopTable(
                    title: 'Top Senders', icon: Icons.send_outlined,
                    rows: s.topSenders.map((e) => (e.email, e.count)).toList(),
                    colors: colors)),
                  const SizedBox(width: 16),
                  Expanded(child: _TopTable(
                    title: 'Top Domains', icon: Icons.domain_outlined,
                    rows: s.topDomains.map((e) => (e.domain, e.count)).toList(),
                    colors: colors)),
                ]),
              loading: () => _LoadingCard(colors: colors, height: 200),
              error: (_, __) => const SizedBox.shrink()),
          ]))),
      ]));
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final AppColors colors; final WidgetRef ref; final String period;
  const _TopBar({required this.colors, required this.ref, required this.period});

  @override
  Widget build(BuildContext context) => Container(
    color: colors.surface,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    child: Row(children: [
      Icon(Icons.dashboard_outlined, color: colors.accent, size: 20),
      const SizedBox(width: 10),
      Text('Dashboard', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
      const Spacer(),
      // Period selector
      for (final p in ['1h', '24h', '7d'])
        Padding(padding: const EdgeInsets.only(left: 6), child: GestureDetector(
          onTap: () => ref.read(statsPeriodProvider.notifier).state = p,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: period == p ? colors.accent.withOpacity(0.12) : colors.bg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: period == p ? colors.accent.withOpacity(0.4) : colors.border)),
            child: Text(p, style: TextStyle(
              color: period == p ? colors.accent : colors.textSecondary, fontSize: 12))))),
      const SizedBox(width: 12),
      // Refresh
      GestureDetector(
        onTap: () { ref.invalidate(serverStatusProvider); ref.invalidate(statsProvider); },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: colors.border)),
          child: Icon(Icons.refresh, color: colors.textSecondary, size: 16))),
    ]));
}

// ─── Alert Banner ─────────────────────────────────────────────────────────────
class _AlertBanner extends StatelessWidget {
  final int count; final AppColors colors;
  const _AlertBanner({required this.count, required this.colors});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: colors.accentRed.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: colors.accentRed.withOpacity(0.3))),
    child: Row(children: [
      Icon(Icons.error_outline, color: colors.accentRed, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(
        '$count critical alert${count > 1 ? "s" : ""} require your attention',
        style: TextStyle(color: colors.accentRed, fontSize: 13))),
      GestureDetector(
        onTap: () => context.go('/alerts'),
        child: Text('View Alerts →',
          style: TextStyle(color: colors.accentRed, fontSize: 12, fontWeight: FontWeight.bold))),
    ]));
}

// ─── Server Status Card ───────────────────────────────────────────────────────
class _ServerStatusCard extends StatelessWidget {
  final ServerStatus status; final AppColors colors; final WidgetRef ref;
  const _ServerStatusCard({required this.status, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    final running = status.isRunning;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card, borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: running ? colors.accentGreen.withOpacity(0.3) : colors.accentRed.withOpacity(0.3))),
      child: Row(children: [
        // Status indicator
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: (running ? colors.accentGreen : colors.accentRed).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14)),
          child: Icon(
            running ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: running ? colors.accentGreen : colors.accentRed, size: 28)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(running ? 'Postfix Running' : 'Postfix Stopped',
              style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            _pill('v${status.version}', colors.textSecondary, colors),
            if (status.pid > 0) ...[
              const SizedBox(width: 6),
              _pill('PID ${status.pid}', colors.textSecondary, colors),
            ],
          ]),
          const SizedBox(height: 4),
          Text(
            status.startedAt != null
                ? 'Started ${_ago(status.startedAt!)} ago'
                : 'Not running',
            style: TextStyle(color: colors.textSecondary, fontSize: 12)),
        ])),
        // Metrics
        _metric('CPU', '${status.cpuUsage.toStringAsFixed(1)}%',
            status.cpuUsage > 80 ? colors.accentRed : colors.accentGreen, colors),
        const SizedBox(width: 20),
        _metric('Memory', '${status.memoryUsage.toStringAsFixed(1)}%',
            status.memoryUsage > 80 ? colors.accentOrange : colors.accentGreen, colors),
        const SizedBox(width: 20),
        _metric('Connections', '${status.connectionsActive}',
            colors.accent, colors),
        const SizedBox(width: 24),
        // Control buttons
        Column(children: [
          if (!running) _ctrlBtn('Start', colors.accentGreen, colors,
              () => ref.read(apiServiceProvider).startServer()),
          if (running) ...[
            _ctrlBtn('Reload', colors.accentOrange, colors,
                () => ref.read(apiServiceProvider).reloadServer()),
            const SizedBox(height: 6),
            _ctrlBtn('Stop', colors.accentRed, colors,
                () => ref.read(apiServiceProvider).stopServer()),
          ],
        ]),
      ]));
  }

  Widget _pill(String text, Color color, AppColors c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(4), border: Border.all(color: c.border)),
    child: Text(text, style: TextStyle(color: color, fontSize: 11, fontFamily: 'monospace')));

  Widget _metric(String label, String value, Color color, AppColors c) => Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
    Text(label, style: TextStyle(color: c.textSecondary, fontSize: 10)),
  ]);

  Widget _ctrlBtn(String label, Color color, AppColors c, VoidCallback onTap) =>
    GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))));

  String _ago(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inDays > 0) return '${d.inDays}d';
    if (d.inHours > 0) return '${d.inHours}h';
    return '${d.inMinutes}m';
  }
}

// ─── Stat Grid ────────────────────────────────────────────────────────────────
class _StatGrid extends StatelessWidget {
  final PostfixStats stats; final AppColors colors;
  const _StatGrid({required this.stats, required this.colors});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _StatData('Total',     '${stats.totalMessages}',     Icons.mail_outline,          colors.accent,       null),
      _StatData('Delivered', '${stats.deliveredMessages}', Icons.check_circle_outline,  colors.accentGreen,
          '${stats.totalMessages > 0 ? (stats.deliveredMessages / stats.totalMessages * 100).toStringAsFixed(1) : 0}%'),
      _StatData('Deferred',  '${stats.deferredMessages}',  Icons.schedule_outlined,     colors.accentOrange, null),
      _StatData('Bounced',   '${stats.bouncedMessages}',   Icons.cancel_outlined,       colors.accentRed,    null),
      _StatData('Rejected',  '${stats.rejectedMessages}',  Icons.block_outlined,        colors.accentPurple, null),
      _StatData('Queue',     '${stats.queueSize}',         Icons.queue_outlined,        colors.accent,       null),
    ];
    return GridView.count(
      crossAxisCount: 6, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.15,
      children: tiles.map((t) => _StatTile(data: t, colors: colors)).toList());
  }
}

class _StatData {
  final String label, value;
  final IconData icon;
  final Color color;
  final String? sub;
  const _StatData(this.label, this.value, this.icon, this.color, this.sub);
}

class _StatTile extends StatelessWidget {
  final _StatData data; final AppColors colors;
  const _StatTile({required this.data, required this.colors});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colors.card, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: colors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(data.icon, color: data.color, size: 16),
        const Spacer(),
        if (data.sub != null)
          Text(data.sub!, style: TextStyle(color: data.color, fontSize: 10, fontWeight: FontWeight.bold)),
      ]),
      const Spacer(),
      Text(data.value,
        style: TextStyle(color: colors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
      Text(data.label, style: TextStyle(color: colors.textSecondary, fontSize: 11)),
    ]));
}

// ─── Volume Bar Chart ─────────────────────────────────────────────────────────
class _VolumeChart extends StatelessWidget {
  final PostfixStats stats; final AppColors colors;
  const _VolumeChart({required this.stats, required this.colors});

  @override
  Widget build(BuildContext context) {
    final entries = stats.hourlyVolume.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final maxVal = entries.isEmpty ? 1.0
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Mail Volume', style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          _legend(colors.accent, 'Messages', colors),
        ]),
        const SizedBox(height: 16),
        Expanded(child: entries.isEmpty
            ? Center(child: Text('No data', style: TextStyle(color: colors.textSecondary)))
            : BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => colors.surface,
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '${entries[group.x].key}\n${rod.toY.toInt()} msgs',
                      TextStyle(color: colors.textPrimary, fontSize: 11)))),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true, reservedSize: 20,
                    getTitlesWidget: (v, _) {
                      if (v.toInt() >= entries.length) return const SizedBox.shrink();
                      final key = entries[v.toInt()].key;
                      if (entries.length > 12 && v.toInt() % 4 != 0) return const SizedBox.shrink();
                      return Text(key.length > 5 ? key.substring(key.length - 5) : key,
                          style: TextStyle(color: colors.textSecondary, fontSize: 9));
                    })),
                  leftTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true, reservedSize: 32,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}',
                        style: TextStyle(color: colors.textSecondary, fontSize: 9)))),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: colors.border, strokeWidth: 0.5)),
                borderData: FlBorderData(show: false),
                barGroups: entries.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [BarChartRodData(
                    toY: e.value.value.toDouble(),
                    width: entries.length > 24 ? 6 : 12,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [colors.accent, colors.accent.withOpacity(0.4)]))]
                )).toList()))),
      ]));
  }

  Widget _legend(Color c, String label, AppColors colors) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 6),
    Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 11)),
  ]);
}

// ─── Delivery Pie Chart ───────────────────────────────────────────────────────
class _DeliveryPieChart extends StatelessWidget {
  final PostfixStats stats; final AppColors colors;
  const _DeliveryPieChart({required this.stats, required this.colors});

  @override
  Widget build(BuildContext context) {
    final total = stats.totalMessages;
    if (total == 0) return _empty(colors);

    final sections = [
      PieChartSectionData(value: stats.deliveredMessages.toDouble(),
          color: colors.accentGreen, title: '', radius: 60),
      PieChartSectionData(value: stats.deferredMessages.toDouble(),
          color: colors.accentOrange, title: '', radius: 60),
      PieChartSectionData(value: stats.bouncedMessages.toDouble(),
          color: colors.accentRed, title: '', radius: 60),
      if (stats.rejectedMessages > 0)
        PieChartSectionData(value: stats.rejectedMessages.toDouble(),
            color: colors.accentPurple, title: '', radius: 60),
    ];

    return Container(
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Delivery Status', style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Expanded(child: Row(children: [
          Expanded(child: PieChart(PieChartData(
            sections: sections, sectionsSpace: 2, centerSpaceRadius: 40,
            borderData: FlBorderData(show: false)))),
          Column(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _leg('Delivered', stats.deliveredMessages, colors.accentGreen, total, colors),
              _leg('Deferred',  stats.deferredMessages,  colors.accentOrange, total, colors),
              _leg('Bounced',   stats.bouncedMessages,   colors.accentRed,    total, colors),
              if (stats.rejectedMessages > 0)
                _leg('Rejected', stats.rejectedMessages, colors.accentPurple, total, colors),
            ]),
        ])),
      ]));
  }

  Widget _leg(String label, int count, Color color, int total, AppColors c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      SizedBox(width: 65, child: Text(label, style: TextStyle(color: c.textSecondary, fontSize: 11))),
      Text('$count', style: TextStyle(color: c.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
      const SizedBox(width: 4),
      Text('(${(count / total * 100).toStringAsFixed(0)}%)',
          style: TextStyle(color: c.textSecondary, fontSize: 10)),
    ]));

  Widget _empty(AppColors c) => Container(
    height: 260, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.border)),
    child: Center(child: Text('No data', style: TextStyle(color: c.textSecondary))));
}

// ─── Top Table ────────────────────────────────────────────────────────────────
class _TopTable extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<(String, int)> rows;
  final AppColors colors;
  const _TopTable({required this.title, required this.icon, required this.rows, required this.colors});

  @override
  Widget build(BuildContext context) {
    final maxCount = rows.isEmpty ? 1 : rows.map((e) => e.$2).reduce((a, b) => a > b ? a : b);
    return Container(
      decoration: BoxDecoration(
        color: colors.card, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border)),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Icon(icon, color: colors.accent, size: 16),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          ])),
        const Divider(height: 1),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No data', style: TextStyle(color: colors.textSecondary)))
        else
          ...rows.take(8).map((row) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              Expanded(child: Text(row.$1,
                style: TextStyle(color: colors.textPrimary, fontSize: 12, fontFamily: 'monospace'),
                overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: Stack(children: [
                  Container(height: 4, decoration: BoxDecoration(
                    color: colors.border, borderRadius: BorderRadius.circular(2))),
                  FractionallySizedBox(
                    widthFactor: row.$2 / maxCount,
                    child: Container(height: 4, decoration: BoxDecoration(
                      color: colors.accent, borderRadius: BorderRadius.circular(2)))),
                ])),
              const SizedBox(width: 8),
              SizedBox(width: 30, child: Text('${row.$2}',
                style: TextStyle(color: colors.textSecondary, fontSize: 11),
                textAlign: TextAlign.right)),
            ]))),
      ]));
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _LoadingCard extends StatelessWidget {
  final AppColors colors; final double height;
  const _LoadingCard({required this.colors, required this.height});
  @override
  Widget build(BuildContext context) => Container(
    height: height, margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.border)),
    child: Center(child: CircularProgressIndicator(color: colors.accent, strokeWidth: 2)));
}

class _ErrorCard extends StatelessWidget {
  final String msg; final AppColors colors;
  const _ErrorCard({required this.msg, required this.colors});
  @override
  Widget build(BuildContext context) => Container(
    height: 80, margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colors.accentRed.withOpacity(0.05), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: colors.accentRed.withOpacity(0.2))),
    child: Row(children: [
      Icon(Icons.wifi_off_outlined, color: colors.accentRed, size: 18),
      const SizedBox(width: 10),
      Text(msg, style: TextStyle(color: colors.accentRed, fontSize: 13)),
    ]));
}
