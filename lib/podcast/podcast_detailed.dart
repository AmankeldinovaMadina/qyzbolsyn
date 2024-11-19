import 'package:flutter/material.dart';
import 'package:last/posts/post_detail_page.dart';
import 'package:last/services/model/podcast.dart';
import 'package:last/services/podcast_service.dart'; // Import the service to fetch podcasts
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Mapping of categories from the database to the Russian version
String _getCategoryName(String category) {
  switch (category) {
    case 'health':
      return 'Все о нашем здоровье';
    case 'understand':
      return 'Как понять себя';
    case 'security':
      return 'Моя безопасность';
    case 'relationship':
      return 'Отношения';
    case 'education':
      return 'Просвещение';
    default:
      return category; // Fallback to the original if no match is found
  }
}

class PodcastDetailScreen extends StatefulWidget {
  final String podcastId; // Accept podcastId as a parameter

  const PodcastDetailScreen({super.key, required this.podcastId});

  @override
  _PodcastDetailScreenState createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  late YoutubePlayerController _controller;
  Podcast? podcast; // Variable to store the fetched podcast
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchPodcastData(); // Fetch the podcast data on initialization
  }

  Future<void> _fetchPodcastData() async {
    try {
      PodcastService podcastService = PodcastService();
      Podcast fetchedPodcast = await podcastService.fetchPodcastById(widget.podcastId);

      // Initialize the YouTube player with the URL from the fetched data
      _controller = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(fetchedPodcast.url)!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );

      setState(() {
        podcast = fetchedPodcast;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching podcast: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.chevron_left, color: Color(0xFFFA7BFD), size: 42),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (podcast == null) {
      return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.chevron_left, color: Color(0xFFFA7BFD), size: 42),
          ),
        ),
        body: Center(child: Text("Failed to load podcast data.")),
      );
    }

    // Display the fetched podcast details
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(Icons.chevron_left, color: Color(0xFFFA7BFD), size: 42),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                ),
              ),
              SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Use _getCategoryName to display the category in Russian
                  TagWidget(label: _getCategoryName(podcast!.category)),
                  LikeableTagWidget(label: 'В избранное'),
                  TagWidget(label: '${podcast!.videoLength} минуты'),
                ],
              ),
              SizedBox(height: 16),
              Text(
                podcast!.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                podcast!.author,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                podcast!.description,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Таймкоды:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...podcast!.timecode.map((timecode) => TimestampWidget(
                    time: timecode.time,
                    label: timecode.label,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class TimestampWidget extends StatelessWidget {
  final String time;
  final String label;

  const TimestampWidget({
    Key? key,
    required this.time,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8), // Space between time and label
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
            maxLines: null, // Allows text to wrap to a new line if needed
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}
