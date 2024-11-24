import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:last/podcast/podcast_detailed.dart';
import 'package:last/services/podcast_service.dart';
import 'package:last/services/model/podcast.dart';

class LastPodcast extends StatefulWidget {
  const LastPodcast({Key? key}) : super(key: key);

  @override
  _LastPodcastState createState() => _LastPodcastState();
}

class _LastPodcastState extends State<LastPodcast> {
  late Future<Podcast> _latestPodcast;

  @override
  void initState() {
    super.initState();
    _latestPodcast = PodcastService().fetchLatestPodcast();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<Podcast>(
      future: _latestPodcast,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No podcast available.'));
        }

        final podcast = snapshot.data!;

        return Container(
          width: screenWidth,
          height: 437,
          child: Stack(
            children: [
              // Background PNG Image with Gradient
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Stack(
                  children: [
                    // PNG Image
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/building.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(0xFFC575C7).withOpacity(0.95),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Foreground content: Text and Buttons
              Positioned(
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Text
                    Text(
                      podcast.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 13.0),
                    // Speaker Text
                    Text(
                      'Спикер: ${podcast.author}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 13.0),

                    // Podcast Watch Button and Like Button
                    Row(
                      children: [
                        // Watch Podcast Button
                        Flexible(
                          child: PodcastWatchButton(
                            text: 'Смотреть подкаст',
                            backgroundColor: Colors.white,
                            textColor: Color(0xFFC575C7),
                            onTap: () {
                              // Navigate to the detailed podcast screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PodcastDetailScreen(podcastId: podcast.id),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        // Like Button
                        LikeButton(podcastId: podcast.id),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



class PodcastWatchButton extends StatelessWidget {
  const PodcastWatchButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.backgroundColor = const Color(0xFFFA7BFD),
    this.borderColor = Colors.transparent,
    this.textColor = Colors.white,
  }) : super(key: key);

  final String text;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 297,  
      height: 32,  
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor, 
          backgroundColor: backgroundColor, 
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 1),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
class LikeButton extends StatefulWidget {
  final String podcastId;

  const LikeButton({Key? key, required this.podcastId}) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _isLiked = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkIfLiked(); // Check if the podcast is already liked
  }

  // Method to check if the podcast is liked
  Future<void> _checkIfLiked() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      List<dynamic> favoritePodcasts = userData?['favoritePodcasts'] ?? [];
      setState(() {
        _isLiked = favoritePodcasts.contains(widget.podcastId);
      });
    }
  }

  // Method to toggle like status and update Firestore
  Future<void> _toggleLike() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentReference userRef = _firestore.collection('users').doc(user.uid);

      if (_isLiked) {
        // Remove from favorites
        await userRef.update({
          'favoritePodcasts': FieldValue.arrayRemove([widget.podcastId])
        });
      } else {
        // Add to favorites
        await userRef.set({
          'favoritePodcasts': FieldValue.arrayUnion([widget.podcastId])
        }, SetOptions(merge: true));
      }

      // Toggle the like state
      setState(() {
        _isLiked = !_isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: IconButton(
        icon: Icon(
          _isLiked ? Icons.favorite : Icons.favorite_border,
          color: const Color(0xFFC575C7), // Purple heart icon
        ),
        onPressed: _toggleLike, // Call toggle like when pressed
      ),
    );
  }
}
