import 'package:flutter/material.dart';

enum IntegrationType {
  http,
  rest,
  soap,
  graphql,
  grpc,
  kafka,
  rabbitmq,
  activemq,
  mqtt,
  amqp,
  database,
  sql,
  mongodb,
  redis,
  elasticsearch,
  file,
  ftp,
  sftp,
  s3,
  azureBlob,
  email,
  smtp,
  imap,
  websocket,
  sse,
  slack,
  discord,
  telegram,
  salesforce,
  hubspot,
  stripe,
  custom,
}

extension IntegrationTypeExtension on IntegrationType {
  String get displayName => name.replaceAll('_', ' ').toUpperCase();

  IconData get icon {
    switch (this) {
      case IntegrationType.http:
      case IntegrationType.rest:
        return Icons.http;
      case IntegrationType.kafka:
      case IntegrationType.rabbitmq:
      case IntegrationType.mqtt:
        return Icons.message;
      case IntegrationType.database:
      case IntegrationType.sql:
      case IntegrationType.mongodb:
        return Icons.storage;
      case IntegrationType.file:
      case IntegrationType.ftp:
      case IntegrationType.s3:
        return Icons.folder;
      case IntegrationType.email:
      case IntegrationType.smtp:
        return Icons.email;
      case IntegrationType.websocket:
        return Icons.cable;
      case IntegrationType.slack:
      case IntegrationType.discord:
      case IntegrationType.telegram:
        return Icons.chat;
      default:
        return Icons.integration_instructions;
    }
  }
}
