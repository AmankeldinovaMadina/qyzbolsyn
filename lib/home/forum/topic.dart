import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:last/home/forum/talking_page.dart';

class TalkTopicWidget extends StatelessWidget {
  const TalkTopicWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Get the screen width

    return ClipRRect(
      borderRadius: BorderRadius.circular(16), // Apply the corner radius to clip the widget
      child: Container(
        width: screenWidth, // Set the width to full screen
        height: 200, // Set the height to 180
        child: Stack(
          children: [
            // Background SVG
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/podcasts/one.svg', // Path to your SVG background image
                fit: BoxFit.cover, // Cover the entire container
              ),
            ),
            // Foreground content (Text and Button)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title Text
                  const Text(
                    'Давайте пообщаемся?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle Text
                  const Text(
                    'Расскажите, какие изменения вы замечаете за своим телом во время цикла?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
