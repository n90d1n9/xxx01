import 'package:flutter/material.dart';

class ChatTheme {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final String? wallpaper;
  final bool isDark;

  const ChatTheme({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    this.wallpaper,
    this.isDark = true,
  });

  static const ChatTheme default_ = ChatTheme(
    name: 'Default',
    primaryColor: Colors.blue,
    secondaryColor: Colors.purple,
  );

  static const ChatTheme ocean = ChatTheme(
    name: 'Ocean',
    primaryColor: Colors.cyan,
    secondaryColor: Colors.teal,
  );

  static const ChatTheme sunset = ChatTheme(
    name: 'Sunset',
    primaryColor: Colors.orange,
    secondaryColor: Colors.red,
  );

  static const ChatTheme forest = ChatTheme(
    name: 'Forest',
    primaryColor: Colors.green,
    secondaryColor: Colors.lightGreen,
  );
}
