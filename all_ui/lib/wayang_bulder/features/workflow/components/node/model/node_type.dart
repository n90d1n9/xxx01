abstract class NodeTypeBase {
  String? name;
}

abstract class ConnectionPortBase {
  String? name;
  PortType? type;
}

enum PortType { input, output }

const nodeType = [
  'modelEndpoint',
  'promptTemplate',
  'dataPipeline',
  'outputProcessor',
  'decision',
  'aggregator',
  'custom',
  'trigger',
  'action',
  'condition',
  'group',
];
