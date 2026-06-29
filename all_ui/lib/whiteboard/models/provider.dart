import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'drawing_path.dart';
import 'drawing_point.dart';
import 'drawing_tool.dart';
import 'shape_fill_style.dart';
import 'template.dart';
import 'user.dart';
import 'user_role.dart';
import 'whiteboard_notifier.dart';
import 'whiteboard_state.dart';

final whiteboardProvider =
    StateNotifierProvider<WhiteboardNotifier, WhiteboardState>((ref) {
      return WhiteboardNotifier();
    });

final currentUserProvider = Provider<User>((ref) {
  final colors = [
    const Color(0xFF3B82F6),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
  ];

  final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
  return User(
    id: userId,
    name: 'User ${userId.substring(userId.length - 4)}',
    cursorColor: colors[math.Random().nextInt(colors.length)],
    role: UserRole.teacher,
  );
});

final templatesProvider = Provider<List<Template>>((ref) {
  return [
    Template(
      id: 'blank',
      name: 'Blank Canvas',
      description: 'Start from scratch',
      icon: Icons.insert_drive_file,
      paths: [],
    ),
    Template(
      id: 'grid',
      name: 'Grid Layout',
      description: 'Organized grid structure',
      icon: Icons.grid_on,
      paths: _createGridTemplate(),
    ),
    Template(
      id: 'brainstorm',
      name: 'Brainstorming',
      description: 'Mind map layout',
      icon: Icons.psychology,
      paths: _createBrainstormTemplate(),
    ),
  ];
});

List<DrawingPath> _createGridTemplate() {
  final paths = <DrawingPath>[];
  final paint =
      Paint()
        ..color = Colors.grey.withOpacity(0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

  for (var i = 0; i <= 3; i++) {
    final x = 100.0 + i * 200.0;
    paths.add(
      DrawingPath(
        points: [
          DrawingPoint(
            point: Offset(x, 100),
            paint: paint,
            userId: 'system',
            timestamp: DateTime.now(),
          ),
          DrawingPoint(
            point: Offset(x, 700),
            paint: paint,
            userId: 'system',
            timestamp: DateTime.now(),
          ),
        ],
        id: 'grid_v_$i',
        userId: 'system',
        tool: DrawingTool.line,
      ),
    );
  }

  for (var i = 0; i <= 3; i++) {
    final y = 100.0 + i * 200.0;
    paths.add(
      DrawingPath(
        points: [
          DrawingPoint(
            point: Offset(100, y),
            paint: paint,
            userId: 'system',
            timestamp: DateTime.now(),
          ),
          DrawingPoint(
            point: Offset(700, y),
            paint: paint,
            userId: 'system',
            timestamp: DateTime.now(),
          ),
        ],
        id: 'grid_h_$i',
        userId: 'system',
        tool: DrawingTool.line,
      ),
    );
  }

  return paths;
}

List<DrawingPath> _createBrainstormTemplate() {
  final paths = <DrawingPath>[];
  final paint =
      Paint()
        ..color = const Color(0xFF3B82F6)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

  paths.add(
    DrawingPath(
      points: [
        DrawingPoint(
          point: const Offset(400, 300),
          paint: paint,
          userId: 'system',
          timestamp: DateTime.now(),
        ),
        DrawingPoint(
          point: const Offset(400, 300),
          paint: paint,
          userId: 'system',
          timestamp: DateTime.now(),
        ),
      ],
      id: 'brain_center',
      userId: 'system',
      tool: DrawingTool.circle,
      fillStyle: ShapeFillStyle.solid,
      fillColor: const Color(0xFF3B82F6).withOpacity(0.1),
    ),
  );

  return paths;
}
