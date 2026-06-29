import 'package:flutter/material.dart';

import '../workflow/workflow_node.dart';

enum NodeType {
  start,
  end,
  llm,
  tool,
  decision,
  loop,
  parallel,
  merge,
  humanInput,
  codeExecution,
  webhook,
  schedule,
  condition,
  switchType,
  delay,
  transform,
  validator,
  router,
  splitter,
  aggregator,
  enricher,
  filter,
  resequencer,
  deadLetterChannel,
  wireTap,
  throttler,
  idempotentReceiver,
  multicast,
  recipientList,
  loadBalancer,
  serviceActivator;

  String get displayName {
    switch (this) {
      case NodeType.start:
        return 'Start';
      case NodeType.end:
        return 'End';
      case NodeType.llm:
        return 'LLM';
      case NodeType.tool:
        return 'Tool';
      case NodeType.decision:
        return 'Decision';
      case NodeType.loop:
        return 'Loop';
      case NodeType.parallel:
        return 'Parallel';
      case NodeType.merge:
        return 'Merge';
      case NodeType.humanInput:
        return 'Human Input';
      case NodeType.codeExecution:
        return 'Code Execution';
      case NodeType.webhook:
        return 'Webhook';
      case NodeType.schedule:
        return 'Schedule';
      case NodeType.condition:
        return 'Condition';
      case NodeType.switchType:
        return 'Switch';
      case NodeType.delay:
        return 'Delay';
      case NodeType.transform:
        return 'Transform';
      case NodeType.validator:
        return 'Validator';
      case NodeType.router:
        return 'Router';
      case NodeType.splitter:
        return 'Splitter';
      case NodeType.aggregator:
        return 'Aggregator';
      case NodeType.enricher:
        return 'Enricher';
      case NodeType.filter:
        return 'Filter';
      case NodeType.resequencer:
        return 'Resequencer';
      case NodeType.deadLetterChannel:
        return 'Dead Letter Channel';
      case NodeType.wireTap:
        return 'Wire Tap';
      case NodeType.throttler:
        return 'Throttler';
      case NodeType.idempotentReceiver:
        return 'Idempotent Receiver';
      case NodeType.multicast:
        return 'Multicast';
      case NodeType.recipientList:
        return 'Recipient List';
      case NodeType.loadBalancer:
        return 'Load Balancer';
      case NodeType.serviceActivator:
        return 'Service Activator';
    }
  }

  IconData get icon {
    switch (this) {
      case NodeType.start:
        return Icons.play_circle_outline;
      case NodeType.end:
        return Icons.stop_circle_outlined;
      case NodeType.llm:
        return Icons.psychology;
      case NodeType.tool:
        return Icons.build;
      case NodeType.decision:
        return Icons.fork_right;
      case NodeType.loop:
        return Icons.loop;
      case NodeType.parallel:
        return Icons.call_split;
      case NodeType.merge:
        return Icons.call_merge;
      case NodeType.humanInput:
        return Icons.person;
      case NodeType.codeExecution:
        return Icons.code;
      case NodeType.webhook:
        return Icons.webhook;
      case NodeType.schedule:
        return Icons.schedule;
      case NodeType.condition:
        return Icons.help_outline;
      case NodeType.switchType:
        return Icons.swap_horiz;
      case NodeType.delay:
        return Icons.timer;
      case NodeType.transform:
        return Icons.transform;
      case NodeType.validator:
        return Icons.verified;
      case NodeType.router:
        return Icons.route;
      case NodeType.splitter:
        return Icons.splitscreen;
      case NodeType.aggregator:
        return Icons.merge_type;
      case NodeType.enricher:
        return Icons.add_circle_outline;
      case NodeType.filter:
        return Icons.filter_alt;
      case NodeType.resequencer:
        return Icons.sort;
      case NodeType.deadLetterChannel:
        return Icons.error_outline;
      case NodeType.wireTap:
        return Icons.tap_and_play;
      case NodeType.throttler:
        return Icons.speed;
      case NodeType.idempotentReceiver:
        return Icons.check_circle_outline;
      case NodeType.multicast:
        return Icons.broadcast_on_personal;
      case NodeType.recipientList:
        return Icons.list;
      case NodeType.loadBalancer:
        return Icons.balance;
      case NodeType.serviceActivator:
        return Icons.power_settings_new;
    }
  }

  Color get color {
    switch (this) {
      case NodeType.start:
        return Colors.green;
      case NodeType.end:
        return Colors.red;
      case NodeType.llm:
        return Colors.purple;
      case NodeType.tool:
        return Colors.blue;
      case NodeType.decision:
      case NodeType.condition:
      case NodeType.switchType:
        return Colors.orange;
      case NodeType.loop:
      case NodeType.parallel:
      case NodeType.merge:
        return Colors.teal;
      case NodeType.humanInput:
        return Colors.pink;
      case NodeType.codeExecution:
        return Colors.indigo;
      case NodeType.webhook:
      case NodeType.schedule:
        return Colors.cyan;
      case NodeType.transform:
      case NodeType.validator:
      case NodeType.enricher:
        return Colors.amber;
      case NodeType.router:
      case NodeType.splitter:
      case NodeType.aggregator:
      case NodeType.recipientList:
        return Colors.deepOrange;
      case NodeType.filter:
      case NodeType.resequencer:
        return Colors.lime;
      case NodeType.deadLetterChannel:
        return Colors.red.shade700;
      case NodeType.wireTap:
      case NodeType.multicast:
        return Colors.lightBlue;
      case NodeType.throttler:
      case NodeType.loadBalancer:
        return Colors.brown;
      case NodeType.idempotentReceiver:
      case NodeType.serviceActivator:
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  NodeCategory get category {
    switch (this) {
      case NodeType.llm:
      case NodeType.tool:
      case NodeType.codeExecution:
        return NodeCategory.ai;
      case NodeType.webhook:
      case NodeType.schedule:
      case NodeType.serviceActivator:
        return NodeCategory.endpoint;
      case NodeType.router:
      case NodeType.splitter:
      case NodeType.aggregator:
      case NodeType.recipientList:
      case NodeType.multicast:
      case NodeType.loadBalancer:
        return NodeCategory.routing;
      case NodeType.transform:
      case NodeType.enricher:
      case NodeType.filter:
      case NodeType.resequencer:
        return NodeCategory.transformation;
      case NodeType.decision:
      case NodeType.condition:
      case NodeType.switchType:
      case NodeType.loop:
      case NodeType.parallel:
      case NodeType.merge:
        return NodeCategory.logic;
      case NodeType.wireTap:
      case NodeType.deadLetterChannel:
      case NodeType.throttler:
      case NodeType.idempotentReceiver:
        return NodeCategory.monitoring;
      default:
        return NodeCategory.logic;
    }
  }
}
