import 'package:flutter/material.dart';

import '../model/form_theme.dart';

class AlignmentGuides extends StatelessWidget {
  final List<Offset> verticalGuides;
  final List<Offset> horizontalGuides;
  final FormTheme theme;

  const AlignmentGuides({
    super.key,
    required this.verticalGuides,
    required this.horizontalGuides,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          ...verticalGuides.map(
            (offset) => Positioned(
              left: offset.dx,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                color: theme.colors.primary.withOpacity(0.5),
              ),
            ),
          ),
          ...horizontalGuides.map(
            (offset) => Positioned(
              left: 0,
              right: 0,
              top: offset.dy,
              child: Container(
                height: 2,
                color: theme.colors.primary.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
