import 'package:flutter/material.dart';

/// Creates the app text theme while keeping generated theme files dependency-light.
TextTheme createTextTheme(
  BuildContext context,
  String bodyFont,
  String displayFont,
) {
  return Theme.of(context).textTheme;
}
