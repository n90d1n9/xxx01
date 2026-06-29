import 'volume_node_resources.dart';

class CSINodeDriver {
  final String name;
  final String nodeID;
  final List<String>? topologyKeys;
  final VolumeNodeResources? allocatable;
  CSINodeDriver({
    required this.name,
    required this.nodeID,
    this.topologyKeys,
    this.allocatable,
  });
  factory CSINodeDriver.fromJson(Map<String, dynamic> json) {
    return CSINodeDriver(
      name: json['name'],
      nodeID: json['nodeID'],
      topologyKeys:
          json['topologyKeys'] != null
              ? List<String>.from(json['topologyKeys'])
              : null,
      allocatable:
          json['allocatable'] != null
              ? VolumeNodeResources.fromJson(json['allocatable'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nodeID': nodeID,
      if (topologyKeys != null) 'topologyKeys': topologyKeys,
      if (allocatable != null) 'allocatable': allocatable!.toJson(),
    };
  }
}
