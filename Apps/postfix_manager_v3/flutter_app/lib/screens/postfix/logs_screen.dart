// lib/screens/postfix/logs_screen.dart — WebSocket live streaming
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
  final _scrollCtrl  = ScrollController();
  final _searchCtrl  = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Connect WebSocket as soon as the screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(logStreamProvider.notifier).connect();
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    // Don't disconnect — keep streaming while navigating so badge can still update
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors     = Theme.of(context).extension<AppColors>()!;
    final logs       = ref.watch(logStreamProvider);
    final wsState    = ref.watch(wsStateProvider);
    final wsStats    = ref.watch(wsStatsProvider);
    final levelFilter = ref.watch(logLevelFilterProvider);
    final isPaused   = ref.watch(logPausedProvider);
    final autoScroll = ref.watch(logAutoScrollProvider);

    // Auto-scroll to bottom on new lines when enabled
    if (autoScroll && !isPaused && logs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut);
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF090D12),
      body: Column(children: [

        // ── Toolbar ──────────────────────────────────────────────────────────
        Container(
          color: colors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(children: [
            Row(children: [
              // Title + connection badge
              Icon(Icons.terminal_outlined, color: colors.accent, size: 20),
              const SizedBox(width: 10),
              Text('Live Logs',
                  style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              _WsBadge(state: wsState, colors: colors),

              // Stats pill
              if (wsStats != null) ...[
                const SizedBox(width: 10),
                _StatPill('${wsStats.linesPerMin}/min', colors.accent, colors),
                if (wsStats.errorRate > 0) ...[
                  const SizedBox(width: 6),
                  _StatPill('${wsStats.errorRate.toStringAsFixed(1)}% err',
                      colors.accentRed, colors),
                ],
              ],

              const Spacer(),

              // Line count
              Text('${logs.length} lines',
                  style: TextStyle(color: colors.textSecondary, fontSize: 11)),
              const SizedBox(width: 16),

              // Search
              SizedBox(width: 220, child: TextField(
                controller: _searchCtrl,
                style: TextStyle(color: colors.textPrimary, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Search in stream…',
                  prefixIcon: Icon(Icons.search, size: 16, color: colors.textSecondary),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8)),
                onChanged: (v) {
                  ref.read(logSearchProvider.notifier).state = v;
                  ref.read(logStreamProvider.notifier).applyFilter();
                })),
              const SizedBox(width: 12),

              // Controls row
              _ToolBtn(
                icon: isPaused ? Icons.play_arrow : Icons.pause,
                label: isPaused ? 'Resume' : 'Pause',
                color: isPaused ? colors.accentGreen : colors.accentOrange,
                colors: colors,
                onTap: () => ref.read(logStreamProvider.notifier).togglePause()),
              const SizedBox(width: 8),

              _ToolBtn(
                icon: autoScroll ? Icons.vertical_align_bottom : Icons.vertical_align_center,
                label: 'Auto-scroll',
                color: autoScroll ? colors.accent : colors.textSecondary,
                colors: colors,
                onTap: () => ref.read(logAutoScrollProvider.notifier).state = !autoScroll),
              const SizedBox(width: 8),

              _ToolBtn(
                icon: Icons.delete_sweep_outlined,
                label: 'Clear',
                color: colors.textSecondary,
                colors: colors,
                onTap: () => ref.read(logStreamProvider.notifier).clear()),
              const SizedBox(width: 8),

              // Reconnect / Disconnect
              wsState == WsConnectionState.disconnected ||
              wsState == WsConnectionState.error
                ? _ToolBtn(
                    icon: Icons.wifi_find_outlined,
                    label: 'Connect',
                    color: colors.accentGreen,
                    colors: colors,
                    onTap: () => ref.read(logStreamProvider.notifier).connect())
                : _ToolBtn(
                    icon: Icons.wifi_off_outlined,
                    label: 'Disconnect',
                    color: colors.accentRed,
                    colors: colors,
                    onTap: () => ref.read(logStreamProvider.notifier).disconnect()),
            ]),

            const SizedBox(height: 10),

            // Level filter chips
            Row(children: [
              for (final level in [null, 'INFO', 'WARN', 'ERROR'])
                Padding(padding: const EdgeInsets.only(right: 8), child:
                  _LevelChip(
                    level: level,
                    active: levelFilter == level,
                    colors: colors,
                    onTap: () {
                      ref.read(logLevelFilterProvider.notifier).state = level;
                      ref.read(logStreamProvider.notifier).applyFilter();
                    })),
              const Spacer(),
              // Log count by level
              _levelCount(logs, 'ERROR', colors),
              const SizedBox(width: 12),
              _levelCount(logs, 'WARN', colors),
              const SizedBox(width: 12),
              _levelCount(logs, 'INFO', colors),
            ]),
          ])),
        const Divider(height: 1),

        // ── Log output ───────────────────────────────────────────────────────
        Expanded(child: logs.isEmpty
          ? _EmptyState(wsState: wsState, colors: colors)
          : _LogList(logs: logs, scrollCtrl: _scrollCtrl,
                     levelFilter: levelFilter, search: ref.watch(logSearchProvider),
                     colors: colors)),
      ]));
  }

  Widget _levelCount(List<MailLog> logs, String level, AppColors c) {
    final count = logs.where((l) => l.level == level).length;
    final color = _lc(level, c);
    return Row(children: [
      Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text('$count $level', style: TextStyle(color: c.textSecondary, fontSize: 10)),
    ]);
  }

  static Color _lc(String level, AppColors c) => switch (level) {
    'ERROR' => c.accentRed,
    'WARN'  => c.accentOrange,
    _       => c.accentGreen,
  };
}

