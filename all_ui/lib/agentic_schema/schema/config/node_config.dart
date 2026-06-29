import 'human_input_config.dart';
import 'load_balancer_config.dart';
import '../common/prompt_template.dart';
import 'throttler_config.dart';
import '../tool/tool.dart';
import 'aggregator_config.dart';
import 'condition_config.dart';
import 'enricher_config.dart';
import 'filter_config.dart';
import '../model/llm_config.dart';
import 'loop_config.dart';
import 'parallel_config.dart';
import 'splitter_config.dart';
import 'transform_config.dart';
import 'validation_config.dart';

class NodeConfig {
  final LLMConfig? llmConfig;
  final Tool? tool;
  final String? prompt;
  final PromptTemplate? promptTemplate;
  final ConditionConfig? condition;
  final LoopConfig? loopConfig;
  final ParallelConfig? parallelConfig;
  final TransformConfig? transformConfig;
  final ValidationConfig? validationConfig;
  final SplitterConfig? splitterConfig;
  final AggregatorConfig? aggregatorConfig;
  final EnricherConfig? enricherConfig;
  final FilterConfig? filterConfig;
  final ThrottlerConfig? throttlerConfig;
  final LoadBalancerConfig? loadBalancerConfig;
  final HumanInputConfig? humanInputConfig;

  NodeConfig({
    this.llmConfig,
    this.tool,
    this.prompt,
    this.promptTemplate,
    this.condition,
    this.loopConfig,
    this.parallelConfig,
    this.transformConfig,
    this.validationConfig,
    this.splitterConfig,
    this.aggregatorConfig,
    this.enricherConfig,
    this.filterConfig,
    this.throttlerConfig,
    this.loadBalancerConfig,
    this.humanInputConfig,
  });

  factory NodeConfig.fromJson(Map<String, dynamic> json) {
    return NodeConfig(
      llmConfig: json['llmConfig'] != null
          ? LLMConfig.fromJson(json['llmConfig'] as Map<String, dynamic>)
          : null,
      tool: json['tool'] != null
          ? Tool.fromJson(json['tool'] as Map<String, dynamic>)
          : null,
      prompt: json['prompt'] as String?,
      promptTemplate: json['promptTemplate'] != null
          ? PromptTemplate.fromJson(
              json['promptTemplate'] as Map<String, dynamic>,
            )
          : null,
      condition: json['condition'] != null
          ? ConditionConfig.fromJson(json['condition'] as Map<String, dynamic>)
          : null,
      loopConfig: json['loopConfig'] != null
          ? LoopConfig.fromJson(json['loopConfig'] as Map<String, dynamic>)
          : null,
      parallelConfig: json['parallelConfig'] != null
          ? ParallelConfig.fromJson(
              json['parallelConfig'] as Map<String, dynamic>,
            )
          : null,
      transformConfig: json['transformConfig'] != null
          ? TransformConfig.fromJson(
              json['transformConfig'] as Map<String, dynamic>,
            )
          : null,
      validationConfig: json['validationConfig'] != null
          ? ValidationConfig.fromJson(
              json['validationConfig'] as Map<String, dynamic>,
            )
          : null,
      splitterConfig: json['splitterConfig'] != null
          ? SplitterConfig.fromJson(
              json['splitterConfig'] as Map<String, dynamic>,
            )
          : null,
      aggregatorConfig: json['aggregatorConfig'] != null
          ? AggregatorConfig.fromJson(
              json['aggregatorConfig'] as Map<String, dynamic>,
            )
          : null,
      enricherConfig: json['enricherConfig'] != null
          ? EnricherConfig.fromJson(
              json['enricherConfig'] as Map<String, dynamic>,
            )
          : null,
      filterConfig: json['filterConfig'] != null
          ? FilterConfig.fromJson(json['filterConfig'] as Map<String, dynamic>)
          : null,
      throttlerConfig: json['throttlerConfig'] != null
          ? ThrottlerConfig.fromJson(
              json['throttlerConfig'] as Map<String, dynamic>,
            )
          : null,
      loadBalancerConfig: json['loadBalancerConfig'] != null
          ? LoadBalancerConfig.fromJson(
              json['loadBalancerConfig'] as Map<String, dynamic>,
            )
          : null,
      humanInputConfig: json['humanInputConfig'] != null
          ? HumanInputConfig.fromJson(
              json['humanInputConfig'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (llmConfig != null) 'llmConfig': llmConfig!.toJson(),
      if (tool != null) 'tool': tool!.toJson(),
      if (prompt != null) 'prompt': prompt,
      if (promptTemplate != null) 'promptTemplate': promptTemplate!.toJson(),
      if (condition != null) 'condition': condition!.toJson(),
      if (loopConfig != null) 'loopConfig': loopConfig!.toJson(),
      if (parallelConfig != null) 'parallelConfig': parallelConfig!.toJson(),
      if (transformConfig != null) 'transformConfig': transformConfig!.toJson(),
      if (validationConfig != null)
        'validationConfig': validationConfig!.toJson(),
      if (splitterConfig != null) 'splitterConfig': splitterConfig!.toJson(),
      if (aggregatorConfig != null)
        'aggregatorConfig': aggregatorConfig!.toJson(),
      if (enricherConfig != null) 'enricherConfig': enricherConfig!.toJson(),
      if (filterConfig != null) 'filterConfig': filterConfig!.toJson(),
      if (throttlerConfig != null) 'throttlerConfig': throttlerConfig!.toJson(),
      if (loadBalancerConfig != null)
        'loadBalancerConfig': loadBalancerConfig!.toJson(),
      if (humanInputConfig != null)
        'humanInputConfig': humanInputConfig!.toJson(),
    };
  }
}
