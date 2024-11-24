import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:last/services/chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

String _formatTime() {
  return DateFormat('HH:mm').format(DateTime.now());
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
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Aa',
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        IconButton(
          icon: Icon(
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

  // Hidden system prompt (not shown in the chat UI)
  final Map<String, String> _systemPrompt = {
    'role': 'system',
    'content': 'Ты моя лучшая подруга, с которой я могу обсудить разные женские темы. Давай поговорим как близкие друзья!'
  };

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _sendDailyAffirmation(); // Send daily affirmation
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
        _setDefaultMessages();
      }
    } catch (e) {
      print("Error loading messages: $e");
      _setDefaultMessages();
    }
  }

  void _setDefaultMessages() {
    setState(() {
      _messages = [
        {
          'role': 'assistant',
          'content': 'Привет, Мадина!',
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

  Future<void> _sendDailyAffirmation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int today = DateTime.now().weekday; // Get current weekday (1 = Monday, 7 = Sunday)

      // Check if the affirmation for today has already been sent
      int? lastAffirmationDay = prefs.getInt('lastAffirmationDay');
      if (lastAffirmationDay == today) return;

      // Fetch the daily affirmation
      String affirmation = await _chatService.fetchDailyAffirmation(today);

      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': affirmation,
          'time': _formatTime(),
        });
      });

      // Save the last affirmation day and updated messages
      prefs.setInt('lastAffirmationDay', today);
      await _saveMessages();
    } catch (e) {
      print("Error sending daily affirmation: $e");
    }
  }

  Future<void> _sendMessage() async {
    String messageText = _messageController.text;

    if (messageText.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'role': 'user',
          'content': messageText,
          'time': _formatTime(),
        });
        _isLoading = true;
      });

      _messageController.clear();
      await _saveMessages(); // Save message history after adding the user's message

      try {
        // Prepare the chat history for the API request, including the hidden system prompt
        List<Map<String, String>> chatHistory = [
          _systemPrompt,
          ..._messages.map((msg) {
            return {
              'role': msg['role'] as String,
              'content': msg['content'] as String,
            };
          }).toList(),
        ];

        // Send the message history to the chat service
        String response = await _chatService.sendMessage(chatHistory);

        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': response,
            'time': _formatTime(),
          });
        });
        await _saveMessages(); // Save updated message history
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
        await _saveMessages(); // Save messages in case of an error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: Icon(
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
            CircleAvatar(
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return MessageBubble(
                  message: message['content'],
                  time: message['time'] ?? '',
                  isSentByMe: message['role'] == 'user',
                );
              },
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: inputField(
              controller: _messageController,
              onSendPressed: _sendMessage,
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;
  final String time;

  MessageBubble({
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
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
            SizedBox(width: 8.0),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
              decoration: BoxDecoration(
                color: isSentByMe ? Color(0xFFC575C7) : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: isSentByMe ? Radius.circular(20) : Radius.circular(0),
                  bottomRight: isSentByMe ? Radius.circular(0) : Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message ?? '',
                    style: TextStyle(
                      color: isSentByMe ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time ?? '',
                        style: TextStyle(
                          color: isSentByMe ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      if (isSentByMe) ...[
                        SizedBox(width: 4),
                        Icon(
                          Icons.check_circle,
                          color: Colors.white.withOpacity(0.8),
                          size: 14,
                        ),
                      ]
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
