class HttpConnections {
  final int accepted;
  final int active;
  final int handled;
  final int reading;
  final int waiting;
  final int writing;

  HttpConnections({
    required this.accepted,
    required this.active,
    required this.handled,
    required this.reading,
    required this.waiting,
    required this.writing,
  });

  factory HttpConnections.fromJson(Map<String, dynamic> json) {
    return HttpConnections(
      accepted: json['accepted'],
      active: json['active'],
      handled: json['handled'],
      reading: json['reading'],
      waiting: json['waiting'],
      writing: json['writing'],
    );
  }
}
