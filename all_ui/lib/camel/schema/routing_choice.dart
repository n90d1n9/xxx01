enum RoutingType {
  contentBased,
  recipientList,
  dynamic,
  loadBalance,
  multicast,
  splitter,
}

class RoutingChoice {
  final String id;
  final String condition;
  final String targetNodeId;
  final String? description;

  const RoutingChoice({
    required this.id,
    required this.condition,
    required this.targetNodeId,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'condition': condition,
    'targetNodeId': targetNodeId,
    'description': description,
  };
}
