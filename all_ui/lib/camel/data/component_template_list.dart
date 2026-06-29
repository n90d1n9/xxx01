import 'package:flutter/material.dart';

import '../models/component_template.dart';
import '../schema/config_property.dart';

class ComponentTemplates {
  static List<ComponentTemplate> getAllComponents() => [
    // ENDPOINTS
    _restEndpoint(),
    _soapEndpoint(),
    _kafkaProducer(),
    _kafkaConsumer(),
    _jmsQueue(),
    _jmsTopic(),
    _fileEndpoint(),
    _ftpEndpoint(),
    _databaseEndpoint(),
    _emailEndpoint(),

    // ROUTING
    _contentBasedRouter(),
    _recipientList(),
    _dynamicRouter(),
    _splitter(),
    _aggregator(),
    _multicast(),
    _loadBalancer(),
    _routingSlip(),
    _resequencer(),

    // TRANSFORMATION
    _dataMapper(),
    _enricher(),
    _filter(),
    _transformer(),
    _validator(),
    _normalizer(),
    _claimCheck(),

    // PROCESSORS
    _scriptProcessor(),
    _customProcessor(),
    _delay(),
    _throttle(),
    _setHeader(),
    _setProperty(),
    _removeHeader(),

    // ERROR HANDLING
    _errorHandler(),
    _deadLetterChannel(),
    _onException(),
    _retry(),
  ];

  // ENDPOINT COMPONENTS
  static ComponentTemplate _restEndpoint() => const ComponentTemplate(
    id: 'rest-endpoint',
    name: 'REST Endpoint',
    description: 'HTTP REST API endpoint with OpenAPI/Swagger support',
    categoryId: 'endpoints',
    icon: Icons.api,
    color: Colors.blue,
    eipPattern: 'Messaging Endpoint',

    defaultConfig: {
      'method': 'GET',
      'path': '/',
      'consumes': 'application/json',
      'produces': 'application/json',
    },
    properties: [
      ConfigProperty(name: 'uri', type: 'string', required: true),
      ConfigProperty(
        name: 'method',
        type: 'select',
        required: true,
        options: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
      ),
      ConfigProperty(name: 'path', type: 'string', required: true),
      ConfigProperty(
        name: 'specification',
        type: 'file',
        description: 'OpenAPI/Swagger specification',
      ),
    ],
  );

  static ComponentTemplate _kafkaProducer() => const ComponentTemplate(
    id: 'kafka-producer',
    name: 'Kafka Producer',
    description: 'Publish messages to Apache Kafka topic',
    categoryId: 'messaging',
    icon: Icons.send,
    color: Colors.green,
    eipPattern: 'Message Channel',
    defaultConfig: {'topic': '', 'brokers': 'localhost:9092', 'key': ''},
    properties: [
      ConfigProperty(name: 'topic', type: 'string', required: true),
      ConfigProperty(name: 'brokers', type: 'string', required: true),
      ConfigProperty(name: 'key', type: 'string'),
      ConfigProperty(name: 'partitioner', type: 'string'),
    ],
  );

  // ROUTING COMPONENTS
  static ComponentTemplate _contentBasedRouter() => const ComponentTemplate(
    id: 'content-based-router',
    name: 'Content Based Router',
    description: 'Route messages based on content evaluation',
    categoryId: 'routing',
    icon: Icons.alt_route,
    color: Colors.purple,
    eipPattern: 'Content-Based Router',
    defaultConfig: {'choices': [], 'otherwise': null},
    properties: [
      ConfigProperty(name: 'expression', type: 'expression', required: true),
      ConfigProperty(name: 'choices', type: 'list', required: true),
    ],
  );

  static ComponentTemplate _splitter() => const ComponentTemplate(
    id: 'splitter',
    name: 'Splitter',
    description: 'Split message into multiple parts',
    categoryId: 'routing',
    icon: Icons.call_split,
    color: Colors.purple,
    eipPattern: 'Splitter',
    defaultConfig: {
      'expression': '',
      'streaming': false,
      'parallelProcessing': false,
    },
    properties: [
      ConfigProperty(name: 'expression', type: 'expression', required: true),
      ConfigProperty(name: 'streaming', type: 'boolean'),
      ConfigProperty(name: 'parallelProcessing', type: 'boolean'),
      ConfigProperty(name: 'timeout', type: 'number'),
    ],
  );

  static ComponentTemplate _aggregator() => const ComponentTemplate(
    id: 'aggregator',
    name: 'Aggregator',
    description: 'Combine multiple messages into single message',
    categoryId: 'routing',
    icon: Icons.call_merge,
    color: Colors.purple,
    eipPattern: 'Aggregator',
    defaultConfig: {
      'correlationExpression': '',
      'completionSize': 0,
      'completionTimeout': 0,
    },
    properties: [
      ConfigProperty(
        name: 'correlationExpression',
        type: 'expression',
        required: true,
      ),
      ConfigProperty(name: 'completionSize', type: 'number'),
      ConfigProperty(name: 'completionTimeout', type: 'number'),
      ConfigProperty(
        name: 'aggregationStrategy',
        type: 'select',
        options: ['useLatest', 'groupedExchange', 'custom'],
      ),
    ],
  );

