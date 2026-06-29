class AgentContext {
  final dynamic input;
  final Map<String, dynamic> metadata;
  final List<String> previousAgents;

  AgentContext({
    required this.input,
    this.metadata = const {},
    this.previousAgents = const [],
  });

  AgentContext copyWith({
    dynamic input,
    Map<String, dynamic>? metadata,
    List<String>? previousAgents,
  }) {
    return AgentContext(
      input: input ?? this.input,
      metadata: metadata ?? this.metadata,
      previousAgents: previousAgents ?? this.previousAgents,
    );
  }
}
