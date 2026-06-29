import 'package:flutter/material.dart';

import '../widget/component_chip.dart';
import 'component_type.dart';

class ComponentPaletteItem extends StatelessWidget {
  final ComponentType type;

  const ComponentPaletteItem({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Draggable<ComponentType>(
      data: type,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: ComponentChip(type: type),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: ListTile(
          dense: true,
          leading: Icon(_getIcon(type), size: 20),
          title: Text(_getLabel(type)),
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(_getIcon(type), size: 20, color: _getColor(type)),
        title: Text(_getLabel(type)),
        subtitle: Text(
          _getDescription(type),
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        onTap: () {},
      ),
    );
  }

  IconData _getIcon(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return Icons.input;
      case ComponentType.to:
        return Icons.output;
      case ComponentType.transform:
        return Icons.transform;
      case ComponentType.filter:
        return Icons.filter_alt;
      case ComponentType.choice:
        return Icons.call_split;
      case ComponentType.log:
        return Icons.article;
      case ComponentType.setHeader:
        return Icons.view_headline;
      case ComponentType.setBody:
        return Icons.data_object;
      case ComponentType.process:
        return Icons.settings;
      case ComponentType.split:
        return Icons.call_split;
      case ComponentType.aggregate:
        return Icons.merge;
      case ComponentType.enrich:
        return Icons.add_circle;
      case ComponentType.multicast:
        return Icons.broadcast_on_personal;
      case ComponentType.wiretap:
        return Icons.visibility;
      case ComponentType.loop:
        return Icons.loop;
      case ComponentType.delay:
        return Icons.schedule;
      case ComponentType.throttle:
        return Icons.speed;
      case ComponentType.removeHeader:
        return Icons.remove_circle;
      case ComponentType.removeHeaders:
        return Icons.clear_all;
      case ComponentType.convertBodyTo:
        return Icons.swap_horiz;
      case ComponentType.marshal:
        return Icons.archive;
      case ComponentType.unmarshal:
        return Icons.unarchive;
      case ComponentType.script:
        return Icons.code;
      case ComponentType.validate:
        return Icons.verified;
      case ComponentType.onException:
        return Icons.error;
      case ComponentType.doTry:
        return Icons.try_sms_star;
      case ComponentType.doCatch:
        return Icons.catching_pokemon;
      case ComponentType.doFinally:
        return Icons.done_all;
      case ComponentType.pollEnrich:
        return Icons.cloud_download;
      case ComponentType.recipientList:
        return Icons.list;
      case ComponentType.dynamicRouter:
        return Icons.alt_route;
      case ComponentType.loadBalance:
        return Icons.balance;
      case ComponentType.hystrix:
        return Icons.shield;
      case ComponentType.idempotentConsumer:
        return Icons.filter_1;
    }
  }

  String _getLabel(ComponentType type) {
    return type.name[0].toUpperCase() +
        type.name
            .substring(1)
            .replaceAllMapped(
              RegExp(r'([A-Z])'),
              (match) => ' ${match.group(1)}',
            );
  }

  String _getDescription(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return 'Consume from endpoint';
      case ComponentType.to:
        return 'Send to endpoint';
      case ComponentType.transform:
        return 'Transform message';
      case ComponentType.filter:
        return 'Filter messages';
      case ComponentType.choice:
        return 'Conditional routing';
      case ComponentType.log:
        return 'Log message';
      case ComponentType.setHeader:
        return 'Set message header';
      case ComponentType.setBody:
        return 'Set message body';
      case ComponentType.process:
        return 'Custom processor';
      case ComponentType.split:
        return 'Split message';
      case ComponentType.aggregate:
        return 'Aggregate messages';
      case ComponentType.enrich:
        return 'Enrich content';
      case ComponentType.multicast:
        return 'Send to multiple endpoints';
      case ComponentType.wiretap:
        return 'Copy to endpoint';
      case ComponentType.loop:
        return 'Loop messages';
      case ComponentType.delay:
        return 'Delay processing';
      case ComponentType.throttle:
        return 'Throttle messages';
      case ComponentType.removeHeader:
        return 'Remove header';
      case ComponentType.removeHeaders:
        return 'Remove multiple headers';
      case ComponentType.convertBodyTo:
        return 'Convert body type';
      case ComponentType.marshal:
        return 'Marshal to format';
      case ComponentType.unmarshal:
        return 'Unmarshal from format';
      case ComponentType.script:
        return 'Execute script';
      case ComponentType.validate:
        return 'Validate message';
      case ComponentType.onException:
        return 'Exception handler';
      case ComponentType.doTry:
        return 'Try block';
      case ComponentType.doCatch:
        return 'Catch block';
      case ComponentType.doFinally:
        return 'Finally block';
      case ComponentType.pollEnrich:
        return 'Poll and enrich';
      case ComponentType.recipientList:
        return 'Dynamic recipients';
      case ComponentType.dynamicRouter:
        return 'Dynamic routing';
      case ComponentType.loadBalance:
        return 'Load balancing';
      case ComponentType.hystrix:
        return 'Circuit breaker';
      case ComponentType.idempotentConsumer:
        return 'Deduplicate messages';
    }
  }

  Color _getColor(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return Colors.green;
      case ComponentType.to:
        return Colors.red;
      case ComponentType.transform:
      case ComponentType.setBody:
      case ComponentType.setHeader:
      case ComponentType.removeHeader:
      case ComponentType.removeHeaders:
      case ComponentType.convertBodyTo:
        return Colors.purple;
      case ComponentType.choice:
      case ComponentType.filter:
      case ComponentType.multicast:
      case ComponentType.split:
      case ComponentType.recipientList:
      case ComponentType.dynamicRouter:
      case ComponentType.loadBalance:
        return Colors.orange;
      case ComponentType.marshal:
      case ComponentType.unmarshal:
        return Colors.teal;
      case ComponentType.onException:
      case ComponentType.doTry:
      case ComponentType.doCatch:
      case ComponentType.doFinally:
        return Colors.red[700]!;
      case ComponentType.loop:
      case ComponentType.delay:
      case ComponentType.throttle:
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }
}
