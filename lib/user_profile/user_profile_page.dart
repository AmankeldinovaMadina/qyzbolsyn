import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:last/auth/forget_password.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package
import 'package:last/services/auth_service.dart'; // Import AuthService for logout functionality

class UserProfilePageEdit extends StatefulWidget {
  const UserProfilePageEdit({Key? key}) : super(key: key);

  @override
  _UserProfilePageEditState createState() => _UserProfilePageEditState();
}

class _UserProfilePageEditState extends State<UserProfilePageEdit> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _usernameController = TextEditingController();
  bool _isEditingUsername = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = _auth.currentUser?.displayName ?? 'No username';
  }

  Future<void> _updateUsername() async {
    String newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username cannot be empty.")),
      );
      return;
    }

    try {
      await _auth.currentUser?.updateDisplayName(newUsername);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username updated successfully.")),
      );
      setState(() {
        _isEditingUsername = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update username: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    String userEmail = user?.email ?? 'No email';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFA7BFD)),
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
            const SizedBox(height: 16),
            // Username Section
            buildInfoSection('Личная информация', color: const Color(0xFF979797)),
            buildEditableUsernameField(context),
            buildNonEditableField(userEmail),
            const SizedBox(height: 24),
            // Password Section
            buildInfoSection('Пароль', color: const Color(0xFF979797)),
            buildEditableFieldForPassword(context, '********', Icons.edit),
            const Spacer(),
            // Support and Log Out buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildActionButton('Удалить аккаунт', const Color(0xFFFA7BFD), () async {
                  await AuthService().deleteAccount(context); // Delete account functionality
                }),
                buildActionButton('Выйти', const Color(0xFFFA7BFD), () async {
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

  // Editable Field for Username with Edit/Check Icon Toggle
  Widget buildEditableUsernameField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _usernameController,
              enabled: _isEditingUsername,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: _isEditingUsername ? 'Enter your username' : _usernameController.text,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _isEditingUsername ? Icons.check : Icons.edit,
              color: const Color(0xFFFA7BFD),
            ),
            onPressed: () {
              if (_isEditingUsername) {
                _updateUsername(); // Save username
              } else {
                setState(() {
                  _isEditingUsername = true;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // Editable Field for Password with Navigation to ForgotPasswordPage
  Widget buildEditableFieldForPassword(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              enabled: false,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: text,
              ),
            ),
          ),
          IconButton(
            icon: Icon(icon, color: const Color(0xFFFA7BFD)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Non-Editable Field (e.g., Email)
  Widget buildNonEditableField(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              enabled: false,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Action Buttons (e.g., Log Out, Delete Account)
  Widget buildActionButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 150,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
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
