import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class AutoSaveNotifier extends StateNotifier<bool> {
  AutoSaveNotifier() : super(true) {
    _startAutoSave();
  }

  Timer? _timer;

  void _startAutoSave() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (state) {
        _performAutoSave();
      }
    });
  }

  void _performAutoSave() {
    // Save current workflow
    debugPrint('Auto-saving workflow...');
  }

  void toggle() {
    state = !state;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final autoSaveProvider = StateNotifierProvider<AutoSaveNotifier, bool>(
  (ref) => AutoSaveNotifier(),
);
