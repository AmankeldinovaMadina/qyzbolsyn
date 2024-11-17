import 'package:flutter/material.dart';
import 'package:last/posts/search_post_page.dart';
import 'package:last/user_profile/user_profile_page.dart';

class LastPodcast extends StatelessWidget {
  const LastPodcast({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Get screen width

    return Container(
      width: screenWidth, // Ensure it takes the full width of the screen
      height: 437,       // Set the fixed height
      child: Stack(
        children: [
          // Background PNG Image with Gradient
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
            child: Stack(
              children: [
                // PNG Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/building.png', // Replace with your PNG image path
                    fit: BoxFit.cover,            // Ensure it covers the entire widget
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0xFFC575C7).withOpacity(0.95), // Purple color with opacity
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Foreground content: Text and Buttons
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Text
                const Text(
                  'Тревожиться — нормально',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 13.0),
                // Speaker Text
                const Text(
                  'Спикер: психологи Jarqyn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 13.0),

                // Podcast Watch Button and Like Button
                Row(
                  children: [
                    // Watch Podcast Button
                    Flexible(
                      child: PodcastWatchButton(
                        text: 'Смотреть подкаст',
                        backgroundColor: Colors.white,
                        textColor: Color(0xFFC575C7), // Purple text
                        onTap: () {
                          // Add functionality for button press
                          print('Watch Podcast Pressed');
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    // Like Button
                    LikeButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}






class PodcastWatchButton extends StatelessWidget {
  const PodcastWatchButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.backgroundColor = const Color(0xFFFA7BFD),
    this.borderColor = Colors.transparent,
    this.textColor = Colors.white,
  }) : super(key: key);

  final String text;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 297,  
      height: 32,  
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor, 
          backgroundColor: backgroundColor, 
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 1),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class LikeButton extends StatelessWidget {
  const LikeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.favorite_border,
          color: Color(0xFFC575C7), // Purple color for the heart icon
        ),
        onPressed: () {
          // Handle Like button press
          print('Like Button Pressed');
        },
      ),
    );
  }
}
