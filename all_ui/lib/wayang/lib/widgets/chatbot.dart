import 'package:flutter/material.dart';

class Chatbot extends StatefulWidget {
  final void Function()? onClosedChat;
  const Chatbot({super.key, required this.onClosedChat});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  TextEditingController _searchController = TextEditingController();
  bool isShowBubble = false;
  String responseMesssage = '';

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // button to close bubblt
                  _bubbleClosedButton(),

                  // Show bubble when send message
                  _bubble(),

                  // Chatbot field
                  _chatField()
                ])));
  }

  Widget _chatField() => Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari atau tanya...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
            Positioned(
                top: 5,
                right: 5,
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        isShowBubble = true;
                        responseMesssage =
                            'Saya akan bantu cari ${_searchController.text}';
                      });
                    },
                    icon: const Icon(Icons.send)))
          ],
        ),
      );

  Widget _bubbleClosedButton() => Align(
      alignment: Alignment.centerRight,
      child: IconButton(
          onPressed: widget.onClosedChat, icon: const Icon(Icons.close)));

  Widget _bubble() => Visibility(
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      visible: isShowBubble,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          responseMesssage,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ));
}
