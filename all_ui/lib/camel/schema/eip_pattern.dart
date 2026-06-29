enum EIPPatternType {
  // Messaging patterns
  messageChannel,
  messageEndpoint,
  messageRouter,
  messageTranslator,
  messageFilter,

  // Routing patterns
  contentBasedRouter,
  messageFilter_,
  dynamicRouter,
  recipientList,
  splitter,
  aggregator,
  resequencer,
  composedMessageProcessor,
  scatterGather,
  routingSlip,

  // Transformation patterns
  contentEnricher,
  contentFilter,
  claimCheck,
  normalizer,

  // Endpoint patterns
  messagingGateway,
  messagingMapper,
  transactionalClient,
  pollingConsumer,
  eventDrivenConsumer,

  // System management
  controlBus,
  detour,
  wireTab,
  messageHistory,
}

/// Enterprise Integration Pattern configuration
class EIPPattern {
  final String id;
  final EIPPatternType type;
  final String name;
  final Map<String, dynamic> config;

  const EIPPattern({
    required this.id,
    required this.type,
    required this.name,
    required this.config,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'name': name,
    'config': config,
  };
}
