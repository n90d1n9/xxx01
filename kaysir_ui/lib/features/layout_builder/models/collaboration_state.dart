import 'dart:ui';

import 'collaborator_state.dart';
import '../widgets/comment.dart';

class CollaborationState {
  final Map<String, CollaboratorState> collaborators;
  final Map<String, Offset> userCursors;
  final Map<String, String> componentLocks;
  final Map<String, List<Comment>> componentComments;
  final bool isLocked;
  final List<String> comments;
  final String? lockedBy;

  const CollaborationState({
    this.collaborators = const {},
    this.userCursors = const {},
    this.componentLocks = const {},
    this.componentComments = const {},
    this.isLocked = false,
    this.comments = const [],
    this.lockedBy,
  });

  CollaborationState copyWith({
    Map<String, CollaboratorState>? collaborators,
    Map<String, Offset>? userCursors,
    Map<String, String>? componentLocks,
    Map<String, List<Comment>>? componentComments,
    bool? isLocked,
    List<String>? comments,
    String? lockedBy,
  }) {
    return CollaborationState(
      collaborators: collaborators ?? this.collaborators,
      userCursors: userCursors ?? this.userCursors,
      componentLocks: componentLocks ?? this.componentLocks,
      componentComments: componentComments ?? this.componentComments,
      isLocked: isLocked ?? this.isLocked,
      comments: comments ?? this.comments,
      lockedBy: lockedBy ?? this.lockedBy,
    );
  }

  static CollaborationState initial() {
    return const CollaborationState();
  }
}
