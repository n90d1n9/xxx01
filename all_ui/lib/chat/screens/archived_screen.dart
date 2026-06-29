import 'package:flutter/material.dart';

class ArchivedChatsScreen extends StatelessWidget {
  const ArchivedChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Archived Chats')),
      body: Center(child: Text('Archived Chats Screen')),
    );
  }
}
