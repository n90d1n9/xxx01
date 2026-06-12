import 'package:flutter_riverpod/legacy.dart';

import '../collaboration_user.dart';
import '../comment.dart';
import '../model/activity.dart';
import '../user_role.dart';
import 'collaboration_state.dart';

class CollaborationManager extends StateNotifier<CollaborationState> {
  CollaborationManager() : super(CollaborationState());

  void addUser(CollaborationUser user) {
    state = state.copyWith(activeUsers: [...state.activeUsers, user]);
  }

  void removeUser(String userId) {
    state = state.copyWith(
      activeUsers: state.activeUsers.where((u) => u.id != userId).toList(),
    );
  }

  void updateUserCursor(UserCursor cursor) {
    final cursors = Map<String, UserCursor>.from(state.userCursors);
    cursors[cursor.userId] = cursor;
    state = state.copyWith(userCursors: cursors);
  }

  void addComment(Comment comment) {
    state = state.copyWith(comments: [...state.comments, comment]);
  }

  void resolveComment(String commentId) {
    final updatedComments = state.comments.map((c) {
      if (c.id == commentId) {
        return Comment(
          id: c.id,
          userId: c.userId,
          userName: c.userName,
          fieldId: c.fieldId,
          text: c.text,
          createdAt: c.createdAt,
          mentions: c.mentions,
          isResolved: true,
          replies: c.replies,
        );
      }
      return c;
    }).toList();

    state = state.copyWith(comments: updatedComments);
  }

  void addActivity(Activity activity) {
    state = state.copyWith(activityFeed: [activity, ...state.activityFeed]);
  }
}
