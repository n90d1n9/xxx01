import '../../workflow/model/workflow_node_port.dart';

class PortConfig {
  final String id;
  final String label;
  final PortType type;
  final bool required;

  PortConfig({
    required this.id,
    required this.label,
    required this.type,
    this.required = true,
  });
}
