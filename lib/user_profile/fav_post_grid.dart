import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import for SVG support
import 'package:last/posts/highlight_page.dart';
import 'dart:math';

import 'package:last/posts/post_detail_page.dart'; // Import the PostDetailPage

class FavPostGrid extends StatelessWidget {
  // Your list of SVG images
  final List<String> imagePaths = [
    'assets/posts/one.svg',
    'assets/posts/two.svg',
    'assets/posts/three.svg',
    'assets/posts/five.svg',
    'assets/posts/six.svg',
  ];

  // Array for different texts in each cell
  final List<String> cellTitles = [
    'Первый раз',
    'Внутренняя мизогиния',
    'Синдром самозванца',
    'Четвёртая тема',
    'Пятая тема',
    'Шестая тема',
  ];

  // Array for different info in each cell
  final List<String> cellInfos = [
    'Как подготовить себя, свое тело и разум?',
    'Что это и как это обнаружить?',
    'Что стоит за этим явлением?',
    'Идеи для обсуждения',
    'Тема для разговора',
    'Факты и советы',
  ];

  // Array for different authors in each cell
  final List<String> authors = [
    'Амина Байтасова',
    'Карина Саркыт',
    'Наталья Белова',
    'Дмитрий Иванов',
    'Алина Ким',
    'Сергей Павлов',
  ];

  // Array for different cat emojis (can be other emojis too)
  final List<String> emojis = ['😺', '😸', '😻', '🐼', '👸'];

  // Path to the newArrow.svg
  final String newArrowPath = 'assets/images/newArrow.svg'; // Update with the correct path

  FavPostGrid({Key? key}) : super(key: key);

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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Highlights недели Text
                const Text(
                  'Посты',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey, // Text color
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
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0), // Space between cells
                    child: GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => PostDetailPage(
                        //       title: cellTitles[index],       // Pass title
                        //       author: authors[index],         // Pass author
                        //       category: "some", //  need to fetch real category here
                        //       content: cellInfos[index],      // Pass content/info
                        //     ),
                        //   ),
                        // ); MARK
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
