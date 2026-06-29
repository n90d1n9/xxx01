import 'package:flutter/material.dart';

import '../models/drawing_path.dart';
import '../models/drawing_point.dart';

class PerformanceHistoryService {
  final List<DrawingPath> _paths = [];
  final List<DrawingPath> _redoStack = [];
  final List<DrawingPath> _clipboard = [];

  // Cache for faster lookups
  final Map<String, int> _pathIndexCache = {};

  List<DrawingPath> get paths => _paths;
  List<DrawingPath> get redoStack => _redoStack;
  List<DrawingPath> get clipboard => _clipboard;

  void addPath(DrawingPath path) {
    _paths.add(path);
    _pathIndexCache[path.id] = _paths.length - 1;
    _redoStack.clear();
  }

  void updatePath(DrawingPath path) {
    final index = _pathIndexCache[path.id];
    if (index != null && index < _paths.length) {
      _paths[index] = path;
    } else {
      // Fallback to linear search
      final foundIndex = _paths.indexWhere((p) => p.id == path.id);
      if (foundIndex != -1) {
        _paths[foundIndex] = path;
        _pathIndexCache[path.id] = foundIndex;
      }
    }
  }

  void removePath(String pathId) {
    final index = _pathIndexCache[pathId];
    if (index != null) {
      _paths.removeAt(index);
      _pathIndexCache.remove(pathId);
      // Update cache for paths after the removed one
      for (var i = index; i < _paths.length; i++) {
        _pathIndexCache[_paths[i].id] = i;
      }
    }
    _redoStack.clear();
  }

  void undo() {
    if (_paths.isNotEmpty) {
      final lastPath = _paths.removeLast();
      _pathIndexCache.remove(lastPath.id);
      _redoStack.add(lastPath);
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      final redoPath = _redoStack.removeLast();
      _paths.add(redoPath);
      _pathIndexCache[redoPath.id] = _paths.length - 1;
    }
  }

  void clear() {
    _paths.clear();
    _redoStack.clear();
    _pathIndexCache.clear();
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
                  paint: p.paint, // Reuse paint object
                  userId: userId,
                  timestamp: DateTime.now(),
                  pressure: p.pressure,
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