  // TRANSFORMATION COMPONENTS
  static ComponentTemplate _dataMapper() => const ComponentTemplate(
    id: 'data-mapper',
    name: 'Data Mapper',
    description: 'Map and transform data between formats',
    categoryId: 'transformation',
    icon: Icons.transform,
    color: Colors.orange,
    eipPattern: 'Message Translator',
    defaultConfig: {
      'mappings': [],
      'sourceFormat': 'json',
      'targetFormat': 'json',
    },
    properties: [
      ConfigProperty(
        name: 'sourceFormat',
        type: 'select',
        required: true,
        options: ['json', 'xml', 'csv'],
      ),
      ConfigProperty(
        name: 'targetFormat',
        type: 'select',
        required: true,
        options: ['json', 'xml', 'csv'],
      ),
      ConfigProperty(name: 'mappings', type: 'mappings', required: true),
    ],
  );

  static ComponentTemplate _enricher() => const ComponentTemplate(
    id: 'enricher',
    name: 'Content Enricher',
    description: 'Enrich message with additional data',
    categoryId: 'transformation',
    icon: Icons.add_circle_outline,
    color: Colors.orange,
    eipPattern: 'Content Enricher',
    defaultConfig: {'resourceUri': '', 'aggregationStrategy': 'useLatest'},
    properties: [
      ConfigProperty(name: 'resourceUri', type: 'string', required: true),
      ConfigProperty(name: 'aggregationStrategy', type: 'select'),
      ConfigProperty(name: 'cacheSize', type: 'number'),
    ],
  );

  static ComponentTemplate _filter() => const ComponentTemplate(
    id: 'filter',
    name: 'Message Filter',
    description: 'Filter messages based on condition',
    categoryId: 'transformation',
    icon: Icons.filter_alt,
    color: Colors.orange,
    eipPattern: 'Message Filter',
    defaultConfig: {'expression': ''},
    properties: [
      ConfigProperty(name: 'expression', type: 'expression', required: true),
    ],
  );

