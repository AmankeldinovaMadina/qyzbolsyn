import 'package:flutter/material.dart';
import 'package:last/auth/register_user_page.dart';
import 'package:last/auth/sign_in_page.dart';
import 'package:last/services/auth_service.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo Image
              Image.asset(
                'assets/images/logo.png',
                height: 323,
              ),
              // Title Text
              const Text(
                'Qyzbolsyn',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),

 
              // Continue with Google Button
              SignInOptionButton(
                text: 'Продолжить через Google',
                icon: Icons.g_translate,
                color: Colors.white,
                textColor: Colors.black,
                iconImage: 'assets/icons/google_logo.png',
                onPressed: () async {
                  // Call the Google sign-in method from AuthService
                  await AuthService().signInWithGoogle(context);
                },
              ),

              const SizedBox(height: 20),

              // Continue with Apple Button
              SignInOptionButton(
              text: 'Продолжить через Apple',
              icon: Icons.apple,
              color: Colors.white,
              textColor: Colors.black,
              onPressed: () async {
                // Call the Apple sign-in method from AuthService
                await AuthService().signInWithApple(context);
              },
            ),

              const SizedBox(height: 20),

              // Continue with Email Button
              SignInOptionButton(
                text: 'Продолжить через Email',
                icon: Icons.email_outlined,
                color: Colors.white,
                textColor: Colors.black,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterUserPage()),
                  );
                }
              ),
              const SizedBox(height: 40),

              // Already have an account? Sign In text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Уже есть аккаунт?',
                    style: TextStyle(color: Colors.black54),
                  ),
                  TextButton(
                    onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInPage()),
                    );
                  },
                    child: const Text(
                      'Войти',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Button Widget for Sign-In Options
class SignInOptionButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final String? iconImage;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const SignInOptionButton({
    super.key,
    required this.text,
    this.icon,
    this.iconImage,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: iconImage != null
            ? Image.asset(iconImage!, height: 24) // Display custom icon image
            : Icon(icon, color: textColor, size: 24), // Display default icon
        label: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          side: const BorderSide(color: Colors.black12), // Optional border styling
        ),
      ),
    );
  }
}