// ─── WebSocket Status Badge ───────────────────────────────────────────────────
class _WsBadge extends StatelessWidget {
  final WsConnectionState state;
  final AppColors colors;
  const _WsBadge({required this.state, required this.colors});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      WsConnectionState.connected    => ('LIVE', colors.accentGreen),
      WsConnectionState.connecting   => ('CONNECTING…', colors.accentOrange),
      WsConnectionState.disconnected => ('OFFLINE', colors.textSecondary),
      WsConnectionState.error        => ('ERROR', colors.accentRed),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (state == WsConnectionState.connected)
          _PulsingDot(color: color),
        if (state == WsConnectionState.connected) const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ]));
  }
}

// Animated pulsing dot for LIVE indicator
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(width: 7, height: 7,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)));
}

class _StatPill extends StatelessWidget {
  final String text; final Color color; final AppColors colors;
  const _StatPill(this.text, this.color, this.colors);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(4)),
    child: Text(text, style: TextStyle(color: color, fontSize: 10)));
}

class _LevelChip extends StatelessWidget {
  final String? level; final bool active;
  final AppColors colors; final VoidCallback onTap;
  const _LevelChip({required this.level, required this.active,
      required this.colors, required this.onTap});

  Color get _color => switch (level) {
    'ERROR' => colors.accentRed,
    'WARN'  => colors.accentOrange,
    'INFO'  => colors.accentGreen,
    _       => colors.accent,
  };

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color:  active ? _color.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: active ? _color.withOpacity(0.4) : colors.border)),
      child: Text(level ?? 'ALL', style: TextStyle(
        color: active ? _color : colors.textSecondary,
        fontSize: 11, fontWeight: FontWeight.w600))));
}

class _ToolBtn extends StatelessWidget {
  final IconData icon; final String label;
  final Color color; final AppColors colors;
  final VoidCallback onTap;
  const _ToolBtn({required this.icon, required this.label, required this.color,
      required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ])));
}

// ─── Log List ─────────────────────────────────────────────────────────────────
class _LogList extends StatelessWidget {
  final List<MailLog> logs;
  final ScrollController scrollCtrl;
  final String? levelFilter;
  final String search;
  final AppColors colors;

  const _LogList({required this.logs, required this.scrollCtrl,
      required this.levelFilter, required this.search, required this.colors});

  List<MailLog> get _filtered {
    var list = logs;
    if (levelFilter != null) list = list.where((l) => l.level == levelFilter).toList();
    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where((l) =>
        l.message.toLowerCase().contains(q) ||
        l.process.toLowerCase().contains(q) ||
        (l.from?.toLowerCase().contains(q) ?? false) ||
        (l.to?.toLowerCase().contains(q) ?? false) ||
        (l.queueId?.toLowerCase().contains(q) ?? false)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filtered;
    if (visible.isEmpty) return Center(
      child: Text('No matching log lines',
          style: TextStyle(color: colors.textSecondary)));

    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: visible.length,
      itemBuilder: (_, i) => _LogLine(log: visible[i], colors: colors));
  }
}