  // Stub implementations for other components...
  static ComponentTemplate _soapEndpoint() => const ComponentTemplate(
    id: 'soap-endpoint',
    name: 'SOAP Endpoint',
    description: 'SOAP web service',
    categoryId: 'endpoints',
    icon: Icons.soap,
    color: Colors.blue,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _kafkaConsumer() => const ComponentTemplate(
    id: 'kafka-consumer',
    name: 'Kafka Consumer',
    description: 'Consume from Kafka',
    categoryId: 'messaging',
    icon: Icons.download,
    color: Colors.green,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _jmsQueue() => const ComponentTemplate(
    id: 'jms-queue',
    name: 'JMS Queue',
    description: 'JMS queue endpoint',
    categoryId: 'messaging',
    icon: Icons.queue,
    color: Colors.green,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _jmsTopic() => const ComponentTemplate(
    id: 'jms-topic',
    name: 'JMS Topic',
    description: 'JMS topic endpoint',
    categoryId: 'messaging',
    icon: Icons.topic,
    color: Colors.green,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _fileEndpoint() => const ComponentTemplate(
    id: 'file-endpoint',
    name: 'File',
    description: 'File system endpoint',
    categoryId: 'endpoints',
    icon: Icons.folder,
    color: Colors.blue,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _ftpEndpoint() => const ComponentTemplate(
    id: 'ftp-endpoint',
    name: 'FTP',
    description: 'FTP/SFTP endpoint',
    categoryId: 'endpoints',
    icon: Icons.cloud_upload,
    color: Colors.blue,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _databaseEndpoint() => const ComponentTemplate(
    id: 'database-endpoint',
    name: 'Database',
    description: 'Database endpoint',
    categoryId: 'database',
    icon: Icons.storage,
    color: Colors.teal,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _emailEndpoint() => const ComponentTemplate(
    id: 'email-endpoint',
    name: 'Email',
    description: 'Email endpoint',
    categoryId: 'endpoints',
    icon: Icons.email,
    color: Colors.blue,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _recipientList() => const ComponentTemplate(
    id: 'recipient-list',
    name: 'Recipient List',
    description: 'Send to multiple recipients',
    categoryId: 'routing',
    icon: Icons.list,
    color: Colors.purple,
    eipPattern: 'Recipient List',
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _dynamicRouter() => const ComponentTemplate(
    id: 'dynamic-router',
    name: 'Dynamic Router',
    description: 'Route dynamically',
    categoryId: 'routing',
    icon: Icons.route,
    color: Colors.purple,
    eipPattern: 'Dynamic Router',
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _multicast() => const ComponentTemplate(
    id: 'multicast',
    name: 'Multicast',
    description: 'Send to all endpoints',
    categoryId: 'routing',
    icon: Icons.broadcast_on_home,
    color: Colors.purple,
    eipPattern: 'Multicast',
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _loadBalancer() => const ComponentTemplate(
    id: 'load-balancer',
    name: 'Load Balancer',
    description: 'Distribute load',
    categoryId: 'routing',
    icon: Icons.balance,
    color: Colors.purple,
    eipPattern: 'Load Balancer',
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _routingSlip() => const ComponentTemplate(
    id: 'routing-slip',
    name: 'Routing Slip',
    description: 'Route via slip',
    categoryId: 'routing',
    icon: Icons.receipt_long,
    color: Colors.purple,
    eipPattern: 'Routing Slip',
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _resequencer() => const ComponentTemplate(
    id: 'resequencer',
    name: 'Resequencer',
    description: 'Reorder messages',
    categoryId: 'routing',
    icon: Icons.reorder,
    color: Colors.purple,
    eipPattern: 'Resequencer',
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _transformer() => const ComponentTemplate(
    id: 'transformer',
    name: 'Transformer',
    description: 'Transform message',
    categoryId: 'transformation',
    icon: Icons.change_circle,
    color: Colors.orange,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _validator() => const ComponentTemplate(
    id: 'validator',
    name: 'Validator',
    description: 'Validate message',
    categoryId: 'transformation',
    icon: Icons.check_circle,
    color: Colors.orange,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _normalizer() => const ComponentTemplate(
    id: 'normalizer',
    name: 'Normalizer',
    description: 'Normalize format',
    categoryId: 'transformation',
    icon: Icons.settings_suggest,
    color: Colors.orange,
    eipPattern: 'Normalizer',
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _claimCheck() => const ComponentTemplate(
    id: 'claim-check',
    name: 'Claim Check',
    description: 'Store and retrieve payload',
    categoryId: 'transformation',
    icon: Icons.bookmark,
    color: Colors.orange,
    eipPattern: 'Claim Check',
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _scriptProcessor() => const ComponentTemplate(
    id: 'script-processor',
    name: 'Script',
    description: 'Execute script',
    categoryId: 'processors',
    icon: Icons.code,
    color: Colors.indigo,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _customProcessor() => const ComponentTemplate(
    id: 'custom-processor',
    name: 'Custom Processor',
    description: 'Custom processing',
    categoryId: 'processors',
    icon: Icons.build,
    color: Colors.indigo,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _delay() => const ComponentTemplate(
    id: 'delay',
    name: 'Delay',
    description: 'Delay processing',
    categoryId: 'processors',
    icon: Icons.schedule,
    color: Colors.indigo,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _throttle() => const ComponentTemplate(
    id: 'throttle',
    name: 'Throttle',
    description: 'Throttle messages',
    categoryId: 'processors',
    icon: Icons.speed,
    color: Colors.indigo,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _setHeader() => const ComponentTemplate(
    id: 'set-header',
    name: 'Set Header',
    description: 'Set message header',
    categoryId: 'processors',
    icon: Icons.title,
    color: Colors.indigo,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _setProperty() => const ComponentTemplate(
    id: 'set-property',
    name: 'Set Property',
    description: 'Set exchange property',
    categoryId: 'processors',
    icon: Icons.text_fields,
    color: Colors.indigo,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _removeHeader() => const ComponentTemplate(
    id: 'remove-header',
    name: 'Remove Header',
    description: 'Remove header',
    categoryId: 'processors',
    icon: Icons.remove_circle,
    color: Colors.indigo,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _errorHandler() => const ComponentTemplate(
    id: 'error-handler',
    name: 'Error Handler',
    description: 'Handle errors',
    categoryId: 'error',
    icon: Icons.error_outline,
    color: Colors.red,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _deadLetterChannel() => const ComponentTemplate(
    id: 'dead-letter-channel',
    name: 'Dead Letter Channel',
    description: 'Send failed messages',
    categoryId: 'error',
    icon: Icons.block,
    color: Colors.red,
    eipPattern: 'Dead Letter Channel',
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _onException() => const ComponentTemplate(
    id: 'on-exception',
    name: 'On Exception',
    description: 'Exception handling',
    categoryId: 'error',
    icon: Icons.report_problem,
    color: Colors.red,
    defaultConfig: {},
    properties: [],
  );

  static ComponentTemplate _retry() => const ComponentTemplate(
    id: 'retry',
    name: 'Retry',
    description: 'Retry on failure',
    categoryId: 'error',
    icon: Icons.refresh,
    color: Colors.red,
    defaultConfig: {},
    properties: [],
  );
}
