import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'package:last/posts/post_detail_page.dart';
import 'package:last/services/model/post.dart';

class CategoryPostsPage extends StatelessWidget {
  final String categoryName;
  final List<Post> posts;
  final List<String> emojis = ['😺', '😸', '😻', '🐼', '👸'];
  final List<String> backgrounds = [
    'assets/posts/one.svg',
    'assets/posts/two.svg',
    'assets/posts/three.svg',
    'assets/posts/five.svg',
    'assets/posts/six.svg',
  ];

   CategoryPostsPage({
    Key? key,
    required this.categoryName,
    required this.posts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final random = Random();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryName,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0), // Overall padding for the grid
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
            crossAxisSpacing: 12, // Space between columns
            mainAxisSpacing: 12, // Space between rows
            childAspectRatio: 1, // Ensures square cells
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final backgroundPath = backgrounds[index % backgrounds.length];

            return GestureDetector(
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
                borderRadius: BorderRadius.circular(16), // Corner radius of 16
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Fallback background color
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: SvgPicture.asset(
                          backgroundPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0), // Padding inside each cell
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              post.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16, // Font size for title unchanged
                                color: Colors.white,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Text(
                                  emojis[random.nextInt(emojis.length)],
                                  style: const TextStyle(fontSize: 24), // Emoji font size unchanged
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    post.author,
                                    style: const TextStyle(
                                      fontSize: 14, // Font size for author unchanged
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
            );
          },
        ),
      ),
    );
  }
}
