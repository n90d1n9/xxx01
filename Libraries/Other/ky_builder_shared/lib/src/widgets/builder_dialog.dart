import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Wraps builder dialogs with consistent title, content sizing, and actions.
class KyBuilderDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final double? width;
  final double? height;
  final double? maxWidth;

  const KyBuilderDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions = const [],
    this.width,
    this.height,
    this.maxWidth,
  });

  @Preview(name: 'Builder dialog')
  const KyBuilderDialog.preview({super.key})
    : title = const Text('Builder dialog'),
      content = const Text('Review the builder action before continuing.'),
      actions = const [
        TextButton(onPressed: null, child: Text('Cancel')),
        FilledButton(onPressed: null, child: Text('Apply')),
      ],
      width = 320,
      height = null,
      maxWidth = 380;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: _DialogContentFrame(
        width: width,
        height: height,
        maxWidth: maxWidth,
        child: content,
      ),
      actions: actions,
    );
  }
}

/// Applies optional sizing constraints to dialog content.
class _DialogContentFrame extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double? maxWidth;

  const _DialogContentFrame({
    required this.child,
    required this.width,
    required this.height,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    Widget current = child;

    if (width != null || height != null) {
      current = SizedBox(width: width, height: height, child: current);
    }

    if (maxWidth != null) {
      current = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: current,
      );
    }

    return current;
  }
}
