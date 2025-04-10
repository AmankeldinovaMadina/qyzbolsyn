import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:last/services/chat_service.dart';

String _formatTime() {
  return DateFormat('HH:mm').format(DateTime.now());
}

Future<String> getUsername() async {
  User? user = FirebaseAuth.instance.currentUser;
  await user?.reload();
  return user?.displayName ?? 'подруга';
}

Widget inputField({
  required TextEditingController controller,
  required VoidCallback onSendPressed,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Aa',
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        IconButton(
          icon: const Icon(
            Icons.chevron_right,
            color: Color(0xFFC575C7),
            size: 32,
          ),
          onPressed: onSendPressed,
        ),
      ],
    ),
  );
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _messages = [];
  String _typingMessage = ''; // Message being animated

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedMessages = prefs.getString('chatMessages');

      if (savedMessages != null) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(json.decode(savedMessages));
        });
      } else {
        await _setDefaultMessages();
      }
    } catch (e) {
      print("Error loading messages: $e");
      await _setDefaultMessages();
    }
  }

  Future<void> _setDefaultMessages() async {
    String username = await getUsername();
    setState(() {
      _messages = [
        {
          'role': 'assistant',
          'content': 'Привет, $username!',
          'time': _formatTime(),
        },
        {
          'role': 'assistant',
          'content': 'Рада тебя видеть! Как я могу тебе помочь?',
          'time': _formatTime(),
        },
      ];
    });
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('chatMessages', json.encode(_messages));
  }

  Future<void> _sendMessage() async {
    String messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      setState(() {
        _messages.add({
          'role': 'user',
          'content': messageText,
          'time': _formatTime(),
        });
        _isLoading = true;
      });

      _messageController.clear();
      await _saveMessages();

      try {
        List<Map<String, String>> chatHistory = _messages.map((msg) {
          return {
            'role': msg['role'] as String,
            'content': msg['content'] as String,
          };
        }).toList();

        String response = await _chatService.sendMessage(chatHistory);

        _animateTyping(response);
      } catch (e) {
        print("Error: $e");
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': 'Ошибка: Не удалось загрузить ответ. Попробуйте снова.',
            'time': _formatTime(),
          });
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
        await _saveMessages();
      }
    }
  }

  void _animateTyping(String fullMessage) {
    const typingSpeed = Duration(milliseconds: 50); // Speed per character
    final StringBuffer buffer = StringBuffer();
    Timer? timer;

    timer = Timer.periodic(typingSpeed, (t) {
      if (buffer.length < fullMessage.length) {
        setState(() {
          buffer.write(fullMessage[buffer.length]);
          _typingMessage = buffer.toString();
        });
      } else {
        t.cancel();
        timer = null;

        // Add the full message to _messages after animation
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': fullMessage,
            'time': _formatTime(),
          });
          _typingMessage = ''; // Clear the typing animation
        });
        _saveMessages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Color(0xFFC575C7),
            size: 42,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Сая',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                Text(
                  'Бот - подруга',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_typingMessage.isNotEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (_typingMessage.isNotEmpty && index == 0) {
                  return MessageBubble(
                    message: _typingMessage,
                    time: '',
                    isSentByMe: false,
                  );
                }

                final message = _messages[_messages.length - 1 - index + (_typingMessage.isNotEmpty ? 1 : 0)];
                return MessageBubble(
                  message: message['content'],
                  time: message['time'] ?? '',
                  isSentByMe: message['role'] == 'user',
                );
              },
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: inputField(
              controller: _messageController,
              onSendPressed: _sendMessage,
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;
  final String time;

  const MessageBubble({
    required this.message,
    required this.isSentByMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSentByMe) ...[
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
            const SizedBox(width: 8.0),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
              decoration: BoxDecoration(
                color: isSentByMe ? const Color(0xFFC575C7) : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isSentByMe ? const Radius.circular(20) : const Radius.circular(0),
                  bottomRight: isSentByMe ? const Radius.circular(0) : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: isSentByMe ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: isSentByMe ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      if (isSentByMe)
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 14,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
