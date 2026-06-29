import 'dart:ui';

import 'package:flutter_riverpod/legacy.dart';

import '../model/pattern_library_state.dart';
import '../schema/common/position.dart';
import '../schema/integration/integration_pattern_template.dart';
import '../schema/model/model_factory.dart';
import '../schema/node/node_type.dart';
import '../schema/pattern/pattern_template.dart';
import '../schema/workflow/workflow_edge.dart';
import '../schema/workflow/workflow_node.dart';

final patternLibraryProvider =
    StateNotifierProvider<PatternLibraryNotifier, PatternLibraryState>(
      (ref) => PatternLibraryNotifier(),
    );

class PatternLibraryNotifier extends StateNotifier<PatternLibraryState> {
  PatternLibraryNotifier() : super(PatternLibraryState()) {
    _loadBuiltInPatterns();
  }

  void _loadBuiltInPatterns() {
    final patterns = _createBuiltInPatterns();
    state = state.copyWith(patterns: patterns, filteredPatterns: patterns);
  }

  List<IntegrationPatternTemplate> _createBuiltInPatterns() {
    return [
      // Messaging Patterns
      _createPattern(
        name: 'Message Channel',
        category: 'messaging',
        pattern: 'message_broker',
        description: 'Enable message-based communication between applications',
        icon: '📨',
        nodes: [
          _createTemplateNode('sender', NodeType.serviceActivator, 100, 100),
          _createTemplateNode('channel', NodeType.router, 300, 100),
          _createTemplateNode('receiver', NodeType.serviceActivator, 500, 100),
        ],
      ),
      _createPattern(
        name: 'Publish-Subscribe',
        category: 'messaging',
        pattern: 'message_broker',
        description: 'Send messages to multiple subscribers',
        icon: '📢',
        nodes: [
          _createTemplateNode('publisher', NodeType.serviceActivator, 100, 150),
          _createTemplateNode('topic', NodeType.multicast, 300, 150),
          _createTemplateNode(
            'subscriber1',
            NodeType.serviceActivator,
            500,
            100,
          ),
          _createTemplateNode(
            'subscriber2',
            NodeType.serviceActivator,
            500,
            200,
          ),
        ],
      ),

      // Routing Patterns
      _createPattern(
        name: 'Content-Based Router',
        category: 'routing',
        pattern: 'content_based_router',
        description: 'Route messages based on message content',
        icon: '🔀',
        nodes: [
          _createTemplateNode('input', NodeType.start, 100, 150),
          _createTemplateNode('router', NodeType.router, 300, 150),
          _createTemplateNode('route_a', NodeType.serviceActivator, 500, 100),
          _createTemplateNode('route_b', NodeType.serviceActivator, 500, 200),
        ],
      ),
      _createPattern(
        name: 'Message Filter',
        category: 'routing',
        pattern: 'message_filter',
        description: 'Filter messages based on criteria',
        icon: '🔍',
        nodes: [
          _createTemplateNode('input', NodeType.start, 100, 100),
          _createTemplateNode('filter', NodeType.filter, 300, 100),
          _createTemplateNode('output', NodeType.end, 500, 100),
        ],
      ),
      _createPattern(
        name: 'Recipient List',
        category: 'routing',
        pattern: 'recipient_list',
        description: 'Send message to multiple recipients dynamically',
        icon: '📋',
        nodes: [
          _createTemplateNode('input', NodeType.start, 100, 150),
          _createTemplateNode(
            'recipientList',
            NodeType.recipientList,
            300,
            150,
          ),
          _createTemplateNode(
            'recipient1',
            NodeType.serviceActivator,
            500,
            100,
          ),
          _createTemplateNode(
            'recipient2',
            NodeType.serviceActivator,
            500,
            200,
          ),
        ],
      ),
      _createPattern(
        name: 'Splitter',
        category: 'routing',
        pattern: 'splitter',
        description: 'Split a message into multiple messages',
        icon: '✂️',
        nodes: [
          _createTemplateNode('input', NodeType.start, 100, 100),
          _createTemplateNode('splitter', NodeType.splitter, 300, 100),
          _createTemplateNode('processor', NodeType.transform, 500, 100),
          _createTemplateNode('output', NodeType.end, 700, 100),
        ],
      ),
      _createPattern(
        name: 'Aggregator',
        category: 'routing',
        pattern: 'aggregator',
        description: 'Combine multiple messages into one',
        icon: '🔗',
        nodes: [
          _createTemplateNode('input1', NodeType.start, 100, 80),
          _createTemplateNode('input2', NodeType.start, 100, 180),
          _createTemplateNode('aggregator', NodeType.aggregator, 300, 130),
          _createTemplateNode('output', NodeType.end, 500, 130),
        ],
      ),

      // Transformation Patterns
      _createPattern(
        name: 'Message Translator',
        category: 'transformation',
        pattern: 'message_translator',
        description: 'Transform message format',
        icon: '🔄',
        nodes: [
          _createTemplateNode('input', NodeType.start, 100, 100),
          _createTemplateNode('translator', NodeType.transform, 300, 100),
          _createTemplateNode('output', NodeType.end, 500, 100),
        ],
      ),
      _createPattern(
        name: 'Content Enricher',
        category: 'transformation',
        pattern: 'content_enricher',
        description: 'Enrich message with additional data',
        icon: '➕',
        nodes: [
          _createTemplateNode('input', NodeType.start, 100, 100),
          _createTemplateNode('enricher', NodeType.enricher, 300, 100),
          _createTemplateNode('output', NodeType.end, 500, 100),
        ],
      ),
      _createPattern(
        name: 'Normalizer',
        category: 'transformation',
        pattern: 'normalizer',
        description: 'Convert messages to common format',
        icon: '⚖️',
        nodes: [
          _createTemplateNode('input1', NodeType.start, 100, 80),
          _createTemplateNode('input2', NodeType.start, 100, 180),
          _createTemplateNode('router', NodeType.router, 250, 130),
          _createTemplateNode('transform1', NodeType.transform, 400, 80),
          _createTemplateNode('transform2', NodeType.transform, 400, 180),
          _createTemplateNode('merge', NodeType.merge, 550, 130),
          _createTemplateNode('output', NodeType.end, 700, 130),
        ],
      ),

      // Endpoint Patterns
      _createPattern(
        name: 'Polling Consumer',
        category: 'endpoint',
        pattern: 'polling_consumer',
        description: 'Poll for messages at intervals',
        icon: '🔄',
        nodes: [
          _createTemplateNode('scheduler', NodeType.schedule, 100, 100),
          _createTemplateNode('poll', NodeType.serviceActivator, 300, 100),
          _createTemplateNode('process', NodeType.transform, 500, 100),
        ],
      ),
      _createPattern(
        name: 'Service Activator',
        category: 'endpoint',
        pattern: 'service_activator',
        description: 'Invoke service from message',
        icon: '⚡',
        nodes: [
          _createTemplateNode('input', NodeType.start, 100, 100),
          _createTemplateNode('activator', NodeType.serviceActivator, 300, 100),
          _createTemplateNode('output', NodeType.end, 500, 100),
        ],
      ),

      // System Management
      _createPattern(
        name: 'Wire Tap',
        category: 'system_management',
        pattern: 'wire_tap',
        description: 'Monitor message flow without affecting it',
        icon: '👁️',
        nodes: [
          _createTemplateNode('input', NodeType.start, 100, 100),
          _createTemplateNode('wireTap', NodeType.wireTap, 300, 100),
          _createTemplateNode('logger', NodeType.serviceActivator, 300, 200),
          _createTemplateNode('output', NodeType.end, 500, 100),
        ],
      ),
      _createPattern(
        name: 'Dead Letter Channel',
        category: 'system_management',
        pattern: 'dead_letter_channel',
        description: 'Handle failed messages',
        icon: '💀',
        nodes: [
          _createTemplateNode('input', NodeType.start, 100, 100),
          _createTemplateNode('processor', NodeType.transform, 300, 100),
          _createTemplateNode('dlq', NodeType.deadLetterChannel, 300, 200),
          _createTemplateNode('output', NodeType.end, 500, 100),
        ],
      ),

      // AI Patterns
      _createPattern(
        name: 'LLM Processing Pipeline',
        category: 'ai',
        pattern: 'process_manager',
        description: 'Process data through LLM with validation',
        icon: '🤖',
        nodes: [
          _createTemplateNode('input', NodeType.start, 100, 150),
          _createTemplateNode('validate', NodeType.validator, 250, 150),
          _createTemplateNode('llm', NodeType.llm, 400, 150),
          _createTemplateNode('transform', NodeType.transform, 550, 150),
          _createTemplateNode('output', NodeType.end, 700, 150),
        ],
      ),
      _createPattern(
        name: 'RAG Pattern',
        category: 'ai',
        pattern: 'content_enricher',
        description: 'Retrieval Augmented Generation',
        icon: '📚',
        nodes: [
          _createTemplateNode('query', NodeType.start, 100, 150),
          _createTemplateNode('retrieve', NodeType.enricher, 250, 150),
          _createTemplateNode('llm', NodeType.llm, 400, 150),
          _createTemplateNode('response', NodeType.end, 550, 150),
        ],
      ),
    ];
  }

