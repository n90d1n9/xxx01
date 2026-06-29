// lib/features/analytics/analytics_screen.dart
//
// Analytics dashboard.
// Displays charts powered by the Rust analytics engine.
// Uses CustomPainter for all charts — no external chart library needed.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/gallery_providers.dart';
import '../../shared/theme/app_theme.dart';

// ── Synthetic data model ──────────────────────────────────────────────────

class _BucketStat {
  final String label;
  final int count;
  const _BucketStat(this.label, this.count);
}

class _MonthStat {
  final String month;
  final int count;
  final int flagged;
  const _MonthStat(this.month, this.count, this.flagged);
}

class _HeatCell {
  final int dow; // 0=Sun
  final int hour;
  final int count;
  const _HeatCell(this.dow, this.hour, this.count);
}

// ── Provider ─────────────────────────────────────────────────────────────────

final analyticsDataProvider = FutureProvider<_AnalyticsData>((ref) async {
  await Future.delayed(const Duration(milliseconds: 120));
  return _AnalyticsData.synthetic();
});

class _AnalyticsData {
  final List<_BucketStat> byCamera;
  final List<_BucketStat> byISO;
  final List<_BucketStat> byFocal;
  final List<_BucketStat> byAperture;
  final List<_MonthStat>  byMonth;
  final List<_HeatCell>   heatmap;
  final int totalItems;
  final int totalSizeBytes;
  final double avgRating;
  final int flaggedCount;
  final int rawCount;

  const _AnalyticsData({
    required this.byCamera, required this.byISO, required this.byFocal,
    required this.byAperture, required this.byMonth, required this.heatmap,
    required this.totalItems, required this.totalSizeBytes,
    required this.avgRating, required this.flaggedCount, required this.rawCount,
  });

  factory _AnalyticsData.synthetic() {
    return _AnalyticsData(
      totalItems: 40, totalSizeBytes: 412 * 1024 * 1024,
      avgRating: 3.2, flaggedCount: 8, rawCount: 14,
      byCamera: const [
        _BucketStat('Sony A7R IV', 18), _BucketStat('Canon EOS R5', 11),
        _BucketStat('Nikon Z9', 6), _BucketStat('Fujifilm X-T5', 5),
      ],
      byISO: const [
        _BucketStat('≤100', 8), _BucketStat('200', 12), _BucketStat('400', 9),
        _BucketStat('800', 5), _BucketStat('1600', 3), _BucketStat('3200+', 3),
      ],
      byFocal: const [
        _BucketStat('≤17mm', 4), _BucketStat('18–24mm', 7), _BucketStat('24–35mm', 8),
        _BucketStat('35–50mm', 10), _BucketStat('50–85mm', 7), _BucketStat('85mm+', 4),
      ],
      byAperture: const [
        _BucketStat('f/1.2–1.8', 6), _BucketStat('f/2.0–2.8', 14),
        _BucketStat('f/3.5–5.6', 11), _BucketStat('f/8+', 9),
      ],
      byMonth: const [
        _MonthStat('Nov 24', 15, 5), _MonthStat('Oct 24', 12, 2),
        _MonthStat('Sep 24', 8, 1), _MonthStat('Aug 24', 5, 0),
      ],
      heatmap: [
        for (int d = 0; d < 7; d++)
          for (int h = 0; h < 24; h++)
            _HeatCell(d, h,
              (h >= 8 && h <= 19)
                  ? (2 + (d % 3) + (h == 10 || h == 16 ? 4 : 0))
                  : 0),
      ],
    );
  }
}

