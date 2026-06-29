// Timeline export & share utilities.
//
// Provides:
//  - [TimelineExporter]       : static methods for all export formats.
//  - [TimelineExportSheet]    : bottom sheet UI to trigger exports.
//  - [TimelineDeepLink]       : encode/decode viewport state in a URL fragment.
//
// Export formats:
//   1. Screenshot PNG  — RenderRepaintBoundary → ui.Image → clipboard (web) or share sheet (mobile).
//   2. Events CSV      — filtered visible events as comma-separated text.
//   3. Events JSON     — full event objects for the current viewport.
//   4. Event card PNG  — renders a single event as a styled image card.
//   5. Deep link URL   — encodes scale, offset, zoom as a fragment hash.
//
// No external packages required. PNG encoding uses dart:ui.
// On web, clipboard API is used. On mobile/desktop, the data is provided
// as a Uint8List the host app can forward to its preferred share plugin.

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../chart_theme.dart';
import 'timeline_event.dart';
import 'timeline_physics.dart';

// ---------------------------------------------------------------------------
// TimelineExporter
// ---------------------------------------------------------------------------

class TimelineExporter {
  // ── Screenshot ──────────────────────────────────────────────────────────

  /// Captures the widget attached to [key] as a PNG [Uint8List].
  /// Returns null if the boundary is not found or rendering fails.
  static Future<Uint8List?> captureWidget(GlobalKey key, {double pixelRatio = 2.0}) async {
    try {
      final boundary = key.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary) return null;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// Copies [bytes] to the system clipboard as an image (web only via
  /// ClipboardData). On non-web returns the raw bytes for the host app.
  static Future<ExportResult> copyImageToClipboard(Uint8List bytes) async {
    try {
      // On web, we write a data URL to clipboard text as a fallback
      // (true image clipboard requires web platform channels).
      final base64 = base64Encode(bytes);
      final dataUrl = 'data:image/png;base64,$base64';
      await Clipboard.setData(ClipboardData(text: dataUrl));
      return ExportResult(success: true, message: 'Screenshot copied (data URL)', bytes: bytes);
    } catch (e) {
      return ExportResult(success: false, message: 'Failed: $e');
    }
  }

  // ── Events CSV ──────────────────────────────────────────────────────────

  static String eventsToCSV(List<TimelineEvent> events) {
    final buf = StringBuffer();
    buf.writeln('id,title,year,month,day,category,importance,flag,location,description,tags');
    for (final ev in events) {
      buf.writeln([
        _csvCell(ev.id),
        _csvCell(ev.title),
        ev.year,
        ev.month ?? '',
        ev.day ?? '',
        _csvCell(ev.category.label),
        ev.importance.toStringAsFixed(1),
        _csvCell(ev.flag),
        _csvCell(ev.location ?? ''),
        _csvCell(ev.description),
        _csvCell(ev.tags.join(';')),
      ].join(','));
    }
    return buf.toString();
  }

  static String _csvCell(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static Future<ExportResult> copyCSV(List<TimelineEvent> events) async {
    final csv = eventsToCSV(events);
    await Clipboard.setData(ClipboardData(text: csv));
    return ExportResult(
      success: true,
      message: 'Copied ${events.length} events as CSV',
      text: csv,
    );
  }

  // ── Events JSON ─────────────────────────────────────────────────────────

  static String eventsToJSON(List<TimelineEvent> events) {
    final list = events.map((e) => {
      'id': e.id,
      'title': e.title,
      'year': e.year,
      if (e.month != null) 'month': e.month,
      if (e.day != null) 'day': e.day,
      'category': e.category.name,
      'importance': e.importance,
      'flag': e.flag,
      if (e.location != null) 'location': e.location,
      'description': e.description,
      'tags': e.tags,
      if (e.images.isNotEmpty) 'images': e.images,
      if (e.videos.isNotEmpty) 'videos': e.videos,
      if (e.references.isNotEmpty) 'references': e.references,
    }).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  static Future<ExportResult> copyJSON(List<TimelineEvent> events) async {
    final json = eventsToJSON(events);
    await Clipboard.setData(ClipboardData(text: json));
    return ExportResult(
      success: true,
      message: 'Copied ${events.length} events as JSON',
      text: json,
    );
  }

  // ── Single-event card ───────────────────────────────────────────────────

  /// Renders a styled card for [event] offscreen and returns PNG bytes.
  static Future<Uint8List?> renderEventCard(
    TimelineEvent event, {
    bool isDark = false,
    double pixelRatio = 2.0,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const w = 400.0;
    const h = 200.0;
    final color = event.effectiveColor;

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, w, h), const Radius.circular(12)),
      Paint()..color = isDark ? const Color(0xFF1E1E2E) : Colors.white,
    );

    // Colour stripe
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, 6, h),
        topLeft: const Radius.circular(12),
        bottomLeft: const Radius.circular(12),
      ),
      Paint()..color = color,
    );

    // Title
    final titlePainter = TextPainter(
      text: TextSpan(
        text: event.title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w - 40);
    titlePainter.paint(canvas, const Offset(20, 20));

    // Year
    final yearLabel = event.year < 0
        ? '${-event.year.toInt()} BC'
        : '${event.year.toInt()} AD';
    final yearPainter = TextPainter(
      text: TextSpan(
        text: yearLabel,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w - 40);
    yearPainter.paint(canvas, Offset(20, 20 + titlePainter.height + 6));

    // Description
    final descPainter = TextPainter(
      text: TextSpan(
        text: event.description,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 12,
          height: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 3,
      ellipsis: '…',
    )..layout(maxWidth: w - 40);
    descPainter.paint(
      canvas,
      Offset(20, 20 + titlePainter.height + yearPainter.height + 16),
    );

    // Category badge
    final catLabel = event.category.label;
    final catPainter = TextPainter(
      text: TextSpan(
        text: catLabel,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final badgeW = catPainter.width + 16;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w - badgeW - 12, 16, badgeW, 20),
        const Radius.circular(10),
      ),
      Paint()..color = color.withValues(alpha: 0.15),
    );
    catPainter.paint(canvas, Offset(w - badgeW - 4, 19));

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (w * pixelRatio).toInt(),
      (h * pixelRatio).toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}

// ---------------------------------------------------------------------------
// ExportResult
// ---------------------------------------------------------------------------

class ExportResult {
  final bool success;
  final String message;
  final Uint8List? bytes;
  final String? text;

  const ExportResult({
    required this.success,
    required this.message,
    this.bytes,
    this.text,
  });
}

// ---------------------------------------------------------------------------
// TimelineDeepLink — URL fragment encoding
// ---------------------------------------------------------------------------

/// Encodes/decodes timeline viewport state as a URL fragment string.
///
/// Format: `#tl!{scale}!{offset}!{zoom}`
///
/// Example: `#tl!century!476.0!2.5`
class TimelineDeepLink {
  static const _prefix = 'tl!';

  /// Encode a [TimelineViewState] into a URL fragment string.
  static String encode(TimelineViewState vs) {
    final scale = vs.scale.name;
    final offset = vs.offsetYears.toStringAsFixed(1);
    final zoom = vs.zoom.toStringAsFixed(3);
    return '#$_prefix$scale!$offset!$zoom';
  }

  /// Decode a URL fragment string into view parameters.
  /// Returns null if the fragment is not a valid timeline link.
  static ({TimelineScale scale, double offset, double zoom})? decode(String fragment) {
    final clean = fragment.startsWith('#') ? fragment.substring(1) : fragment;
    if (!clean.startsWith(_prefix)) return null;
    final parts = clean.substring(_prefix.length).split('!');
    if (parts.length < 3) return null;

    final scale = TimelineScale.values.firstWhere(
      (s) => s.name == parts[0],
      orElse: () => TimelineScale.century,
    );
    final offset = double.tryParse(parts[1]) ?? 0;
    final zoom = double.tryParse(parts[2]) ?? 1;

    return (scale: scale, offset: offset, zoom: zoom);
  }

  /// Copy the deep link for the current view to the clipboard.
  static Future<bool> copyToClipboard(TimelineViewState vs, {String baseUrl = ''}) async {
    try {
      final link = '$baseUrl${encode(vs)}';
      await Clipboard.setData(ClipboardData(text: link));
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ---------------------------------------------------------------------------
// TimelineExportSheet — bottom sheet UI
// ---------------------------------------------------------------------------

class TimelineExportSheet extends StatefulWidget {
  final List<TimelineEvent> visibleEvents;
  final List<TimelineEvent> allEvents;
  final TimelineViewState viewState;
  final GlobalKey? chartKey;
  final bool isDark;

  const TimelineExportSheet({
    super.key,
    required this.visibleEvents,
    required this.allEvents,
    required this.viewState,
    this.chartKey,
    this.isDark = false,
  });

  static Future<void> show(
    BuildContext context, {
    required List<TimelineEvent> visibleEvents,
    required List<TimelineEvent> allEvents,
    required TimelineViewState viewState,
    GlobalKey? chartKey,
    bool isDark = false,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TimelineExportSheet(
        visibleEvents: visibleEvents,
        allEvents: allEvents,
        viewState: viewState,
        chartKey: chartKey,
        isDark: isDark,
      ),
    );
  }

  @override
  State<TimelineExportSheet> createState() => _TimelineExportSheetState();
}

class _TimelineExportSheetState extends State<TimelineExportSheet> {
  bool _loading = false;
  String? _lastMessage;

  Future<void> _run(Future<ExportResult> Function() action) async {
    setState(() { _loading = true; _lastMessage = null; });
    final result = await action();
    if (mounted) {
      setState(() {
        _loading = false;
        _lastMessage = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black87;
    final subColor = widget.isDark ? Colors.white54 : Colors.black45;

    final items = <_ExportItem>[
      _ExportItem(
        icon: Icons.screenshot_monitor_outlined,
        title: 'Screenshot',
        subtitle: 'Copy chart as PNG image',
        onTap: widget.chartKey == null ? null : () => _run(() async {
          final bytes = await TimelineExporter.captureWidget(widget.chartKey!);
          if (bytes == null) return ExportResult(success: false, message: 'Capture failed');
          return TimelineExporter.copyImageToClipboard(bytes);
        }),
      ),
      _ExportItem(
        icon: Icons.table_chart_outlined,
        title: 'Visible events as CSV',
        subtitle: '${widget.visibleEvents.length} events in current view',
        onTap: () => _run(() => TimelineExporter.copyCSV(widget.visibleEvents)),
      ),
      _ExportItem(
        icon: Icons.data_object_outlined,
        title: 'All events as JSON',
        subtitle: '${widget.allEvents.length} total events',
        onTap: () => _run(() => TimelineExporter.copyJSON(widget.allEvents)),
      ),
      _ExportItem(
        icon: Icons.link_outlined,
        title: 'Copy deep link',
        subtitle: 'Share this exact view position',
        onTap: () => _run(() async {
          final ok = await TimelineDeepLink.copyToClipboard(widget.viewState);
          return ExportResult(
            success: ok,
            message: ok ? 'Link copied to clipboard' : 'Failed to copy',
          );
        }),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 14),
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.white24 : Colors.black24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Export / Share',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                const Spacer(),
                if (_loading)
                  const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
          ),

          if (_lastMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 6),
                  Text(_lastMessage!, style: const TextStyle(fontSize: 12, color: Color(0xFF4CAF50))),
                ],
              ),
            ),

          const SizedBox(height: 8),

          ...items.map((item) => ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 20, color: const Color(0xFF2196F3)),
            ),
            title: Text(item.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
            subtitle: Text(item.subtitle, style: TextStyle(fontSize: 11, color: subColor)),
            enabled: item.onTap != null && !_loading,
            onTap: item.onTap,
          )),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ExportItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ExportItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}
