import 'dart:ui';

class CollaboratorState {
  final String id;
  final String name;
  final Offset cursorPosition;
  final bool isActive;
  final DateTime? lastActivity;

  const CollaboratorState({
    required this.id,
    required this.name,
    required this.cursorPosition,
    this.isActive = false,
    this.lastActivity,
  });

  CollaboratorState copyWith({
    String? id,
    String? name,
    Offset? cursorPosition,
    bool? isActive,
    DateTime? lastActivity,
  }) {
    return CollaboratorState(
      id: id ?? this.id,
      name: name ?? this.name,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      isActive: isActive ?? this.isActive,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}
