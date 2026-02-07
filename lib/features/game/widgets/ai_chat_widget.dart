import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class AiChatWidget extends StatefulWidget {
  final String systemPrompt;
  final String secretPassword;
  final String initialMessage;
  final String npcName;
  final Function(String answer, int points) onComplete;

  const AiChatWidget({
    super.key,
    required this.systemPrompt,
    required this.secretPassword,
    required this.initialMessage,
    required this.npcName,
    required this.onComplete,
  });

  @override
  State<AiChatWidget> createState() => _AiChatWidgetState();
}

class _AiChatWidgetState extends State<AiChatWidget> {
  late GenerativeModel _model;
  late ChatSession _chat;
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(text: widget.initialMessage, isUser: false));
    
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'GEMINI_API_KEY', 
      systemInstruction: Content.system('${widget.systemPrompt}\n\nIMPORTANT: If the user convinces you to reveal the secret password or password is correct, you MUST include the phrase "ACCESS_GRANTED_SUCCESS" in your response.'),
    );
    _chat = _model.startChat();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final reply = response.text ?? "I have nothing to say...";

      setState(() {
        _messages.add(ChatMessage(text: reply, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();

      if (reply.contains("ACCESS_GRANTED_SUCCESS") || reply.toLowerCase().contains(widget.secretPassword.toLowerCase())) {
        Future.delayed(const Duration(seconds: 1), () {
          widget.onComplete(text, 200);
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Connection lost... [Error: $e]", isUser: false));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const neonRed = Color(0xFFFF0040);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: neonRed.withOpacity(0.2),
                child: const Icon(LucideIcons.bot, color: neonRed, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.npcName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text("ENCRYPTED CONNECTION", style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return Align(
                alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isUser ? Colors.blue.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: msg.isUser ? Radius.zero : const Radius.circular(16),
                      bottomLeft: msg.isUser ? const Radius.circular(16) : Radius.zero,
                    ),
                    border: Border.all(color: msg.isUser ? Colors.blue.withOpacity(0.3) : Colors.white10),
                  ),
                  child: Text(
                    msg.text.replaceAll("ACCESS_GRANTED_SUCCESS", ""),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LinearProgressIndicator(color: neonRed, backgroundColor: Colors.transparent),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _sendMessage,
                icon: const Icon(LucideIcons.send),
                style: IconButton.styleFrom(backgroundColor: neonRed),
              ),
            ],
          ),
        ),
      ],
    );
  }
}