// Clipboard for Copy/Paste
import 'package:flutter_riverpod/legacy.dart';

import '../models/node_card.dart';

class ClipboardState {
  final List<NodeCard> nodes;
  final DateTime timestamp;

  ClipboardState({required this.nodes, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

final clipboardProvider = StateProvider<ClipboardState?>((ref) => null);
