import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/legacy.dart';

import 'drawing_tool.dart';
import 'shape_fill_style.dart';
import 'line_style.dart';
import 'platform_type.dart';
import 'laser_point.dart';
import 'whiteboard_image.dart';
import 'drawing_path.dart';
import 'user.dart';
import 'chat_message.dart';

class WhiteboardState {
  final List<DrawingPath> paths;
  final List<DrawingPath> redoStack;
  final List<DrawingPath> clipboard;
  final Map<String, WhiteboardImage> images;
  final String? selectedImageId;
  final DrawingTool currentTool;
  final Color currentColor;
  final double strokeWidth;
  final Map<String, User> activeUsers;
  final double zoom;
  final Offset panOffset;
  final Set<String> selectedPathIds;
  final bool isGridVisible;
  final bool isHandMode;
  final ShapeFillStyle currentFillStyle;
  final Color? currentFillColor;
  final LineStyle currentLineStyle;
  final double currentOpacity;
  final bool isAutoSaveEnabled;
  final DateTime? lastSaveTime;
  final List<ChatMessage> chatMessages;
  final bool isChatOpen;
  final bool isFollowMode;
  final String? followingUserId;
  final bool isRecording;
  final DateTime? recordingStartTime;
  final Uint8List? backgroundImage;
  final bool showMinimap;
  final PlatformType platformType;
  final bool isPalmRejectionEnabled;
  final List<LaserPoint> laserPoints;
  final bool showTouchIndicators;
  final double touchSensitivity;
  WhiteboardState({
    this.paths = const [],
    this.redoStack = const [],
    this.clipboard = const [],
    this.images = const {},
    this.selectedImageId,
    this.currentTool = DrawingTool.pen,
    this.currentColor = Colors.black,
    this.strokeWidth = 3.0,
    this.activeUsers = const {},
    this.zoom = 1.0,
    this.panOffset = Offset.zero,
    this.selectedPathIds = const {},
    this.isGridVisible = false,
    this.isHandMode = false,
    this.currentFillStyle = ShapeFillStyle.none,
    this.currentFillColor,
    this.currentLineStyle = LineStyle.solid,
    this.currentOpacity = 1.0,
    this.isAutoSaveEnabled = true,
    this.lastSaveTime,
    this.chatMessages = const [],
    this.isChatOpen = false,
    this.isFollowMode = false,
    this.followingUserId,
    this.isRecording = false,
    this.recordingStartTime,
    this.backgroundImage,
    this.showMinimap = false,
    this.platformType = PlatformType.desktop,
    this.isPalmRejectionEnabled = true,
    this.laserPoints = const [],
    this.showTouchIndicators = true,
    this.touchSensitivity = 1.0,
  });
  WhiteboardState copyWith({
    List<DrawingPath>? paths,
    List<DrawingPath>? redoStack,
    List<DrawingPath>? clipboard,
    Map<String, WhiteboardImage>? images,
    String? selectedImageId,
    DrawingTool? currentTool,
    Color? currentColor,
    double? strokeWidth,
    Map<String, User>? activeUsers,
    double? zoom,
    Offset? panOffset,
    Set<String>? selectedPathIds,
    bool? isGridVisible,
    bool? isHandMode,
    ShapeFillStyle? currentFillStyle,
    Color? currentFillColor,
    LineStyle? currentLineStyle,
    double? currentOpacity,
    bool? isAutoSaveEnabled,
    DateTime? lastSaveTime,
    List<ChatMessage>? chatMessages,
    bool? isChatOpen,
    bool? isFollowMode,
    String? followingUserId,
    bool? isRecording,
    DateTime? recordingStartTime,
    Uint8List? backgroundImage,
    bool? showMinimap,
    PlatformType? platformType,
    bool? isPalmRejectionEnabled,
    List<LaserPoint>? laserPoints,
    bool? showTouchIndicators,
    double? touchSensitivity,
    bool clearSelection = false,
    bool clearFillColor = false,
    bool clearFollowing = false,
    bool clearRecording = false,
    bool clearImageSelection = false,
    bool clearBackground = false,
  }) {
    return WhiteboardState(
      paths: paths ?? this.paths,
      redoStack: redoStack ?? this.redoStack,
      clipboard: clipboard ?? this.clipboard,
      images: images ?? this.images,
      selectedImageId: clearImageSelection
          ? null
          : (selectedImageId ?? this.selectedImageId),
      currentTool: currentTool ?? this.currentTool,
      currentColor: currentColor ?? this.currentColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      activeUsers: activeUsers ?? this.activeUsers,
      zoom: zoom ?? this.zoom,
      panOffset: panOffset ?? this.panOffset,
      selectedPathIds: clearSelection
          ? {}
          : (selectedPathIds ?? this.selectedPathIds),
      isGridVisible: isGridVisible ?? this.isGridVisible,
      isHandMode: isHandMode ?? this.isHandMode,
      currentFillStyle: currentFillStyle ?? this.currentFillStyle,
      currentFillColor: clearFillColor
          ? null
          : (currentFillColor ?? this.currentFillColor),
      currentLineStyle: currentLineStyle ?? this.currentLineStyle,
      currentOpacity: currentOpacity ?? this.currentOpacity,
      isAutoSaveEnabled: isAutoSaveEnabled ?? this.isAutoSaveEnabled,
      lastSaveTime: lastSaveTime ?? this.lastSaveTime,
      chatMessages: chatMessages ?? this.chatMessages,
      isChatOpen: isChatOpen ?? this.isChatOpen,
      isFollowMode: isFollowMode ?? this.isFollowMode,
      followingUserId: clearFollowing
          ? null
          : (followingUserId ?? this.followingUserId),
      isRecording: isRecording ?? this.isRecording,
      recordingStartTime: clearRecording
          ? null
          : (recordingStartTime ?? this.recordingStartTime),
      backgroundImage: clearBackground
          ? null
          : (backgroundImage ?? this.backgroundImage),
      showMinimap: showMinimap ?? this.showMinimap,
      platformType: platformType ?? this.platformType,
      isPalmRejectionEnabled:
          isPalmRejectionEnabled ?? this.isPalmRejectionEnabled,
      laserPoints: laserPoints ?? this.laserPoints,
      showTouchIndicators: showTouchIndicators ?? this.showTouchIndicators,
      touchSensitivity: touchSensitivity ?? this.touchSensitivity,
    );
  }
}
