import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:last/services/model/post.dart'; // Your Post model
import 'package:last/services/posts_service.dart'; // Your API service to fetch posts

class HighlightPage extends StatelessWidget {
  final String backButtonPath = 'assets/images/backButton.svg'; // Path to back button

  HighlightPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use FutureBuilder to fetch posts dynamically
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Highlights недели',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // Custom back button using GestureDetector
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // Navigate back when tapped
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.chevron_left,
              color: Color(0xFFFA7BFD), // Your specified color
              size: 42, // Adjust size as needed
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Post>>(
          future: ApiService().fetchPosts(), // Fetch posts from API or service
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); // Show loading indicator
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}')); // Show error message if any
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No posts available')); // No data available message
            } else {
              final posts = snapshot.data!; // Data is available
              return GridView.builder(
                itemCount: posts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two items per row
                  crossAxisSpacing: 8, // Space between items horizontally
                  mainAxisSpacing: 8, // Space between items vertically
                  childAspectRatio: 1, // Set to 1 for a square ratio
                ),
                itemBuilder: (BuildContext context, int index) {
                  final post = posts[index]; // Get the current post
                  return Container(
                    width: 167,  // Set the width for the cells
                    height: 167, // Set the height for the cells
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.purpleAccent.withOpacity(0.2), // Background color
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12), // Clip children to match the container
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // SVG Image as background (assuming you have a background asset)
                          SvgPicture.asset(
                            'assets/posts/one.svg', // Replace with dynamic asset if available
                            fit: BoxFit.cover,
                          ),
                          // Content over the background
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Post Title Text with ellipsis
                                Text(
                                  post.title, // Use dynamic post title
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1, // Limit to one line
                                  overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                                ),

                                // Description Text with fixed height and ellipsis
                                SizedBox(
                                  height: 34, // Adjust height to allow for 2 lines of text
                                  child: Text(
                                    post.content[0].text, // Use post content snippet
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 2, // Limit to two lines
                                    overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                                  ),
                                ),

                                // Author with Icon and Name
                                Row(
                                  children: [
                                    // Emoji or icon (if applicable)
                                    const Text(
                                      '😺', // Default emoji (you can randomize or change as needed)
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 4),
                                    // Post Author Name
                                    Flexible(
                                      child: Text(
                                        post.author, // Use dynamic author
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
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
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
