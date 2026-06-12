import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';

import 'chat_message.dart';
import 'service.dart';
import 'drawing_tool.dart';
import 'platform_type.dart';
import 'laser_point.dart';
import 'drawing_path.dart';
import 'template.dart';
import 'user.dart';
import 'whiteboard_state.dart';

class WhiteboardNotifier extends StateNotifier<WhiteboardState> {
  final TimerService _timerService = TimerService();
  final SyncService _syncService = SyncService();
  final DrawingService _drawingService = DrawingService();
  final SelectionService _selectionService = SelectionService();
  final ExportService _exportService = ExportService();
  final ImageService _imageService = ImageService();
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();
  final TemplateService _templateService = TemplateService();
  final HistoryService _historyService = HistoryService();

  double _initialZoom = 1.0;
  double _initialPinchDistance = 0;

  WhiteboardNotifier() : super(WhiteboardState()) {
    _initializeServices();
    _detectPlatform();
  }

  void _initializeServices() {
    _timerService.startAutoSaveTimer(_autoSave);
    _timerService.startUserActivityTimer(_checkUserActivity);
    _timerService.startLaserCleanupTimer(_cleanupLaserPoints);
  }

  Stream<Map<String, dynamic>> get syncStream => _syncService.syncStream;

  @override
  void dispose() {
    _timerService.dispose();
    _syncService.dispose();
    super.dispose();
  }

