// Timer Management Service
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'chat_message.dart';
import 'drawing_path.dart';
import 'drawing_point.dart';
import 'drawing_tool.dart';
import 'line_style.dart';
import 'shape_fill_style.dart';
import 'template.dart';
import 'user.dart';
import 'whiteboard_image.dart';
import 'whiteboard_painter.dart';

class TimerService {
  Timer? _autoSaveTimer;
  Timer? _activityTimer;
  Timer? _laserTimer;

  void startAutoSaveTimer(VoidCallback onAutoSave) {
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => onAutoSave(),
    );
  }

  void startUserActivityTimer(VoidCallback onActivityCheck) {
    _activityTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => onActivityCheck(),
    );
  }

  void startLaserCleanupTimer(VoidCallback onLaserCleanup) {
    _laserTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => onLaserCleanup(),
    );
  }

  void dispose() {
    _autoSaveTimer?.cancel();
    _activityTimer?.cancel();
    _laserTimer?.cancel();
  }
}

// Sync Service for real-time collaboration
class SyncService {
  final _syncController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get syncStream => _syncController.stream;

  void broadcastAction(String action, Map<String, dynamic> data) {
    _syncController.add({
      'action': action,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void dispose() {
    _syncController.close();
  }
}

// Drawing Service
class DrawingService {
  DrawingPath? _currentPath;
  Offset? _startPoint;

  DrawingPath? get currentPath => _currentPath;

  DrawingPath createNewPath({
    required Offset point,
    required String userId,
    required DrawingTool tool,
    required Color color,
    required double strokeWidth,
    required double opacity,
    required ShapeFillStyle fillStyle,
    required Color? fillColor,
    required LineStyle lineStyle,
    double pressure = 1.0,
    double tiltX = 0.0,
    double tiltY = 0.0,
  }) {
    final adjustedStrokeWidth = strokeWidth * pressure;
    final paint =
        Paint()
          ..color =
              tool == DrawingTool.eraser
                  ? Colors.white
                  : color.withOpacity(opacity)
          ..strokeWidth =
              tool == DrawingTool.highlighter
                  ? adjustedStrokeWidth * 3
                  : adjustedStrokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    if (tool == DrawingTool.highlighter) {
      paint.color = color.withOpacity(0.3 * opacity);
    }

    return DrawingPath(
      points: [
        DrawingPoint(
          point: point,
          paint: paint,
          userId: userId,
          timestamp: DateTime.now(),
          pressure: pressure,
          tiltX: tiltX,
          tiltY: tiltY,
        ),
      ],
      id: '${userId}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      tool: tool,
      fillStyle: fillStyle,
      fillColor: fillColor,
      lineStyle: lineStyle,
      opacity: opacity,
    );
  }

  DrawingPath updatePathWithNewPoint(
    DrawingPath path,
    Offset point,
    String userId, {
    double pressure = 1.0,
    double tiltX = 0.0,
    double tiltY = 0.0,
  }) {
    final newPoint = DrawingPoint(
      point: point,
      paint: path.points.first.paint,
      userId: userId,
      timestamp: DateTime.now(),
      pressure: pressure,
      tiltX: tiltX,
      tiltY: tiltY,
    );

    return path.copyWith(points: [...path.points, newPoint]);
  }

  DrawingPath updateShapePath(
    DrawingPath path,
    Offset point,
    String userId, {
    double pressure = 1.0,
    double tiltX = 0.0,
    double tiltY = 0.0,
  }) {
    final newPoint = DrawingPoint(
      point: point,
      paint: path.points.first.paint,
      userId: userId,
      timestamp: DateTime.now(),
      pressure: pressure,
      tiltX: tiltX,
      tiltY: tiltY,
    );

    return path.copyWith(points: [path.points.first, newPoint]);
  }

  void setCurrentPath(DrawingPath? path) {
    _currentPath = path;
  }

  void setStartPoint(Offset? point) {
    _startPoint = point;
  }

  void reset() {
    _currentPath = null;
    _startPoint = null;
  }
}

// Selection Service
class SelectionService {
  Set<String> _selectedPathIds = {};
  String? _selectedImageId;

  Set<String> get selectedPathIds => _selectedPathIds;
  String? get selectedImageId => _selectedImageId;

  void selectPath(String pathId, {bool addToSelection = false}) {
    if (addToSelection) {
      if (_selectedPathIds.contains(pathId)) {
        _selectedPathIds.remove(pathId);
      } else {
        _selectedPathIds.add(pathId);
      }
    } else {
      _selectedPathIds = {pathId};
    }
    _selectedImageId = null;
  }

  void selectImage(String? imageId) {
    _selectedImageId = imageId;
    _selectedPathIds.clear();
  }

  void selectAll(List<DrawingPath> paths) {
    _selectedPathIds = paths.map((p) => p.id).toSet();
    _selectedImageId = null;
  }

  void clearSelection() {
    _selectedPathIds.clear();
    _selectedImageId = null;
  }

  bool isPathSelected(String pathId) => _selectedPathIds.contains(pathId);
  bool get hasSelection =>
      _selectedPathIds.isNotEmpty || _selectedImageId != null;
}

// Export Service
class ExportService {
  Future<Uint8List?> exportToPNG({
    required List<DrawingPath> paths,
    required Map<String, WhiteboardImage> images,
    Uint8List? backgroundImage,
    Rect? area,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(area ?? Rect.fromLTWH(0, 0, 1920, 1080), bgPaint);

      if (backgroundImage != null) {
        final codec = await ui.instantiateImageCodec(backgroundImage);
        final frame = await codec.getNextFrame();
        canvas.drawImage(frame.image, Offset.zero, Paint());
      }

      final painter = WhiteboardPainter(
        paths: paths,
        activeUsers: {},
        zoom: 1.0,
        panOffset: Offset.zero,
        selectedPathIds: {},
        isGridVisible: false,
        images: images,
        selectedImageId: null,
        backgroundImage: null,
        laserPoints: [],
        showTouchIndicators: false,
      );
      painter.paint(canvas, area?.size ?? const Size(1920, 1080));
      final picture = recorder.endRecording();
      final img = await picture.toImage(
        area?.width.toInt() ?? 1920,
        area?.height.toInt() ?? 1080,
      );
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Export to PNG failed: $e');
      return null;
    }
  }

  String exportToSVG(List<DrawingPath> paths) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080">',
    );

    for (var path in paths) {
      if (path.points.isEmpty) continue;
      final color = path.points.first.paint.color;
      final strokeWidth = path.points.first.paint.strokeWidth;

      if (path.tool == DrawingTool.pen ||
          path.tool == DrawingTool.highlighter) {
        buffer.write('<path d="M');
        for (var i = 0; i < path.points.length; i++) {
          final point = path.points[i].point;
          buffer.write('${point.dx},${point.dy}');
          if (i < path.points.length - 1) buffer.write(' L');
        }
        buffer.writeln(
          '" fill="none" stroke="rgb(${color.red},${color.green},${color.blue})" stroke-width="$strokeWidth" opacity="${path.opacity}"/>',
        );
      }
    }

    buffer.writeln('</svg>');
    return buffer.toString();
  }

  String exportToJson({
    required List<DrawingPath> paths,
    required Map<String, WhiteboardImage> images,
    required Uint8List? backgroundImage,
    required List<ChatMessage> chatMessages,
  }) {
    final data = {
      'paths': paths.map((p) => p.toJson()).toList(),
      'images': images.map((key, value) => MapEntry(key, value.toJson())),
      'backgroundImage':
          backgroundImage != null ? base64Encode(backgroundImage!) : null,
      'chatMessages': chatMessages.map((m) => m.toJson()).toList(),
      'version': '4.0',
      'timestamp': DateTime.now().toIso8601String(),
    };
    return jsonEncode(data);
  }
}

// Image Service
class ImageService {
  final Map<String, WhiteboardImage> _images = {};
  String? _selectedImageId;

