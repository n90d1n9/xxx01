import 'package:flutter/material.dart';

class AdminPageScaffold extends StatelessWidget {
  const AdminPageScaffold({
    super.key,
    required this.children,
    this.header,
    this.padding,
    this.maxContentWidth = 1280,
    this.spacing = 20,
  });

  final Widget? header;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double maxContentWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectivePadding =
            padding ?? EdgeInsets.all(constraints.maxWidth < 720 ? 16 : 24);
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildChildren(),
        );

        return SingleChildScrollView(
          padding: effectivePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: content,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildChildren() {
    final items = <Widget>[if (header != null) header!, ...children];

    if (items.isEmpty) return const [SizedBox.shrink()];

    return [
      for (var index = 0; index < items.length; index++) ...[
        items[index],
        if (index < items.length - 1) SizedBox(height: spacing),
      ],
    ];
  }
}
