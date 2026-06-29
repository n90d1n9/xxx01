// Real-time Collaboration
import 'collaboration_event.dart';
import 'user_cursor.dart';

class CollaborationState {
  final Map<String, UserCursor> activeCursors;
  final List<CollaborationEvent> recentEvents;
  final bool isConnected;

  CollaborationState({
    this.activeCursors = const {},
    this.recentEvents = const [],
    this.isConnected = false,
  });

  CollaborationState copyWith({
    Map<String, UserCursor>? activeCursors,
    List<CollaborationEvent>? recentEvents,
    bool? isConnected,
  }) {
    return CollaborationState(
      activeCursors: activeCursors ?? this.activeCursors,
      recentEvents: recentEvents ?? this.recentEvents,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
