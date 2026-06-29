import 'dart:async';

class TypingExpiryTracker {
  // Map of userId to their active expiry timer
  final Map<String, Timer> _timers = {};
  
  // Set of currently typing userIds
  final Set<String> _typingUsers = {};
  
  // Stream controller to emit updates
  final StreamController<Set<String>> _controller = StreamController<Set<String>>.broadcast();

  /// Stream of currently typing users
  Stream<Set<String>> get typingStream => _controller.stream;

  /// Get current set of typing users
  Set<String> get currentTypingUsers => Set.unmodifiable(_typingUsers);

  /// Default expiry duration
  final Duration expiryDuration;

  TypingExpiryTracker({this.expiryDuration = const Duration(seconds: 5)});

  /// Mark a user as typing (starts or resets their expiry timer)
  void markTyping(String userId) {
    _timers[userId]?.cancel();
    
    bool wasAdded = _typingUsers.add(userId);
    if (wasAdded) {
      _controller.add(Set.unmodifiable(_typingUsers));
    }

    _timers[userId] = Timer(expiryDuration, () {
      markStopped(userId);
    });
  }

  /// Mark a user as stopped typing explicitly
  void markStopped(String userId) {
    _timers[userId]?.cancel();
    _timers.remove(userId);

    bool wasRemoved = _typingUsers.remove(userId);
    if (wasRemoved) {
      _controller.add(Set.unmodifiable(_typingUsers));
    }
  }

  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _typingUsers.clear();
    _controller.close();
  }
}
