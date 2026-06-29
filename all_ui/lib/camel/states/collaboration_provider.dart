import 'package:flutter_riverpod/legacy.dart';

import '../models/collaboration_state.dart';

final collaborationProvider = StateProvider<CollaborationState>((ref) {
  return CollaborationState();
});
