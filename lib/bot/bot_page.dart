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
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/botbgv.png'), // Background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Center(
            child: Transform.translate(
              offset: Offset(0, -50), // Move content 50 pixels upward
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Saya Image
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image.asset(
                        'assets/images/saya.png', // Saya image
                        width: 200, // Adjust size as needed
                      ),
                      Positioned(
                        bottom: -6,
                        child: Text(
                          'Сая',
                          style: TextStyle(
                            fontSize: 68,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 5,
                                color: Colors.white,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Description Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      'Бот Сая - искусственный интеллект, готовая помочь с подбором статей, подкастов и комфортных слов для поддержки Вашего эмоционального состояния :)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black.withOpacity(0.1), // Subtle shadow effect
                            offset: Offset(1, 1), // Shadow position
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