  Map<String, WhiteboardImage> get images => _images;
  String? get selectedImageId => _selectedImageId;

  void addImage(Uint8List imageData, Offset position, String userId) {
    final imageId = '${userId}_img_${DateTime.now().millisecondsSinceEpoch}';
    final image = WhiteboardImage(
      id: imageId,
      imageData: imageData,
      position: position,
      size: const Size(200, 200),
    );
    _images[imageId] = image;
    _selectedImageId = imageId;
  }

  void updateImagePosition(String imageId, Offset position) {
    if (_images.containsKey(imageId)) {
      _images[imageId] = _images[imageId]!.copyWith(position: position);
    }
  }

  void updateImageSize(String imageId, Size size) {
    if (_images.containsKey(imageId)) {
      _images[imageId] = _images[imageId]!.copyWith(size: size);
    }
  }

  void rotateImage(String imageId, double rotation) {
    if (_images.containsKey(imageId)) {
      _images[imageId] = _images[imageId]!.copyWith(rotation: rotation);
    }
  }

  void deleteImage(String imageId) {
    _images.remove(imageId);
    if (_selectedImageId == imageId) {
      _selectedImageId = null;
    }
  }

  void selectImage(String? imageId) {
    _selectedImageId = imageId;
  }

  void clearImages() {
    _images.clear();
    _selectedImageId = null;
  }
}

// User Service
class UserService {
  final Map<String, User> _activeUsers = {};

