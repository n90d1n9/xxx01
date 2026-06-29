import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'workflow/workflow_provider.dart';

final cursorPositionProvider = Provider<Offset?>((ref) {
  return ref.watch(workflowProvider.select((state) => state.cursorPosition));
});
