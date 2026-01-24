import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_widgets.dart';
import '../../shared/widgets/premium_background.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/ai_service.dart';

/// AI Chat Screen - Islamic Q&A with LLM
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final AIService _aiService = getIt<AIService>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Suggested queries for quick access
  final List<String> _suggestedQueries = [
    'Explain Surah Al-Fatiha',
    'Dua for anxiety',
    'What is Tawhid?',
    'Steps for Wudu',
    'Importance of Salah',
    'What does Islam say about patience?',
  ];

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(ChatMessage(
      id: const Uuid().v4(),
      content: '''Assalamu Alaikum! 🤲

I'm your Islamic knowledge assistant. I can help you with:

• **Quran explanations** and Tafsir
• **Hadith** references and meanings
• **Dua suggestions** for different situations
• **Islamic guidance** on daily life

How can I help you today?''',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      content: text.trim(),
      isUser: true,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await _aiService.sendMessage(text);
      
      final aiMessage = ChatMessage(
        id: const Uuid().v4(),
        content: response,
        isUser: false,
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          id: const Uuid().v4(),
          content: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
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
    return Stack(
      children: [
        const PremiumBackgroundWithParticles(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                       const BackButton(color: Colors.white),
                       Expanded(child: TopBar(title: "Iman Flow AI", subtitle: "Powered by Islamic Knowledge")),
                    ],
                  ),
                ),
                
                // Chat Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
                ),

                // Suggested Queries (when chat is minimal)
                if (_messages.length <= 2)
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _suggestedQueries.length,
                      separatorBuilder: (c, i) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return ActionChip(
                          label: Text(_suggestedQueries[index]),
                          onPressed: () => _sendMessage(_suggestedQueries[index]),
                          backgroundColor: ImanFlowTheme.glass2,
                          side: BorderSide.none,
                          labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        );
                      },
                    ),
                  ),

                // Input Area
                Padding(
                  padding: EdgeInsets.fromLTRB(14, 12, 14, MediaQuery.of(context).padding.bottom + 12),
                  child: Glass(
                    radius: 24,
                    padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Ask about Islam...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                              border: InputBorder.none,
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: _sendMessage,
                          ),
                        ),
                        IconButton(
                          onPressed: _isLoading ? null : () => _sendMessage(_messageController.text),
                          icon: Icon(Icons.send_rounded, color: _isLoading ? Colors.white38 : ImanFlowTheme.gold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? ImanFlowTheme.emeraldGlow.withOpacity(0.2) : ImanFlowTheme.glass2,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: Border.all(
            color: isUser ? ImanFlowTheme.emeraldGlow.withOpacity(0.3) : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             if (!isUser) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 12, color: ImanFlowTheme.gold),
                    const SizedBox(width: 6),
                    Text("Iman AI", style: TextStyle(color: ImanFlowTheme.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
             ],
             Text(message.content, style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 15)),
           ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
     return Align(
       alignment: Alignment.centerLeft,
       child: Container(
         margin: const EdgeInsets.only(bottom: 14),
         padding: const EdgeInsets.all(16),
         decoration: BoxDecoration(
           color: ImanFlowTheme.glass,
           borderRadius: BorderRadius.circular(16),
         ),
         child: const SizedBox(
           width: 24, height: 24,
           child: CircularProgressIndicator(strokeWidth: 2, color: ImanFlowTheme.gold),
         ),
       ),
     );
  }

  void _showAiDisclaimer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ImanFlowTheme.bgMid,
        title: Row(
          children: [
             Icon(Icons.info_outline, color: ImanFlowTheme.gold),
             const SizedBox(width: 8),
             const Text('AI Assistant', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'This assistant provides information based on Islamic sources but may make mistakes. Always verify with scholars for important rulings.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood', style: TextStyle(color: ImanFlowTheme.gold)),
          ),
        ],
      ),
    );
  }
}
