import 'package:flutter/material.dart';
import 'package:last/bot/chat_page.dart';

class BotPage extends StatelessWidget {
  const BotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/botBG.png', // Replace with your image path
              fit: BoxFit.cover,         // Ensure the image covers the entire screen
            ),
          ),
          
          // Positioned Button (150px from the bottom)
          Positioned(
            bottom: 150, // Move the button 150px from the bottom
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 251, // Set the width of the button
                height: 41, // Set the height of the button
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatPage()),
                  );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE66EE9), // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                    ),
                    elevation: 0, // Remove shadow
                  ),
                  child: const Text(
                    'Перейти к диалогу', // Button text
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
