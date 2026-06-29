import '../collaboration_user.dart';
import '../comment.dart';
import '../model/activity.dart';
import '../user_role.dart';

class CollaborationState {
  final List<CollaborationUser> activeUsers;
  final Map<String, UserCursor> userCursors;
  final List<Comment> comments;
  final List<Activity> activityFeed;

  CollaborationState({
    this.activeUsers = const [],
    this.userCursors = const {},
    this.comments = const [],
    this.activityFeed = const [],
  });

  CollaborationState copyWith({
    List<CollaborationUser>? activeUsers,
    Map<String, UserCursor>? userCursors,
    List<Comment>? comments,
    List<Activity>? activityFeed,
  }) {
    return CollaborationState(
      activeUsers: activeUsers ?? this.activeUsers,
      userCursors: userCursors ?? this.userCursors,
      comments: comments ?? this.comments,
      activityFeed: activityFeed ?? this.activityFeed,
    );
  }
}
