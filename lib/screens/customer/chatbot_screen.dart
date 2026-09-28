import 'package:flutter/material.dart';

import '../../widgets/harvi_avatar.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  HarviExpression _expression = HarviExpression.greeting;

  final Map<String, String> _qaDictionary = {
    'hello': 'Hello! I am Harvi, your AI Farm Assistant. How can I help you?',
    'hi': 'Hi there! What farming or product questions do you have?',
    'how to store tomatoes': 'Store tomatoes at room temperature away from direct sunlight. Do not refrigerate them as it affects their flavor and texture.',
    'how to store potatoes': 'Store potatoes in a cool, dark, and well-ventilated place. Keep them away from onions to prevent them from sprouting too quickly.',
    'what is organic farming': 'Organic farming relies on natural principles like composting and crop rotation, without synthetic fertilizers or pesticides.',
    'best season for apples': 'Apples are typically best harvested in late summer through autumn.',
    'default': 'I am currently operating in offline demo mode. I can answer basic questions like "how to store tomatoes" or "what is organic farming".'
  };

  @override
  void initState() {
    super.initState();

    _messages.add(
      ChatMessage(
        text: "Hello! I am Harvi, your AI Farm Assistant. How can I help you with agriculture, nutrition, or storage tips today?",
        isUser: false,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _expression == HarviExpression.greeting) {
        setState(() {
          _expression = HarviExpression.idle;
        });
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
      _expression = HarviExpression.thinking;
    });
    _controller.clear();
    _scrollToBottom();

    // Simulated network delay
    await Future.delayed(const Duration(seconds: 1));

    String lowercaseText = text.toLowerCase();
    String responseText = _qaDictionary['default']!;

    for (var key in _qaDictionary.keys) {
      if (key != 'default' && lowercaseText.contains(key)) {
        responseText = _qaDictionary[key]!;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _expression = HarviExpression.talking;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _expression = HarviExpression.idle);
      });

      setState(() {
        _messages.add(ChatMessage(text: responseText, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF9FBF9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                HarviAvatar(expression: _expression, size: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Harvi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      Text(
                        _expression == HarviExpression.thinking
                            ? 'Thinking...'
                            : _expression == HarviExpression.talking
                            ? 'Typing...'
                            : 'Online',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? const Color(0xFF1B5E20)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomRight: msg.isUser
                            ? const Radius.circular(0)
                            : const Radius.circular(20),
                        bottomLeft: msg.isUser
                            ? const Radius.circular(20)
                            : const Radius.circular(0),
                      ),
                      boxShadow: [
                        if (!msg.isUser)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser
                            ? Colors.white
                            : const Color(0xFF1F2937),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
            ),

          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask Harvi something...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B5E20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
