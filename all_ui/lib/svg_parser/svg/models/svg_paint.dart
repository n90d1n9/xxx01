// Paint representation
import 'package:flutter/material.dart';

class SvgPaint {
  final Color? color;
  final String? reference;
  final bool isNone;

  SvgPaint.color(this.color) : reference = null, isNone = false;
  SvgPaint.reference(this.reference) : color = null, isNone = false;
  SvgPaint.none() : color = null, reference = null, isNone = true;
}
