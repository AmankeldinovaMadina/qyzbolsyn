import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:last/services/model/podcast.dart';
import 'package:last/services/model/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../home/home.dart';
import '../auth/welcome_page.dart';
import 'package:http/http.dart' as http;


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  


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
    String? username,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String displayName = username?.isNotEmpty == true
          ? username!
          : (email.length >= 5 ? email.substring(0, 5) : email);

      await userCredential.user?.updateDisplayName(displayName);

      // Save user profile in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _navigateToHome(context);
    } on FirebaseAuthException catch (e) {
      _showToast(_getAuthErrorMessage(e));
    } catch (e) {
      _showToast("An unexpected error occurred.");
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _navigateToHome(context);
    } on FirebaseAuthException catch (e) {
      _showToast(_getAuthErrorMessage(e));
    }
  }

  Future<void> signout({required BuildContext context}) async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('rememberMe');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const WelcomePage()),
      );
    } catch (e) {
      _showToast("Error signing out.");
    }
  }

  // Apple Sign-In Method
Future<void> signInWithApple(BuildContext context) async {
  try {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oAuthProvider = OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    // Check if user exists in Firestore
    final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    if (!userDoc.exists) {
      _showToast('User not registered. Please register first.');
      return;
    }

    _navigateToHome(context);
  } catch (e) {
    _showToast('Failed to sign in with Apple.');
    print(e);
  }
}


Future<void> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      _showToast('Google sign-in was canceled.');
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    // Check if user exists in Firestore
    final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    if (!userDoc.exists) {
      // Show toast message if the user is not registered
      _showToast('User not registered. Please register first.');
      return;
    }

    // Navigate to home if user exists
    _navigateToHome(context);
  } on FirebaseAuthException catch (e) {
    _showToast('Authentication failed: ${_getAuthErrorMessage(e)}');
    print(e);
  } catch (e) {
    _showToast('Failed to sign in with Google. Please try again.');
    print(e);
  }
}



  Future<void> addFavoritePost(String postId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'favoritePosts': FieldValue.arrayUnion([postId]),
        }, SetOptions(merge: true));
      } catch (e) {
        _showToast("Failed to add favorite post.");
      }
    } else {
      _showToast("You must be logged in to perform this action.");
    }
  }

  Future<void> addFavoritePodcast(String podcastId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'favoritePodcasts': FieldValue.arrayUnion([podcastId]),
        }, SetOptions(merge: true));
      } catch (e) {
        _showToast("Failed to add favorite podcast.");
      }
    } else {
      _showToast("You must be logged in to perform this action.");
    }
  }

  Future<void> removeFavoritePost(String postId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'favoritePosts': FieldValue.arrayRemove([postId]),
        }, SetOptions(merge: true));
      } catch (e) {
        _showToast("Failed to remove favorite post.");
      }
    } else {
      _showToast("You must be logged in to perform this action.");
    }
  }

  Future<void> removeFavoritePodcast(String podcastId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'favoritePodcasts': FieldValue.arrayRemove([podcastId]),
        }, SetOptions(merge: true));
      } catch (e) {
        _showToast("Failed to remove favorite podcast.");
      }
    } else {
      _showToast("You must be logged in to perform this action.");
    }
  }
Future<void> registerUserWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    // Check if the user already exists
    final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    if (!userDoc.exists) {
      // Register the new user
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'displayName': userCredential.user!.displayName ?? 'Google User',
        'photoURL': userCredential.user!.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    _navigateToHome(context);
  } catch (e) {
    _showToast('Failed to register with Google.');
    print(e);
  }
}

Future<void> registerUserWithApple(BuildContext context) async {
  try {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oAuthProvider = OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    // Check if the user already exists
    final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    if (!userDoc.exists) {
      // Register the new user
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': appleCredential.email ?? '',
        'displayName': appleCredential.givenName != null
            ? '${appleCredential.givenName} ${appleCredential.familyName}'
            : 'Apple User',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    _navigateToHome(context);
  } catch (e) {
    _showToast('Failed to register with Apple.');
    print(e);
  }
}


Future<List<Post>> getFavoritePosts() async {
  final user = _auth.currentUser;
  if (user != null) {
    try {
      // Fetch IDs from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      List<String> postIds = List<String>.from(doc.data()?['favoritePosts'] ?? []);

      // Fetch details from the backend
      List<Post> posts = [];
      for (String postId in postIds) {
        final response = await http.get(
          Uri.parse('https://qyzbolsyn-backend-3.onrender.com/posts/posts/$postId'),
          headers: {'accept': 'application/json'},
        );

        if (response.statusCode == 200) {
          // Decode the response using utf8 and map to Post
          Map<String, dynamic> postJson = json.decode(utf8.decode(response.bodyBytes));
          posts.add(Post.fromJson(postJson)); // Use Post model to parse data
        } else {
          throw Exception('Failed to load post with ID: $postId');
        }
      }
      return posts;
    } catch (e) {
      _showToast("Failed to fetch favorite posts.");
      print(e);
    }
  }
  return [];
}


Future<List<Podcast>> getFavoritePodcasts() async {
  final user = _auth.currentUser;
  if (user != null) {
    try {
      // Fetch IDs from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      List<String> podcastIds = List<String>.from(doc.data()?['favoritePodcasts'] ?? []);

      // Fetch details from the backend
      List<Podcast> podcasts = [];
      for (String podcastId in podcastIds) {
        final response = await http.get(
          Uri.parse('https://qyzbolsyn-backend-3.onrender.com/podcasts/podcasts/$podcastId'),
          headers: {'accept': 'application/json'},
        );

        if (response.statusCode == 200) {
          // Decode the response using utf8 and map to Podcast
          Map<String, dynamic> podcastJson = json.decode(utf8.decode(response.bodyBytes));
          podcasts.add(Podcast.fromJson(podcastJson)); // Use Podcast model to parse data
        } else {
          throw Exception('Failed to load podcast with ID: $podcastId');
        }
      }
      return podcasts;
    } catch (e) {
      _showToast("Failed to fetch favorite podcasts.");
      print(e);
    }
  }
  return [];
}


Future<void> resetPassword({
  required String email,
  required BuildContext context,
}) async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
    _showToast('A password reset link has been sent to $email.');
  } on FirebaseAuthException catch (e) {
    _showToast(_getAuthErrorMessage(e));
  } catch (e) {
    _showToast('An unexpected error occurred. Please try again.');
  }
}

Future<void> deleteAccount(BuildContext context) async {
  final user = _auth.currentUser;
  if (user != null) {
    try {
      // Delete the user's Firestore document
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete the user account from Firebase Authentication
      await user.delete();

      // Show a success message
      _showToast("Your account has been deleted successfully.");

      // Navigate to the Welcome page after deletion
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showToast("Please log in again to delete your account.");
      } else {
        _showToast("An error occurred while deleting the account.");
      }
    } catch (e) {
      _showToast("An unexpected error occurred. Please try again.");
    }
  } else {
    _showToast("No user is logged in.");
  }
}

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
