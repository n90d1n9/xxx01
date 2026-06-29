import '../components/connection/model/connection_data.dart';
import '../components/node/model/schema/node_data.dart';
import 'workflow_metadata.dart';

class WorkflowData {
  final String id;
  final String name;
  final String description;
  final List<NodeData> nodes;
  final List<ConnectionData> connections;
  final WorkflowMetadata metadata;
  WorkflowData({
    required this.id,
    required this.name,
    required this.description,
    required this.nodes,
    required this.connections,
    required this.metadata,
  });
}
