import 'package:flutter/material.dart';

class ModernChatbot extends StatefulWidget {
  const ModernChatbot({Key? key}) : super(key: key);

  @override
  State<ModernChatbot> createState() => _ModernChatbotState();
}

class _ModernChatbotState extends State<ModernChatbot>
    with TickerProviderStateMixin {
  bool _isChatOpen = false;
  late AnimationController _fabController;
  late AnimationController _chatController;
  late AnimationController _pulseController;
  late Animation<double> _fabRotation;
  late Animation<double> _chatSlide;
  late Animation<double> _chatOpacity;
  late Animation<double> _pulseAnimation;

  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();

    // FAB rotation animation
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabRotation = Tween<double>(
      begin: 0,
      end: 0.125,
    ).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeInOut));

    // Chat bubble slide and opacity animations
    _chatController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _chatSlide = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(parent: _chatController, curve: Curves.elasticOut),
    );
    _chatOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _chatController, curve: Curves.easeIn));

    // Pulse animation for FAB
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startPulseAnimation();
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });

    if (_isChatOpen) {
      _fabController.forward();
      _chatController.forward();
      _pulseController.stop();
    } else {
      _fabController.reverse();
      _chatController.reverse();
      _startPulseAnimation();
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: _messageController.text.trim(),
            isUser: true,
            timestamp: DateTime.now(),
          ),
        );
      });

      // Simulate bot response
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _messages.add(
            ChatMessage(
              text: "Thanks for your message! How can I help you today?",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      });

      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _fabController.dispose();
    _chatController.dispose();
    _pulseController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content area
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade50, Colors.purple.shade50],
              ),
            ),
            child: const Center(
              child: Text(
                'Your App Content Here',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            ),
          ),

          // Chat bubble overlay
          if (_isChatOpen)
            AnimatedBuilder(
              animation: _chatController,
              builder: (context, child) {
                return Positioned(
                  bottom: 100,
                  right: 16,
                  child: Transform.translate(
                    offset: Offset(0, _chatSlide.value),
                    child: Opacity(
                      opacity: _chatOpacity.value,
                      child: _buildChatBubble(),
                    ),
                  ),
                );
              },
            ),

          // Floating Action Button
          Positioned(
            bottom: 16,
            right: 16,
            child: AnimatedBuilder(
              animation: Listenable.merge([_fabController, _pulseController]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Transform.rotate(
                    angle: _fabRotation.value * 2 * 3.14159,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade400,
                            Colors.purple.shade400,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        onPressed: _toggleChat,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _isChatOpen ? Icons.close : Icons.chat,
                            key: ValueKey(_isChatOpen),
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble() {
    return Container(
      width: 320,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade400, Colors.purple.shade400],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Assistant',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Online now',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Messages area
          Expanded(
            child:
                _messages.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.waving_hand,
                            size: 48,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Hello! How can I help you?',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.purple.shade400],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    message.isUser
                        ? Colors.blue.shade500
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 16, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// Usage example:
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Chatbot',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ModernChatbot(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(const MyApp());
}