class _EmptyState extends StatelessWidget {
  final WsConnectionState wsState;
  final AppColors colors;
  const _EmptyState({required this.wsState, required this.colors});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(
        wsState == WsConnectionState.connected
            ? Icons.hourglass_empty : Icons.wifi_off_outlined,
        color: colors.textSecondary, size: 40),
      const SizedBox(height: 12),
      Text(
        wsState == WsConnectionState.connected
            ? 'Waiting for log events…'
            : wsState == WsConnectionState.connecting
              ? 'Connecting to log stream…'
              : 'Not connected to log stream',
        style: TextStyle(color: colors.textSecondary, fontSize: 14)),
      if (wsState == WsConnectionState.error) ...[
        const SizedBox(height: 8),
        Text('Auto-reconnecting…',
            style: TextStyle(color: colors.accentOrange, fontSize: 12)),
      ],
    ]));
}

// ─── Single Log Line ──────────────────────────────────────────────────────────
class _LogLine extends StatelessWidget {
  final MailLog log;
  final AppColors colors;
  const _LogLine({required this.log, required this.colors});

  Color get _levelColor => switch (log.level) {
    'ERROR' => colors.accentRed,
    'WARN'  => colors.accentOrange,
    _       => colors.accentGreen,
  };

  Color get _bgColor => switch (log.level) {
    'ERROR' => colors.accentRed.withOpacity(0.04),
    'WARN'  => colors.accentOrange.withOpacity(0.03),
    _       => Colors.transparent,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        final line = '${DateFormat("HH:mm:ss").format(log.timestamp)}'
            '  ${log.level.padRight(5)}  ${log.process}  ${log.message}';
        Clipboard.setData(ClipboardData(text: line));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copied to clipboard'),
              duration: const Duration(seconds: 1),
              backgroundColor: colors.surface));
      },
      child: Container(
        color: _bgColor,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Timestamp
          SizedBox(width: 72, child: Text(
            DateFormat('HH:mm:ss').format(log.timestamp),
            style: TextStyle(
              color: colors.textSecondary.withOpacity(0.55),
              fontSize: 11, fontFamily: 'monospace'))),

          // Level
          SizedBox(width: 46, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: _levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3)),
            child: Text(
              log.level.length > 4 ? log.level.substring(0,4) : log.level,
              style: TextStyle(color: _levelColor, fontSize: 9,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center))),

          const SizedBox(width: 4),

          // Process
          SizedBox(width: 155, child: Text(log.process,
            style: TextStyle(color: colors.accent.withOpacity(0.55),
                fontSize: 11, fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis)),

          const SizedBox(width: 4),

          // Message with highlighting
          Expanded(child: _Highlighted(message: log.message, colors: colors)),
        ])));
  }
}

// ─── Syntax-highlighted message ───────────────────────────────────────────────
class _Highlighted extends StatelessWidget {
  final String message;
  final AppColors colors;
  static final _emailRe   = RegExp(r'[\w.+\-]+@[\w.\-]+\.\w+');
  static final _queueIdRe = RegExp(r'\b[A-F0-9]{9,14}\b');
  static final _ipRe      = RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b');
  static final _statusRe  = RegExp(r'\bstatus=(sent|deferred|bounced|reject)\b');

  const _Highlighted({required this.message, required this.colors});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    // Build a combined pattern with named groups
    final all = RegExp(
        '(${_emailRe.pattern})'
        '|(${_queueIdRe.pattern})'
        '|(${_ipRe.pattern})'
        '|(${_statusRe.pattern})');

    int last = 0;
    for (final m in all.allMatches(message)) {
      if (m.start > last) {
        spans.add(TextSpan(text: message.substring(last, m.start),
            style: TextStyle(color: colors.textPrimary.withOpacity(0.75))));
      }
      final matched = m.group(0)!;
      Color c;
      if (_emailRe.hasMatch(matched))   c = colors.accentOrange;
      else if (_queueIdRe.hasMatch(matched)) c = colors.accent;
      else if (_statusRe.hasMatch(matched)) {
        c = matched.contains('sent') ? colors.accentGreen : colors.accentRed;
      }
      else c = colors.accentPurple; // IP

      spans.add(TextSpan(text: matched,
          style: TextStyle(color: c, fontWeight: FontWeight.w600)));
      last = m.end;
    }
    if (last < message.length) {
      spans.add(TextSpan(text: message.substring(last),
          style: TextStyle(color: colors.textPrimary.withOpacity(0.75))));
    }
    return RichText(text: TextSpan(
        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
        children: spans));
  }
}