  Map<String, User> get activeUsers => _activeUsers;

  void addUser(User user) {
    _activeUsers[user.id] = user;
  }

  void removeUser(String userId) {
    _activeUsers.remove(userId);
  }

  void updateUserCursor(String userId, Offset position) {
    if (_activeUsers.containsKey(userId)) {
      _activeUsers[userId] = _activeUsers[userId]!.copyWith(
        cursorPosition: position,
        lastActivity: DateTime.now(),
      );
    }
  }

  void updateUserActivity(String userId) {
    if (_activeUsers.containsKey(userId)) {
      _activeUsers[userId] = _activeUsers[userId]!.copyWith(
        lastActivity: DateTime.now(),
        isActive: true,
      );
    }
  }

  void deactivateInactiveUsers() {
    final now = DateTime.now();
    for (var entry in _activeUsers.entries) {
      final diff = now.difference(entry.value.lastActivity);
      if (diff.inMinutes > 5 && entry.value.isActive) {
        _activeUsers[entry.key] = entry.value.copyWith(isActive: false);
      }
    }
  }

  User? getUser(String userId) => _activeUsers[userId];
}

// Chat Service
class ChatService {
  final List<ChatMessage> _chatMessages = [];
  bool _isChatOpen = false;

  List<ChatMessage> get chatMessages => _chatMessages;
  bool get isChatOpen => _isChatOpen;

  void addMessage(
    String message,
    String userId,
    String userName,
    Color userColor,
  ) {
    final chatMessage = ChatMessage(
      id: '${userId}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      message: message,
      timestamp: DateTime.now(),
      userColor: userColor,
    );
    _chatMessages.add(chatMessage);
  }

  void toggleChat() {
    _isChatOpen = !_isChatOpen;
  }

  void clearChat() {
    _chatMessages.clear();
  }

