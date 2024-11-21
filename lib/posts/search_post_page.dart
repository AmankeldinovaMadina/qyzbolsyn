import 'package:flutter/material.dart';
import 'package:last/services/model/post.dart';
import 'package:last/services/posts_service.dart';
import 'package:last/widgets/horizontal_grid.dart';

class SearchPostsScreen extends StatefulWidget {
  const SearchPostsScreen({super.key});

  @override
  _SearchPostsScreenState createState() => _SearchPostsScreenState();
}

class _SearchPostsScreenState extends State<SearchPostsScreen> {
  late Future<List<Post>> futurePosts;
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
        filteredPosts = posts; // Initially, show all posts
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
            // Header section with back button and title
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(
                        Icons.chevron_left,
                        color: Color(0xFFFA7BFD),
                        size: 42,
                      ),
                    ),
                  ),
                  // Title
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
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
            const SizedBox(height: 30.0),
            // Horizontal Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredPosts.isEmpty
                      ? const Center(child: Text('No posts found.'))
                      : HorizontalGridWidget(posts: filteredPosts),
            ),
          ],
        ),
      ),
    );
  }
}

