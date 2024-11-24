import 'package:flutter/material.dart';
import 'package:last/auth/sign_in_page.dart';
import 'package:last/widgets/auth_button.dart';
import 'package:last/services/auth_service.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Full white background
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Back button
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: Color(0xFFFA7BFD), size: 32),
                          onPressed: () {
                            Navigator.of(context).pop(); // Go back to the previous screen
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Star icon
                    Align(
                      alignment: Alignment.topRight,
                      child: Image.asset(
                        'assets/images/star.png', // Path to your star image
                        height: 32,
                      ),
                    ),
                    const SizedBox(height: 100), // Add spacing for the title
                    // Title
                    const Text(
                      'Забыли пароль?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    const Text(
                      'Не переживайте! Мы отправим вам на почту код, с помощью которого легко восстановим доступ к профилю',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    // Email text field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Your email',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Submit button
                    CustomElevatedButton(
                      text: 'Отправить код',
                      onPressed: () {
                        String email = _emailController.text.trim();
                        if (email.isNotEmpty) {
                          _authService.resetPassword(
                            email: email,
                            context: context,
                          );
                        } else {
                         print('error sending message');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Footer text at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInPage()),
                    );
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: 'Вспомнили пароль? ',
                      style: TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: 'Войти',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
