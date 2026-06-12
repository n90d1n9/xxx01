import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';

import 'whiteboard_painter.dart';
import 'drawing_tool.dart';
import 'shape_fill_style.dart';
import 'line_style.dart';
import 'platform_type.dart';
import 'drawing_point.dart';
import 'laser_point.dart';
import 'whiteboard_image.dart';
import 'drawing_path.dart';
import 'user.dart';
import 'chat_message.dart';
import 'template.dart';
import 'whiteboard_state.dart';

class WhiteboardNotifier extends StateNotifier<WhiteboardState> {
  WhiteboardNotifier() : super(WhiteboardState()) {
    _startAutoSaveTimer();
    _startUserActivityCheck();
    _startLaserCleanup();
    _detectPlatform();
  }
  DrawingPath? _currentPath;
  Offset? _startPoint;
  Timer? _autoSaveTimer;
  Timer? _activityTimer;
  Timer? _laserTimer;
  final _syncController = StreamController<Map<String, dynamic>>.broadcast();
  Offset? _lastTouchPosition;
  DateTime? _lastTouchTime;
  double _initialPinchDistance = 0;
  double _initialZoom = 1.0;
  Stream<Map<String, dynamic>> get syncStream => _syncController.stream;
  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _activityTimer?.cancel();
    _laserTimer?.cancel();
    _syncController.close();
    super.dispose();
  }

  void _detectPlatform() {
    state = state.copyWith(platformType: PlatformType.desktop);
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (state.isAutoSaveEnabled && state.paths.isNotEmpty) {
        _autoSave();
      }
    });
  }

  void _startUserActivityCheck() {
    _activityTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkUserActivity();
    });
  }

  void _startLaserCleanup() {
    _laserTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _cleanupLaserPoints();
    });
  }

  void _cleanupLaserPoints() {
    final validPoints = state.laserPoints.where((p) => !p.isExpired).toList();
    if (validPoints.length != state.laserPoints.length) {
      state = state.copyWith(laserPoints: validPoints);
    }
  }

  void _checkUserActivity() {
    final now = DateTime.now();
    final users = Map<String, User>.from(state.activeUsers);
    var updated = false;
    for (var entry in users.entries) {
      final diff = now.difference(entry.value.lastActivity);
      if (diff.inMinutes > 5 && entry.value.isActive) {
        users[entry.key] = entry.value.copyWith(isActive: false);
        updated = true;
      }
    }
    if (updated) {
      state = state.copyWith(activeUsers: users);
    }
  }

  void handlePinchStart(ScaleStartDetails details) {
    _initialPinchDistance = 0;
    _initialZoom = state.zoom;
  }

  void handlePinchUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount == 2) {
      final newZoom = (_initialZoom * details.scale).clamp(0.1, 5.0);
      setZoom(newZoom);
    } else if (details.pointerCount == 1 && state.isHandMode) {
      final delta = details.focalPointDelta;
      setPanOffset(state.panOffset + delta);
    }
  }

  void handlePinchEnd(ScaleEndDetails details) {
    _initialPinchDistance = 0;
  }

  void handleDoubleTap(Offset position) {
    if (state.zoom != 1.0) {
      resetView();
    }
  }

  void handleLongPress(Offset position) {
    debugPrint('Long press at $position');
  }

  bool shouldRejectTouch(Offset position, double pressure) {
    if (!state.isPalmRejectionEnabled) return false;
    if (pressure < 0.1) {
      return true;
    }
    return false;
  }

  void addLaserPoint(Offset point) {
    final laserPoint = LaserPoint(point: point, timestamp: DateTime.now());
    state = state.copyWith(laserPoints: [...state.laserPoints, laserPoint]);
  }

  void clearLaserPoints() {
    state = state.copyWith(laserPoints: []);
  }

  void togglePalmRejection() {
    state = state.copyWith(
      isPalmRejectionEnabled: !state.isPalmRejectionEnabled,
    );
  }

  void toggleTouchIndicators() {
    state = state.copyWith(showTouchIndicators: !state.showTouchIndicators);
  }

  void setTouchSensitivity(double sensitivity) {
    state = state.copyWith(touchSensitivity: sensitivity.clamp(0.5, 2.0));
  }

  void addImage(Uint8List imageData, Offset position, String userId) {
    final imageId = '${userId}_img_${DateTime.now().millisecondsSinceEpoch}';
    final image = WhiteboardImage(
      id: imageId,
      imageData: imageData,
      position: position,
      size: const Size(200, 200),
    );
    final images = Map<String, WhiteboardImage>.from(state.images);
    images[imageId] = image;
    state = state.copyWith(images: images, selectedImageId: imageId);
    _broadcastAction('addImage', {'imageId': imageId});
    _autoSave();
  }

  void updateImagePosition(String imageId, Offset position) {
    final images = Map<String, WhiteboardImage>.from(state.images);
    if (images.containsKey(imageId)) {
      images[imageId] = images[imageId]!.copyWith(position: position);
      state = state.copyWith(images: images);
    }
  }

  void updateImageSize(String imageId, Size size) {
    final images = Map<String, WhiteboardImage>.from(state.images);
    if (images.containsKey(imageId)) {
      images[imageId] = images[imageId]!.copyWith(size: size);
      state = state.copyWith(images: images);
    }
  }

  void rotateImage(String imageId, double rotation) {
    final images = Map<String, WhiteboardImage>.from(state.images);
    if (images.containsKey(imageId)) {
      images[imageId] = images[imageId]!.copyWith(rotation: rotation);
      state = state.copyWith(images: images);
    }
  }

  void deleteImage(String imageId) {
    final images = Map<String, WhiteboardImage>.from(state.images);
    images.remove(imageId);
    state = state.copyWith(images: images, clearImageSelection: true);
    _autoSave();
  }

  void selectImage(String? imageId) {
    state = state.copyWith(selectedImageId: imageId, clearSelection: true);
  }

  void setBackgroundImage(Uint8List? imageData) {
    state = state.copyWith(
      backgroundImage: imageData,
      clearBackground: imageData == null,
    );
    _autoSave();
  }

  void toggleMinimap() {
    state = state.copyWith(showMinimap: !state.showMinimap);
  }

  Future<Uint8List?> exportToPNG({Rect? area}) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(area ?? Rect.fromLTWH(0, 0, 1920, 1080), bgPaint);
      if (state.backgroundImage != null) {
        final codec = await ui.instantiateImageCodec(state.backgroundImage!);
        final frame = await codec.getNextFrame();
        canvas.drawImage(frame.image, Offset.zero, Paint());
      }
      final painter = WhiteboardPainter(
        paths: state.paths,
        activeUsers: {},
        zoom: 1.0,
        panOffset: Offset.zero,
        selectedPathIds: {},
        isGridVisible: false,
        images: state.images,
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

  String exportToSVG() {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080">',
    );
    for (var path in state.paths) {
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

  Future<void> handleImagePaste(Uint8List imageData, String userId) async {
    addImage(imageData, Offset(100, 100), userId);
  }

  void startDrawing(
    Offset point,
    String userId, {
    double pressure = 1.0,
    double tiltX = 0.0,
    double tiltY = 0.0,
  }) {
    if (state.isHandMode) return;
    if (shouldRejectTouch(point, pressure)) {
      debugPrint('Touch rejected: palm detection');
      return;
    }
    if (state.currentTool == DrawingTool.laser) {
      addLaserPoint(point);
      return;
    }
    _startPoint = point;
    final adjustedStrokeWidth =
        state.strokeWidth * pressure * state.touchSensitivity;
    final paint =
        Paint()
          ..color =
              state.currentTool == DrawingTool.eraser
                  ? Colors.white
                  : state.currentColor.withOpacity(state.currentOpacity)
          ..strokeWidth =
              state.currentTool == DrawingTool.highlighter
                  ? adjustedStrokeWidth * 3
                  : adjustedStrokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
    if (state.currentTool == DrawingTool.highlighter) {
      paint.color = state.currentColor.withOpacity(0.3 * state.currentOpacity);
    }
    _currentPath = DrawingPath(
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
      tool: state.currentTool,
      fillStyle: state.currentFillStyle,
      fillColor: state.currentFillColor,
      lineStyle: state.currentLineStyle,
      opacity: state.currentOpacity,
    );
    state = state.copyWith(
      redoStack: [],
      clearSelection: true,
      clearImageSelection: true,
    );
    _broadcastAction('startDrawing', {'path': _currentPath!.toJson()});
  }

  void updateDrawing(
    Offset point,
    String userId, {
    double pressure = 1.0,
    double tiltX = 0.0,
    double tiltY = 0.0,
  }) {
    if (state.currentTool == DrawingTool.laser) {
      addLaserPoint(point);
      return;
    }
    if (_currentPath == null || state.isHandMode) return;
    final paint = _currentPath!.points.first.paint;
    if (state.currentTool == DrawingTool.pen ||
        state.currentTool == DrawingTool.eraser ||
        state.currentTool == DrawingTool.highlighter) {
      _currentPath = DrawingPath(
        points: [
          ..._currentPath!.points,
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
        id: _currentPath!.id,
        userId: userId,
        tool: _currentPath!.tool,
        fillStyle: _currentPath!.fillStyle,
        fillColor: _currentPath!.fillColor,
        lineStyle: _currentPath!.lineStyle,
        opacity: _currentPath!.opacity,
      );
      state = state.copyWith(
        paths: [
          ...state.paths.where((p) => p.id != _currentPath!.id),
          _currentPath!,
        ],
      );
    } else {
      _currentPath = DrawingPath(
        points: [
          _currentPath!.points.first,
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
        id: _currentPath!.id,
        userId: userId,
        tool: _currentPath!.tool,
        fillStyle: _currentPath!.fillStyle,
        fillColor: _currentPath!.fillColor,
        lineStyle: _currentPath!.lineStyle,
        opacity: _currentPath!.opacity,
      );
      state = state.copyWith(
        paths: [
          ...state.paths.where((p) => p.id != _currentPath!.id),
          _currentPath!,
        ],
      );
    }
    _broadcastAction('updateDrawing', {'path': _currentPath!.toJson()});
  }

  void endDrawing() {
    if (state.currentTool == DrawingTool.laser) {
      clearLaserPoints();
      return;
    }
    if (_currentPath != null) {
      state = state.copyWith(
        paths: [
          ...state.paths.where((p) => p.id != _currentPath!.id),
          _currentPath!,
        ],
      );
      _broadcastAction('endDrawing', {'pathId': _currentPath!.id});
      _currentPath = null;
      _startPoint = null;
      _autoSave();
    }
  }

  void addTextPath(Offset position, String text, String userId) {
    final paint =
        Paint()
          ..color = state.currentColor.withOpacity(state.currentOpacity)
          ..strokeWidth = state.strokeWidth;
    final textPath = DrawingPath(
      points: [
        DrawingPoint(
          point: position,
          paint: paint,
          userId: userId,
          timestamp: DateTime.now(),
        ),
      ],
      id: '${userId}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      tool: DrawingTool.text,
      text: text,
      opacity: state.currentOpacity,
    );
    state = state.copyWith(paths: [...state.paths, textPath], redoStack: []);
    _broadcastAction('addText', {'path': textPath.toJson()});
    _autoSave();
  }

  void addStickyNote(Offset position, String text, Color color, String userId) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2;
    final stickyPath = DrawingPath(
      points: [
        DrawingPoint(
          point: position,
          paint: paint,
          userId: userId,
          timestamp: DateTime.now(),
        ),
        DrawingPoint(
          point: position + const Offset(150, 150),
          paint: paint,
          userId: userId,
          timestamp: DateTime.now(),
        ),
      ],
      id: '${userId}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      tool: DrawingTool.stickyNote,
      text: text,
      stickyNoteColor: color,
      opacity: 1.0,
    );
    state = state.copyWith(paths: [...state.paths, stickyPath], redoStack: []);
    _broadcastAction('addStickyNote', {'path': stickyPath.toJson()});
    _autoSave();
  }

  void setTool(DrawingTool tool) {
    state = state.copyWith(currentTool: tool, isHandMode: false);
  }

  void setColor(Color color) {
    state = state.copyWith(currentColor: color);
  }

  void setStrokeWidth(double width) {
    state = state.copyWith(strokeWidth: width);
  }

  void setFillStyle(ShapeFillStyle fillStyle) {
    state = state.copyWith(currentFillStyle: fillStyle);
  }

  void setFillColor(Color? color) {
    state = state.copyWith(
      currentFillColor: color,
      clearFillColor: color == null,
    );
  }

  void setLineStyle(LineStyle lineStyle) {
    state = state.copyWith(currentLineStyle: lineStyle);
  }

  void setOpacity(double opacity) {
    state = state.copyWith(currentOpacity: opacity);
  }

  void toggleHandMode() {
    state = state.copyWith(isHandMode: !state.isHandMode);
  }

  void toggleGrid() {
    state = state.copyWith(isGridVisible: !state.isGridVisible);
  }

  void toggleChat() {
    state = state.copyWith(isChatOpen: !state.isChatOpen);
  }

  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom.clamp(0.1, 5.0));
    _broadcastAction('zoom', {'zoom': state.zoom});
  }

  void setPanOffset(Offset offset) {
    state = state.copyWith(panOffset: offset);
    _broadcastAction('pan', {
      'offset': {'dx': offset.dx, 'dy': offset.dy},
    });
  }

  void resetView() {
    state = state.copyWith(zoom: 1.0, panOffset: Offset.zero);
    _broadcastAction('resetView', {});
  }

  void clearBoard() {
    state = state.copyWith(
      paths: [],
      redoStack: [],
      images: {},
      clearSelection: true,
      clearImageSelection: true,
    );
    _broadcastAction('clear', {});
    _autoSave();
  }

  void undo() {
    if (state.paths.isNotEmpty) {
      final lastPath = state.paths.last;
      state = state.copyWith(
        paths: state.paths.sublist(0, state.paths.length - 1),
        redoStack: [...state.redoStack, lastPath],
      );
      _broadcastAction('undo', {'pathId': lastPath.id});
      _autoSave();
    }
  }

  void redo() {
    if (state.redoStack.isNotEmpty) {
      final redoPath = state.redoStack.last;
      state = state.copyWith(
        paths: [...state.paths, redoPath],
        redoStack: state.redoStack.sublist(0, state.redoStack.length - 1),
      );
      _broadcastAction('redo', {'pathId': redoPath.id});
      _autoSave();
    }
  }

  void selectPath(String pathId, {bool addToSelection = false}) {
    if (addToSelection) {
      final newSelection = Set<String>.from(state.selectedPathIds);
      if (newSelection.contains(pathId)) {
        newSelection.remove(pathId);
      } else {
        newSelection.add(pathId);
      }
      state = state.copyWith(
        selectedPathIds: newSelection,
        clearImageSelection: true,
      );
    } else {
      state = state.copyWith(
        selectedPathIds: {pathId},
        clearImageSelection: true,
      );
    }
  }

  void clearSelection() {
    state = state.copyWith(clearSelection: true, clearImageSelection: true);
  }

  void selectAll() {
    state = state.copyWith(
      selectedPathIds: state.paths.map((p) => p.id).toSet(),
      clearImageSelection: true,
    );
  }

  void deleteSelected() {
    if (state.selectedPathIds.isEmpty) return;
    final deletedIds = state.selectedPathIds.toList();
    state = state.copyWith(
      paths:
          state.paths
              .where((p) => !state.selectedPathIds.contains(p.id))
              .toList(),
      clearSelection: true,
      redoStack: [],
    );
    _broadcastAction('deleteMultiple', {'pathIds': deletedIds});
    _autoSave();
  }

  void deletePath(String pathId) {
    state = state.copyWith(
      paths: state.paths.where((p) => p.id != pathId).toList(),
      clearSelection: true,
      redoStack: [],
    );
    _broadcastAction('delete', {'pathId': pathId});
    _autoSave();
  }

  void lockSelected() {
    if (state.selectedPathIds.isEmpty) return;
    final paths =
        state.paths.map((p) {
          if (state.selectedPathIds.contains(p.id)) {
            return p.copyWith(isLocked: !p.isLocked);
          }
          return p;
        }).toList();
    state = state.copyWith(paths: paths);
    _broadcastAction('lockMultiple', {
      'pathIds': state.selectedPathIds.toList(),
    });
    _autoSave();
  }

  void duplicateSelected() {
    if (state.selectedPathIds.isEmpty) return;
    final newPaths = <DrawingPath>[];
    final newSelectedIds = <String>{};
    for (var path in state.paths) {
      if (state.selectedPathIds.contains(path.id)) {
        final offset = const Offset(20, 20);
        final newPoints =
            path.points
                .map(
                  (p) => DrawingPoint(
                    point: p.point + offset,
                    paint: p.paint,
                    userId: p.userId,
                    timestamp: DateTime.now(),
                    pressure: p.pressure,
                    tiltX: p.tiltX,
                    tiltY: p.tiltY,
                  ),
                )
                .toList();
        final newId =
            '${path.userId}_${DateTime.now().millisecondsSinceEpoch}_${newPaths.length}';
        final newPath = DrawingPath(
          points: newPoints,
          id: newId,
          userId: path.userId,
          tool: path.tool,
          text: path.text,
          fillStyle: path.fillStyle,
          fillColor: path.fillColor,
          lineStyle: path.lineStyle,
          opacity: path.opacity,
          stickyNoteColor: path.stickyNoteColor,
        );
        newPaths.add(newPath);
        newSelectedIds.add(newId);
      }
    }
    state = state.copyWith(
      paths: [...state.paths, ...newPaths],
      selectedPathIds: newSelectedIds,
      redoStack: [],
    );
    _broadcastAction('duplicate', {
      'paths': newPaths.map((p) => p.toJson()).toList(),
    });
    _autoSave();
  }

  void copySelected() {
    if (state.selectedPathIds.isEmpty) return;
    final clipboard =
        state.paths.where((p) => state.selectedPathIds.contains(p.id)).toList();
    state = state.copyWith(clipboard: clipboard);
  }

  void paste(String userId) {
    if (state.clipboard.isEmpty) return;
    final newPaths = <DrawingPath>[];
    final newSelectedIds = <String>{};
    final offset = const Offset(30, 30);
    for (var path in state.clipboard) {
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
      final newId =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}_${newPaths.length}';
      final newPath = DrawingPath(
        points: newPoints,
        id: newId,
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
      newSelectedIds.add(newId);
    }
    state = state.copyWith(
      paths: [...state.paths, ...newPaths],
      selectedPathIds: newSelectedIds,
      redoStack: [],
    );
    _broadcastAction('paste', {
      'paths': newPaths.map((p) => p.toJson()).toList(),
    });
    _autoSave();
  }

  void bringToFront() {
    if (state.selectedPathIds.isEmpty) return;
    final selectedPaths = <DrawingPath>[];
    final otherPaths = <DrawingPath>[];
    for (var path in state.paths) {
      if (state.selectedPathIds.contains(path.id)) {
        selectedPaths.add(path);
      } else {
        otherPaths.add(path);
      }
    }
    state = state.copyWith(paths: [...otherPaths, ...selectedPaths]);
    _broadcastAction('bringToFront', {
      'pathIds': state.selectedPathIds.toList(),
    });
    _autoSave();
  }

  void sendToBack() {
    if (state.selectedPathIds.isEmpty) return;
    final selectedPaths = <DrawingPath>[];
    final otherPaths = <DrawingPath>[];
    for (var path in state.paths) {
      if (state.selectedPathIds.contains(path.id)) {
        selectedPaths.add(path);
      } else {
        otherPaths.add(path);
      }
    }
    state = state.copyWith(paths: [...selectedPaths, ...otherPaths]);
    _broadcastAction('sendToBack', {'pathIds': state.selectedPathIds.toList()});
    _autoSave();
  }

  void updateUserCursor(String userId, Offset position) {
    final users = Map<String, User>.from(state.activeUsers);
    if (users.containsKey(userId)) {
      users[userId] = users[userId]!.copyWith(
        cursorPosition: position,
        lastActivity: DateTime.now(),
      );
      state = state.copyWith(activeUsers: users);
      _broadcastAction('cursorMove', {
        'userId': userId,
        'position': {'dx': position.dx, 'dy': position.dy},
      });
    }
  }

  void addUser(User user) {
    final users = Map<String, User>.from(state.activeUsers);
    users[user.id] = user;
    state = state.copyWith(activeUsers: users);
    _broadcastAction('userJoined', {'user': user.toJson()});
  }

  void removeUser(String userId) {
    final users = Map<String, User>.from(state.activeUsers);
    users.remove(userId);
    state = state.copyWith(activeUsers: users);
    _broadcastAction('userLeft', {'userId': userId});
  }

  void addChatMessage(
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
    state = state.copyWith(chatMessages: [...state.chatMessages, chatMessage]);
    _broadcastAction('chatMessage', {'message': chatMessage.toJson()});
  }

  void toggleFollowMode(String? userId) {
    if (state.isFollowMode && state.followingUserId == userId) {
      state = state.copyWith(isFollowMode: false, clearFollowing: true);
    } else {
      state = state.copyWith(isFollowMode: true, followingUserId: userId);
    }
  }

  void followUser(User user) {
    if (user.cursorPosition != null) {
      final center = Offset(
        user.cursorPosition!.dx - (400 / state.zoom),
        user.cursorPosition!.dy - (300 / state.zoom),
      );
      state = state.copyWith(panOffset: center * state.zoom);
    }
  }

  void startRecording() {
    state = state.copyWith(
      isRecording: true,
      recordingStartTime: DateTime.now(),
    );
    _broadcastAction('startRecording', {});
  }

  void stopRecording() {
    state = state.copyWith(isRecording: false, clearRecording: true);
    _broadcastAction('stopRecording', {});
  }

  void applyTemplate(Template template, String userId) {
    final newPaths =
        template.paths.map((path) {
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
    state = state.copyWith(paths: [...state.paths, ...newPaths], redoStack: []);
    _broadcastAction('applyTemplate', {'templateId': template.id});
    _autoSave();
  }

  void _autoSave() {
    if (state.isAutoSaveEnabled) {
      state = state.copyWith(lastSaveTime: DateTime.now());
      debugPrint('Auto-saved at ${state.lastSaveTime}');
    }
  }

  void _broadcastAction(String action, Map<String, dynamic> data) {
    _syncController.add({
      'action': action,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void handleRemoteAction(Map<String, dynamic> syncData) {
    final action = syncData['action'];
    final data = syncData['data'];
    switch (action) {
      case 'startDrawing':
      case 'updateDrawing':
      case 'endDrawing':
        final path = DrawingPath.fromJson(data['path']);
        final existingIndex = state.paths.indexWhere((p) => p.id == path.id);
        if (existingIndex != -1) {
          final newPaths = List<DrawingPath>.from(state.paths);
          newPaths[existingIndex] = path;
          state = state.copyWith(paths: newPaths);
        } else {
          state = state.copyWith(paths: [...state.paths, path]);
        }
        break;
      case 'delete':
        state = state.copyWith(
          paths: state.paths.where((p) => p.id != data['pathId']).toList(),
        );
        break;
      case 'clear':
        state = state.copyWith(paths: [], images: {});
        break;
      case 'userJoined':
        final user = User.fromJson(data['user']);
        final users = Map<String, User>.from(state.activeUsers);
        users[user.id] = user;
        state = state.copyWith(activeUsers: users);
        break;
      case 'userLeft':
        final users = Map<String, User>.from(state.activeUsers);
        users.remove(data['userId']);
        state = state.copyWith(activeUsers: users);
        break;
      case 'cursorMove':
        final userId = data['userId'];
        final position = Offset(data['position']['dx'], data['position']['dy']);
        updateUserCursor(userId, position);
        break;
      case 'chatMessage':
        final message = ChatMessage.fromJson(data['message']);
        state = state.copyWith(chatMessages: [...state.chatMessages, message]);
        break;
    }
  }

  String exportToJson() {
    final data = {
      'paths': state.paths.map((p) => p.toJson()).toList(),
      'images': state.images.map((key, value) => MapEntry(key, value.toJson())),
      'backgroundImage':
          state.backgroundImage != null
              ? base64Encode(state.backgroundImage!)
              : null,
      'chatMessages': state.chatMessages.map((m) => m.toJson()).toList(),
      'version': '4.0',
      'timestamp': DateTime.now().toIso8601String(),
    };
    return jsonEncode(data);
  }

  void importFromJson(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr);
      final paths =
          (data['paths'] as List).map((p) => DrawingPath.fromJson(p)).toList();
      final images = <String, WhiteboardImage>{};
      if (data['images'] != null) {
        (data['images'] as Map<String, dynamic>).forEach((key, value) {
          images[key] = WhiteboardImage.fromJson(value);
        });
      }
      final backgroundImage =
          data['backgroundImage'] != null
              ? base64Decode(data['backgroundImage'])
              : null;
      state = state.copyWith(
        paths: paths,
        images: images,
        backgroundImage: backgroundImage,
        redoStack: [],
        clearSelection: true,
        clearImageSelection: true,
      );
      _autoSave();
    } catch (e) {
      debugPrint('Import error: $e');
    }
  }
}
