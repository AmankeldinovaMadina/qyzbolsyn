import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:last/podcast/podcast_detailed.dart';
import 'package:last/services/model/podcast.dart';
import 'package:last/services/auth_service.dart';

class FavoritePodcastsGrid extends StatelessWidget {
  final List<String> favoritePodcastIds;
  final List<String> emojis = ['🎧', '🎤', '🎼', '🎵', '🎶'];
  final List<String> backgrounds = [
    'assets/posts/one.svg',
    'assets/posts/two.svg',
    'assets/posts/three.svg',
    'assets/posts/five.svg',
    'assets/posts/six.svg',
  ];

  FavoritePodcastsGrid({Key? key, required this.favoritePodcastIds}) : super(key: key);

  Future<List<Podcast>> fetchFavoritePodcasts() async {
    try {
      return await AuthService().getFavoritePodcasts();
    } catch (e) {
      print("Error fetching favorite podcasts: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Подкасты" Label
        const Padding(
          padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            'Подкасты',
            style: TextStyle(
              color: Colors.grey, // Gray color
              fontWeight: FontWeight.w600, // Semibold
              fontSize: 18, // Slightly larger font size
            ),
          ),
        ),
        FutureBuilder<List<Podcast>>(
          future: fetchFavoritePodcasts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return const SizedBox(
                height: 200,
                child: Center(child: Text("Failed to load favorite podcasts.")),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(child: Text("No favorite podcasts found.")),
              );
            }

            final podcasts = snapshot.data!;

            return SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0), // Add horizontal padding to the grid
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: podcasts.length,
                  itemBuilder: (context, index) {
                    final podcast = podcasts[index];
                    final backgroundPath = backgrounds[index % backgrounds.length];

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PodcastDetailScreen(
                                podcastId: podcast.id,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12), // Apply border radius here
                          child: Container(
                            width: 188,
                            height: 180,
                            decoration: BoxDecoration(
                              // Remove borderRadius here, since it's applied by ClipRRect
                              // borderRadius: BorderRadius.circular(12),
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
                                        podcast.title,
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
                                              podcast.author,
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