  List<ChatMessage> getRecentMessages(int count) {
    return _chatMessages.reversed.take(count).toList().reversed.toList();
  }
}

// Template Service
class TemplateService {
  List<DrawingPath> applyTemplate(Template template, String userId) {
    return template.paths.map((path) {
      final newPoints =
          path.points
              .map(
                (p) => DrawingPoint(
                  point: p.point,
                  paint: p.paint,
                  userId: userId,
                  timestamp: DateTime.now(),
                  pressure: p.pressure,
                  tiltX: p.tiltX,
                  tiltY: p.tiltY,
                ),
              )
              .toList();

      return DrawingPath(
        points: newPoints,
        id:
            '${userId}_${DateTime.now().millisecondsSinceEpoch}_${template.paths.indexOf(path)}',
        userId: userId,
        tool: path.tool,
        text: path.text,
        fillStyle: path.fillStyle,
        fillColor: path.fillColor,
        lineStyle: path.lineStyle,
        opacity: path.opacity,
        stickyNoteColor: path.stickyNoteColor,
      );
    }).toList();
  }

  List<DrawingPath> createGridTemplate(String userId) {
    final paths = <DrawingPath>[];
    final paint =
        Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Create grid lines
    for (var i = 0; i <= 3; i++) {
      final x = 100.0 + i * 200.0;
      paths.add(
        DrawingPath(
          points: [
            DrawingPoint(
              point: Offset(x, 100),
              paint: paint,
              userId: userId,
              timestamp: DateTime.now(),
            ),
            DrawingPoint(
              point: Offset(x, 700),
              paint: paint,
              userId: userId,
              timestamp: DateTime.now(),
            ),
          ],
          id: 'grid_v_$i',
          userId: userId,
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
              userId: userId,
              timestamp: DateTime.now(),
            ),
            DrawingPoint(
              point: Offset(700, y),
              paint: paint,
              userId: userId,
              timestamp: DateTime.now(),
            ),
          ],
          id: 'grid_h_$i',
          userId: userId,
          tool: DrawingTool.line,
        ),
      );
    }

    return paths;
  }
}

// History Service for Undo/Redo
class HistoryService {
  final List<DrawingPath> _paths = [];
  final List<DrawingPath> _redoStack = [];
  final List<DrawingPath> _clipboard = [];

  List<DrawingPath> get paths => _paths;
  List<DrawingPath> get redoStack => _redoStack;
  List<DrawingPath> get clipboard => _clipboard;

  void addPath(DrawingPath path) {
    _paths.add(path);
    _redoStack.clear();
  }

  void updatePath(DrawingPath path) {
    final index = _paths.indexWhere((p) => p.id == path.id);
    if (index != -1) {
      _paths[index] = path;
    }
  }

  void removePath(String pathId) {
    _paths.removeWhere((p) => p.id == pathId);
    _redoStack.clear();
  }

  void undo() {
    if (_paths.isNotEmpty) {
      final lastPath = _paths.removeLast();
      _redoStack.add(lastPath);
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      final redoPath = _redoStack.removeLast();
      _paths.add(redoPath);
    }
  }

  void clear() {
    _paths.clear();
    _redoStack.clear();
  }

  void copyToClipboard(List<DrawingPath> paths) {
    _clipboard.clear();
    _clipboard.addAll(paths);
  }

  List<DrawingPath> pasteFromClipboard(String userId, Offset offset) {
    final newPaths = <DrawingPath>[];
    for (var path in _clipboard) {
      final newPoints =
          path.points
              .map(
                (p) => DrawingPoint(
                  point: p.point + offset,
                  paint: p.paint,
                  userId: userId,
                  timestamp: DateTime.now(),
                  pressure: p.pressure,
                  tiltX: p.tiltX,
                  tiltY: p.tiltY,
                ),
              )
              .toList();

      final newPath = DrawingPath(
        points: newPoints,
        id:
            '${userId}_${DateTime.now().millisecondsSinceEpoch}_${newPaths.length}',
        userId: userId,
        tool: path.tool,
        text: path.text,
        fillStyle: path.fillStyle,
        fillColor: path.fillColor,
        lineStyle: path.lineStyle,
        opacity: path.opacity,
        stickyNoteColor: path.stickyNoteColor,
      );
      newPaths.add(newPath);
    }
    return newPaths;
  }
}
