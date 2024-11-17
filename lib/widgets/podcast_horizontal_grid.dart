import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import for SVG support
import 'dart:math';

import 'package:last/posts/highlight_page.dart'; // For randomizing emojis
import 'package:last/podcast/podcast_detailed.dart'; // Import for PodcastDetailScreen

class PodcastHorizontalGridWidget extends StatelessWidget {
  // Your list of SVG images
  final List<String> imagePaths = [
    'assets/posts/one.svg',
  ];

  // Array for different texts in each cell
  final List<String> cellTitles = [
    'Тревожиться — нормально',
  ];

  // Array for different info in each cell
  final List<String> cellInfos = [
    'Первые гости нашего подкастa психологами Jarqyn',
  ];

  // Array for different authors in each cell
  final List<String> authors = [
    'Jarqyn',
  ];

  // Array for different cat emojis (can be other emojis too)
  final List<String> emojis = [ '😻' ];

  // Path to the newArrow.svg
  final String newArrowPath = 'assets/images/newArrow.svg'; // Update with the correct path

  PodcastHorizontalGridWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final random = Random(); // Initialize random number generator

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Adjust column to fit content
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with text and arrow button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Highlights недели Text
                const Text(
                  'Последние новинки',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey, // Text color
                  ),
                ),
                
                // SVG Arrow Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HighlightPage()),
                    );
                  },
                  child: SvgPicture.asset(
                    newArrowPath, // Path to the SVG file for the arrow
                    height: 24,  // Adjust the size as needed
                    width: 15,   
                  ),
                ),
              ],
            ),
          ),

          // Adjusted space between the title and grid
          const SizedBox(height: 8), // Smaller space between title and grid

          // Use a SizedBox or Container to define the height of the grid
          SizedBox(
            height: 200, // Set the desired height for the grid
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Enable horizontal scrolling
              child: Row( // This Row contains multiple cells
                children: List.generate(imagePaths.length, (index) {
                  return GestureDetector( // Wrap each cell with GestureDetector for navigation
                    onTap: () {
                      // Navigate to PodcastDetailScreen when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PodcastDetailScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0), // Space between cells
                      child: Container(
                        width: 188,  // Cell width
                        height: 180, // Cell height
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            // Background SVG image using Positioned.fill
                            Positioned.fill(
                              child: SvgPicture.asset(
                                imagePaths[index], // Use different SVG image for each cell
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Foreground content (Text and Emoji)
                            Padding(
                              padding: const EdgeInsets.all(16.0), // Add padding inside the cell
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between elements
                                children: [
                                  // Topic title
                                  Text(
                                    cellTitles[index], // Use title text
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  
                                  // Info about the topic
                                  Text(
                                    cellInfos[index],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  
                                  // Author's name and randomly selected emoji at the bottom
                                  Row(
                                    children: [
                                      // Randomly select an emoji from the list
                                      Text(
                                        emojis[random.nextInt(emojis.length)], // Random emoji
                                        style: const TextStyle(
                                          fontSize: 24, // Emoji font size
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        authors[index], // Author's name
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
