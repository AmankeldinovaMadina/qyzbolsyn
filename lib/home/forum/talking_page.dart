import 'package:flutter/material.dart';
import 'package:last/home/forum/topic.dart';
import 'package:last/services/talk_service.dart';
import 'package:last/services/model/talk.dart';
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
  final TextEditingController _messageController = TextEditingController(); // Controller for input field
  List<Map<String, String>> messages = []; // Initialize the messages list
  late Future<Talk> futureTalk; // Future to fetch the talk data

  // List of background images to cycle through
  final List<String> backgrounds = [
    'assets/podcasts/one.svg',
    'assets/podcasts/two.svg',
    'assets/podcasts/three.svg',
    'assets/podcasts/four.svg',
    'assets/podcasts/five.svg',
    'assets/podcasts/six.svg',
  ];

  @override
  void initState() {
    super.initState();
    futureTalk = TalkService().fetchLastTalk(); // Fetch the last talk
  }

  void _sendMessage(String talkId) async {
    String messageText = _messageController.text;
    if (messageText.trim().isNotEmpty) {
      // Fetch the logged-in user's name
      User? user = FirebaseAuth.instance.currentUser;
      String username = user?.displayName ?? "Anonymous"; // Default to "Anonymous" if no name is available

      try {
        // Call the backend to add the message
        Talk updatedTalk = await TalkService().addAnswerToTalk(
          talkId: talkId,
          username: username, // Use the authenticated user's name
          bodyMsg: messageText,
        );

        // Add the new message to the local list
        setState(() {
          messages.add({
            "username": username,
            "profileImageUrl": "assets/images/avatar.png", // Replace with dynamic profile image if needed
            "timeAgo": "Just now", // Immediate feedback
            "message": messageText,
            "backgroundAsset": backgrounds[messages.length % backgrounds.length],
          });
        });

        // Clear the input field after sending the message
        _messageController.clear();
      } catch (e) {
        // Show an error message if the API call fails
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
            Navigator.of(context).pop(); // Navigate back when tapped
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.chevron_left,
              color: Color(0xFFFA7BFD), // Your specified color
              size: 42, // Adjust the size as needed
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

            // Only populate messages if they are empty to prevent overwriting local changes
            if (messages.isEmpty) {
              messages = talk.answers
                  .map((answer) => {
                        "username": answer['username'] ?? "Unknown",
                        "profileImageUrl": "assets/images/avatar.png", // Replace with dynamic profile image
                        "timeAgo": timeago.format(DateTime.parse(answer['created_at']).toLocal()), // Human-readable time
                        "message": answer['bodyMsg'] ?? "",
                        "backgroundAsset": backgrounds[messages.length % backgrounds.length],
                      })
                  .map((e) => e.map((key, value) => MapEntry(key, value.toString()))) // Ensure String values
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
                              TalkTopicWidget(), // Your original widget for the topic
                              const SizedBox(height: 16),
                              const Divider(
                                color: Color(0xFFD1D1D6),
                                thickness: 1,
                              ),
                            ],
                          ),
                        ),
                        // Displaying list of message bubbles
                        if (messages.isEmpty)
                          const Center(child: Text('No messages yet.')), // Show if no messages
                        if (messages.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), // Disable scrolling inside ListView
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: MessageBubble(
                                  username: message['username'] ?? 'Unknown',
                                  profileImageUrl: message['profileImageUrl'] ?? 'assets/avatar.png',
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
                // Input field at the bottom
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: inputField(
                    controller: _messageController,
                    onSendPressed: () => _sendMessage(talk.id), // Pass the talk ID to _sendMessage
                  ),
                ),
                const SizedBox(height: 10), // Space below input field
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
    padding: const EdgeInsets.symmetric(horizontal: 8.0), // Padding around the field
    child: Row(
      children: [
        // Input Field with rounded corners
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4), // Light gray background
              borderRadius: BorderRadius.circular(30), // Fully rounded corners
            ),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Aa',
                border: InputBorder.none, // No border
                contentPadding: EdgeInsets.only(left: 0), // Align text closely to left
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0), // Space between input and button
        // Send Button with chevron_left icon rotated 180 degrees
        IconButton(
          icon: Transform.rotate(
            angle: 3.1416, // Rotate 180 degrees (π radians)
            child: Icon(
              Icons.chevron_left,
              color: const Color(0xFFFA7BFD), // Same purple color as the back button
              size: 42, // Adjust the size as needed
            ),
          ),
          onPressed: onSendPressed, // Send message when pressed
        ),
      ],
    ),
  );
}
