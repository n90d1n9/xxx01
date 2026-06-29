import 'package:flutter/material.dart';

import '../components/ifelse/screen/ifelse_editor_screen.dart';
import '../components/ifelse/model/ifelse_node_definition.dart';
import '../components/ifelse/utils/ifelse_node_execution.dart';
import '../components/whileloop/while_loop_editor_screen.dart';
import '../components/whileloop/while_loop_node_definition.dart';
import '../components/whileloop/while_node_node_executor.dart';
import 'batch/batch_editor_screen.dart';
import 'batch/batch_process_executor.dart';
import 'batch/batch_processor_node_definition.dart';
import 'filter/cache/cache_node_definition.dart';
import 'filter/cache/cache_node_executor.dart';
import 'filter/delay_schedule_node_definition.dart';
import 'filter/delay_scheduled_node_executor.dart';
import 'filter/filter_transform_definition.dart';
import 'filter/filter_transform_executor.dart';
import 'filter/merge_join_definition.dart';
import 'filter/merge_join_executor.dart';
import 'human/human_executor.dart';
import 'human/model/human_loop_definition.dart';
import 'human/screen/human_inloop_screen.dart';
import 'pararel/pararel_executor_editor.dart';
import 'switch/switch_editor.dart';
import 'switch/switch_router_editor.dart';
import 'switch/switch_router_node_executor.dart';
import 'trycatch/pararel_execution_exception.dart';
import 'trycatch/try_catch_editor.dart';
import 'trycatch/trycatch_finally_defintion.dart';
import 'trycatch/trycatch_finaly.dart';

class ComprehensiveNodeFactory {
  static dynamic createExecutor(
    String nodeType,
    Map<String, dynamic> definition,
  ) {
    switch (nodeType) {
      // Control Flow Nodes
      case 'if_else':
        return IfElseNodeExecutor(IfElseNodeDefinition.fromJson(definition));
      case 'while_loop':
        return WhileLoopNodeExecutor(
          WhileLoopNodeDefinition.fromJson(definition),
        );
      case 'human_in_loop':
        return HumanInLoopNodeExecutor(
          HumanInLoopNodeDefinition.fromJson(definition),
        );

      // Advanced Nodes
      case 'try_catch':
        return TryCatchFinallyNodeExecutor(
          TryCatchFinallyNodeDefinition.fromJson(definition),
        );
      case 'parallel':
        return ParallelExecutionNodeExecutor(
          ParallelExecutionNodeDefinition.fromJson(definition),
        );
      case 'router':
        return SwitchRouterNodeExecutor(
          SwitchRouterNodeDefinition.fromJson(definition),
        );
      case 'batch':
        return BatchProcessorNodeExecutor(
          BatchProcessorNodeDefinition.fromJson(definition),
        );
      case 'merge':
        return MergeJoinNodeExecutor(
          MergeJoinNodeDefinition.fromJson(definition),
        );
      case 'delay':
        return DelayScheduleNodeExecutor(
          DelayScheduleNodeDefinition.fromJson(definition),
        );
      case 'filter':
        return FilterTransformNodeExecutor(
          FilterTransformNodeDefinition.fromJson(definition),
        );
      case 'cache':
        return CacheNodeExecutor(CacheNodeDefinition.fromJson(definition));

      default:
        throw Exception('Unknown node type: $nodeType');
    }
  }

  static Widget createEditor(String nodeType, {dynamic existingDefinition}) {
    switch (nodeType) {
      case 'if_else':
        return IfElseEditorScreen(existingDefinition: existingDefinition);
      case 'while_loop':
        return WhileLoopEditorScreen(existingDefinition: existingDefinition);
      case 'human_in_loop':
        return HumanInLoopEditorScreen(existingDefinition: existingDefinition);
      case 'try_catch':
        return TryCatchFinallyEditorScreen(
          existingDefinition: existingDefinition,
        );
      case 'parallel':
        return ParallelExecutionEditorScreen(
          existingDefinition: existingDefinition,
        );
      case 'router':
        return SwitchRouterEditorScreen(existingDefinition: existingDefinition);
      case 'batch':
        return BatchProcessorEditorScreen(
          existingDefinition: existingDefinition,
        );
      default:
        throw Exception('No editor available for: $nodeType');
    }
  }
}
