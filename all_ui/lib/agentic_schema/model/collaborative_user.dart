import 'package:flutter/material.dart';

class CollaborativeUser {
  final String id;
  final String name;
  final String email;
  final Color color;
  final Offset? cursorPosition;
  final DateTime lastSeen;
  final bool isActive;
  final List<String>? selectedNodeIds;

  CollaborativeUser({
    required this.id,
    required this.name,
    required this.email,
    required this.color,
    this.cursorPosition,
    required this.lastSeen,
    required this.isActive,
    this.selectedNodeIds,
  });

  CollaborativeUser copyWith({
    String? id,
    String? name,
    String? email,
    Color? color,
    Offset? cursorPosition,
    DateTime? lastSeen,
    bool? isActive,
    List<String>? selectedNodeIds,
  }) {
    return CollaborativeUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      color: color ?? this.color,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      lastSeen: lastSeen ?? this.lastSeen,
      isActive: isActive ?? this.isActive,
      selectedNodeIds: selectedNodeIds ?? this.selectedNodeIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'color': color.value,
    'cursorPosition': cursorPosition != null
        ? {'x': cursorPosition!.dx, 'y': cursorPosition!.dy}
        : null,
    'lastSeen': lastSeen.toIso8601String(),
    'isActive': isActive,
    'selectedNodeIds': selectedNodeIds,
  };

  factory CollaborativeUser.fromJson(Map<String, dynamic> json) {
    return CollaborativeUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      color: Color(json['color']),
      cursorPosition: json['cursorPosition'] != null
          ? Offset(json['cursorPosition']['x'], json['cursorPosition']['y'])
          : null,
      lastSeen: DateTime.parse(json['lastSeen']),
      isActive: json['isActive'],
      selectedNodeIds: json['selectedNodeIds'] != null
          ? List<String>.from(json['selectedNodeIds'])
          : null,
    );
  }
}
