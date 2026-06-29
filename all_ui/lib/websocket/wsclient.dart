import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: KafkaMessagesScreen());
  }
}

class KafkaMessagesScreen extends StatefulWidget {
  const KafkaMessagesScreen({super.key});

  @override
  _KafkaMessagesScreenState createState() => _KafkaMessagesScreenState();
}

class _KafkaMessagesScreenState extends State<KafkaMessagesScreen> {
  late WebSocketChannel channel;
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(
      //Uri.parse('ws://localhost:8080/ws/events'),
      Uri.parse('ws://localhost:8080/start-websocket/aba'),
    );

    channel.stream.listen((message) {
      setState(() {
        print(message);
        messages.add(message);
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kafka Messages')),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(messages[index]));
        },
      ),
    );
  }
}
