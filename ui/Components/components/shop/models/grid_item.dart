import 'package:flutter/material.dart';

class GridItem {
  final double? id;
  final IconData? icon;
  final String? path;
  final String? title;
  final String? imagePath;
  final Color? color;
  GridItem(
      {this.id, this.title, this.path, this.icon, this.imagePath, this.color});
}