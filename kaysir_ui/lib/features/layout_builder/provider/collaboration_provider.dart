import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/collaboration_state.dart';
import '../widgets/comment.dart';

final collaborationProvider =
    StateNotifierProvider<CollaborationNotifier, CollaborationState>((ref) {
      return CollaborationNotifier();
    });

class CollaborationNotifier extends StateNotifier<CollaborationState> {
  CollaborationNotifier() : super(CollaborationState.initial());

  void updateUserCursor(String userId, Offset position) {
    final updatedCursors = {...state.userCursors};
    updatedCursors[userId] = position;
    state = state.copyWith(userCursors: updatedCursors);
  }

  void lockComponent(String componentId, String userId) {
    final updatedLocks = {...state.componentLocks};
    updatedLocks[componentId] = userId;
    state = state.copyWith(
      componentLocks: updatedLocks,
      isLocked: true,
      lockedBy: userId,
    );
  }

  void unlockComponent(String componentId) {
    final updatedLocks = {...state.componentLocks}..remove(componentId);
    state = state.copyWith(
      componentLocks: updatedLocks,
      isLocked: updatedLocks.isNotEmpty,
      lockedBy: updatedLocks.isEmpty ? null : updatedLocks.values.first,
    );
  }

  void addComment(String componentId, Comment comment) {
    final updatedComments = {...state.componentComments};
    if (!updatedComments.containsKey(componentId)) {
      updatedComments[componentId] = [];
    }
    updatedComments[componentId]!.add(comment);
    state = state.copyWith(componentComments: updatedComments);
  }
}
