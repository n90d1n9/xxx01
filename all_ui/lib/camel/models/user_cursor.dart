import 'package:flutter/material.dart';

class UserCursor {
  final String userId;
  final String userName;
  final Color color;
  final Offset position;
  final DateTime lastSeen;

  UserCursor({
    required this.userId,
    required this.userName,
    required this.color,
    required this.position,
    required this.lastSeen,
  });
}
