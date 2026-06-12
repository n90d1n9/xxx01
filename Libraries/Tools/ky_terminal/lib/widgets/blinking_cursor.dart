import 'package:flutter/material.dart';
import '../theme/terminal_theme.dart';

class BlinkingCursor extends StatefulWidget {
  final bool blink;
  final double height;
  final double width;

  const BlinkingCursor({
    super.key,
    this.blink = true,
    this.height = 18,
    this.width = 8,
  });

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    if (widget.blink) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(BlinkingCursor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.blink != oldWidget.blink) {
      if (widget.blink) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 1;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: TerminalTheme.cursor,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
