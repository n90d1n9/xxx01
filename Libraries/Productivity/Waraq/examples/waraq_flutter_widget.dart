// examples/waraq_flutter_widget.dart
//
// Real Flutter widget that renders the Waraq editor engine output.
//
// Architecture:
//   WaraqEditorWidget (StatefulWidget)
//     └─ _WaraqEditorState
//         ├─ WaraqEditor (FFI handle)
//         ├─ _EditorPainter (CustomPainter) — renders lines, cursors, tokens
//         └─ RawKeyboardListener — sends keystrokes to engine
//
// The engine owns all text state. Flutter is a pure renderer.
// On every keypress: engine.handleKey → engine.renderFrame → setState → repaint.

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../bindings/dart/waraq_editor.dart';

// ── Theme ─────────────────────────────────────────────────────────────────────

class EditorTheme {
  // Token colours
  final Color defaultText;
  final Color keyword;
  final Color string;
  final Color number;
  final Color comment;
  final Color operator;
  final Color function;
  final Color type;
  final Color variable;
  final Color constant;
  final Color punctuation;
  final Color error;

  // UI colours
  final Color background;
  final Color currentLine;
  final Color selection;
  final Color cursor;
  final Color lineNumber;
  final Color lineNumberActive;
  final Color gutterBackground;
  final Color foldIndicator;
  final Color searchMatch;
  final Color searchMatchCurrent;
  final Color diagnosticError;
  final Color diagnosticWarning;

  // Typography
  final TextStyle monoStyle;
  final double lineHeight;
  final double gutterWidth;

  const EditorTheme({
    required this.defaultText,
    required this.keyword,
    required this.string,
    required this.number,
    required this.comment,
    required this.operator,
    required this.function,
    required this.type,
    required this.variable,
    required this.constant,
    required this.punctuation,
    required this.error,
    required this.background,
    required this.currentLine,
    required this.selection,
    required this.cursor,
    required this.lineNumber,
    required this.lineNumberActive,
    required this.gutterBackground,
    required this.foldIndicator,
    required this.searchMatch,
    required this.searchMatchCurrent,
    required this.diagnosticError,
    required this.diagnosticWarning,
    required this.monoStyle,
    this.lineHeight = 20.0,
    this.gutterWidth = 52.0,
  });

  Color tokenColor(int kind) {
    switch (kind) {
      case 1:
        return keyword;
      case 2:
        return string;
      case 3:
        return number;
      case 4:
        return comment;
      case 5:
        return operator;
      case 6:
        return function;
      case 7:
        return type;
      case 8:
        return variable;
      case 9:
        return constant;
      case 10:
        return punctuation;
      case 255:
        return error;
      default:
        return defaultText;
    }
  }

  static const EditorTheme dark = EditorTheme(
    defaultText: Color(0xFFF8F8F2),
    keyword: Color(0xFFFF79C6),
    string: Color(0xFFF1FA8C),
    number: Color(0xFFBD93F9),
    comment: Color(0xFF6272A4),
    operator: Color(0xFFFF79C6),
    function: Color(0xFF50FA7B),
    type: Color(0xFF8BE9FD),
    variable: Color(0xFFF8F8F2),
    constant: Color(0xFFBD93F9),
    punctuation: Color(0xFFF8F8F2),
    error: Color(0xFFFF5555),
    background: Color(0xFF282A36),
    currentLine: Color(0xFF44475A),
    selection: Color(0xFF44475A),
    cursor: Color(0xFFF8F8F2),
    lineNumber: Color(0xFF6272A4),
    lineNumberActive: Color(0xFFF8F8F2),
    gutterBackground: Color(0xFF21222C),
    foldIndicator: Color(0xFF6272A4),
    searchMatch: Color(0x4051E8F0),
    searchMatchCurrent: Color(0x80F1FA8C),
    diagnosticError: Color(0xFFFF5555),
    diagnosticWarning: Color(0xFFFFB86C),
    monoStyle: TextStyle(
      fontFamily: 'JetBrains Mono',
      fontSize: 14.0,
      height: 1.43,
      color: Color(0xFFF8F8F2),
    ),
  );

