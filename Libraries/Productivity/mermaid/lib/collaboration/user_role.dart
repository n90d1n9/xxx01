import 'package:flutter/widgets.dart';

enum UserRole { owner, editor, viewer }

class UserCursor {
  final String userId;
  final Offset position;
  final String? selectedFieldId;
  final DateTime lastUpdate;

  const UserCursor({
    required this.userId,
    required this.position,
    this.selectedFieldId,
    required this.lastUpdate,
  });
}
