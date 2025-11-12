import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'widgets/bottom_nav.dart';

const String API_ENDPOINT = 'https://api.intelligence.io.solutions/api/v1/chat/completions';
const String API_KEY = 'io-v2-your-api-key';
const String MODEL_ID = 'openai/gpt-oss-120b';
const String LOCAL_CHAT_KEY = 'local_chat';

class ChatPage extends StatefulWidget {
  final String userId;
  const ChatPage({super.key, required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<_ChatMessage> _messages = [];
  bool _loading = false;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadChat();
  }

  String get _systemPrompt => '''
Ты — Ноизи 🐶, ламповая осенняя собака-менеджер.
Отвечай коротко и дружелюбно на русском.
''';

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text));
      _loading = true;
      _controller.clear();
    });
    _saveChat();

    final payloadMessages = <Map<String, String>>[
      {"role": "system", "content": _systemPrompt},
      ..._messages.map((m) => {"role": m.role, "content": m.content}),
    ];

    final payload = {
      "model": MODEL_ID,
      "messages": payloadMessages,
      "max_tokens": 512,
      "temperature": 0.8,
    };

    try {
      final resp = await http.post(
        Uri.parse(API_ENDPOINT),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $API_KEY',
        },
        body: jsonEncode(payload),
      );

      String reply = 'Упс... задумалась я на осеннем ветру 🍂';

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['choices'] != null && (data['choices'] as List).isNotEmpty) {
          final first = (data['choices'] as List).first;
          reply = first['message']?['content']?.toString() ??
              first['text']?.toString() ??
              reply;
        }
      } else {
        reply = 'Ошибка сервера (${resp.statusCode}) 😔';
      }

      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', content: reply));
      });
      _saveChat();
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
            role: 'assistant',
            content: 'Интернет убежал гулять 🍂\n$e'));
      });
      _saveChat();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadChat() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(LOCAL_CHAT_KEY);
    if (data != null) {
      try {
        final list = jsonDecode(data) as List<dynamic>;
        setState(() {
          _messages = list.map((e) {
            return _ChatMessage(
              role: (e['role'] ?? 'assistant').toString(),
              content: (e['content'] ?? '').toString(),
            );
          }).toList();
        });
      } catch (e) {
        setState(() {
          _messages = [];
        });
        await prefs.remove(LOCAL_CHAT_KEY);
      }
    }
  }

  Future<void> _saveChat() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _messages
        .map((e) => {'role': e.role, 'content': e.content})
        .toList();
    await prefs.setString(LOCAL_CHAT_KEY, jsonEncode(list));
  }

  Future<void> _clearChat() async {
    setState(() {
      _messages.clear();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(LOCAL_CHAT_KEY);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onBottomTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/choice_tests', arguments: widget.userId);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map_page', arguments: widget.userId);
        break;
      case 2:
        // Already on chat page
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/professions', arguments: widget.userId);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile', arguments: widget.userId);
        break;
    }
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    final isUser = msg.role == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFEF3124),
                child: Text('🐶', style: TextStyle(fontSize: 14)),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFFEF3124) : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                msg.content,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Чат с Ноизи 🐶'),
        backgroundColor: const Color(0xFF0A0F2D),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: _messages.length,
                itemBuilder: (context, i) => _buildMessageBubble(_messages[i]),
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFEF3124),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Напиши сообщение...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor:
                    _loading ? Colors.grey : const Color(0xFFEF3124),
                    child: IconButton(
                      onPressed: _loading ? null : _sendMessage,
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                  IconButton(
                    onPressed: _clearChat,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onBottomTap,
        userId: widget.userId,
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String content;
  _ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}