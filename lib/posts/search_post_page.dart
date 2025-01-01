import 'package:flutter/material.dart';
import 'package:last/home/category_post.dart';
import 'package:last/services/model/post.dart';
import 'package:last/services/posts_service.dart';
import 'package:last/widgets/horizontal_grid.dart';

// Same category map as in HomePage
const Map<String, String> categoryMap = {
  'health': 'Все о нашем здоровье',
  'understand': 'Как понять себя',
  'security': 'Моя безопасность',
  'relationship': 'Отношения',
  'education': 'Просвещение',
};

class SearchPostsScreen extends StatefulWidget {
  const SearchPostsScreen({super.key});

  @override
  _SearchPostsScreenState createState() => _SearchPostsScreenState();
}

class _SearchPostsScreenState extends State<SearchPostsScreen> {
  TextEditingController searchController = TextEditingController();
  List<Post> allPosts = [];
  List<Post> filteredPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPosts() async {
    try {
      final posts = await ApiService().fetchPosts();
      setState(() {
        allPosts = posts;
        filteredPosts = posts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching posts: $e");
    }
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredPosts = allPosts
          .where((post) =>
              post.title.toLowerCase().contains(query) ||
              post.author.toLowerCase().contains(query) ||
              post.category.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFFFA7BFD),
                      size: 42,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  const Text(
                    'Навигация',
                    style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 48.0,
                child: TextField(
                  controller: searchController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
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
            ),
            const SizedBox(height: 16.0),
            // Content: Horizontal Grids for Categories
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredPosts.isEmpty
                      ? const Center(child: Text('Нет постов.'))
                      : _buildCategoryGrids(),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildCategoryGrids() {
  // Group posts by category
  Map<String, List<Post>> postsByCategory = {};
  for (var post in filteredPosts) {
    postsByCategory.putIfAbsent(post.category, () => []).add(post);
  }

  return SingleChildScrollView(
    child: Column(
      children: categoryMap.entries.map((entry) {
        String category = entry.key;
        String categoryName = entry.value;

        if (!postsByCategory.containsKey(category)) {
          return Container(); // Skip categories with no posts
        }

        List<Post> posts = postsByCategory[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category title with chevron and navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryPostsPage(
                            categoryName: categoryName,
                            posts: posts,
                          ),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFFA7BFD),
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
            // Horizontal grid for the category
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: HorizontalGridWidget(posts: posts),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFD1D1D6), thickness: 1),
          ],
        );
      }).toList(),
    ),
  );
}
}
