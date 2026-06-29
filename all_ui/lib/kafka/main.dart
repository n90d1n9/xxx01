// Main App Setup
import 'package:flutter/material.dart';

import 'screens/management_screen.dart';
import 'services/kafka_auth_service.dart';
import 'services/kafka_management_service.dart';

class KafkaManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<KafkaService>(
          create: (_) => KafkaService(KafkaClient()),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'Kafka Management',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: KafkaManagementScreen(),
      ),
    );
  }
}

// Main App Configuration
class KafkaManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<KafkaAuthService>(create: (_) => KafkaAuthService()),
        Provider<KafkaManagementService>(
          create: (_) => KafkaManagementService(KafkaClient()),
        ),
      ],
      child: MaterialApp(
        title: 'Advanced Kafka Management',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AdvancedKafkaManagementScreen(),
      ),
    );
  }
}
