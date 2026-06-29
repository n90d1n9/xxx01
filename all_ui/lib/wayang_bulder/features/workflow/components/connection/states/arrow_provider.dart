import 'dart:ui';

import 'package:flutter_riverpod/legacy.dart';

final arrowPositionProvider = StateProvider<Offset>((ref) => Offset.zero);

final isHoveredProvider = StateProvider<bool>((ref) => false);
final isDraggingProvider = StateProvider<bool>((ref) => false);
