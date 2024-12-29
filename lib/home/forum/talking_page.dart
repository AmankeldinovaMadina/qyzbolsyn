import 'package:flutter/material.dart';
import 'package:last/home/forum/topic.dart';
import 'package:last/services/model/talk.dart';
import 'package:last/services/talk_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'message_bubble.dart'; // Import your MessageBubble widget
import 'package:timeago/timeago.dart' as timeago;

class TalkingPage extends StatefulWidget {
  final String talkId;

  const TalkingPage({super.key, required this.talkId});

  @override
  _TalkingPageState createState() => _TalkingPageState();
}

class _TalkingPageState extends State<TalkingPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> messages = [];
  late Future<Talk> futureTalk;

  // List of background images to cycle through
  final List<String> backgrounds = [
    'assets/podcasts/one.svg',
    'assets/podcasts/two.svg',
    'assets/podcasts/three.svg',
    // 'assets/podcasts/four.svg',
    'assets/podcasts/five.svg',
    'assets/podcasts/six.svg',
  ];

  @override
  void initState() {
    super.initState();
    futureTalk = TalkService().fetchLastTalk();
  }

  void _sendMessage(String talkId) async {
    String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser;
      String username = user?.displayName ?? "Anonymous";

      try {
        Talk updatedTalk = await TalkService().addAnswerToTalk(
          talkId: talkId,
          username: username,
          bodyMsg: messageText,
        );

        setState(() {
          messages.add({
            "username": username,
            "profileImageUrl": "assets/images/avatar.png",
            "timeAgo": "Just now",
            "message": messageText,
            "backgroundAsset": backgrounds[messages.length % backgrounds.length], // Cycle through backgrounds
          });
        });

        _messageController.clear();
      } catch (e) {
        print("Failed to send message: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send message: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.chevron_left,
              color: const Color(0xFFFA7BFD),
              size: 42,
            ),
          ),
        ),
      ),
      body: FutureBuilder<Talk>(
        future: futureTalk,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final talk = snapshot.data!;

            if (messages.isEmpty) {
              messages = talk.answers
                  .asMap()
                  .entries
                  .map((entry) {
                    final answer = entry.value;
                    final index = entry.key;

                    return {
                      "username": answer['username'] ?? "Unknown",
                      "profileImageUrl": "assets/images/avatar.png",
                      "timeAgo": timeago.format(DateTime.parse(answer['created_at']).toLocal()),
                      "message": answer['bodyMsg'] ?? "",
                      "backgroundAsset": backgrounds[index % backgrounds.length], // Cycle through backgrounds
                    };
                  })
                  .map((e) => e.map((key, value) => MapEntry(key, value.toString())))
                  .toList();
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TalkTopicWidget(),
                              const SizedBox(height: 16),
                              const Divider(
                                color: Color(0xFFD1D1D6),
                                thickness: 1,
                              ),
                            ],
                          ),
                        ),
                        if (messages.isEmpty)
                          const Center(child: Text('No messages yet.')),
                        if (messages.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: MessageBubble(
                                  username: message['username'] ?? 'Unknown',
                                  timeAgo: message['timeAgo'] ?? '',
                                  message: message['message'] ?? '',
                                  backgroundAsset: message['backgroundAsset']!,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: inputField(
                    controller: _messageController,
                    onSendPressed: () => _sendMessage(talk.id),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}

// Input Field Widget
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
          icon: Transform.rotate(
            angle: 3.1416,
            child: const Icon(
              Icons.chevron_left,
              color: Color(0xFFFA7BFD),
              size: 42,
            ),
          ),
          onPressed: onSendPressed,
        ),
      ],
    ),
  );
}