  IntegrationPatternTemplate _createPattern({
    required String name,
    required String category,
    required String pattern,
    required String description,
    required String icon,
    required List<WorkflowNode> nodes,
  }) {
    return IntegrationPatternTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString() + name,
      name: name,
      category: category,
      pattern: pattern,
      description: description,
      icon: icon,
      color: _getCategoryColor(category),
      template: PatternTemplate(
        nodes: nodes,
        edges: _createEdgesFromNodes(nodes),
      ),
    );
  }

  WorkflowNode _createTemplateNode(
    String name,
    NodeType type,
    double x,
    double y,
  ) {
    return ModelFactory.createNode(
      type: type,
      name: name,
      position: Position(x: x, y: y),
    );
  }

  List<WorkflowEdge> _createEdgesFromNodes(List<WorkflowNode> nodes) {
    final edges = <WorkflowEdge>[];
    for (int i = 0; i < nodes.length - 1; i++) {
      edges.add(
        ModelFactory.createEdge(source: nodes[i].id, target: nodes[i + 1].id),
      );
    }
    return edges;
  }

  String _getCategoryColor(String category) {
    switch (category) {
      case 'messaging':
        return '#4CAF50';
      case 'routing':
        return '#2196F3';
      case 'transformation':
        return '#FF9800';
      case 'endpoint':
        return '#9C27B0';
      case 'system_management':
        return '#F44336';
      case 'ai':
        return '#E91E63';
      default:
        return '#757575';
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredPatterns: state.patterns, searchQuery: '');
      return;
    }

    final filtered = state.patterns.where((pattern) {
      return pattern.name.toLowerCase().contains(query.toLowerCase()) ||
          pattern.description!.toLowerCase().contains(query.toLowerCase()) ||
          pattern.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    state = state.copyWith(filteredPatterns: filtered, searchQuery: query);
  }

  void filterByCategory(String? category) {
    List<IntegrationPatternTemplate> filtered;

    if (category == null) {
      filtered = state.patterns;
    } else {
      filtered = state.patterns.where((p) => p.category == category).toList();
    }

    state = state.copyWith(
      selectedCategory: category,
      filteredPatterns: filtered,
    );
  }

  void selectPattern(IntegrationPatternTemplate? pattern) {
    state = state.copyWith(selectedPattern: pattern);
  }

  void applyPattern(IntegrationPatternTemplate pattern, Offset position) {
    // This will be called from UI to apply pattern to canvas
    // Implementation will use workflowProvider to add nodes
  }
}
