import 'package:flutter/material.dart';

class SearchInChatScreen extends StatelessWidget {
  final String roomId;

  const SearchInChatScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search in Chat')),
      body: Center(child: Text('Search in Chat Screen')),
    );
  }
}