  static const EditorTheme light = EditorTheme(
    defaultText: Color(0xFF24292E),
    keyword: Color(0xFFD73A49),
    string: Color(0xFF032F62),
    number: Color(0xFF005CC5),
    comment: Color(0xFF6A737D),
    operator: Color(0xFFD73A49),
    function: Color(0xFF6F42C1),
    type: Color(0xFF005CC5),
    variable: Color(0xFF24292E),
    constant: Color(0xFF005CC5),
    punctuation: Color(0xFF24292E),
    error: Color(0xFFCB2431),
    background: Color(0xFFFFFFFF),
    currentLine: Color(0xFFFAFAFA),
    selection: Color(0xFFBAD4F7),
    cursor: Color(0xFF24292E),
    lineNumber: Color(0xFFBBBBBB),
    lineNumberActive: Color(0xFF24292E),
    gutterBackground: Color(0xFFF6F8FA),
    foldIndicator: Color(0xFFBBBBBB),
    searchMatch: Color(0x40FFE56D),
    searchMatchCurrent: Color(0x80FF9F00),
    diagnosticError: Color(0xFFCB2431),
    diagnosticWarning: Color(0xFFE36209),
    monoStyle: TextStyle(
      fontFamily: 'JetBrains Mono',
      fontSize: 14.0,
      height: 1.43,
      color: Color(0xFF24292E),
    ),
  );
}

// ── Controller ───────────────────────────────────────────────────────────────

/// Exposes the native editor to the widget tree.
class WaraqEditorController extends ChangeNotifier {
  late final WaraqEditor _editor;
  RenderFrame? _frame;
  bool _initialized = false;

  WaraqEditorController({
    String content = '',
    String language = '',
    String fileUri = '',
  }) {
    _editor = WaraqEditor.fromString(content, language: language);
    if (fileUri.isNotEmpty) _editor.setFileUri(fileUri);
    _refreshFrame();
    _initialized = true;
  }

  RenderFrame? get frame => _frame;
  WaraqEditor get editor => _editor;

  void _refreshFrame() {
    _frame = _editor.renderFrame();
    if (_initialized) notifyListeners();
  }

  // ── Text mutations ─────────────────────────────────────────────────────────

  void typeChar(int codepoint) {
    _editor.typeChar(codepoint);
    _refreshFrame();
  }

  void typeString(String s) {
    _editor.typeString(s);
    _refreshFrame();
  }

  void keyBackspace() {
    _editor.keyBackspace();
    _refreshFrame();
  }

  void keyDelete() {
    _editor.keyDelete();
    _refreshFrame();
  }

  void keyEnter() {
    _editor.keyEnter();
    _refreshFrame();
  }

  void keyTab() {
    _editor.keyTab();
    _refreshFrame();
  }

  void keyShiftTab() {
    _editor.keyShiftTab();
    _refreshFrame();
  }

  // ── Motion ─────────────────────────────────────────────────────────────────

  void motionCode(int code, {bool extend = false}) {
    _editor.motionCode(code, extend: extend);
    _refreshFrame();
  }

  void moveUp(int n, {bool extend = false}) {
    _editor.moveUp(n, extend: extend);
    _refreshFrame();
  }

  void moveDown(int n, {bool extend = false}) {
    _editor.moveDown(n, extend: extend);
    _refreshFrame();
  }

  // ── Selection ──────────────────────────────────────────────────────────────

  void selectWord() {
    _editor.selectWord();
    _refreshFrame();
  }

  void selectLine() {
    _editor.selectLine();
    _refreshFrame();
  }

  void selectAll() {
    _editor.selectAll();
    _refreshFrame();
  }

