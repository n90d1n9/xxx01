class ExampleConversation {
  final String user;
  final String assistant;

  ExampleConversation({required this.user, required this.assistant});

  factory ExampleConversation.fromJson(Map<String, dynamic> json) {
    return ExampleConversation(
      user: json['user'] as String,
      assistant: json['assistant'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user, 'assistant': assistant};
  }
}
