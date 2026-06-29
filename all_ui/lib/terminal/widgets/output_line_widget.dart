import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/terminal_models.dart';
import '../theme/terminal_theme.dart';
import '../utils/ansi_parser.dart';

// OutputLineWidget reads pre-parsed spans from output.getSpans() — zero
// ANSI parsing happens inside build(). The widget itself is a StatelessWidget
// so Flutter's element tree can diff it cheaply.
class OutputLineWidget extends StatelessWidget {
  final TerminalOutput output;
  final double fontSize;
  final bool showLineNumber;
  final int? lineNumber;
  final String? searchQuery;

  const OutputLineWidget({
    super.key,
    required this.output,
    this.fontSize = 13,
    this.showLineNumber = false,
    this.lineNumber,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    if (output.type == OutputType.separator) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Divider(color: TerminalTheme.border, height: 1, thickness: 1),
      );
    }

    return GestureDetector(
      onSecondaryTapDown: (d) => _showContextMenu(context, d.globalPosition),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: output.type == OutputType.system ? 0 : 1,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showLineNumber && lineNumber != null) ...[
              SizedBox(
                width: 36,
                child: Text(
                  '$lineNumber',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: fontSize - 2,
                    color: TerminalTheme.textMuted,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (output.type) {
      case OutputType.input:
        return _InputLine(text: output.text, fontSize: fontSize);
      case OutputType.error:
        return _SpanText(
          spans: output.getSpans(),
          defaultColor: TerminalTheme.red,
          fontSize: fontSize,
          prefix: '✗ ',
          searchQuery: searchQuery,
        );
      case OutputType.warning:
        return _SpanText(
          spans: output.getSpans(),
          defaultColor: TerminalTheme.yellow,
          fontSize: fontSize,
          prefix: '⚠ ',
          searchQuery: searchQuery,
        );
      case OutputType.info:
        return _SpanText(
          spans: output.getSpans(),
          defaultColor: TerminalTheme.blue,
          fontSize: fontSize,
          prefix: 'ℹ ',
          searchQuery: searchQuery,
        );
      case OutputType.success:
        return _SpanText(
          spans: output.getSpans(),
          defaultColor: TerminalTheme.green,
          fontSize: fontSize,
          prefix: '✓ ',
          searchQuery: searchQuery,
        );
      case OutputType.system:
        return _SpanText(
          spans: output.getSpans(),
          defaultColor: TerminalTheme.textMuted,
          fontSize: fontSize - 1,
          searchQuery: searchQuery,
        );
      default:
        return _SpanText(
          spans: output.getSpans(),
          defaultColor: TerminalTheme.textPrimary,
          fontSize: fontSize,
          searchQuery: searchQuery,
        );
    }
  }

  Future<void> _showContextMenu(BuildContext context, Offset pos) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final rel = RelativeRect.fromRect(
      Rect.fromPoints(pos, pos),
      Rect.fromLTWH(0, 0, overlay.size.width, overlay.size.height),
    );
    final result = await showMenu<String>(
      context: context,
      position: rel,
      color: TerminalTheme.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: TerminalTheme.border),
      ),
      items: [
        _menuItem('copy',      Icons.copy,        'Copy line'),
        _menuItem('copy_text', Icons.text_snippet, 'Copy text only'),
      ],
    );
    if (result == 'copy' || result == 'copy_text') {
      final text = result == 'copy_text' ? AnsiParser.strip(output.text) : output.text;
      await Clipboard.setData(ClipboardData(text: text));
    }
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      height: 36,
      child: Row(children: [
        Icon(icon, size: 14, color: TerminalTheme.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: TerminalTheme.textPrimary, fontSize: 13)),
      ]),
    );
  }
}

// ── Input echo line ────────────────────────────────────────────────────────────
class _InputLine extends StatelessWidget {
  final String text;
  final double fontSize;
  const _InputLine({required this.text, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: '❯ ',
          style: TextStyle(
            fontFamily: 'JetBrains Mono', fontSize: fontSize,
            color: TerminalTheme.green, fontWeight: FontWeight.bold, height: 1.6,
          ),
        ),
        TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: 'JetBrains Mono', fontSize: fontSize,
            color: TerminalTheme.textPrimary, fontWeight: FontWeight.w500, height: 1.6,
          ),
        ),
      ]),
    );
  }
}

// ── Cached-span renderer ───────────────────────────────────────────────────────
// Receives already-parsed List<AnsiSpan> — never calls the parser.
class _SpanText extends StatelessWidget {
  final List<AnsiSpan> spans;
  final Color defaultColor;
  final double fontSize;
  final String prefix;
  final String? searchQuery;

  const _SpanText({
    required this.spans,
    required this.defaultColor,
    required this.fontSize,
    this.prefix = '',
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final inlineSpans = <InlineSpan>[];

    if (prefix.isNotEmpty) {
      inlineSpans.add(TextSpan(
        text: prefix,
        style: TextStyle(
          fontFamily: 'JetBrains Mono', fontSize: fontSize,
          color: defaultColor, fontWeight: FontWeight.bold, height: 1.6,
        ),
      ));
    }

    final query = (searchQuery ?? '').toLowerCase();

    for (final span in spans) {
      final color = span.color ?? defaultColor;
      // Each AnsiSpan may contain embedded newlines; we honour them.
      final segments = span.text.split('\n');
      for (var si = 0; si < segments.length; si++) {
        if (si > 0) inlineSpans.add(const TextSpan(text: '\n'));
        final seg = segments[si];
        if (seg.isEmpty) continue;

        if (query.isNotEmpty && seg.toLowerCase().contains(query)) {
          _addWithHighlight(inlineSpans, seg, color, span, query);
        } else {
          inlineSpans.add(_span(seg, color, span));
        }
      }
    }

    return RichText(
      text: TextSpan(children: inlineSpans),
      softWrap: true,
    );
  }

  void _addWithHighlight(
    List<InlineSpan> out, String text, Color color, AnsiSpan span, String query,
  ) {
    final lower = text.toLowerCase();
    int start = 0;
    while (start < text.length) {
      final idx = lower.indexOf(query, start);
      if (idx == -1) { out.add(_span(text.substring(start), color, span)); break; }
      if (idx > start) out.add(_span(text.substring(start, idx), color, span));
      out.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: TextStyle(
          fontFamily: 'JetBrains Mono', fontSize: fontSize, height: 1.6,
          color: TerminalTheme.background, backgroundColor: TerminalTheme.yellow,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = idx + query.length;
    }
  }

  TextSpan _span(String text, Color color, AnsiSpan s) => TextSpan(
    text: text,
    style: TextStyle(
      fontFamily: 'JetBrains Mono',
      fontSize: fontSize,
      height: 1.6,
      color: color,
      backgroundColor: s.background,
      fontWeight: s.bold ? FontWeight.bold : FontWeight.normal,
      fontStyle:  s.italic ? FontStyle.italic : FontStyle.normal,
      decoration: s.underline ? TextDecoration.underline : TextDecoration.none,
    ),
  );
}
