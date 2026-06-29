import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:giphy_picker/giphy_picker.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(message: message, isSentByMe: true));
        _messageController.clear();
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _messages.add(ChatMessage(image: pickedFile.path, isSentByMe: true));
      });
    }
  }

  Future<void> _pickFile() async {
    String? filePath = await FilePicker.platform.pickFiles().then((value) => value!.files.first.path);
    if (filePath != null) {
      setState(() {
        _messages.add(ChatMessage(file: filePath, isSentByMe: true));
      });
    }
  }

  Future<void> _pickGif() async {
    final gif = await GiphyPicker.pickGif(context: context, apiKey: 'FpmedydoBruNCYt3QH3GmJaB5puKgB8I');
    if (gif != null) {
      setState(() {
        _messages.add(ChatMessage(gifUrl: gif.images.original!.url, isSentByMe: true));
      });
    }
  }

  /* Future<void> _showStickerDialog() async {
    await showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Sticker'),
          content: Container(
            height: 200,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: 10, // Replace with actual sticker count
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _messages.add(ChatMessage(sticker: 'sticker${index + 1}', isSentByMe: true));
                      Navigator.pop(context);
                    });
                  },
                  child: Image.asset('assets/stickers/sticker${index + 1}.png'), // Replace with your sticker assets
                );
              },
            ),
          ),
        );
      },
    );
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildMessageItem(_messages[index]);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                ),
                IconButton(
                  onPressed: _pickFile,
                  icon: Icon(Icons.file_upload),
                ),
                IconButton(
                  onPressed: _pickGif,
                  icon: Icon(Icons.gif),
                ),
                /* IconButton(
                  onPressed: _showStickerDialog,
                  icon: Icon(Icons.emoji_emotions),
                ), */
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Align(
        alignment: message.isSentByMe ? Alignment.bottomRight : Alignment.bottomLeft,
        child: Column(
          crossAxisAlignment: message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.image != null)
              Image.file(
                File(message.image!),
                width: 200,
              ),
            if (message.file != null)
              Text(
                'File: ${message.file}',
                style: TextStyle(fontSize: 12),
              ),
            if (message.gifUrl != null)
              Image.network(
                message.gifUrl!,
                width: 200,
              ),
            if (message.sticker != null)
              Image.asset(
                'assets/stickers/${message.sticker}.png', // Replace with your sticker assets
                width: 50,
              ),
            if (message.message != null)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: message.isSentByMe ? Colors.blue[200] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  message.message!,
                  style: TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String? message;
  final String? image;
  final String? file;
  final String? gifUrl;
  final String? sticker;
  final bool isSentByMe;

  ChatMessage({this.message, this.image, this.file, this.gifUrl, this.sticker, required this.isSentByMe});
}