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

class PodcastsScreen extends StatefulWidget {
  const PodcastsScreen({super.key});

  @override
  _PodcastsScreenState createState() => _PodcastsScreenState();
}

class _PodcastsScreenState extends State<PodcastsScreen> {
  late Future<List<Podcast>> futurePodcasts; // Fetch podcasts
  List<Podcast> allPodcasts = [];
  List<Podcast> filteredPodcasts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPodcasts();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPodcasts() async {
    try {
      final podcasts = await PodcastService().fetchPodcasts();
      setState(() {
        allPodcasts = podcasts;
        filteredPodcasts = podcasts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching podcasts: $e");
    }
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredPodcasts = allPodcasts
          .where((podcast) =>
              podcast.title.toLowerCase().contains(query) ||
              podcast.author.toLowerCase().contains(query) ||
              podcast.category.toLowerCase().contains(query))
          .toList();
    });
  }

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
              children: const [
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
          // Search Bar
          PodcastSearchBar(controller: searchController),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPodcasts.isEmpty
                    ? const Center(child: Text('No podcasts available'))
                    : ListView(
                        padding: EdgeInsets.zero,
                        children: categoryMap.entries.map((entry) {
                          String category = entry.key;
                          String categoryName = entry.value;

                          // Filter podcasts by category
                          List<Podcast> categoryPodcasts = filteredPodcasts
                              .where((podcast) => podcast.category == category)
                              .toList();

                          if (categoryPodcasts.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16.0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Text(
                                    categoryName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                PodcastHorizontalGridWidget(
                                    podcasts: categoryPodcasts),
                                const SizedBox(height: 8),
                                if (category != categoryMap.keys.last)
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Divider(
                                      color: Color(0xFFD1D1D6),
                                      thickness: 1,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }
}

class PodcastSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const PodcastSearchBar({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 48.0,
        child: TextField(
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
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