  void expandSelection() {
    _editor.expandSelection();
    _refreshFrame();
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  SearchMatch? searchStart(String pattern, {int flags = WaraqEditor.flagCase}) {
    final m = _editor.searchStart(pattern, flags: flags);
    _refreshFrame();
    return m;
  }

  SearchMatch? searchNext() {
    final m = _editor.searchNext();
    _refreshFrame();
    return m;
  }

  SearchMatch? searchPrev() {
    final m = _editor.searchPrev();
    _refreshFrame();
    return m;
  }

  void searchClear() {
    _editor.searchClear();
    _refreshFrame();
  }

  // ── Folds ──────────────────────────────────────────────────────────────────

  void toggleFold(int line) {
    _editor.toggleFold(line);
    _refreshFrame();
  }

  void foldAll() {
    _editor.foldAll();
    _refreshFrame();
  }

  void unfoldAll() {
    _editor.unfoldAll();
    _refreshFrame();
  }

  // ── Undo / Redo ────────────────────────────────────────────────────────────

  void undo() {
    _editor.undo();
    _refreshFrame();
  }

  void redo() {
    _editor.redo();
    _refreshFrame();
  }

  bool get canUndo => _editor.canUndo;
  bool get canRedo => _editor.canRedo;

  // ── Viewport ───────────────────────────────────────────────────────────────

  void setViewportHeight(int h) {
    _editor.setViewportHeight(h);
    _refreshFrame();
  }

  void scrollBy(int delta) {
    _editor.scrollBy(delta);
    _refreshFrame();
  }

  // ── AI Completion ──────────────────────────────────────────────────────────

  bool get hasCompletion => _editor.hasCompletion;
  String? get completionText => _editor.completionText;

  void feedCompletion(int requestId, String text, int latencyMs) {
    _editor.feedCompletion(requestId, text, latencyMs);
    _refreshFrame();
  }

  void dismissCompletion() {
    _editor.dismissCompletion();
    _refreshFrame();
  }

  @override
  void dispose() {
    _editor.dispose();
    super.dispose();
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _EditorPainter extends CustomPainter {
  final RenderFrame frame;
  final EditorTheme theme;
  final double charWidth; // pre-measured from font metrics

  _EditorPainter({
    required this.frame,
    required this.theme,
    required this.charWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.background);

    // Gutter background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, theme.gutterWidth, size.height),
      Paint()..color = theme.gutterBackground,
    );

    final lineH = theme.lineHeight;
    final textX = theme.gutterWidth + 8.0;

    for (int i = 0; i < frame.lines.length; i++) {
      final line = frame.lines[i];
      final lineN = line.lineNumber;
      final y = i * lineH;

      // Current line highlight
      final isCursorLine =
          frame.cursors.isNotEmpty &&
          _offsetOnLine(frame.cursors[0]['col']!, lineN, frame);
      if (isCursorLine) {
        canvas.drawRect(
          Rect.fromLTWH(
            theme.gutterWidth,
            y,
            size.width - theme.gutterWidth,
            lineH,
          ),
          Paint()..color = theme.currentLine,
        );
      }

      // Selection background
      for (final sel in frame.selections) {
        _paintSelectionOnLine(canvas, sel, lineN, line, y, textX, size.width);
      }

      // Search match highlights
      for (final match in frame.searchMatches) {
        _paintSearchMatch(canvas, match, lineN, line, y, textX);
      }

      // Line number
      _paintLineNumber(canvas, lineN + 1, y, isCursorLine);

      // Fold indicator
      final fold = frame.folds.cast<FoldInfo?>().firstWhere(
        (f) => f!.startLine == lineN,
        orElse: () => null,
      );
      if (fold != null) _paintFoldIndicator(canvas, y, fold.collapsed);

      // Diagnostics underline
      for (final d in frame.diagnostics) {
        if (d.line == lineN) {
          _paintDiagnosticUnderline(canvas, d, line, y, textX);
        }
      }

      // Text with syntax highlighting
      _paintLine(canvas, line.text, lineN, y, textX);
    }

    // Cursor(s)
    for (final cursor in frame.cursors) {
      _paintCursor(canvas, cursor, frame, textX);
    }

    // AI completion ghost text
    // (would be drawn at cursor position in a lighter colour)
  }

  void _paintLine(
    Canvas canvas,
    String text,
    int lineNum,
    double y,
    double textX,
  ) {
    if (text.isEmpty) return;

    // Gather tokens on this line
    final lineTokens = frame.tokens.where((t) => t.line == lineNum).toList()
      ..sort((a, b) => a.colStart.compareTo(b.colStart));

    if (lineTokens.isEmpty) {
      // Plain text
      _drawText(canvas, text, theme.defaultText, textX, y);
      return;
    }

    // Render spans between tokens
    double x = textX;
    int charPos = 0;
    for (final tok in lineTokens) {
      // Text before this token
      if (tok.colStart > charPos && charPos < text.length) {
        final before = _safeSubstring(text, charPos, tok.colStart);
        x = _drawText(canvas, before, theme.defaultText, x, y);
      }
      // Token text
      if (tok.colStart < text.length) {
        final tokText = _safeSubstring(text, tok.colStart, tok.colEnd);
        x = _drawText(canvas, tokText, theme.tokenColor(tok.kind), x, y);
      }
      charPos = tok.colEnd;
    }
    // Remaining text
    if (charPos < text.length) {
      _drawText(canvas, text.substring(charPos), theme.defaultText, x, y);
    }
  }

  double _drawText(
    Canvas canvas,
    String text,
    Color color,
    double x,
    double y,
  ) {
    if (text.isEmpty) return x;
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: theme.monoStyle.copyWith(color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x, y + (theme.lineHeight - tp.height) / 2));
    return x + tp.width;
  }

  void _paintLineNumber(Canvas canvas, int n, double y, bool isActive) {
    final color = isActive ? theme.lineNumberActive : theme.lineNumber;
    final tp = TextPainter(
      text: TextSpan(
        text: '$n',
        style: theme.monoStyle.copyWith(color: color, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: theme.gutterWidth - 8);
    tp.paint(
      canvas,
      Offset(
        theme.gutterWidth - tp.width - 8,
        y + (theme.lineHeight - tp.height) / 2,
      ),
    );
  }

  void _paintFoldIndicator(Canvas canvas, double y, bool collapsed) {
    const size = 12.0;
    final cx = theme.gutterWidth - 20.0;
    final cy = y + theme.lineHeight / 2;
    final paint = Paint()
      ..color = theme.foldIndicator
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path();
    if (collapsed) {
      // Right-pointing triangle
      path.moveTo(cx - size / 3, cy - size / 3);
      path.lineTo(cx + size / 3, cy);
      path.lineTo(cx - size / 3, cy + size / 3);
      path.close();
    } else {
      // Down-pointing triangle
      path.moveTo(cx - size / 3, cy - size / 4);
      path.lineTo(cx + size / 3, cy - size / 4);
      path.lineTo(cx, cy + size / 3);
      path.close();
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = theme.foldIndicator
        ..style = PaintingStyle.fill,
    );
  }

  void _paintSelectionOnLine(
    Canvas canvas,
    Map<String, int> sel,
    int lineNum,
    VisibleLine line,
    double y,
    double textX,
    double maxX,
  ) {
    // Simplified: paint entire line if selected (full implementation would
    // calculate precise character-level start/end)
    final startOffset = sel['start']!;
    final endOffset = sel['end']!;
    if (line.byteOffset > endOffset) return;
    if (line.byteOffset + line.text.length < startOffset) return;

    canvas.drawRect(
      Rect.fromLTWH(textX, y, maxX - textX, theme.lineHeight),
      Paint()..color = theme.selection,
    );
  }

  void _paintSearchMatch(
    Canvas canvas,
    SearchMatchHighlight match,
    int lineNum,
    VisibleLine line,
    double y,
    double textX,
  ) {
    final color = match.isCurrent
        ? theme.searchMatchCurrent
        : theme.searchMatch;
    // Approximate: highlight the whole line for simplicity
    // Full implementation: calculate col from byte offset
    if (match.start >= line.byteOffset &&
        match.start < line.byteOffset + line.text.length) {
      final colStart = match.start - line.byteOffset;
      final colEnd = math.min(match.end - line.byteOffset, line.text.length);
      canvas.drawRect(
        Rect.fromLTWH(
          textX + colStart * charWidth,
          y,
          (colEnd - colStart) * charWidth,
          theme.lineHeight,
        ),
        Paint()..color = color,
      );
    }
  }

  void _paintDiagnosticUnderline(
    Canvas canvas,
    DiagInfo d,
    VisibleLine line,
    double y,
    double textX,
  ) {
    final color = d.severity == 1
        ? theme.diagnosticError
        : theme.diagnosticWarning;
    final startX = textX + d.col * charWidth;
    final endX = textX + (d.col + 10).toDouble() * charWidth; // approximate
    final lineY = y + theme.lineHeight - 2;

    // Squiggly underline
    final path = Path();
    path.moveTo(startX, lineY);
    double x = startX;
    bool up = true;
    while (x < endX) {
      path.lineTo(x + 3, lineY + (up ? -2 : 2));
      x += 3;
      up = !up;
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _paintCursor(
    Canvas canvas,
    Map<String, int> cursor,
    RenderFrame frame,
    double textX,
  ) {
    final lineIdx = cursor['line'] ?? 0;
    final col = cursor['col'] ?? 0;
    if (lineIdx >= frame.lines.length) return;

    final y = lineIdx * theme.lineHeight;
    final x = textX + col * charWidth;
    canvas.drawRect(
      Rect.fromLTWH(x, y + 2, 2, theme.lineHeight - 4),
      Paint()..color = theme.cursor,
    );
  }

  bool _offsetOnLine(int offset, int lineNum, RenderFrame frame) {
    if (lineNum >= frame.lines.length) return false;
    return true; // simplified
  }

  String _safeSubstring(String s, int start, int end) {
    final s2 = start.clamp(0, s.length);
    final e2 = end.clamp(s2, s.length);
    return s.substring(s2, e2);
  }

  @override
  bool shouldRepaint(_EditorPainter old) => old.frame != frame;
}

// ── Widget ────────────────────────────────────────────────────────────────────

class WaraqEditorWidget extends StatefulWidget {
  final WaraqEditorController controller;
  final EditorTheme theme;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  const WaraqEditorWidget({
    super.key,
    required this.controller,
    this.theme = EditorTheme.dark,
    this.autofocus = true,
    this.onChanged,
  });

  @override
  State<WaraqEditorWidget> createState() => _WaraqEditorWidgetState();
}

class _WaraqEditorWidgetState extends State<WaraqEditorWidget> {
  final FocusNode _focusNode = FocusNode();
  late double _charWidth;
  late double _viewportHeightLines;

  @override
  void initState() {
    super.initState();
    _measureCharWidth();
    widget.controller.addListener(_onFrameUpdate);
  }

  void _measureCharWidth() {
    final tp = TextPainter(
      text: TextSpan(text: 'M', style: widget.theme.monoStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    _charWidth = tp.width;
  }

  void _onFrameUpdate() {
    if (mounted) setState(() {});
    widget.onChanged?.call(widget.controller.editor.getText());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onFrameUpdate);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKey: _handleKey,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onPanUpdate: _handlePanUpdate,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final linesVisible =
                (constraints.maxHeight / widget.theme.lineHeight).ceil();
            if (linesVisible != _viewportHeightLines.toInt()) {
              _viewportHeightLines = linesVisible.toDouble();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.controller.setViewportHeight(linesVisible);
              });
            }
            final frame = widget.controller.frame;
            if (frame == null) return const SizedBox.shrink();
            return CustomPaint(
              painter: _EditorPainter(
                frame: frame,
                theme: widget.theme,
                charWidth: _charWidth,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }

  KeyEventResult _handleKey(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
    final ctrl = event.isControlPressed || event.isMetaPressed;
    final shift = event.isShiftPressed;
    final alt = event.isAltPressed;
    final c = widget.controller;

    // Common shortcuts
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyZ && !shift) {
      c.undo();
      return KeyEventResult.handled;
    }
    if (ctrl &&
        (event.logicalKey == LogicalKeyboardKey.keyZ && shift ||
            event.logicalKey == LogicalKeyboardKey.keyY)) {
      c.redo();
      return KeyEventResult.handled;
    }
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyA) {
      c.selectAll();
      return KeyEventResult.handled;
    }
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyF) {
      // Would show a search bar overlay — trigger from parent
      return KeyEventResult.handled;
    }
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyD) {
      widget.controller.editor.addCursorAtNext();
      c._refreshFrame();
      return KeyEventResult.handled;
    }

    // Navigation
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        if (ctrl)
          c.motionCode(2, extend: shift);
        else
          c.motionCode(0, extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        if (ctrl)
          c.motionCode(3, extend: shift);
        else
          c.motionCode(1, extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        c.moveUp(1, extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        c.moveDown(1, extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.home:
        c.motionCode(ctrl ? 15 : (shift ? 6 : 5), extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.end:
        c.motionCode(ctrl ? 16 : 7, extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageUp:
        c.motionCode(12, extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageDown:
        c.motionCode(13, extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.backspace:
        c.keyBackspace();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.delete:
        c.keyDelete();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
        c.keyEnter();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.tab:
        if (shift)
          c.keyShiftTab();
        else
          c.keyTab();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        if (c.hasCompletion) {
          c.dismissCompletion();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
    }

    // Printable characters
    final character = event.character;
    if (character != null && character.isNotEmpty && !ctrl && !alt) {
      for (final rune in character.runes) {
        c.typeChar(rune);
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _handleTapDown(TapDownDetails details) {
    _focusNode.requestFocus();
    final frame = widget.controller.frame;
    if (frame == null) return;
    final localPos = details.localPosition;
    final lineIdx = (localPos.dy / widget.theme.lineHeight).floor();
    final colIdx = ((localPos.dx - widget.theme.gutterWidth - 8) / _charWidth)
        .round();

    if (lineIdx >= 0 && lineIdx < frame.lines.length) {
      final line = frame.lines[lineIdx];
      final col = colIdx.clamp(0, line.text.length);
      // Convert line+col to byte offset
      final byteOffset = line.byteOffset + _colToBytes(line.text, col);
      widget.controller.editor.moveCursor(byteOffset);
      widget.controller._refreshFrame();
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    // Drag = extend selection (simplified)
    final frame = widget.controller.frame;
    if (frame == null) return;
    final localPos = details.localPosition;
    final lineIdx = (localPos.dy / widget.theme.lineHeight).floor().clamp(
      0,
      frame.lines.length - 1,
    );
    if (lineIdx < frame.lines.length) {
      final line = frame.lines[lineIdx];
      final col = ((localPos.dx - widget.theme.gutterWidth - 8) / _charWidth)
          .round()
          .clamp(0, line.text.length);
      final byteOffset = line.byteOffset + _colToBytes(line.text, col);
      widget.controller.editor.moveCursor(byteOffset, extend: true);
      widget.controller._refreshFrame();
    }
  }

  int _colToBytes(String text, int col) {
    var bytes = 0;
    var chars = 0;
    for (final rune in text.runes) {
      if (chars >= col) break;
      bytes += String.fromCharCode(rune).length; // UTF-16 approximation
      chars++;
    }
    return bytes;
  }
}

// ── Extension for addCursorAtNext ────────────────────────────────────────────

extension on WaraqEditorController {
  void _refreshFrame() {
    frame;
    notifyListeners();
  }
}

extension WaraqEditorExt on WaraqEditor {
  void addCursorAtNext() => addCursorAtNextOccurrence();
}

// ── Example app ──────────────────────────────────────────────────────────────

void main() {
  runApp(const WaraqExampleApp());
}

/// Root Material app for the Waraq sidebar example.
class WaraqExampleApp extends StatelessWidget {
  const WaraqExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waraq Editor',
      theme: ThemeData.dark(),
      home: const _WaraqExampleShell(),
    );
  }
}

/// Sidebar destinations exposed by the Waraq example shell.
enum _WaraqExampleDestination {
  editor(label: 'Editor', icon: Icons.code_outlined, selectedIcon: Icons.code),
  artifactApi(
    label: 'Artifact API',
    icon: Icons.api_outlined,
    selectedIcon: Icons.api,
  ),
  readiness(
    label: 'Readiness',
    icon: Icons.fact_check_outlined,
    selectedIcon: Icons.fact_check,
  ),
  contract(
    label: 'Contract',
    icon: Icons.description_outlined,
    selectedIcon: Icons.description,
  );

  const _WaraqExampleDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  _WaraqInfoScreenSpec? get infoScreenSpec {
    return switch (this) {
      _WaraqExampleDestination.editor => null,
      _WaraqExampleDestination.artifactApi => _artifactApiInfo,
      _WaraqExampleDestination.readiness => _readinessInfo,
      _WaraqExampleDestination.contract => _contractInfo,
    };
  }
}

/// Coordinates sidebar selection and the currently visible Waraq screen.
class _WaraqExampleShell extends StatefulWidget {
  const _WaraqExampleShell();

  @override
  State<_WaraqExampleShell> createState() => _WaraqExampleShellState();
}

class _WaraqExampleShellState extends State<_WaraqExampleShell> {
  _WaraqExampleDestination _destination = _WaraqExampleDestination.editor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final expandedSidebar = constraints.maxWidth >= 840;

        return Scaffold(
          backgroundColor: const Color(0xFF191A21),
          body: Row(
            children: [
              _WaraqSidebar(
                selectedDestination: _destination,
                expanded: expandedSidebar,
                onDestinationSelected: (destination) {
                  setState(() => _destination = destination);
                },
              ),
              const VerticalDivider(width: 1, color: Color(0xFF303241)),
              Expanded(child: _WaraqDestinationPane(destination: _destination)),
            ],
          ),
        );
      },
    );
  }
}

/// Navigation rail that keeps every Waraq example screen one click away.
class _WaraqSidebar extends StatelessWidget {
  const _WaraqSidebar({
    required this.selectedDestination,
    required this.expanded,
    required this.onDestinationSelected,
  });

  final _WaraqExampleDestination selectedDestination;
  final bool expanded;
  final ValueChanged<_WaraqExampleDestination> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: expanded,
      minWidth: 72,
      minExtendedWidth: 192,
      backgroundColor: const Color(0xFF21222C),
      selectedIndex: selectedDestination.index,
      groupAlignment: -0.86,
      labelType: expanded ? null : NavigationRailLabelType.none,
      selectedIconTheme: const IconThemeData(color: Color(0xFF8BE9FD)),
      unselectedIconTheme: const IconThemeData(color: Color(0xFF6272A4)),
      selectedLabelTextStyle: const TextStyle(
        color: Color(0xFFF8F8F2),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: Color(0xFF9AA6C3),
        fontSize: 11,
      ),
      onDestinationSelected: (index) {
        onDestinationSelected(_WaraqExampleDestination.values[index]);
      },
      leading: const Padding(
        padding: EdgeInsets.only(top: 14, bottom: 24),
        child: Icon(Icons.view_sidebar, color: Color(0xFF50FA7B)),
      ),
      destinations: [
        for (final destination in _WaraqExampleDestination.values)
          NavigationRailDestination(
            icon: Tooltip(
              message: destination.label,
              child: Icon(destination.icon),
            ),
            selectedIcon: Tooltip(
              message: destination.label,
              child: Icon(destination.selectedIcon),
            ),
            label: Text(destination.label),
          ),
      ],
    );
  }
}

/// Selects the screen widget for the active sidebar destination.
class _WaraqDestinationPane extends StatelessWidget {
  const _WaraqDestinationPane({required this.destination});

  final _WaraqExampleDestination destination;

  @override
  Widget build(BuildContext context) {
    final infoScreenSpec = destination.infoScreenSpec;
    if (infoScreenSpec != null) {
      return _WaraqInfoScreen(spec: infoScreenSpec);
    }
    return const _EditorScreen();
  }
}

/// Immutable content model rendered by a Waraq information screen.
class _WaraqInfoScreenSpec {
  const _WaraqInfoScreenSpec({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<_WaraqInfoItem> items;
}

/// Reusable compact information screen used by sidebar panes.
class _WaraqInfoScreen extends StatelessWidget {
  const _WaraqInfoScreen({required this.spec});

  final _WaraqInfoScreenSpec spec;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282A36),
      appBar: AppBar(
        backgroundColor: const Color(0xFF21222C),
        title: Text(
          spec.title,
          style: const TextStyle(color: Color(0xFFF8F8F2), fontSize: 14),
        ),
      ),
      body: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(spec.icon, color: const Color(0xFF8BE9FD), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        spec.subtitle,
                        style: const TextStyle(
                          color: Color(0xFFF8F8F2),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                for (final item in spec.items) ...[
                  _WaraqInfoRow(item: item),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Immutable display value rendered on a Waraq information screen.
class _WaraqInfoItem {
  const _WaraqInfoItem({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;
}

const _artifactApiInfo = _WaraqInfoScreenSpec(
  icon: Icons.api,
  title: 'Artifact API',
  subtitle: 'waraq.editor / API v25',
  items: [
    _WaraqInfoItem(
      label: 'Result envelope',
      value: 'ok_value_error',
      accent: Color(0xFF8BE9FD),
    ),
    _WaraqInfoItem(
      label: 'Restore preflight',
      value: 'editor_artifact_restore_preflight_result_json',
      accent: Color(0xFF50FA7B),
    ),
    _WaraqInfoItem(
      label: 'Legacy restore',
      value: 'EditorHandle* after preflight',
      accent: Color(0xFFF1FA8C),
    ),
  ],
);

const _readinessInfo = _WaraqInfoScreenSpec(
  icon: Icons.fact_check,
  title: 'Readiness',
  subtitle: 'Shared artifact lifecycle checks',
  items: [
    _WaraqInfoItem(
      label: 'Conformance',
      value: '10 checks',
      accent: Color(0xFF50FA7B),
    ),
    _WaraqInfoItem(
      label: 'Replay harness',
      value: '4 checks',
      accent: Color(0xFF8BE9FD),
    ),
    _WaraqInfoItem(
      label: 'Compaction harness',
      value: '8 checks',
      accent: Color(0xFFFFB86C),
    ),
    _WaraqInfoItem(
      label: 'Lifecycle total',
      value: '22 checks',
      accent: Color(0xFFBD93F9),
    ),
  ],
);

const _contractInfo = _WaraqInfoScreenSpec(
  icon: Icons.description,
  title: 'Contract',
  subtitle: 'Shared core + specialized engines',
  items: [
    _WaraqInfoItem(
      label: 'Operation',
      value: 'OperationEnvelope<Edit>',
      accent: Color(0xFF8BE9FD),
    ),
    _WaraqInfoItem(
      label: 'Operation log',
      value: 'OperationLog<Edit>',
      accent: Color(0xFF50FA7B),
    ),
    _WaraqInfoItem(
      label: 'Artifact',
      value: 'OperationArtifact<Snapshot, Edit>',
      accent: Color(0xFFF1FA8C),
    ),
  ],
);

/// One stable label/value row in a Waraq information screen.
class _WaraqInfoRow extends StatelessWidget {
  const _WaraqInfoRow({required this.item});

  final _WaraqInfoItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        color: const Color(0xFF21222C),
        border: Border(left: BorderSide(color: item.accent, width: 3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              item.label,
              style: const TextStyle(color: Color(0xFF9AA6C3), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              item.value,
              style: const TextStyle(
                color: Color(0xFFF8F8F2),
                fontSize: 13,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example screen that hosts the Waraq code editor widget.
class _EditorScreen extends StatefulWidget {
  const _EditorScreen();

  @override
  State<_EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<_EditorScreen> {
  late final WaraqEditorController _controller;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _controller = WaraqEditorController(
      content: _sampleRustCode,
      language: 'rust',
      fileUri: 'file:///example/main.rs',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282A36),
      appBar: AppBar(
        backgroundColor: const Color(0xFF21222C),
        title: const Text(
          'Waraq Editor',
          style: TextStyle(color: Color(0xFFF8F8F2), fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFFBD93F9)),
            onPressed: () => setState(() => _showSearch = !_showSearch),
          ),
          IconButton(
            icon: const Icon(Icons.undo, color: Color(0xFFF8F8F2)),
            onPressed: _controller.canUndo ? _controller.undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo, color: Color(0xFFF8F8F2)),
            onPressed: _controller.canRedo ? _controller.redo : null,
          ),
          IconButton(
            icon: const Icon(Icons.unfold_more, color: Color(0xFFF8F8F2)),
            onPressed: _controller.unfoldAll,
          ),
          IconButton(
            icon: const Icon(Icons.unfold_less, color: Color(0xFFF8F8F2)),
            onPressed: _controller.foldAll,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearch) _buildSearchBar(),
          Expanded(
            child: WaraqEditorWidget(
              controller: _controller,
              theme: EditorTheme.dark,
            ),
          ),
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFF44475A),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: const TextStyle(color: Color(0xFFF8F8F2), fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Color(0xFF6272A4)),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (v) {
                if (v.isNotEmpty)
                  _controller.searchStart(v);
                else
                  _controller.searchClear();
              },
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.navigate_before,
              color: Color(0xFFF8F8F2),
              size: 18,
            ),
            onPressed: _controller.searchPrev,
          ),
          IconButton(
            icon: const Icon(
              Icons.navigate_next,
              color: Color(0xFFF8F8F2),
              size: 18,
            ),
            onPressed: _controller.searchNext,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFFF8F8F2), size: 18),
            onPressed: () {
              _controller.searchClear();
              setState(() => _showSearch = false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    final frame = _controller.frame;
    final totalLines = frame?.totalLines ?? 0;
    final lang = frame?.language ?? '';
    final errors = _controller.editor.errorCount;
    final warnings = _controller.editor.warningCount;

    return Container(
      color: const Color(0xFF191A21),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          Text(
            lang.isEmpty ? 'Plain Text' : lang,
            style: const TextStyle(color: Color(0xFF6272A4), fontSize: 12),
          ),
          const Spacer(),
          if (errors > 0)
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF5555),
                  size: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  '$errors',
                  style: const TextStyle(
                    color: Color(0xFFFF5555),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          if (warnings > 0)
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_outlined,
                  color: Color(0xFFFFB86C),
                  size: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  '$warnings',
                  style: const TextStyle(
                    color: Color(0xFFFFB86C),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          Text(
            '$totalLines lines',
            style: const TextStyle(color: Color(0xFF6272A4), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

const _sampleRustCode = '''use std::collections::HashMap;

fn main() {
    let mut scores: HashMap<String, i32> = HashMap::new();
    
    scores.insert("Alice".to_string(), 95);
    scores.insert("Bob".to_string(), 87);
    scores.insert("Charlie".to_string(), 92);
    
    for (name, score) in &scores {
        println!("{}: {}", name, score);
    }
    
    if let Some(alice_score) = scores.get("Alice") {
        println!("Alice scored: {}", alice_score);
    }
}
''';
