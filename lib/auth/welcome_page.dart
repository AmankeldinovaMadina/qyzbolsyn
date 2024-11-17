import 'package:flutter/material.dart';
import 'package:last/auth/register_page.dart';
import 'package:last/auth/sign_in_page.dart';
import 'package:last/widgets/auth_button.dart';  

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Wrapping the Image.asset in a FittedBox to ensure it scales
              Container(
                height: 323,  // Set the desired height
                width: double.infinity,  // Full width
                padding: const EdgeInsets.symmetric(horizontal: 62),  // Horizontal padding
                child: FittedBox(  // FittedBox forces the image to expand to fill its container
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,  // Ensures the image scales appropriately
                  ),
                ),
              ),

              const Text(
                'Qyzbolsyn',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle Text
              Text(
                'Добро пожаловать!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],  // A neutral color for the subtitle
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 50),

              // Custom Elevated Button with the correct dimensions
              CustomElevatedButton(
                text: 'Зарегистрироваться',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                }
              ),
              const SizedBox(height: 20),

              // Custom Outlined Button with the correct dimensions
              CustomOutlinedButton(
                text: 'Войти',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
