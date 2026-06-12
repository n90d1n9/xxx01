import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/terminal_models.dart';
import '../theme/terminal_theme.dart';
import '../utils/ansi_parser.dart';

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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Divider(color: TerminalTheme.border, height: 1),
      );
    }

    return GestureDetector(
      onSecondaryTapDown: (details) => _showContextMenu(context, details.globalPosition),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showLineNumber && lineNumber != null)
              SizedBox(
                width: 36,
                child: Text(
                  '$lineNumber',
                  style: TerminalTheme.monoFontSmall.copyWith(
                    color: TerminalTheme.textMuted,
                    fontSize: fontSize - 2,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            if (showLineNumber) const SizedBox(width: 12),
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
        return _AnsiText(
          text: output.text,
          defaultColor: TerminalTheme.red,
          fontSize: fontSize,
          prefix: '✗ ',
          searchQuery: searchQuery,
        );
      case OutputType.warning:
        return _AnsiText(
          text: output.text,
          defaultColor: TerminalTheme.yellow,
          fontSize: fontSize,
          prefix: '⚠ ',
          searchQuery: searchQuery,
        );
      case OutputType.info:
        return _AnsiText(
          text: output.text,
          defaultColor: TerminalTheme.blue,
          fontSize: fontSize,
          prefix: 'ℹ ',
          searchQuery: searchQuery,
        );
      case OutputType.success:
        return _AnsiText(
          text: output.text,
          defaultColor: TerminalTheme.green,
          fontSize: fontSize,
          prefix: '✓ ',
          searchQuery: searchQuery,
        );
      case OutputType.system:
        return _AnsiText(
          text: output.text,
          defaultColor: TerminalTheme.textMuted,
          fontSize: fontSize - 1,
          searchQuery: searchQuery,
        );
      default:
        return _AnsiText(
          text: output.text,
          defaultColor: TerminalTheme.textPrimary,
          fontSize: fontSize,
          searchQuery: searchQuery,
        );
    }
  }

  void _showContextMenu(BuildContext context, Offset position) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(position, position),
        Rect.fromLTWH(0, 0, overlay.size.width, overlay.size.height),
      ),
      color: TerminalTheme.surfaceElevated,
      items: [
        const PopupMenuItem(value: 'copy', child: Text('Copy', style: TextStyle(color: TerminalTheme.textPrimary))),
        const PopupMenuItem(value: 'copy_text', child: Text('Copy text only', style: TextStyle(color: TerminalTheme.textPrimary))),
      ],
    );
    if (result == 'copy' || result == 'copy_text') {
      final text = result == 'copy_text' ? AnsiParser.strip(output.text) : output.text;
      await Clipboard.setData(ClipboardData(text: text));
    }
  }
}

class _InputLine extends StatelessWidget {
  final String text;
  final double fontSize;

  const _InputLine({required this.text, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '❯ ',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: fontSize,
              color: TerminalTheme.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: fontSize,
              color: TerminalTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnsiText extends StatelessWidget {
  final String text;
  final Color defaultColor;
  final double fontSize;
  final String prefix;
  final String? searchQuery;

  const _AnsiText({
    required this.text,
    required this.defaultColor,
    required this.fontSize,
    this.prefix = '',
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final spans = AnsiParser.parse(text);
    final inlineSpans = <InlineSpan>[];

    if (prefix.isNotEmpty) {
      inlineSpans.add(TextSpan(
        text: prefix,
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: fontSize,
          color: defaultColor,
          fontWeight: FontWeight.bold,
        ),
      ));
    }

    for (final span in spans) {
      final color = span.color ?? defaultColor;
      // Handle newlines in span text
      final lines = span.text.split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (i > 0) {
          inlineSpans.add(const TextSpan(text: '\n'));
        }
        if (lines[i].isEmpty) continue;

        // Search highlight
        if (searchQuery != null && searchQuery!.isNotEmpty && lines[i].toLowerCase().contains(searchQuery!.toLowerCase())) {
          final lower = lines[i].toLowerCase();
          final query = searchQuery!.toLowerCase();
          int start = 0;
          while (start < lines[i].length) {
            final idx = lower.indexOf(query, start);
            if (idx == -1) {
              inlineSpans.add(_makeSpan(lines[i].substring(start), color, span));
              break;
            }
            if (idx > start) {
              inlineSpans.add(_makeSpan(lines[i].substring(start, idx), color, span));
            }
            inlineSpans.add(TextSpan(
              text: lines[i].substring(idx, idx + query.length),
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: fontSize,
                color: TerminalTheme.background,
                backgroundColor: TerminalTheme.yellow,
                fontWeight: span.bold ? FontWeight.bold : FontWeight.normal,
              ),
            ));
            start = idx + query.length;
          }
        } else {
          inlineSpans.add(_makeSpan(lines[i], color, span));
        }
      }
    }

    return RichText(
      text: TextSpan(children: inlineSpans),
      softWrap: true,
    );
  }

  TextSpan _makeSpan(String text, Color color, AnsiSpan span) {
    return TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: fontSize,
        color: color,
        backgroundColor: span.background,
        fontWeight: span.bold ? FontWeight.bold : FontWeight.normal,
        fontStyle: span.italic ? FontStyle.italic : FontStyle.normal,
        decoration: span.underline ? TextDecoration.underline : TextDecoration.none,
        height: 1.6,
      ),
    );
  }
}
