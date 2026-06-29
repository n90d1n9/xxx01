import 'package:flutter_riverpod/legacy.dart';

import 'collaboration_manager.dart';
import 'collaboration_state.dart';

final collaborationProvider =
    StateNotifierProvider<CollaborationManager, CollaborationState>((ref) {
      return CollaborationManager();
    });
