import 'package:flutter/material.dart';

class Folder {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final DateTime createdAt;
  Folder({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.createdAt,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon.codePoint,
    'color': color.value,
    'createdAt': createdAt.toIso8601String(),
  };
  factory Folder.fromJson(Map<String, dynamic> json) => Folder(
    id: json['id'],
    name: json['name'],
    icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    color: Color(json['color']),
    createdAt: DateTime.parse(json['createdAt']),
  );
}
