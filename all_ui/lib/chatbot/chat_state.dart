import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Models
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String id;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? id,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      id: id ?? this.id,
    );
  }
}

// State classes
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  const ChatState({this.messages = const [], this.isLoading = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatUIState {
  final bool isChatOpen;
  final String currentMessage;

  const ChatUIState({this.isChatOpen = false, this.currentMessage = ''});

  ChatUIState copyWith({bool? isChatOpen, String? currentMessage}) {
    return ChatUIState(
      isChatOpen: isChatOpen ?? this.isChatOpen,
      currentMessage: currentMessage ?? this.currentMessage,
    );
  }
}

// Providers
final chatStateProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

final chatUIProvider = StateNotifierProvider<ChatUINotifier, ChatUIState>((
  ref,
) {
  return ChatUINotifier();
});

// State Notifiers
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    // Simulate bot response delay
    await Future.delayed(const Duration(milliseconds: 800));

    final botMessage = ChatMessage(
      text: _generateBotResponse(text),
      isUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, botMessage],
      isLoading: false,
    );
  }

  String _generateBotResponse(String userMessage) {
    final responses = [
      "Thanks for your message! How can I help you today?",
      "That's interesting! Tell me more about that.",
      "I understand. Is there anything specific you'd like to know?",
      "Great question! Let me help you with that.",
      "I'm here to assist you. What would you like to explore?",
    ];

    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return "Hello! Nice to meet you. How can I assist you today?";
    } else if (lowerMessage.contains('help')) {
      return "I'm here to help! What do you need assistance with?";
    } else if (lowerMessage.contains('thank')) {
      return "You're welcome! Is there anything else I can help you with?";
    }

    return responses[DateTime.now().millisecond % responses.length];
  }

  void clearMessages() {
    state = const ChatState();
  }
}

class ChatUINotifier extends StateNotifier<ChatUIState> {
  ChatUINotifier() : super(const ChatUIState());

  void toggleChat() {
    state = state.copyWith(isChatOpen: !state.isChatOpen);
  }

  void updateMessage(String message) {
    state = state.copyWith(currentMessage: message);
  }

  void clearMessage() {
    state = state.copyWith(currentMessage: '');
  }

  void openChat() {
    state = state.copyWith(isChatOpen: true);
  }

  void closeChat() {
    state = state.copyWith(isChatOpen: false);
  }
}

// Main Chatbot Widget
class ModernChatbot extends ConsumerStatefulWidget {
  const ModernChatbot({Key? key}) : super(key: key);

  @override
  ConsumerState<ModernChatbot> createState() => _ModernChatbotState();
}

class _ModernChatbotState extends ConsumerState<ModernChatbot>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late AnimationController _chatController;
  late AnimationController _pulseController;
  late Animation<double> _fabRotation;
  late Animation<double> _chatSlide;
  late Animation<double> _chatOpacity;
  late Animation<double> _pulseAnimation;

  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startPulseAnimation();
  }

  void _initializeAnimations() {
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
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  void _handleChatToggle() {
    final chatUI = ref.read(chatUIProvider.notifier);
    chatUI.toggleChat();

    final isOpen = ref.read(chatUIProvider).isChatOpen;

    if (isOpen) {
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
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      ref.read(chatStateProvider.notifier).sendMessage(message);
      ref.read(chatUIProvider.notifier).clearMessage();
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
    final chatUI = ref.watch(chatUIProvider);

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
          if (chatUI.isChatOpen)
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
                      child: const ChatBubbleWidget(),
                    ),
                  ),
                );
              },
            ),

          // Floating Action Button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingChatButton(
              onPressed: _handleChatToggle,
              fabController: _fabController,
              pulseController: _pulseController,
              fabRotation: _fabRotation,
              pulseAnimation: _pulseAnimation,
            ),
          ),
        ],
      ),
    );
  }
}

// Floating Chat Button Widget
class FloatingChatButton extends ConsumerWidget {
  final VoidCallback onPressed;
  final AnimationController fabController;
  final AnimationController pulseController;
  final Animation<double> fabRotation;
  final Animation<double> pulseAnimation;

  const FloatingChatButton({
    Key? key,
    required this.onPressed,
    required this.fabController,
    required this.pulseController,
    required this.fabRotation,
    required this.pulseAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatUI = ref.watch(chatUIProvider);

    return AnimatedBuilder(
      animation: Listenable.merge([fabController, pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: pulseAnimation.value,
          child: Transform.rotate(
            angle: fabRotation.value * 2 * 3.14159,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
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
                onPressed: onPressed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    chatUI.isChatOpen ? Icons.close : Icons.chat,
                    key: ValueKey(chatUI.isChatOpen),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Chat Bubble Widget
class ChatBubbleWidget extends ConsumerWidget {
  const ChatBubbleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatStateProvider);

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
          const ChatHeader(),
          Expanded(
            child:
                chatState.messages.isEmpty
                    ? const ChatWelcomeWidget()
                    : ChatMessagesWidget(messages: chatState.messages),
          ),
          if (chatState.isLoading) const ChatLoadingWidget(),
          const ChatInputWidget(),
        ],
      ),
    );
  }
}

// Chat Header Widget
class ChatHeader extends StatelessWidget {
  const ChatHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
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
    );
  }
}

// Chat Welcome Widget
class ChatWelcomeWidget extends StatelessWidget {
  const ChatWelcomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.waving_hand, size: 48, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Hello! How can I help you?',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Chat Messages Widget
class ChatMessagesWidget extends StatelessWidget {
  final List<ChatMessage> messages;

  const ChatMessagesWidget({Key? key, required this.messages})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return MessageBubbleWidget(message: messages[index]);
      },
    );
  }
}

// Message Bubble Widget
class MessageBubbleWidget extends StatelessWidget {
  final ChatMessage message;

  const MessageBubbleWidget({Key? key, required this.message})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
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

// Chat Loading Widget
class ChatLoadingWidget extends StatelessWidget {
  const ChatLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade400,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Typing...',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Chat Input Widget
class ChatInputWidget extends ConsumerStatefulWidget {
  const ChatInputWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends ConsumerState<ChatInputWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      ref.read(chatStateProvider.notifier).sendMessage(message);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                controller: _controller,
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
    );
  }
}

// Usage example with ProviderScope
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Modern Chatbot with Riverpod',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const ModernChatbot(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
