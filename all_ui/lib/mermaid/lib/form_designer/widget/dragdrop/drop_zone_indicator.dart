import 'package:flutter/material.dart';

import '../../model/drag_drop_state.dart';
import '../../model/form_theme.dart';

class DropZoneIndicator extends StatelessWidget {
  final bool isActive;
  final DropPosition position;
  final FormTheme theme;

  const DropZoneIndicator({
    super.key,
    required this.isActive,
    required this.position,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: position == DropPosition.inside ? 80 : 4,
      decoration: BoxDecoration(
        color: theme.colors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(
          position == DropPosition.inside ? 8 : 2,
        ),
        border: Border.all(color: theme.colors.primary, width: 2),
      ),
      child: position == DropPosition.inside
          ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle, color: theme.colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Drop inside container',
                    style: TextStyle(
                      color: theme.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
