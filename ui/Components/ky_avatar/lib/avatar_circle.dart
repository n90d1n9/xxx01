import 'package:flutter/material.dart';

import 'avatar_pile.dart';

class AvatarCircle extends StatelessWidget {
  final AvatarFrame frame;
  final double size;
  final Color nameLabelColor;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Duration animationDuration;

  const AvatarCircle({
    super.key,
    required this.frame,
    required this.size,
    required this.nameLabelColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
          radius: 30.0,
          backgroundImage: frame.avatar,// NetworkImage('https://robohash.org/urang'),
          backgroundColor: backgroundColor,
          /* child: ClipOval(
            child: Image.network(
              'https://api.dicebear.com/8.x/adventurer/svg?seed=Gizmo',
            ),
          ), */
        );
  }
}