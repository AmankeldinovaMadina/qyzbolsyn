import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'package:last/posts/post_detail_page.dart';
import 'package:last/services/model/post.dart';

class HorizontalGridWidget extends StatelessWidget {
  final List<Post> posts;
  final List<String> emojis = ['😺', '😸', '😻', '🐼', '👸'];
  final String newArrowPath = 'assets/images/newArrow.svg';

  final List<String> backgrounds = [
    'assets/posts/one.svg',
    'assets/posts/two.svg',
    'assets/posts/three.svg',
    'assets/posts/five.svg',
    'assets/posts/six.svg',
  ];

  HorizontalGridWidget({Key? key, required this.posts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final random = Random();

    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(posts.length, (index) {
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
                        title: post.title,
                        category: post.category,
                        author: post.author,
                        content: post.content,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 188,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
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
            );
          }),
        ),
      ),
    );
  }
}
