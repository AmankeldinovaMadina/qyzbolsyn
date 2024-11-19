import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'package:last/podcast/podcast_detailed.dart';
import 'package:last/services/model/podcast.dart';

class PodcastHorizontalGridWidget extends StatelessWidget {
  final List<Podcast> podcasts;
  final List<String> emojis = ['🎧', '🎙️', '🎵', '📻', '🎶'];
  final String newArrowPath = 'assets/images/newArrow.svg';

  final List<String> backgrounds = [
    'assets/posts/one.svg',
    'assets/posts/two.svg',
    'assets/posts/three.svg',
    'assets/posts/five.svg',
    'assets/posts/six.svg',
  ];

  PodcastHorizontalGridWidget({Key? key, required this.podcasts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final random = Random();

    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0), // Top and horizontal padding
          child: Row(
            children: List.generate(podcasts.length, (index) {
              final podcast = podcasts[index];
              final backgroundPath = backgrounds[index % backgrounds.length];

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to PodcastDetailScreen and pass the podcastId
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PodcastDetailScreen(
                          podcastId: podcast.id, // Pass the podcast ID
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
                                podcast.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                maxLines: 3,
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
              );
            }),
          ),
        ),
      ),
    );
  }
}
