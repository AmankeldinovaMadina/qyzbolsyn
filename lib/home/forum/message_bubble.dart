import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MessageBubble extends StatelessWidget {
  final String username;
  final String profileImageUrl;
  final String timeAgo;
  final String message;
  final String backgroundAsset; // SVG background path

  const MessageBubble({
    Key? key,
    required this.username,
    required this.profileImageUrl,
    required this.timeAgo,
    required this.message,
    required this.backgroundAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          // Background using SVG image
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: SvgPicture.asset(
              backgroundAsset,
              width: double.infinity,
              height: 150, // Adjust based on your design
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info row with profile picture, name, and time ago
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage(profileImageUrl), // Use `NetworkImage` if loading from network
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
                    fontWeight: FontWeight.w600,
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
