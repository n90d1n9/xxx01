import 'package:flutter/material.dart';

/* class GCell {
  final dynamic value;
  late final GTableCell? cell;
  GCell({this.value, this.cell});
} */

class GCell {
  final dynamic value;
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final TextAlign align;
  final BoxConstraints? constraints;
  final BoxDecoration? decoration;
  GCell(
      { 
      this.value,
      this.child,
      this.width,
      this.height,
      this.align = TextAlign.left,
      this.constraints,
      this.decoration,
      this.margin,
      this.padding});
}

class GTableHeader {
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final BoxDecoration? decoration;
  GTableHeader(
      {this.child,
      this.width,
      this.height,
      this.constraints,
      this.decoration,
      this.margin,
      this.padding});
}