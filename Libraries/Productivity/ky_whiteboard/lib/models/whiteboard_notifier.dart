import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';

import '../services/performance_history_service.dart';
import 'chat_message.dart';
import 'drawing_point.dart';
import 'service.dart';
import 'drawing_tool.dart';
import 'platform_type.dart';
import 'laser_point.dart';
import 'drawing_path.dart';
import 'template.dart';
import 'user.dart';
import 'whiteboard_state.dart';

class WhiteboardNotifier extends StateNotifier<WhiteboardState> {
  // KEEP ALL YOUR EXISTING SERVICES
  final TimerService _timerService = TimerService();
  final SyncService _syncService = SyncService();
  final DrawingService _drawingService = DrawingService();
  final SelectionService _selectionService = SelectionService();
  final ExportService _exportService = ExportService();
  final ImageService _imageService = ImageService();
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();
  final TemplateService _templateService = TemplateService();
  final PerformanceHistoryService _historyService = PerformanceHistoryService();

  // Fix: Remove batch updating that causes shaking
  void startDrawing(Offset point, String userId, {double pressure = 1.0}) {
    if (state.isHandMode) return;

    if (state.currentTool == DrawingTool.laser) {
      final laserPoint = LaserPoint(point: point, timestamp: DateTime.now());
      state = state.copyWith(laserPoints: [...state.laserPoints, laserPoint]);
      return;
    }

    final paint = _createPaintForTool(
      state.currentTool,
      state.currentColor,
      state.strokeWidth,
      state.currentOpacity,
      pressure,
    );

    _currentPath = DrawingPath(
      points: [
        DrawingPoint(
          point: point,
          paint: paint,
          userId: userId,
          timestamp: DateTime.now(),
          pressure: pressure,
        ),
      ],
      id:
          '${userId}_${DateTime.now().millisecondsSinceEpoch}_${state.paths.length}',
      userId: userId,
      tool: state.currentTool,
      fillStyle: state.currentFillStyle,
      fillColor: state.currentFillColor,
      lineStyle: state.currentLineStyle,
      opacity: state.currentOpacity,
      stickyNoteColor:
          state.currentTool == DrawingTool.stickyNote
              ? (state.currentFillColor ?? const Color(0xFFFFF9C4))
              : null,
    );

    // FIX: Use history service but sync immediately (no batch)
    _historyService.addPath(_currentPath!);
    _selectionService.clearSelection();
    _syncState(force: true); // Force immediate sync
  }

  void updateDrawing(Offset point, String userId, {double pressure = 1.0}) {
    if (state.currentTool == DrawingTool.laser) {
      final laserPoint = LaserPoint(point: point, timestamp: DateTime.now());
      state = state.copyWith(laserPoints: [...state.laserPoints, laserPoint]);
      return;
    }

    if (_currentPath == null || state.isHandMode) return;

    final newPoint = DrawingPoint(
      point: point,
      paint: _currentPath!.points.first.paint,
      userId: userId,
      timestamp: DateTime.now(),
      pressure: pressure,
    );

    final updatedPath = _currentPath!.copyWith(
      points: [..._currentPath!.points, newPoint],
    );

    _currentPath = updatedPath;

    // FIX: Update in history service and sync immediately
    _historyService.updatePath(updatedPath);
    _syncState(force: true); // Force immediate sync
  }

  void endDrawing() {
    if (state.currentTool == DrawingTool.laser) {
      // Don't clear immediately - let cleanup timer handle it
      return;
    }
    _currentPath = null;
  }

  // KEEP ALL YOUR EXISTING METHODS - selection, images, users, chat, templates, etc.
  void selectPath(String pathId, {bool addToSelection = false}) {
    _selectionService.selectPath(pathId, addToSelection: addToSelection);
    _syncState();
  }

  void selectImage(String? imageId) {
    _imageService.selectImage(imageId);
    _syncState();
  }

  void addImage(Uint8List imageData, Offset position, String userId) {
    _imageService.addImage(imageData, position, userId);
    _syncState();
    _syncService.broadcastAction('addImage', {
      'imageId': _imageService.selectedImageId,
    });
    _autoSave();
  }

  void addUser(User user) {
    _userService.addUser(user);
    _syncState();
    _syncService.broadcastAction('userJoined', {'user': user.toJson()});
  }

  void addChatMessage(
    String message,
    String userId,
    String userName,
    Color userColor,
  ) {
    _chatService.addMessage(message, userId, userName, userColor);
    _syncState();
    _syncService.broadcastAction('chatMessage', {
      'message': _chatService.chatMessages.last.toJson(),
    });
  }

