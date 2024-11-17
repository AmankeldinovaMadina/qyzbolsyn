import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG support
import 'package:last/posts/highlight_page.dart';
import 'dart:math';
import 'package:last/posts/post_detail_page.dart'; // PostDetailPage import
import 'package:last/services/model/post.dart';

class HorizontalGridWidget extends StatelessWidget {
  final List<Post> posts; // List of posts passed from the parent widget

  // Define static emojis array
  final List<String> emojis = ['😺', '😸', '😻', '🐼', '👸'];

  final String newArrowPath = 'assets/images/newArrow.svg'; // Update with the correct path
  
  // Define SVG backgrounds
  final List<String> backgrounds = [
    'assets/posts/one.svg',
    'assets/posts/two.svg',
    'assets/posts/three.svg',
    'assets/posts/five.svg',
    'assets/posts/six.svg',
    'assets/posts/seven.svg',
  ];

  HorizontalGridWidget({Key? key, required this.posts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final random = Random(); // Initialize random number generator for emojis

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row with title and arrow
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Highlights недели Text
              const Text(
                'Highlights недели',
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

        const SizedBox(height: 8), // Adjusted space between the title and grid

        // Horizontal scrollable grid
        SizedBox(
          height: 200, // Set the desired height for the grid
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Enable horizontal scrolling
            child: Row(
              children: List.generate(posts.length, (index) {
                final post = posts[index];
                
                // Get the appropriate background based on the index, cycling through the list if needed
                final backgroundPath = backgrounds[index % backgrounds.length];

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0), // Space between cells
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to PostDetailPage with the correct data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailPage(
                            title: post.title,        // Pass post title
                            author: post.author,      // Pass post author
                            content: post.content[0].text, // Pass the first content text
                          ),
                        ),
                      );
                    },
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
                              backgroundPath, // Set SVG background based on index
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
                                // Topic title with ellipsis
                                Text(
                                  post.title, // Use post title
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1, // Limit to one line
                                  overflow: TextOverflow.ellipsis, // Show ellipsis if the title is too long
                                ),
                                
                                // Description text snippet (clipped to two lines)
                                SizedBox(
                                  height: 40, // Adjust height to allow for 2 lines of text
                                  child: Text(
                                    post.content[0].text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Author's name and randomly selected emoji at the bottom
                                Row(
                                  children: [
                                    // Random emoji
                                    Text(
                                      emojis[random.nextInt(emojis.length)], // Random emoji
                                      style: const TextStyle(
                                        fontSize: 24, // Emoji font size
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      post.author, // Post author's name
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
    );
  }
}
