import 'dart:math';
import 'package:flutter/material.dart';
import 'package:last/podcast/podcast_detailed.dart'; 
import 'package:last/widgets/podcast_horizontal_grid.dart'; // Import the new search bar widget

class PodcastsScreen extends StatelessWidget {
  const PodcastsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white, // Background color for the header
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 78.0), // Add space before the text
                Text(
                  'Подкасты',
                  style: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Text color
                  ),
                ),
              ],
            ),
          ),
          const PodcastSearchBar(), // Use the search bar widget
          SizedBox(height: 30.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding to the grid
            child: PodcastHorizontalGridWidget(),
          ),
        ],
      ),
    );
  }
}

class PodcastSearchBar extends StatelessWidget {
  const PodcastSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 48.0, // Increase the height of the search bar to provide enough space
        child: TextField(
          textAlignVertical: TextAlignVertical.center, // Vertically center the hint text
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 12.0), // Adjust padding inside the TextField
            hintText: 'Поиск',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Color(0xFF3C3C43).withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
