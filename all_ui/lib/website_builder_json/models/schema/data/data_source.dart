import '../api_config.dart';
import '../cache_config.dart';
import 'data_transform.dart';

class DataSource {
  final String id;
  final String type; // api, static, form, state, localStorage
  final String? name;
  final ApiConfig? apiConfig;
  final Map<String, dynamic>? staticData;
  final DataTransform? transform;
  final CacheConfig? cache;

  DataSource({
    required this.id,
    required this.type,
    this.name,
    this.apiConfig,
    this.staticData,
    this.transform,
    this.cache,
  });

  factory DataSource.fromJson(Map<String, dynamic> json) {
    return DataSource(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String?,
      apiConfig:
          json['apiConfig'] != null
              ? ApiConfig.fromJson(json['apiConfig'] as Map<String, dynamic>)
              : null,
      staticData: json['staticData'] as Map<String, dynamic>?,
      transform:
          json['transform'] != null
              ? DataTransform.fromJson(
                json['transform'] as Map<String, dynamic>,
              )
              : null,
      cache:
          json['cache'] != null
              ? CacheConfig.fromJson(json['cache'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    if (name != null) 'name': name,
    if (apiConfig != null) 'apiConfig': apiConfig!.toJson(),
    if (staticData != null) 'staticData': staticData,
    if (transform != null) 'transform': transform!.toJson(),
    if (cache != null) 'cache': cache!.toJson(),
  };
}