// ── Screen ───────────────────────────────────────────────────────────────────

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(analyticsDataProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg0,
      body: Column(
        children: [
          _Header(onClose: () => Navigator.of(context).pop()),
          Expanded(
            child: async.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.accent, strokeWidth: 1.5)),
              error: (e, _) => Center(
                  child: Text('$e', style: const TextStyle(color: AppTheme.flagRed))),
              data: (data) => _Dashboard(data: data),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.toolbarHeight,
      color: AppTheme.bg1,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppTheme.textSecondary),
            onPressed: onClose,
          ),
          const Text('Analytics',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  final _AnalyticsData data;
  const _Dashboard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards row
            _SummaryCards(data: data),
            const SizedBox(height: 24),
            // Charts grid
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _BarChart(
                    title: 'By Camera', buckets: data.byCamera,
                    color: AppTheme.accent, width: 320),
                _BarChart(
                    title: 'By ISO', buckets: data.byISO,
                    color: AppTheme.flagBlue, width: 280),
                _BarChart(
                    title: 'Focal Length', buckets: data.byFocal,
                    color: AppTheme.flagGreen, width: 320),
                _BarChart(
                    title: 'Aperture', buckets: data.byAperture,
                    color: AppTheme.flagPurple, width: 260),
                _MonthChart(months: data.byMonth),
                _HeatmapChart(cells: data.heatmap),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final _AnalyticsData data;
  const _SummaryCards({required this.data});

  @override
  Widget build(BuildContext context) {
    final gb = (data.totalSizeBytes / 1e9).toStringAsFixed(2);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _Card('Total Images', '${data.totalItems}', AppTheme.accent),
        _Card('Total Size', '$gb GB', AppTheme.flagBlue),
        _Card('RAW Files', '${data.rawCount}', AppTheme.flagPurple),
        _Card('Picked', '${data.flaggedCount}', AppTheme.flagGreen),
        _Card('Avg Rating', data.avgRating.toStringAsFixed(1), AppTheme.flagYellow),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Card(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w300, color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BarChart extends StatelessWidget {
  final String title;
  final List<_BucketStat> buckets;
  final Color color;
  final double width;
  const _BarChart(
      {required this.title,
      required this.buckets,
      required this.color,
      this.width = 300});

  @override
  Widget build(BuildContext context) {
    final max = buckets.isEmpty
        ? 1
        : buckets.map((b) => b.count).reduce((a, b) => a > b ? a : b);

    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          ...buckets.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(b.label,
                          style: const TextStyle(
                              fontSize: 10, color: AppTheme.textMuted),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                              height: 10,
                              decoration: BoxDecoration(
                                  color: AppTheme.bg3,
                                  borderRadius: BorderRadius.circular(2))),
                          FractionallySizedBox(
                            widthFactor: b.count / max,
                            child: Container(
                                height: 10,
                                decoration: BoxDecoration(
                                    color: color.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(2))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('${b.count}',
                        style: TextStyle(
                            fontSize: 10, color: color, fontFamily: 'JetBrains Mono')),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _MonthChart extends StatelessWidget {
  final List<_MonthStat> months;
  const _MonthChart({required this.months});

  @override
  Widget build(BuildContext context) {
    final max = months.isEmpty
        ? 1
        : months.map((m) => m.count).reduce((a, b) => a > b ? a : b);

    return Container(
      width: 340,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Activity',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(312, 120),
              painter: _MonthBarPainter(months: months, max: max),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthBarPainter extends CustomPainter {
  final List<_MonthStat> months;
  final int max;
  const _MonthBarPainter({required this.months, required this.max});

  @override
  void paint(Canvas canvas, Size size) {
    if (months.isEmpty) return;
    final barW = (size.width / months.length) - 4;
    for (int i = 0; i < months.length; i++) {
      final m = months[i];
      final x = i * (size.width / months.length) + 2;
      final barH = (m.count / max) * (size.height - 20);
      final flagH = (m.flagged / max) * (size.height - 20);

      // Total bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - 20 - barH, barW, barH),
          const Radius.circular(2),
        ),
        Paint()..color = AppTheme.accent.withOpacity(0.3),
      );
      // Flagged overlay
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - 20 - flagH, barW, flagH),
          const Radius.circular(2),
        ),
        Paint()..color = AppTheme.flagGreen.withOpacity(0.8),
      );

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: m.month,
          style: const TextStyle(fontSize: 8, color: AppTheme.textMuted),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x, size.height - 16));
    }
  }

  @override
  bool shouldRepaint(_MonthBarPainter old) => old.months != months;
}

class _HeatmapChart extends StatelessWidget {
  final List<_HeatCell> cells;
  const _HeatmapChart({required this.cells});

  @override
  Widget build(BuildContext context) {
    final max = cells.isEmpty
        ? 1
        : cells.map((c) => c.count).reduce((a, b) => a > b ? a : b);

    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const cellSize = 11.0;
    const gap = 1.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Shooting Hours Heatmap',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day labels
              Column(
                children: [
                  const SizedBox(height: 12),
                  for (final d in days)
                    SizedBox(
                      height: cellSize + gap,
                      width: 28,
                      child: Text(d,
                          style: const TextStyle(
                              fontSize: 8, color: AppTheme.textMuted)),
                    ),
                ],
              ),
              // Grid
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hour labels
                  SizedBox(
                    height: 12,
                    width: 24 * (cellSize + gap),
                    child: Row(
                      children: List.generate(24, (h) {
                        if (h % 6 != 0) return SizedBox(width: cellSize + gap);
                        return SizedBox(
                          width: 6 * (cellSize + gap),
                          child: Text('${h}h',
                              style: const TextStyle(
                                  fontSize: 7, color: AppTheme.textMuted)),
                        );
                      }),
                    ),
                  ),
                  for (int d = 0; d < 7; d++)
                    Row(
                      children: List.generate(24, (h) {
                        final cell = cells.firstWhere(
                          (c) => c.dow == d && c.hour == h,
                          orElse: () => _HeatCell(d, h, 0),
                        );
                        final intensity = cell.count / max;
                        return Container(
                          width: cellSize,
                          height: cellSize,
                          margin: const EdgeInsets.all(gap / 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(
                                intensity == 0 ? 0.05 : 0.1 + intensity * 0.9),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        );
                      }),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
