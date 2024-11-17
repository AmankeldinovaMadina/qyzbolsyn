import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:last/auth/welcome_page.dart';
import 'package:last/home/home.dart';
import 'package:last/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("Loaded API Key: ${dotenv.env['OPEN_AI']}");
  } catch (e) {
    print("Error loading .env file: $e");
  }

  try {
    // Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      Firebase.app();
    }
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  // Check if the user should be remembered
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isRemembered = prefs.getBool('rememberMe');

  // Decide which page to show based on the "Remember Me" preference
  Widget initialPage = (isRemembered == true) ? const Home() : const WelcomePage();

  runApp(MyApp(initialPage: initialPage));
}

class MyApp extends StatelessWidget {
  final Widget initialPage;
  const MyApp({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: initialPage, // Set the initial page dynamically
      debugShowCheckedModeBanner: false,
    );
  }
}