  // === State Synchronization Methods ===
  void _syncState() {
    state = state.copyWith(
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
  }

  // === Drawing Methods ===
  void startDrawing(
    Offset point,
    String userId, {
    double pressure = 1.0,
    double tiltX = 0.0,
    double tiltY = 0.0,
  }) {
    if (state.isHandMode) return;
    if (_shouldRejectTouch(point, pressure)) {
      debugPrint('Touch rejected: palm detection');
      return;
    }

    if (state.currentTool == DrawingTool.laser) {
      _addLaserPoint(point);
      return;
    }

    final newPath = _drawingService.createNewPath(
      point: point,
      userId: userId,
      tool: state.currentTool,
      color: state.currentColor,
      strokeWidth: state.strokeWidth,
      opacity: state.currentOpacity,
      fillStyle: state.currentFillStyle,
      fillColor: state.currentFillColor,
      lineStyle: state.currentLineStyle,
      pressure: pressure,
      tiltX: tiltX,
      tiltY: tiltY,
    );

    _drawingService.setCurrentPath(newPath);
    _selectionService.clearSelection();
    _syncState();

    _syncService.broadcastAction('startDrawing', {'path': newPath.toJson()});
  }

  void updateDrawing(
    Offset point,
    String userId, {
    double pressure = 1.0,
    double tiltX = 0.0,
    double tiltY = 0.0,
  }) {
    if (state.currentTool == DrawingTool.laser) {
      _addLaserPoint(point);
      return;
    }

    final currentPath = _drawingService.currentPath;
    if (currentPath == null || state.isHandMode) return;

    DrawingPath updatedPath;
    if (state.currentTool == DrawingTool.pen ||
        state.currentTool == DrawingTool.eraser ||
        state.currentTool == DrawingTool.highlighter) {
      updatedPath = _drawingService.updatePathWithNewPoint(
        currentPath,
        point,
        userId,
        pressure: pressure,
        tiltX: tiltX,
        tiltY: tiltY,
      );
    } else {
      updatedPath = _drawingService.updateShapePath(
        currentPath,
        point,
        userId,
        pressure: pressure,
        tiltX: tiltX,
        tiltY: tiltY,
      );
    }

    _drawingService.setCurrentPath(updatedPath);
    _historyService.updatePath(updatedPath);
    _syncState();

    _syncService.broadcastAction('updateDrawing', {
      'path': updatedPath.toJson(),
    });
  }

  void endDrawing() {
    if (state.currentTool == DrawingTool.laser) {
      _clearLaserPoints();
      return;
    }

    final currentPath = _drawingService.currentPath;
    if (currentPath != null) {
      _historyService.addPath(currentPath);
      _syncService.broadcastAction('endDrawing', {'pathId': currentPath.id});
      _autoSave();
    }

    _drawingService.reset();
    _syncState();
  }

  // === Selection & Editing Methods ===
  void selectPath(String pathId, {bool addToSelection = false}) {
    _selectionService.selectPath(pathId, addToSelection: addToSelection);
    _syncState();
  }

  void selectImage(String? imageId) {
    _imageService.selectImage(imageId);
    _syncState();
  }

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

  void undo() {
    _historyService.undo();
    _syncState();
    _autoSave();
  }

  void redo() {
    _historyService.redo();
    _syncState();
    _autoSave();
  }

  void clearBoard() {
    _historyService.clear();
    _imageService.clearImages();
    _selectionService.clearSelection();
    _clearLaserPoints();
    _syncState();
    _syncService.broadcastAction('clear', {});
    _autoSave();
  }

  // === Image Methods ===
  void addImage(Uint8List imageData, Offset position, String userId) {
    _imageService.addImage(imageData, position, userId);
    _syncState();
    _syncService.broadcastAction('addImage', {
      'imageId': _imageService.selectedImageId,
    });
    _autoSave();
  }

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
  void addUser(User user) {
    _userService.addUser(user);
    _syncState();
    _syncService.broadcastAction('userJoined', {'user': user.toJson()});
  }

  void removeUser(String userId) {
    _userService.removeUser(userId);
    _syncState();
    _syncService.broadcastAction('userLeft', {'userId': userId});
  }

  void updateUserCursor(String userId, Offset position) {
    _userService.updateUserCursor(userId, position);
    _syncState();
    _syncService.broadcastAction('cursorMove', {
      'userId': userId,
      'position': {'dx': position.dx, 'dy': position.dy},
    });
  }

  // === Chat Methods ===
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

  void toggleChat() {
    _chatService.toggleChat();
    _syncState();
  }

  // === Template Methods ===
  void applyTemplate(Template template, String userId) {
    final newPaths = _templateService.applyTemplate(template, userId);
    for (var path in newPaths) {
      _historyService.addPath(path);
    }
    _syncState();
    _syncService.broadcastAction('applyTemplate', {'templateId': template.id});
    _autoSave();
  }

  // === Tool & View Methods ===
  void setTool(DrawingTool tool) {
    state = state.copyWith(currentTool: tool, isHandMode: false);
  }

  void setColor(Color color) {
    state = state.copyWith(currentColor: color);
  }

  void setStrokeWidth(double width) {
    state = state.copyWith(strokeWidth: width);
  }

  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom.clamp(0.1, 5.0));
    _syncService.broadcastAction('zoom', {'zoom': state.zoom});
  }

  void setPanOffset(Offset offset) {
    state = state.copyWith(panOffset: offset);
    _syncService.broadcastAction('pan', {
      'offset': {'dx': offset.dx, 'dy': offset.dy},
    });
  }

  void resetView() {
    state = state.copyWith(zoom: 1.0, panOffset: Offset.zero);
    _syncService.broadcastAction('resetView', {});
  }

  void toggleHandMode() {
    state = state.copyWith(isHandMode: !state.isHandMode);
  }

  void toggleGrid() {
    state = state.copyWith(isGridVisible: !state.isGridVisible);
  }

  void togglePalmRejection() {
    state = state.copyWith(
      isPalmRejectionEnabled: !state.isPalmRejectionEnabled,
    );
  }

  void toggleTouchIndicators() {
    state = state.copyWith(showTouchIndicators: !state.showTouchIndicators);
  }

  // === Utility Methods ===
  void handlePinchStart(ScaleStartDetails details) {
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

  // In WhiteboardNotifier, update the palm rejection logic
  bool _shouldRejectTouch(Offset position, double pressure) {
    if (!state.isPalmRejectionEnabled) return false;

    // Adjust these thresholds based on testing
    if (pressure < 0.05) {
      // Reduced from 0.1 to 0.05
      debugPrint('Touch rejected: low pressure ($pressure)');
      return true;
    }

    // Add additional checks if needed
    return false;
  }

  void _addLaserPoint(Offset point) {
    final laserPoint = LaserPoint(point: point, timestamp: DateTime.now());
    state = state.copyWith(laserPoints: [...state.laserPoints, laserPoint]);
  }

  void _clearLaserPoints() {
    state = state.copyWith(laserPoints: []);
  }

  void _cleanupLaserPoints() {
    final validPoints = state.laserPoints.where((p) => !p.isExpired).toList();
    if (validPoints.length != state.laserPoints.length) {
      state = state.copyWith(laserPoints: validPoints);
    }
  }

  void _checkUserActivity() {
    _userService.deactivateInactiveUsers();
    _syncState();
  }

  void _autoSave() {
    if (state.isAutoSaveEnabled && _historyService.paths.isNotEmpty) {
      state = state.copyWith(lastSaveTime: DateTime.now());
      debugPrint('Auto-saved at ${state.lastSaveTime}');
    }
  }

  void _detectPlatform() {
    state = state.copyWith(platformType: PlatformType.desktop);
  }

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

  void handlePinchEnd(ScaleEndDetails details) {
    _initialPinchDistance = 0;
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
