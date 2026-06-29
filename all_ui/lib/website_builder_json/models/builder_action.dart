class BuilderAction {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  BuilderAction({
    required this.type,
    required this.data,
    required this.timestamp,
  });
}
