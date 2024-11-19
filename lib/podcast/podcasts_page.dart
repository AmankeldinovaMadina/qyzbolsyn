import 'package:flutter/material.dart';
import 'package:last/services/model/podcast.dart';
import 'package:last/services/podcast_service.dart';
import 'package:last/widgets/podcast_horizontal_grid.dart';

// List of categories and their mapped names
const Map<String, String> categoryMap = {
  'health': 'Все о нашем здоровье',
  'understand': 'Как понять себя',
  'security': 'Моя безопасность',
  'relationship': 'Отношения',
  'education': 'Просвещение',
};

class PodcastsScreen extends StatelessWidget {
  const PodcastsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final futurePodcasts = PodcastService().fetchPodcasts(); // Fetch podcasts from the service

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
                const SizedBox(height: 78.0), // Add space before the text
                const Text(
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
          // Removed extra padding and spacing
          Expanded(
            // Use Expanded to ensure the content fills the available space
            child: FutureBuilder<List<Podcast>>(
              future: futurePodcasts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No podcasts available'));
                } else {
                  // Counter to track the number of displayed categories
                  int categoryCounter = 0;

                  // Iterate over categories and display podcasts in a grid
                  return ListView(
                    padding: EdgeInsets.zero, // Remove ListView padding
                    children: categoryMap.entries.map((entry) {
                      String category = entry.key;
                      String categoryName = entry.value;

                      // Filter podcasts by category
                      List<Podcast> filteredPodcasts = snapshot.data!
                          .where((podcast) => podcast.category == category)
                          .toList();

                      // Only show the grid if there are podcasts in this category
                      if (filteredPodcasts.isNotEmpty) {
                        categoryCounter++;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category title
                            const SizedBox(height: 16.0),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: Text(
                                categoryName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            
                            // Horizontal grid for the category
                            PodcastHorizontalGridWidget(podcasts: filteredPodcasts),
                            const SizedBox(height: 8), // Reduced space
                           if (categoryCounter != categoryMap.length)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Divider(
                                color: Color(0xFFD1D1D6),
                                thickness: 1,
                              ),
                            ),

                            const SizedBox(height: 8), // Reduced space
                          ],
                        );
                      } else {
                        return Container(); // Return an empty container if no podcasts
                      }
                    }).toList(),
                  );
                }
              },
            ),
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
        height: 48.0,
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0), // Reduced vertical padding
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
