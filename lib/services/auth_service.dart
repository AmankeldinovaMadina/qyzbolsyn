import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:last/auth/welcome_page.dart'; // Import WelcomePage
import '../home/home.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Helper method to show toast messages
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  // Helper method to navigate to home
  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const Home(),
      ),
    );
  }

  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final UserCredential userCredential = 
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile
      await userCredential.user?.updateDisplayName(email.split('@')[0]);

      print("Signup successful!");
      _navigateToHome(context);
    } on FirebaseAuthException catch (e) {
      String message = _getAuthErrorMessage(e);
      _showToast(message);
      print("Error: $message");
    } catch (e) {
      print("Unknown error: $e");
      _showToast("An unexpected error occurred");
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _navigateToHome(context);
    } on FirebaseAuthException catch (e) {
      String message = _getAuthErrorMessage(e);
      _showToast(message);
    }
  }

  Future<void> signout({
    required BuildContext context,
  }) async {
    try {
      // Sign out from Firebase and Google
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      // Clear the "Remember Me" preference
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('rememberMe'); // Remove the "rememberMe" key

      // Navigate to the WelcomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const WelcomePage(),
        ),
      );
    } catch (e) {
      _showToast("Error signing out");
      print("Signout error: $e");
    }
  }

  // Enhanced Google Sign-In/Registration method
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Create new credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with credential
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      // Check if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // This is a new user - perform additional registration steps
        await _handleNewGoogleUser(userCredential.user, googleUser);
        _showToast("Welcome! Your account has been created");
      } else {
        _showToast("Welcome back!");
      }

      _navigateToHome(context);
    } catch (e) {
      print("Google sign-in error: $e");
      _showToast('Failed to sign in with Google');
    }
  }

  // Helper method to handle new Google users
  Future<void> _handleNewGoogleUser(User? firebaseUser, 
      GoogleSignInAccount googleUser) async {
    if (firebaseUser != null) {
      // Update profile if needed
      if (firebaseUser.displayName?.isEmpty ?? true) {
        await firebaseUser.updateDisplayName(googleUser.displayName);
      }
      if (firebaseUser.photoURL?.isEmpty ?? true) {
        await firebaseUser.updatePhotoURL(googleUser.photoUrl);
      }

      // Here you can add additional user data to Firestore/RTDB if needed
      // await _saveAdditionalUserData(firebaseUser.uid, {
      //   'email': firebaseUser.email,
      //   'name': firebaseUser.displayName,
      //   'photoUrl': firebaseUser.photoURL,
      //   'lastLogin': FieldValue.serverTimestamp(),
      // });
    }
  }

  // Helper method to get auth error messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled.';
      case 'invalid-credential':
        return 'Invalid credentials.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
