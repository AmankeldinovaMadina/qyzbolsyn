import 'package:flutter/material.dart'; 
import 'package:last/home/forum/topic.dart';
import 'message_bubble.dart'; // Import your MessageBubble widget

class TalkingPage extends StatefulWidget {
  const TalkingPage({super.key});

  @override
  _TalkingPageState createState() => _TalkingPageState();
}

class _TalkingPageState extends State<TalkingPage> {
  final TextEditingController _messageController = TextEditingController(); // Controller for input field
  List<Map<String, String>> messages = []; // Initialize the messages list

  // List of background images to cycle through
  final List<String> backgrounds = [
    'assets/podcasts/one.svg',
    'assets/podcasts/two.svg',
    'assets/podcasts/three.svg',
    'assets/podcasts/four.svg',
    'assets/podcasts/five.svg',
    'assets/podcasts/six.svg',
  ];

  void _sendMessage() {
    String messageText = _messageController.text;
    if (messageText.trim().isNotEmpty) {
      setState(() {
        // Add message to the list
        messages.add({
          "username": "You",
          "profileImageUrl": "assets/images/avatar.png", // Replace with the user's image path
          "timeAgo": "Just now",
          "message": messageText,
          "backgroundAsset": backgrounds[messages.length % backgrounds.length], // Cycle through backgrounds
        });
      });
      _messageController.clear(); // Clear the input field after sending
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
      body: Column(
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
                        TalkTopicWidget(), // Your talk widget
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
                          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Horizontal padding for message bubbles
                          child: MessageBubble(
                            username: message['username'] ?? 'Unknown',
                            profileImageUrl: message['profileImageUrl'] ?? 'assets/avatar.png',
                            timeAgo: message['timeAgo'] ?? '',
                            message: message['message'] ?? '',
                            backgroundAsset: message['backgroundAsset']!, // Each message has a unique background
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
            child: inputField(controller: _messageController, onSendPressed: _sendMessage),
          ),
          const SizedBox(height: 10), // Space below input field
        ],
      ),
    );
  }
}

// Input Field Widget with the same icon as back button but rotated
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
