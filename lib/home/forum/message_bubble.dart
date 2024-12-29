import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math'; // Import for random functionality

class MessageBubble extends StatelessWidget {
  final String username;
  final String timeAgo;
  final String message;
  final String backgroundAsset; // SVG background path

  const MessageBubble({
    Key? key,
    required this.username,
    required this.timeAgo,
    required this.message,
    required this.backgroundAsset,
  }) : super(key: key);

  static const List<String> _emojis = [
    '🤪', // Zany face
    '😜', // Winking with tongue
    '🦄', // Unicorn
    '💃', // Dancing lady
    '🦖', // Dinosaur
    '🍩', // Donut
    '🚀', // Rocket
    '🥳', // Party face
    '🕺', // Dancing man
    '🐥', // Chick
    '🦥', // Sloth
  ];

  // Function to get a random emoji
  String _getRandomEmoji() {
    final random = Random();
    return _emojis[random.nextInt(_emojis.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          // Background using SVG image with 30% opacity
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Opacity(
              opacity: 0.3, // Set opacity to 30%
              child: SvgPicture.asset(
                backgroundAsset,
                width: double.infinity,
                height: 150, // Adjust based on your design
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info row with random emoji, name, and time ago
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white, // Background for the emoji
                      child: Text(
                        _getRandomEmoji(),
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // The actual message content
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
