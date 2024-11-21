import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:last/posts/post_detail_page.dart';
import 'package:last/services/model/post.dart';
import 'package:last/services/auth_service.dart';

class FavoritePostsGrid extends StatelessWidget {
  final List<String> favoritePostIds; // List of favorite post IDs
  final List<String> emojis = ['😺', '😸', '😻', '🐼', '👸'];
  final String newArrowPath = 'assets/images/newArrow.svg';

  final List<String> backgrounds = [
    'assets/posts/one.svg',
    'assets/posts/two.svg',
    'assets/posts/three.svg',
    'assets/posts/five.svg',
    'assets/posts/six.svg',
  ];

  FavoritePostsGrid({Key? key, required this.favoritePostIds}) : super(key: key);

  Future<List<Post>> fetchFavoritePosts() async {
    try {
      return await AuthService().getFavoritePosts();
    } catch (e) {
      print("Error fetching favorite posts: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Посты" Label
        const Padding(
          padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            'Посты',
            style: TextStyle(
              color: Colors.grey, // Gray color
              fontWeight: FontWeight.w600, // Semibold
              fontSize: 18, // Slightly larger font size
            ),
          ),
        ),
        FutureBuilder<List<Post>>(
          future: fetchFavoritePosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Failed to load favorite posts."));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No favorite posts found."));
            }

            final posts = snapshot.data!;

            return SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0), // Add horizontal padding to the grid
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final backgroundPath = backgrounds[index % backgrounds.length];

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailPage(
                                id: post.id,
                                title: post.title,
                                category: post.category,
                                author: post.author,
                                content: post.content,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12), // Apply border radius here
                          child: Container(
                            width: 188,
                            height: 180,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: SvgPicture.asset(
                                    backgroundPath,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        post.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            emojis[random.nextInt(emojis.length)],
                                            style: const TextStyle(fontSize: 24),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              post.author,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
