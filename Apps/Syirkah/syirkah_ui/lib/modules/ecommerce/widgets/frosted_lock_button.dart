import 'dart:ui';

import 'package:flutter/material.dart';
import '../utils/color_utils.dart';
import '../utils/images.dart';

class FrostedLockButton extends StatelessWidget {
  const FrostedLockButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(color: frostedBackColor.withOpacity(0.5), borderRadius: BorderRadius.circular(30.0)),
          height: 40.0,
          width: 40.0,
          child: Image.asset(icLock),
        ),
      ),
    );
  }
}