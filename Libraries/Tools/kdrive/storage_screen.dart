// lib/screens/storage_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';
import '../utils/file_utils.dart';

class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key});

  static const int _totalStorageBytes = 15 * 1024 * 1024 * 1024; // 15 GB

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(storageStatsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final usedBytes = stats.totalBytes;
    final usedFraction = usedBytes / _totalStorageBytes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage'),
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main donut + summary ────────────────────────────────────────
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Storage used',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text(
                                _formatBytes(usedBytes),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'of ${_formatBytes(_totalStorageBytes)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: usedFraction,
                                  minHeight: 10,
                                  backgroundColor: colorScheme.surfaceVariant,
                                  valueColor: AlwaysStoppedAnimation(
                                    usedFraction > 0.8
                                        ? Colors.red
                                        : colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(usedFraction * 100).toStringAsFixed(1)}% used · '
                                '${_formatBytes(_totalStorageBytes - usedBytes)} free',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: _DonutChart(stats: stats, total: _totalStorageBytes),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text('Breakdown by type',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            // ── Type breakdown cards ────────────────────────────────────────
            ...FileUtils.filterableTypes
                .where((t) => t != FileType.folder)
                .map((type) {
              final bytes = stats.bytesByType[type] ?? 0;
              if (bytes == 0) return const SizedBox.shrink();
              final fraction = usedBytes > 0 ? bytes / usedBytes : 0.0;
              return _TypeRow(type: type, bytes: bytes, fraction: fraction);
            }),

            const SizedBox(height: 24),
            Text('Storage tips',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            _TipCard(
              icon: Icons.video_library_rounded,
              color: Colors.red,
              title: 'Videos use the most space',
              subtitle: 'Consider compressing or archiving old videos.',
            ),
            const SizedBox(height: 8),
            _TipCard(
              icon: Icons.auto_delete_rounded,
              color: Colors.orange,
              title: 'Empty your trash',
              subtitle: 'Items in trash still count toward your storage.',
            ),
            const SizedBox(height: 8),
            _TipCard(
              icon: Icons.cloud_upload_rounded,
              color: Colors.blue,
              title: 'Upgrade for more space',
              subtitle: 'Get 100 GB, 200 GB, or 2 TB plans.',
              action: 'View plans',
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Get more storage'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class _DonutChart extends StatelessWidget {
  final StorageStats stats;
  final int total;
  const _DonutChart({required this.stats, required this.total});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DonutPainter(stats: stats, total: total),
      child: Center(
        child: Text(
          '${((stats.totalBytes / total) * 100).toStringAsFixed(0)}%',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final StorageStats stats;
  final int total;
  _DonutPainter({required this.stats, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 4;
    final strokeWidth = 16.0;

    // background track
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      0, 2 * pi, false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = Colors.grey.withOpacity(0.15),
    );

    if (stats.totalBytes == 0) return;

    double startAngle = -pi / 2;
    final types = FileUtils.filterableTypes.where((t) => t != FileType.folder);
    for (final type in types) {
      final bytes = stats.bytesByType[type] ?? 0;
      if (bytes == 0) continue;
      final sweep = (bytes / total) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle, sweep - 0.02, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = FileUtils.getFileColor(type),
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.stats != stats;
}

class _TypeRow extends StatelessWidget {
  final FileType type;
  final int bytes;
  final double fraction;
  const _TypeRow({required this.type, required this.bytes, required this.fraction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = FileUtils.getFileColor(type);
    final displayBytes = bytes < 1024 * 1024
        ? '${(bytes / 1024).toStringAsFixed(1)} KB'
        : bytes < 1024 * 1024 * 1024
            ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
            : '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(FileUtils.getFileIcon(type), color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(FileUtils.getFileTypeName(type),
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    Text(displayBytes,
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 4,
                    backgroundColor: colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? action;
  const _TipCard({required this.icon, required this.color,
    required this.title, required this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitle, style: TextStyle(
                  color: colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: Text(action!),
            ),
          ],
        ],
      ),
    );
  }
}
