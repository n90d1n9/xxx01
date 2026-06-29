import 'merge_strategy.dart';

class MergeJoinNodeDefinition {
  final String id;
  final String name;
  final String description;
  final int inputCount;
  final MergeStrategy strategy;
  final bool waitForAll;
  final Duration? timeout;
  final Map<String, dynamic> mergeRules; // Field mapping rules
  final Map<String, dynamic> metadata;

  MergeJoinNodeDefinition({
    required this.id,
    required this.name,
    required this.description,
    this.inputCount = 2,
    this.strategy = MergeStrategy.union,
    this.waitForAll = true,
    this.timeout,
    this.mergeRules = const {},
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'inputCount': inputCount,
    'strategy': strategy.name,
    'waitForAll': waitForAll,
    'timeout': timeout?.inMilliseconds,
    'mergeRules': mergeRules,
    'metadata': metadata,
  };

  factory MergeJoinNodeDefinition.fromJson(Map<String, dynamic> json) =>
      MergeJoinNodeDefinition(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        inputCount: json['inputCount'] ?? 2,
        strategy: MergeStrategy.values.firstWhere(
          (e) => e.name == json['strategy'],
          orElse: () => MergeStrategy.union,
        ),
        waitForAll: json['waitForAll'] ?? true,
        timeout: json['timeout'] != null
            ? Duration(milliseconds: json['timeout'])
            : null,
        mergeRules: json['mergeRules'] ?? {},
        metadata: json['metadata'] ?? {},
      );
}
