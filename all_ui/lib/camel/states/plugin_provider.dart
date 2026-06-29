import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/component_template.dart';
import '../models/plugin.dart';

final pluginsProvider = StateProvider<List<Plugin>>((ref) {
  return [
    Plugin(
      id: 'aws-plugin',
      name: 'AWS Integration',
      version: '1.0.0',
      description: 'Amazon Web Services components',
      icon: Icons.cloud,
      components: [
        ComponentTemplate(
          id: 'aws-s3',
          name: 'AWS S3',
          category: 'destination',
          icon: Icons.storage,
          color: Colors.orange,
          defaultConfig: {'bucket': '', 'region': 'us-east-1'},
          description: 'Amazon S3 storage integration',
          tags: ['aws', 'storage', 'cloud'],
          properties: [],
        ),
        ComponentTemplate(
          id: 'aws-lambda',
          name: 'AWS Lambda',
          category: 'processor',
          icon: Icons.functions,
          color: Colors.orange,
          defaultConfig: {'function': '', 'region': 'us-east-1'},
          description: 'AWS Lambda function invocation',
          tags: ['aws', 'serverless', 'compute'],
          properties: [],
        ),
      ],
    ),
    Plugin(
      id: 'azure-plugin',
      name: 'Azure Integration',
      version: '1.0.0',
      description: 'Microsoft Azure components',
      icon: Icons.cloud_circle,
      components: [
        ComponentTemplate(
          id: 'azure-blob',
          name: 'Azure Blob',
          category: 'destination',
          icon: Icons.storage,
          color: Colors.blue,
          defaultConfig: {'container': '', 'connectionString': ''},
          description: 'Azure Blob Storage integration',
          tags: ['azure', 'storage', 'cloud'],
          properties: [],
        ),
      ],
    ),
    Plugin(
      id: 'monitoring-plugin',
      name: 'Advanced Monitoring',
      version: '1.0.0',
      description: 'Prometheus, Grafana, DataDog integration',
      icon: Icons.monitor_heart,
      components: [
        ComponentTemplate(
          id: 'prometheus',
          name: 'Prometheus',
          category: 'destination',
          icon: Icons.analytics,
          color: Colors.red,
          defaultConfig: {'endpoint': 'http://prometheus:9090'},
          description: 'Prometheus metrics export',
          tags: ['monitoring', 'metrics', 'observability'],
          properties: [],
        ),
      ],
    ),
  ];
});
