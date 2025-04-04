import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:last/user_profile/fav_podcast_grid.dart';
import 'package:last/user_profile/fav_post_grid.dart';
import 'package:last/user_profile/user_profile_page.dart';
import 'package:last/widgets/horizontal_grid.dart';
import 'package:last/widgets/podcast_horizontal_grid.dart';
import 'package:last/services/auth_service.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String userName = user?.displayName ?? 'No name';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Back navigation
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFFFA7BFD), // Color for the back arrow
            size: 30,
          ),
        ),
        title: const Text(
          'Мой профиль',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Username
            // Text(
            //   userName,
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: Colors.grey,
            //   ),
            // ),

            const SizedBox(height: 10),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start, // Align to the leading side
                children: [
                  // "Сохраненные" button
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFA7BFD), // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      'Сохраненные',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // Add spacing between buttons

                  // "Редактировать профиль" button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the edit profile page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserProfilePageEdit()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFA7BFD), // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      'Редактировать профиль',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider with horizontal padding and reduced height
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Divider(height: 20, thickness: 1, color: Color(0xFFD8DADC)), // Reduced height and thickness
            ),

            // Horizontal grid with padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FavoritePostsGrid(favoritePostIds: []),
            ),

            const SizedBox(height: 20),

            // Another Divider with padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Divider(height: 20, thickness: 1, color: Color(0xFFD8DADC)), // Reduced height and thickness
            ),

            // Podcast horizontal grid with padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FavoritePodcastsGrid(favoritePodcastIds: []),
            ),
          ],
        ),
      ),
    );
  }
}
