// lib/features/detail/widgets/histogram_panel.dart
//
// RGB + luminosity histogram rendered with CustomPainter.
// Data is fetched from the Rust engine via a FutureProvider.
// Shows 4 overlaid channel curves (R, G, B, luma) on a dark background.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/gallery_models.dart';
import '../../../shared/theme/app_theme.dart';

// ─── Provider ────────────────────────────────────────────────────────────────
// In production this calls GalleryBridge.computeHistogram(item.thumbnailPath)
// which calls the Rust duplicate::compute_histogram() function.
// For now we generate a plausible synthetic histogram for the demo.

final histogramProvider = FutureProvider.family<_HistData, int>((ref, itemId) async {
  await Future.delayed(const Duration(milliseconds: 80));
  return _HistData.synthetic(itemId);
});

class HistogramPanel extends ConsumerWidget {
  final GMediaItem item;
  const HistogramPanel({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(histogramProvider(item.id));
    return Container(
      width: 240,
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xDD0E0E10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
            child: Row(
              children: [
                const Text('Histogram',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textMuted,
                        fontFamily: 'Inter')),
                const Spacer(),
                _ChannelDot(color: Colors.red.withOpacity(0.7), label: 'R'),
                _ChannelDot(color: Colors.green.withOpacity(0.7), label: 'G'),
                _ChannelDot(color: Colors.blue.withOpacity(0.7), label: 'B'),
                _ChannelDot(color: Colors.white.withOpacity(0.5), label: 'L'),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(
                  child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 1, color: AppTheme.accent))),
              error: (e, _) => const Center(
                  child: Text('No data',
                      style: TextStyle(fontSize: 10, color: AppTheme.textMuted))),
              data: (hist) => Padding(
                padding: const EdgeInsets.all(8),
                child: CustomPaint(
                  painter: _HistogramPainter(hist),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelDot extends StatelessWidget {
  final Color color;
  final String label;
  const _ChannelDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, color: color),
          const SizedBox(width: 2),
          Text(label,
              style: TextStyle(fontSize: 9, color: color, fontFamily: 'JetBrains Mono')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HistData {
  final List<double> r, g, b, luma;
  const _HistData({
    required this.r, required this.g, required this.b, required this.luma,
  });

  /// Generate a synthetic histogram that looks realistic
  factory _HistData.synthetic(int seed) {
    double gauss(double x, double mu, double sigma) {
      final d = (x - mu) / sigma;
      return (1.0 / (sigma * 2.507)) * ((-0.5 * d * d).exp());
    }

    final r = List.generate(256, (i) {
      final v = gauss(i.toDouble(), (seed * 17 % 200 + 40).toDouble(), 40) +
          gauss(i.toDouble(), 200, 30) * 0.3;
      return v;
    });
    final g = List.generate(256, (i) {
      final v = gauss(i.toDouble(), (seed * 13 % 180 + 60).toDouble(), 45) +
          gauss(i.toDouble(), 220, 25) * 0.2;
      return v;
    });
    final b = List.generate(256, (i) {
      final v = gauss(i.toDouble(), (seed * 7 % 160 + 80).toDouble(), 35);
      return v;
    });
    final luma = List.generate(256, (i) {
      return r[i] * 0.2126 + g[i] * 0.7152 + b[i] * 0.0722;
    });

    double norm(List<double> v) => v.reduce((a, b) => a > b ? a : b);
    final maxR = norm(r), maxG = norm(g), maxB = norm(b), maxL = norm(luma);

    return _HistData(
      r:    r.map((v) => v / maxR).toList(),
      g:    g.map((v) => v / maxG).toList(),
      b:    b.map((v) => v / maxB).toList(),
      luma: luma.map((v) => v / maxL).toList(),
    );
  }
}

class _HistogramPainter extends CustomPainter {
  final _HistData hist;
  const _HistogramPainter(this.hist);

  @override
  void paint(Canvas canvas, Size size) {
    void drawChannel(List<double> data, Color color) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;

      final path = Path();
      for (int i = 0; i < 256; i++) {
        final x = i / 255 * size.width;
        final y = size.height - data[i] * size.height;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);

      // Fill under curve
      final fillPaint = Paint()
        ..color = color.withOpacity(0.08)
        ..style = PaintingStyle.fill;
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(fillPath, fillPaint);
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;
    for (int i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    drawChannel(hist.luma, Colors.white.withOpacity(0.45));
    drawChannel(hist.r,    Colors.red.withOpacity(0.65));
    drawChannel(hist.g,    Colors.green.withOpacity(0.65));
    drawChannel(hist.b,    Colors.blue.withOpacity(0.65));
  }

  @override
  bool shouldRepaint(_HistogramPainter old) => old.hist != hist;
}
