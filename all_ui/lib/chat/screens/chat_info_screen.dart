import 'package:flutter/material.dart';

import '../models/chat_room.dart';

class ChatInfoScreen extends StatelessWidget {
  final ChatRoom room;

  const ChatInfoScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Info')),
      body: Center(child: Text('Chat Info Screen')),
    );
  }
}
