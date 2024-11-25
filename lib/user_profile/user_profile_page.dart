import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:last/auth/forget_password.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package
import 'package:last/services/auth_service.dart'; // Import AuthService for logout functionality


class UserProfilePageEdit extends StatelessWidget {
  const UserProfilePageEdit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? 'No email';
    String userName = user?.displayName ?? 'No username';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFFFA7BFD)),
          onPressed: () {
            Navigator.pop(context); // Back button functionality
          },
        ),
        title: const Text(
          'Мой профиль',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture with Edit Icon
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/avatar.png'), // Replace with your image asset
                  backgroundColor: Colors.black,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFA7BFD),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit, size: 16, color: Colors.white),
                    onPressed: () {
                      // Edit profile picture functionality
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // User Name
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Personal Information Section (no edit icons)
            buildInfoSection('Личная информация', color: Color(0xFF979797)),
            buildNonEditableField(userName),
            buildNonEditableField(userEmail),
            const SizedBox(height: 24),
            // Password Section (only password has edit icon)
            buildInfoSection('Пароль', color: Color(0xFF979797)),
            buildEditableField(context, '********', Icons.edit),
            Spacer(),
            // Support and Log Out buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // buildActionButton('Служба поддержки', Color(0xFFFA7BFD), _sendSupportEmail),
                buildActionButton('Выйти', Color(0xFFFA7BFD), () async {
                  await AuthService().signout(context: context); // Logout functionality
                }),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Method to send support email
  void _sendSupportEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'qyzbolsyn.app@gmail.com',
      query: 'subject=Support Request&body=Hello, I need help with...',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      print('Could not launch email app'); // Error handling
    }
  }

  // Helper method to build section title
  Widget buildInfoSection(String title, {required Color color}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: color,
        ),
      ),
    );
  }

  // Helper method to build a non-editable text field (no edit icon)
  Widget buildNonEditableField(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              enabled: false, // Make it non-editable
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                hintText: text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build an editable text field with an edit icon (for password only)
  Widget buildEditableField(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              enabled: false, // Make it non-editable
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                hintText: text,
              ),
            ),
          ),
          IconButton(
            icon: Icon(icon, color: Color(0xFFFA7BFD)), // Keep icon for password field only
            onPressed: () {
              // Navigate to the ForgotPasswordPage when the edit icon is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForgotPasswordPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper method to build action buttons (Support and Log Out)
  Widget buildActionButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 150, // Set button width
      height: 50, // Set button height
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed, // Pass in the onPressed function for the button
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
