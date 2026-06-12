import 'package:flutter/material.dart';

class AdminPageToolbar extends StatelessWidget {
  const AdminPageToolbar({
    super.key,
    required this.children,
    this.trailing,
    this.spacing = 10,
    this.runSpacing = 10,
  });

  final List<Widget> children;
  final Widget? trailing;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty && trailing == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        final controls = Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        );

        if (trailing == null) return controls;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              controls,
              SizedBox(height: runSpacing),
              Align(alignment: Alignment.centerLeft, child: trailing),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: controls),
            SizedBox(width: spacing),
            trailing!,
          ],
        );
      },
    );
  }
}
