import 'config_map_node_config_source.dart';

class NodeConfigSource {
  final ConfigMapNodeConfigSource? configMap;
  NodeConfigSource({this.configMap});
  factory NodeConfigSource.fromJson(Map<String, dynamic> json) {
    return NodeConfigSource(
      configMap:
          json['configMap'] != null
              ? ConfigMapNodeConfigSource.fromJson(json['configMap'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {if (configMap != null) 'configMap': configMap!.toJson()};
  }
}