  void applyTemplate(Template template, String userId) {
    final newPaths = _templateService.applyTemplate(template, userId);
    for (var path in newPaths) {
      _historyService.addPath(path);
    }
    _syncState();
    _syncService.broadcastAction('applyTemplate', {'templateId': template.id});
    _autoSave();
  }

  // Batch state updates to reduce rebuilds
  bool _isBatchUpdating = false;
  bool _needsStateSync = false;
  double _initialZoom = 1.0;

  Offset _initialPanOffset = Offset.zero;

  DrawingPath? _currentPath;
  Offset? _lastPoint;
  Timer? _laserCleanupTimer;

  WhiteboardNotifier() : super(WhiteboardState()) {
    _startLaserCleanup();
  }

  void handlePinchStart(ScaleStartDetails details) {
    _initialZoom = state.zoom;
    _initialPanOffset = state.panOffset;
  }

  void handlePinchUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount == 2) {
      // Zoom
      final newZoom = (_initialZoom * details.scale).clamp(0.1, 5.0);
      setZoom(newZoom);
    } else if (details.pointerCount == 1) {
      // Pan
      final newOffset = _initialPanOffset + details.focalPointDelta;
      setPanOffset(newOffset);
    }
  }

  void handlePinchEnd(ScaleEndDetails details) {
    // Reset if needed
  }

  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom.clamp(0.1, 5.0));
  }

  void setPanOffset(Offset offset) {
    state = state.copyWith(panOffset: offset);
  }

  void resetView() {
    state = state.copyWith(zoom: 1.0, panOffset: Offset.zero);
  }

  void _startLaserCleanup() {
    _laserCleanupTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _cleanupLaserPoints();
    });
  }

  void _cleanupLaserPoints() {
    final now = DateTime.now();
    final validPoints =
        state.laserPoints.where((point) {
          final age = now.difference(point.timestamp).inMilliseconds;
          return age < 1000; // Keep points for 1 second
        }).toList();

    if (validPoints.length != state.laserPoints.length) {
      state = state.copyWith(laserPoints: validPoints);
    }
  }

  @override
  void dispose() {
    _laserCleanupTimer?.cancel();
    super.dispose();
  }

  Paint _createPaintForTool(
    DrawingTool tool,
    Color color,
    double strokeWidth,
    double opacity,
    double pressure,
  ) {
    final adjustedStrokeWidth = strokeWidth * pressure;

    switch (tool) {
      case DrawingTool.pen:
        return Paint()
          ..color = color.withOpacity(opacity)
          ..strokeWidth = adjustedStrokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true;

      case DrawingTool.highlighter:
        return Paint()
          ..color = color.withOpacity(0.3 * opacity) // Semi-transparent
          ..strokeWidth =
              adjustedStrokeWidth *
              3 // Wider
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true
          ..blendMode = BlendMode.multiply;

      case DrawingTool.eraser:
        return Paint()
          ..color = const Color(0xFFF8F9FA) // Background color
          ..strokeWidth =
              adjustedStrokeWidth *
              2 // Wider
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true;

      case DrawingTool.laser:
        return Paint()
          ..color = Colors.red.withOpacity(0.7)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true;

      default:
        return Paint()
          ..color = color.withOpacity(opacity)
          ..strokeWidth = adjustedStrokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true;
    }
  }

  // Basic tool methods
  void setTool(DrawingTool tool) {
    state = state.copyWith(currentTool: tool);
  }

  void setColor(Color color) {
    state = state.copyWith(currentColor: color);
  }

  void setStrokeWidth(double width) {
    state = state.copyWith(strokeWidth: width);
  }

  void togglePalmRejection() {
    state = state.copyWith(
      isPalmRejectionEnabled: !state.isPalmRejectionEnabled,
    );
  }

  void toggleTouchIndicators() {
    state = state.copyWith(showTouchIndicators: !state.showTouchIndicators);
  }

  void clearBoard() {
    state = state.copyWith(paths: []);
  }

  void undo() {
    if (state.paths.isNotEmpty) {
      state = state.copyWith(
        paths: state.paths.sublist(0, state.paths.length - 1),
      );
    }
  }

  void _syncState({bool force = false}) {
    debugPrint('_syncState called - force: $force, batch: $_isBatchUpdating');

    if (_isBatchUpdating && !force) {
      _needsStateSync = true;
      return;
    }

    final newState = state.copyWith(
      paths: _historyService.paths,
      redoStack: _historyService.redoStack,
      clipboard: _historyService.clipboard,
      images: _imageService.images,
      selectedImageId: _imageService.selectedImageId,
      activeUsers: _userService.activeUsers,
      chatMessages: _chatService.chatMessages,
      isChatOpen: _chatService.isChatOpen,
      selectedPathIds: _selectionService.selectedPathIds,
    );

    debugPrint('State updated - paths: ${newState.paths.length}');
    state = newState;
    _needsStateSync = false;
  }

  void updatePlatformType(PlatformType platformType) {
    state = state.copyWith(platformType: platformType);
  }

  void _autoSave() {
    if (state.isAutoSaveEnabled && _historyService.paths.isNotEmpty) {
      state = state.copyWith(lastSaveTime: DateTime.now());
      debugPrint('Auto-saved at ${state.lastSaveTime}');
    }
  }

  // === Selection & Editing Methods ===
  void selectAll() {
    _selectionService.selectAll(_historyService.paths);
    _syncState();
  }

  void clearSelection() {
    _selectionService.clearSelection();
    _imageService.selectImage(null);
    _syncState();
  }

  void deleteSelected() {
    if (_selectionService.hasSelection) {
      for (var pathId in _selectionService.selectedPathIds) {
        _historyService.removePath(pathId);
      }
      _selectionService.clearSelection();
      _syncState();
      _autoSave();
    }
  }

  void redo() {
    _historyService.redo();
    _syncState();
    _autoSave();
  }

  // === Image Methods ===
  void updateImagePosition(String imageId, Offset position) {
    _imageService.updateImagePosition(imageId, position);
    _syncState();
  }

  void updateImageSize(String imageId, Size size) {
    _imageService.updateImageSize(imageId, size);
    _syncState();
  }

  void deleteImage(String imageId) {
    _imageService.deleteImage(imageId);
    _syncState();
    _autoSave();
  }

  // === User Methods ===
  void removeUser(String userId) {
    _userService.removeUser(userId);
    _syncState();
    _syncService.broadcastAction('userLeft', {'userId': userId});
  }

  // In your WhiteboardNotifier
  void updateUserCursor(String userId, Offset position) {
    // Transform screen coordinates to world coordinates
    final transformedPosition = (position - state.panOffset) / state.zoom;

    final users = Map<String, User>.from(state.activeUsers);
    if (users.containsKey(userId)) {
      users[userId] = users[userId]!.copyWith(
        cursorPosition: transformedPosition, // Store in world coordinates
        lastActivity: DateTime.now(),
      );
      state = state.copyWith(activeUsers: users);
    }
  }

  // === Chat Methods ===

  void toggleChat() {
    _chatService.toggleChat();
    _syncState();
  }

  // === Template Methods ===

  // === Tool & View Methods ===

  void toggleHandMode() {
    state = state.copyWith(isHandMode: !state.isHandMode);
  }

  void toggleGrid() {
    state = state.copyWith(isGridVisible: !state.isGridVisible);
  }

  // === Utility Methods ===
  // === Export Methods ===
  Future<Uint8List?> exportToPNG({Rect? area}) async {
    return _exportService.exportToPNG(
      paths: _historyService.paths,
      images: _imageService.images,
      backgroundImage: state.backgroundImage,
      area: area,
    );
  }

  String exportToSVG() {
    return _exportService.exportToSVG(_historyService.paths);
  }

  String exportToJson() {
    return _exportService.exportToJson(
      paths: _historyService.paths,
      images: _imageService.images,
      backgroundImage: state.backgroundImage,
      chatMessages: _chatService.chatMessages,
    );
  }

  // === Remote Action Handler ===
  void handleRemoteAction(Map<String, dynamic> syncData) {
    final action = syncData['action'];
    final data = syncData['data'];

    switch (action) {
      case 'startDrawing':
      case 'updateDrawing':
        final path = DrawingPath.fromJson(data['path']);
        _historyService.updatePath(path);
        break;
      case 'endDrawing':
        // Path already added in updateDrawing
        break;
      case 'delete':
        _historyService.removePath(data['pathId']);
        break;
      case 'clear':
        _historyService.clear();
        _imageService.clearImages();
        break;
      case 'userJoined':
        final user = User.fromJson(data['user']);
        _userService.addUser(user);
        break;
      case 'userLeft':
        _userService.removeUser(data['userId']);
        break;
      case 'cursorMove':
        final userId = data['userId'];
        final position = Offset(data['position']['dx'], data['position']['dy']);
        _userService.updateUserCursor(userId, position);
        break;
      case 'chatMessage':
        final message = ChatMessage.fromJson(data['message']);
        _chatService.addMessage(
          message.message,
          message.userId,
          message.userName,
          message.userColor,
        );
        break;
    }
    _syncState();
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

  void setTouchSensitivity(double sensitivity) {
    state = state.copyWith(touchSensitivity: sensitivity.clamp(0.5, 2.0));
  }
}
