class EndpointConditions {
  final bool? ready;
  final bool? serving;
  final bool? terminating;
  EndpointConditions({this.ready, this.serving, this.terminating});
  factory EndpointConditions.fromJson(Map<String, dynamic> json) {
    return EndpointConditions(
      ready: json['ready'],
      serving: json['serving'],
      terminating: json['terminating'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (ready != null) 'ready': ready,
      if (serving != null) 'serving': serving,
      if (terminating != null) 'terminating': terminating,
    };
  }
}
