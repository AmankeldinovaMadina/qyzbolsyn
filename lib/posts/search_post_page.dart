import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG support
import 'package:last/services/model/post.dart';
import 'package:last/services/posts_service.dart';
import 'package:last/widgets/horizontal_grid.dart'; // Import your custom widgets

class SearchPostsScreen extends StatelessWidget {
  const SearchPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with back button and title
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white, // Background color for the header
              child: Row(
                children: [
                  // Custom back button using SVG
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(); // Navigate back when tapped
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0), // Add padding to the right of the back button
                      child:Icon(
                      Icons.chevron_left,
                      color: Color(0xFFFA7BFD), // Your specified color
                      size: 42, // Adjust size as needed
                    ),
                    ),
                  ),
                  // Title next to the back button
                  const Text(
                    'Навигация',
                    style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Text color
                    ),
                  ),
                ],
              ),
            ),
            // Add a search bar with some padding
            const PodcastSearchBar(),
            const SizedBox(height: 30.0),

            // Horizontal grid with padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              // Ensure that you pass the correct posts to HorizontalGridWidget
              child: FutureBuilder<List<Post>>(
                future: ApiService().fetchPosts(), // Assuming ApiService fetches the posts
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No posts found.'));
                  } else {
                    return HorizontalGridWidget(posts: snapshot.data!);
                  }
                },
              ),
            ),
          ],
        ),
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
        height: 48.0, // Height of the search bar
        child: TextField(
          textAlignVertical: TextAlignVertical.center, // Vertically center the hint text
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0), // Adjust padding inside the TextField
            hintText: 'Поиск',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFF3C3C43).withOpacity(0.1),
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
