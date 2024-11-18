import 'package:flutter/material.dart';
import 'package:last/services/model/post.dart';

class PostDetailPage extends StatelessWidget {
  final String title;
  final String author;
  final String category;
  final List<Content> content; // Update content to be a list of Content objects

  const PostDetailPage({
    Key? key,
    required this.title,
    required this.author,
    required this.category,
    required this.content,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top section with back button and title
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: 16.0),
                child: Stack(
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Navigate back
                        },
                        child: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFFFA7BFD), // Set to your desired color
                          size: 42,
                        ),
                      ),
                    ),
                    // Centered title
                    Center(
                      child: SizedBox(
                        width: 150, // Set your fixed width
                        height: 30, // Set your fixed height
                        child: Text(
                          title, // Your title or description text
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1, // Limit to a single line
                          overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis (...)
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Image section
              Image.asset(
                'assets/images/article_cover.png', // Replace with your image asset if needed
                width: MediaQuery.of(context).size.width, // Full screen width
                height: 280, // Fixed height for the image
                fit: BoxFit.cover, // Cover the available space
              ),

              const SizedBox(height: 16),

              // Section below the image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags aligned to the left
                    Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        TagWidget(label: _getCategoryName(category)), // Custom tag widget with mapped category
                        LikeableTagWidget(label: 'В избранное'), // Custom Likeable widget
                        TagWidget(label: author),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title and subtitle section
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Автор: $author',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Content section: Iterate over the content list
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: content.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.headline, // Headline in bold
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.text, // Text in regular style
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5, // Adjust line height for readability
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tag widget for displaying tags (same as in your Podcast page)
class TagWidget extends StatelessWidget {
  final String label;

  const TagWidget({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label),
    );
  }
}

// Likeable tag widget for "В избранное" (same as in your Podcast page)
class LikeableTagWidget extends StatefulWidget {
  final String label;

  const LikeableTagWidget({Key? key, required this.label}) : super(key: key);

  @override
  _LikeableTagWidgetState createState() => _LikeableTagWidgetState();
}

class _LikeableTagWidgetState extends State<LikeableTagWidget> {
  bool _isLiked = false;

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: const Color(0xFFC575C7), // Heart icon color
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(widget.label),
          ],
        ),
      ),
    );
  }
}
