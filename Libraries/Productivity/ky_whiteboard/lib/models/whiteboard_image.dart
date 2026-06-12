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

class WhiteboardImage {
  final String id;
  final Uint8List imageData;
  final Offset position;
  final Size size;
  final double rotation;
  WhiteboardImage({
    required this.id,
    required this.imageData,
    required this.position,
    required this.size,
    this.rotation = 0.0,
  });
  WhiteboardImage copyWith({Offset? position, Size? size, double? rotation}) {
    return WhiteboardImage(
      id: id,
      imageData: imageData,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageData': base64Encode(imageData),
    'position': {'dx': position.dx, 'dy': position.dy},
    'size': {'width': size.width, 'height': size.height},
    'rotation': rotation,
  };
  factory WhiteboardImage.fromJson(Map<String, dynamic> json) {
    return WhiteboardImage(
      id: json['id'],
      imageData: base64Decode(json['imageData']),
      position: Offset(json['position']['dx'], json['position']['dy']),
      size: Size(json['size']['width'], json['size']['height']),
      rotation: json['rotation'] ?? 0.0,
    );
  }
}
