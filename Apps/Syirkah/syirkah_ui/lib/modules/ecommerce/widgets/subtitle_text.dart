import 'package:flutter/material.dart';

import '../utils/color_utils.dart';
import '../utils/dimens.dart';

class SubTitleText extends StatelessWidget {
  final String? label;
  final int maxLine;

  const SubTitleText({super.key, this.label, this.maxLine = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        label!,
        maxLines: maxLine,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'AvertaSemibold',
          color: subtitleTextColor,
          fontSize: fontSmall,
          fontWeight: fontWeightSemiBold,
          letterSpacing: 0.28,
        ),
      ),
    );
  }
}
