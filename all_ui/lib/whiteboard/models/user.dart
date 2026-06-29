import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/legacy.dart';

import 'user_role.dart';

class User {
  final String id;
  final String name;
  final Color cursorColor;
  final Offset? cursorPosition;
  final bool isActive;
  final UserRole role;
  final DateTime lastActivity;
  User({
    required this.id,
    required this.name,
    required this.cursorColor,
    this.cursorPosition,
    this.isActive = true,
    this.role = UserRole.student,
    DateTime? lastActivity,
  }) : lastActivity = lastActivity ?? DateTime.now();
  User copyWith({
    String? name,
    Color? cursorColor,
    Offset? cursorPosition,
    bool? isActive,
    UserRole? role,
    DateTime? lastActivity,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cursorColor': cursorColor.value,
    'cursorPosition':
        cursorPosition != null
            ? {'dx': cursorPosition!.dx, 'dy': cursorPosition!.dy}
            : null,
    'isActive': isActive,
    'role': role.toString(),
    'lastActivity': lastActivity.toIso8601String(),
  };
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      cursorColor: Color(json['cursorColor']),
      cursorPosition:
          json['cursorPosition'] != null
              ? Offset(
                json['cursorPosition']['dx'],
                json['cursorPosition']['dy'],
              )
              : null,
      isActive: json['isActive'] ?? true,
      role: UserRole.values.firstWhere(
        (r) => r.toString() == json['role'],
        orElse: () => UserRole.student,
      ),
      lastActivity: DateTime.parse(json['lastActivity']),
    );
  }
}
