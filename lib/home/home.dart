import 'package:flutter/material.dart';
import 'package:last/bot/bot_page.dart';
import 'package:last/home/category_post.dart';
import 'package:last/podcast/podcasts_page.dart';
import 'package:last/posts/search_post_page.dart';
import 'package:last/services/model/post.dart';
import 'package:last/services/posts_service.dart';
import 'package:last/user_profile/user_favourites.dart'; 
import 'package:last/widgets/horizontal_grid.dart';
import 'package:last/widgets/last_podcast.dart';
import 'package:last/home/forum/talk.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController; // TabController to manage tabs
  late Future<List<Post>> futurePosts; // Future for fetching posts
  int _currentIndex = 0; // Initialize _currentIndex

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Initialize TabController with 3 tabs
    futurePosts = ApiService().fetchPosts(); // Initialize futurePosts inside initState
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the TabController when not in use
    super.dispose();
  }

  // List of pages to display based on the selected tab
  final List<Widget> _pages = [
    HomePage(), // HomePage content, futurePosts will be passed in build
    const BotPage(),  // BotPage content
    const PodcastsScreen(), // PodcastPage content
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display content based on selected tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Highlights the selected tab
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update current index when a tab is tapped
          });
        },
        selectedItemColor: const Color(0xFFFA7BFD), // Accent color for selected tab
        unselectedItemColor: Colors.grey, // Gray color for unselected tabs
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная', // Home tab label
          ),
          BottomNavigationBarItem(
            // Load different assets for selected/unselected states
            icon: _currentIndex == 1
                ? Image.asset('assets/images/messageF.png', width: 24, height: 24)
                : Image.asset('assets/images/message.png', width: 24, height: 24),
            label: 'Бот', // Bot tab label
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Подкасты', // Podcasts tab label
          ),
        ],
      ),
    );
  }
}

  // List of categories and their mapped names
  const Map<String, String> categoryMap = {
    'health': 'Все о нашем здоровье',
    'understand': 'Как понять себя',
    'security': 'Моя безопасность',
    'relationship': 'Отношения',
    'education': 'Просвещение',
  };
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final futurePosts = ApiService().fetchPosts(); // Fetch the posts when the widget is built

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ignore SafeArea for LastPodcast widget
              MediaQuery.removePadding(
                context: context,
                removeTop: true, // Ignore the top padding (e.g., the notch or status bar)
                child: const LastPodcast(), // Your last podcast widget
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // FutureBuilder to handle asynchronous fetching of posts
                    FutureBuilder<List<Post>>(
                      future: futurePosts,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          // Show a loading spinner while data is being fetched
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          // Show an error message if something goes wrong
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          // Show a message if there are no posts
                          return const Center(child: Text('No posts available'));
                        } else {
                          // Counter to track the number of displayed categories
                          int categoryCounter = 0;

                          // Filter posts by category and create a HorizontalGridWidget for each
                          return Column(
                            children: categoryMap.entries.map((entry) {
                              String category = entry.key;
                              String categoryName = entry.value;

                              // Filter posts by category
                              List<Post> filteredPosts = snapshot.data!
                                  .where((post) => post.category == category)
                                  .toList();

                              // Only show the grid if there are posts in this category
                              if (filteredPosts.isNotEmpty) {
                                // Increment the category counter
                                categoryCounter++;

                                // Add the LetsTalk widget after the first category
                                  // Inside your map iteration for displaying categories
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Category title with chevron icon
                                    Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                                  posts: filteredPosts,
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
                                    HorizontalGridWidget(posts: filteredPosts),
                                    const SizedBox(height: 16),
                                    // Add Divider and LetsTalk widget
                                    if (categoryCounter == 2) ...[
                                      const Divider(
                                        color: Color(0xFFD1D1D6),
                                        thickness: 1,
                                      ),
                                      const TalkWidget(),
                                    ],
                                    // Add Divider after each HorizontalGridWidget and after LetsTalk
                                    if (categoryCounter != categoryMap.length)
                                      const Divider(
                                        color: Color(0xFFD1D1D6),
                                        thickness: 1,
                                      ),
                                    const SizedBox(height: 16),
                                  ],
                                );

                              } else {
                                return Container(); // Return an empty container if no posts
                              }
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Transparent AppBar over the LastPodcast
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: Colors.transparent, // Transparent AppBar with no background color
            elevation: 0, // Remove shadow
            automaticallyImplyLeading: false, // Remove default back button
            toolbarHeight: 80, // Adjust the toolbar height as needed
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // User Profile button (top-left)
                    IconButton(
                      icon: Image.asset(
                        'assets/images/user.png', // Your user profile button image
                        width: 64,
                        height: 64,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UserProfilePage()),
                        );
                      },
                    ),
                    // Search button (top-right)
                    IconButton(
                      icon: Image.asset(
                        'assets/images/search.png', // Your search button image
                        width: 32,
                        height: 32,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SearchPostsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}